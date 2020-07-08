#include <cstddef>

#include "lib/process_wrapper/system.h"

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>

#include <iostream>

namespace process_wrapper {

namespace {
// Algorithm used:
// https://docs.microsoft.com/en-us/archive/blogs/twistylittlepassagesallalike/everyone-quotes-command-line-arguments-the-wrong-way

void ArgumentQuote(const System::StrType& argument,
                   System::StrType& command_line) {
  if (argument.empty() == false &&
      argument.find_first_of(PW_SYS_STR(" \t\n\v\"")) == argument.npos) {
    command_line.append(argument);
  } else {
    command_line.push_back(PW_SYS_STR('"'));

    for (auto it = argument.begin();; ++it) {
      unsigned number_backslashes = 0;

      while (it != argument.end() && *it == PW_SYS_STR('\\')) {
        ++it;
        ++number_backslashes;
      }

      if (it == argument.end()) {
        command_line.append(number_backslashes * 2, PW_SYS_STR('\\'));
        break;
      } else if (*it == L'"') {
        command_line.append(number_backslashes * 2 + 1, PW_SYS_STR('\\'));
        command_line.push_back(*it);
      } else {
        command_line.append(number_backslashes, PW_SYS_STR('\\'));
        command_line.push_back(*it);
      }
    }
    command_line.push_back(PW_SYS_STR('"'));
  }
}

void MakeCommandLine(const System::Arguments& arguments,
                     System::StrType& command_line) {
  for (const System::StrType& argument : arguments) {
    command_line.push_back(PW_SYS_STR(' '));
    ArgumentQuote(argument, command_line);
  }
}

void MakeEnvironmentBlock(const System::EnvironmentBlock& environment_block,
                          System::StrType& environment_block_win) {
  for (const System::StrType& ev : environment_block) {
    environment_block_win += ev;
    environment_block_win.push_back(PW_SYS_STR('\0'));
  }
  environment_block_win.push_back(PW_SYS_STR('\0'));
}

}  // namespace

System::StrType System::GetWorkingDirectory() {
  constexpr DWORD kMaxBufferLength = 4096;
  TCHAR buffer[kMaxBufferLength];
  if (::GetCurrentDirectory(kMaxBufferLength, buffer) == 0) {
    return System::StrType{};
  }
  return System::StrType{buffer};
}

int System::Exec(const System::StrType& executable,
                 const System::Arguments& arguments,
                 const System::EnvironmentBlock& environment_block,
                 const StrType& stdout_file) {
  PROCESS_INFORMATION process_info;
  ZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

  STARTUPINFO startup_info;
  ZeroMemory(&startup_info, sizeof(STARTUPINFO));
  startup_info.cb = sizeof(STARTUPINFO);

  HANDLE child_stdout_reader = NULL;
  HANDLE child_stdout_writer = NULL;

  if (!stdout_file.empty()) {
    SECURITY_ATTRIBUTES saAttr;
    ZeroMemory(&saAttr, sizeof(SECURITY_ATTRIBUTES));
    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle = TRUE;
    saAttr.lpSecurityDescriptor = NULL;
    if (!CreatePipe(&child_stdout_reader, &child_stdout_writer, &saAttr, 0)) {
      std::cerr << "error: failed to create stdout pipe." << std::endl;
      return -1;
    }

    if (!SetHandleInformation(child_stdout_reader, HANDLE_FLAG_INHERIT, 0)) {
      std::cerr << "error: failed to set handle informations." << std::endl;
      return -1;
    }

    startup_info.hStdOutput = child_stdout_writer;
    startup_info.dwFlags |= STARTF_USESTDHANDLES;
  }

  System::StrType command_line;
  ArgumentQuote(executable, command_line);
  MakeCommandLine(arguments, command_line);

  System::StrType environment_block_win;
  MakeEnvironmentBlock(environment_block, environment_block_win);

  BOOL success = ::CreateProcess(
      /*lpApplicationName*/ nullptr,
      /*lpCommandLine*/ command_line.empty() ? nullptr : &command_line[0],
      /*lpProcessAttributes*/ nullptr,
      /*lpThreadAttributes*/ nullptr, /*bInheritHandles*/ TRUE,
      /*dwCreationFlags*/ 0
#if defined(UNICODE)
          | CREATE_UNICODE_ENVIRONMENT
#endif  // defined(UNICODE)
      ,
      /*lpEnvironment*/ environment_block_win.empty()
          ? nullptr
          : &environment_block_win[0],
      /*lpCurrentDirectory*/ nullptr,
      /*lpStartupInfo*/ &startup_info,
      /*lpProcessInformation*/ &process_info);

  if (success == FALSE) {
    std::cerr << "error: Failed to launch a new process." << std::endl;
    return -1;
  }

  if (!stdout_file.empty()) {
    CloseHandle(child_stdout_writer);
    HANDLE stdout_file_handle = CreateFile(
        /*lpFileName*/ stdout_file.c_str(),
        /*dwDesiredAccess*/ GENERIC_WRITE,
        /*dwShareMode*/ FILE_SHARE_WRITE,
        /*lpSecurityAttributes*/ NULL,
        /*dwCreationDisposition*/ CREATE_ALWAYS,
        /*dwFlagsAndAttributes*/ FILE_ATTRIBUTE_NORMAL,
        /*hTemplateFile*/ NULL);

    if (stdout_file_handle == INVALID_HANDLE_VALUE) {
      return -1;
    }

    constexpr DWORD kBufferSize = 4096;
    CHAR buffer[kBufferSize];
    while (1) {
      DWORD read;
      bool success =
          ReadFile(child_stdout_reader, buffer, kBufferSize, &read, NULL);
      if (read == 0) {
        break;
      } else if (!success) {
        std::cerr << "error: failed to read child process stdout." << std::endl;
        return -1;
      }

      DWORD written;
      success = WriteFile(stdout_file_handle, buffer, read, &written, NULL);
      if (!success) {
        std::cerr << "error: failed to write to stdout capture file."
                  << std::endl;
        return -1;
      }
    }
  }

  DWORD exit_status;
  WaitForSingleObject(process_info.hProcess, INFINITE);
  if (GetExitCodeProcess(process_info.hProcess, &exit_status) == FALSE)
    exit_status = -1;
  CloseHandle(process_info.hProcess);
  return exit_status;
}

}  // namespace process_wrapper
