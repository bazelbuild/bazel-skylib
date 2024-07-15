#include "lib/process_wrapper/system.h"
#include "lib/process_wrapper/utils.h"

// posix headers
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <iostream>
#include <vector>

namespace process_wrapper {

namespace {

class StdoutPipe {
 public:
  static constexpr size_t kReadEndDesc = 0;
  static constexpr size_t kWriteEndDesc = 1;

  ~StdoutPipe() {
    CloseReadEnd();
    CloseWriteEnd();
  }

  int CreateEnds() {
    if (pipe(stdout_pipe_desc_) != 0) {
      std::cerr << "process wrapper error: failed to open the stdout pipes."
                << std::endl;
      return false;
    }
    return true;
  }
  void DupWriteEnd() {
    dup2(stdout_pipe_desc_[kWriteEndDesc], STDOUT_FILENO);
    CloseReadEnd();
    CloseWriteEnd();
  }

  void CloseReadEnd() { Close(kReadEndDesc); }
  void CloseWriteEnd() { Close(kWriteEndDesc); }

  int ReadEndDesc() const { return stdout_pipe_desc_[kReadEndDesc]; }
  int WriteEndDesc() const { return stdout_pipe_desc_[kWriteEndDesc]; }

  bool WriteToFile(const System::StrType& stdout_file) {
    CloseWriteEnd();

    constexpr size_t kBufferSize = 4096;
    char buffer[kBufferSize];
    int stdout_file_desc =
        open(stdout_file.c_str(), O_WRONLY | O_CREAT | O_TRUNC);
    if (stdout_file_desc == -1) {
      std::cerr << "process wrapper error: failed to open redirection file."
                << std::endl;
      return false;
    }
    while (1) {
      ssize_t read_bytes = read(ReadEndDesc(), buffer, kBufferSize);
      if (read_bytes < 0) {
        std::cerr << "process wrapper error: failed child process stdout."
                  << std::endl;
        return false;
      } else if (read_bytes == 0) {
        break;
      }
      ssize_t written_bytes = write(stdout_file_desc, buffer, read_bytes);
      if (written_bytes < 0 || written_bytes != read_bytes) {
        std::cerr << "process wrapper error: failed to write to stdout file."
                  << std::endl;
        return false;
      }
    }

    CloseReadEnd();
    close(stdout_file_desc);
    return true;
  }

 private:
  void Close(size_t idx) {
    if (stdout_pipe_desc_[idx] > 0) {
      close(stdout_pipe_desc_[idx]);
    }
    stdout_pipe_desc_[idx] = -1;
  }
  int stdout_pipe_desc_[2] = {-1};
};

}  // namespace

System::StrType System::GetWorkingDirectory() {
  const size_t kMaxBufferLength = 4096;
  char cwd[kMaxBufferLength];
  if (getcwd(cwd, sizeof(cwd)) == NULL) {
    return System::StrType{};
  }
  return System::StrType{cwd};
}

int System::Exec(const System::StrType& executable,
                 const System::Arguments& arguments,
                 const System::EnvironmentBlock& environment_block,
                 const StrType& stdout_file) {
  StdoutPipe stdout_pipe;
  if (!stdout_file.empty() && !stdout_pipe.CreateEnds()) {
    return -1;
  }
  
  pid_t child_pid = fork();
  if (child_pid < 0) {
    std::cerr << "process wrapper error: failed to fork the current process."
              << std::endl;
    return -1;
  } else if (child_pid == 0) {
    if (!stdout_file.empty()) {
      stdout_pipe.DupWriteEnd();
    }
    std::vector<char*> argv;
    argv.push_back(const_cast<char*>(executable.c_str()));
    for (const StrType& argument : arguments) {
      argv.push_back(const_cast<char*>(argument.c_str()));
    }
    argv.push_back(nullptr);

    std::vector<char*> envp;
    for (const StrType& ev : environment_block) {
      envp.push_back(const_cast<char*>(ev.c_str()));
    }
    envp.push_back(nullptr);

    umask(022);

    execve(executable.c_str(), argv.data(), envp.data());
    std::cerr << "process wrapper error: failed to exec the new process."
              << std::endl;
    return -1;
  }

  if (!stdout_file.empty()) {
    if (!stdout_pipe.WriteToFile(stdout_file)) {
      return -1;
    }
  }

  int err, exit_status = -1;
  do {
    err = waitpid(child_pid, &exit_status, 0);
  } while (err == -1 && errno == EINTR);

  return exit_status;
}

}  // namespace process_wrapper
