#include <cstddef>

#include "lib/process_wrapper/system.h"

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <windows.h>

#include <iostream>

namespace process_wrapper {

namespace {

// We need to follow specific quoting rules for maximum compatibility as
// explained here:
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

// Arguments needs to be quoted and space separated
void MakeCommandLine(const System::Arguments& arguments,
                     System::StrType& command_line) {
  for (const System::StrType& argument : arguments) {
    command_line.push_back(PW_SYS_STR(' '));
    ArgumentQuote(argument, command_line);
  }
}

// Environment variables are \0 separated
void MakeEnvironmentBlock(const System::EnvironmentBlock& environment_block,
                          System::StrType& environment_block_win) {
  for (const System::StrType& ev : environment_block) {
    environment_block_win += ev;
    environment_block_win.push_back(PW_SYS_STR('\0'));
  }
  environment_block_win.push_back(PW_SYS_STR('\0'));
}

class OutputPipe {
 public:
  static constexpr size_t kReadEndHandle = 0;
  static constexpr size_t kWriteEndHandle = 1;

  ~OutputPipe() {
    CloseReadEnd();
    CloseWriteEnd();
  }

  bool CreateEnds(STARTUPINFO& startup_info, bool err) {
    SECURITY_ATTRIBUTES saAttr;
    ZeroMemory(&saAttr, sizeof(SECURITY_ATTRIBUTES));
    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle = TRUE;
    saAttr.lpSecurityDescriptor = NULL;
    if (!::CreatePipe(&output_pipe_handles_[kReadEndHandle],
                      &output_pipe_handles_[kWriteEndHandle], &saAttr, 0)) {
      return false;
    }

    if (!::SetHandleInformation(output_pipe_handles_[kReadEndHandle],
                                HANDLE_FLAG_INHERIT, 0)) {
      return false;
    }

    if (err) {
      startup_info.hStdError = output_pipe_handles_[kWriteEndHandle];
    } else {
      startup_info.hStdOutput = output_pipe_handles_[kWriteEndHandle];
    }
    startup_info.dwFlags |= STARTF_USESTDHANDLES;

    return true;
  }

  void CloseReadEnd() { Close(kReadEndHandle); }
  void CloseWriteEnd() { Close(kWriteEndHandle); }

  HANDLE ReadEndHandle() const { return output_pipe_handles_[kReadEndHandle]; }
  HANDLE WriteEndHandle() const {
    return output_pipe_handles_[kWriteEndHandle];
  }

  bool WriteToFile(const System::StrType& stdout_file) {
    CloseWriteEnd();
    HANDLE output_file_handle = CreateFile(
        /*lpFileName*/ stdout_file.c_str(),
        /*dwDesiredAccess*/ GENERIC_WRITE,
        /*dwShareMode*/ FILE_SHARE_WRITE,
        /*lpSecurityAttributes*/ NULL,
        /*dwCreationDisposition*/ CREATE_ALWAYS,
        /*dwFlagsAndAttributes*/ FILE_ATTRIBUTE_NORMAL,
        /*hTemplateFile*/ NULL);

    if (output_file_handle == INVALID_HANDLE_VALUE) {
      std::cerr << "process wrapper error: failed to open the output file.\n";
      return false;
    }

    constexpr DWORD kBufferSize = 4096;
    CHAR buffer[kBufferSize];
    while (1) {
      DWORD read;
      bool success =
          ReadFile(ReadEndHandle(), buffer, kBufferSize, &read, NULL);
      if (read == 0) {
        break;
      } else if (!success) {
        std::cerr
            << "process wrapper error: failed to read child process output.\n";
        return false;
      }

      DWORD written;
      success = WriteFile(output_file_handle, buffer, read, &written, NULL);
      if (!success) {
        std::cerr << "process wrapper error: failed to write to output capture "
                     "file.\n";
        return false;
      }
    }
    return true;
  }

 private:
  void Close(size_t idx) {
    if (output_pipe_handles_[idx] != nullptr) {
      ::CloseHandle(output_pipe_handles_[idx]);
    }
    output_pipe_handles_[idx] = nullptr;
  }
  HANDLE output_pipe_handles_[2] = {nullptr};
};

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
                 const StrType& stdout_file, const StrType& stderr_file) {
  STARTUPINFO startup_info;
  ZeroMemory(&startup_info, sizeof(STARTUPINFO));
  startup_info.cb = sizeof(STARTUPINFO);

  OutputPipe stdout_pipe;
  if (!stdout_file.empty() &&
      !stdout_pipe.CreateEnds(startup_info, /*err*/ false)) {
    std::cerr << "process wrapper error: failed to create stdout pipe.\n";
    return -1;
  }
  OutputPipe stderr_pipe;
  if (!stderr_file.empty() &&
      !stderr_pipe.CreateEnds(startup_info, /*err*/ true)) {
    std::cerr << "process wrapper error: failed to create stderr pipe.\n";
    return -1;
  }

  System::StrType command_line;
  ArgumentQuote(executable, command_line);
  MakeCommandLine(arguments, command_line);

  System::StrType environment_block_win;
  MakeEnvironmentBlock(environment_block, environment_block_win);

  PROCESS_INFORMATION process_info;
  ZeroMemory(&process_info, sizeof(PROCESS_INFORMATION));

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
    std::cerr << "process wrapper error: Failed to launch a new process.\n";
    return -1;
  }

  if (!stdout_file.empty()) {
    if (!stdout_pipe.WriteToFile(stdout_file)) {
      return -1;
    }
  }
  if (!stderr_file.empty()) {
    if (!stderr_pipe.WriteToFile(stderr_file)) {
      return -1;
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
