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
  if (argument.empty() == false && argument.find_first_of(RTW_SYS_STR_LITERAL(
                                       " \t\n\v\"")) == argument.npos) {
    command_line.append(argument);
  } else {
    command_line.push_back(RTW_SYS_STR_LITERAL('"'));

    for (auto it = argument.begin();; ++it) {
      unsigned number_backslashes = 0;

      while (it != argument.end() && *it == RTW_SYS_STR_LITERAL('\\')) {
        ++it;
        ++number_backslashes;
      }

      if (it == argument.end()) {
        command_line.append(number_backslashes * 2, RTW_SYS_STR_LITERAL('\\'));
        break;
      } else if (*it == L'"') {
        command_line.append(number_backslashes * 2 + 1,
                            RTW_SYS_STR_LITERAL('\\'));
        command_line.push_back(*it);
      } else {
        command_line.append(number_backslashes, RTW_SYS_STR_LITERAL('\\'));
        command_line.push_back(*it);
      }
    }
    command_line.push_back(RTW_SYS_STR_LITERAL('"'));
  }
}

void MakeCommandLine(const System::Arguments& arguments,
                     System::StrType& command_line) {
  for (const System::StrType& argument : arguments) {
    command_line.push_back(RTW_SYS_STR_LITERAL(' '));
    ArgumentQuote(argument, command_line);
  }
}

void MakeEnvironmentBlock(const System::EnvironmentBlock& environment_block,
                          System::StrType& environment_block_win) {
  for (const System::StrType& ev : environment_block) {
    environment_block_win += ev;
    environment_block_win.push_back(RTW_SYS_STR_LITERAL('\0'));
  }
  environment_block_win.push_back(RTW_SYS_STR_LITERAL('\0'));
}

}  // namespace

System::StrType System::GetWorkingDirectory() {
  const DWORD kMaxBufferLength = 4096;
  TCHAR buffer[kMaxBufferLength];
  if (::GetCurrentDirectory(kMaxBufferLength, buffer) == 0) {
    return System::StrType{};
  }
  return System::StrType{buffer};
}

System::StrType System::JoinPaths(const StrType& path1, const StrType& path2) {
  return path1 + RTW_SYS_STR_LITERAL("\\") + path2;
}

int System::Exec(const System::StrType& executable,
                 const System::Arguments& arguments,
                 const System::EnvironmentBlock& environment_block) {
  PROCESS_INFORMATION process_info;
  ZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

  STARTUPINFO startup_info;
  ZeroMemory(&startup_info, sizeof(STARTUPINFO));
  startup_info.cb = sizeof(STARTUPINFO);

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

  DWORD exit_status;
  WaitForSingleObject(process_info.hProcess, INFINITE);
  if (GetExitCodeProcess(process_info.hProcess, &exit_status) == FALSE)
    exit_status = -1;
  CloseHandle(process_info.hProcess);
  return exit_status;
}

}  // namespace process_wrapper
