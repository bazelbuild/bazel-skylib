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

class OutputPipe {
 public:
  static constexpr size_t kReadEndDesc = 0;
  static constexpr size_t kWriteEndDesc = 1;

  ~OutputPipe() {
    CloseReadEnd();
    CloseWriteEnd();
  }

  int CreateEnds() {
    if (pipe(output_pipe_desc_) != 0) {
      std::cerr << "process wrapper error: failed to open the stdout pipes.\n";
      return false;
    }
    return true;
  }
  void DupWriteEnd(int newfd) {
    dup2(output_pipe_desc_[kWriteEndDesc], newfd);
    CloseReadEnd();
    CloseWriteEnd();
  }

  void CloseReadEnd() { Close(kReadEndDesc); }
  void CloseWriteEnd() { Close(kWriteEndDesc); }

  int ReadEndDesc() const { return output_pipe_desc_[kReadEndDesc]; }
  int WriteEndDesc() const { return output_pipe_desc_[kWriteEndDesc]; }

  bool WriteToFile(const System::StrType& stdout_file) {
    CloseWriteEnd();

    constexpr size_t kBufferSize = 4096;
    char buffer[kBufferSize];
    int output_file_desc =
        open(stdout_file.c_str(), O_WRONLY | O_CREAT | O_TRUNC,
             S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if (output_file_desc == -1) {
      std::cerr << "process wrapper error: failed to open redirection file.\n";
      return false;
    }
    while (1) {
      ssize_t read_bytes = read(ReadEndDesc(), buffer, kBufferSize);
      if (read_bytes < 0) {
        std::cerr
            << "process wrapper error: failed to read child process ouptput.\n";
        return false;
      } else if (read_bytes == 0) {
        break;
      }
      ssize_t written_bytes = write(output_file_desc, buffer, read_bytes);
      if (written_bytes < 0 || written_bytes != read_bytes) {
        std::cerr << "process wrapper error: failed to write to ouput file.\n";
        return false;
      }
    }

    CloseReadEnd();
    close(output_file_desc);
    return true;
  }

 private:
  void Close(size_t idx) {
    if (output_pipe_desc_[idx] > 0) {
      close(output_pipe_desc_[idx]);
    }
    output_pipe_desc_[idx] = -1;
  }
  int output_pipe_desc_[2] = {-1};
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
                 const StrType& stdout_file, const StrType& stderr_file) {
  OutputPipe stdout_pipe;
  if (!stdout_file.empty() && !stdout_pipe.CreateEnds()) {
    return -1;
  }
  OutputPipe stderr_pipe;
  if (!stderr_file.empty() && !stderr_pipe.CreateEnds()) {
    return -1;
  }

  pid_t child_pid = fork();
  if (child_pid < 0) {
    std::cerr << "process wrapper error: failed to fork the current process.\n";
    return -1;
  } else if (child_pid == 0) {
    if (!stdout_file.empty()) {
      stdout_pipe.DupWriteEnd(STDOUT_FILENO);
    }
    if (!stderr_file.empty()) {
      stderr_pipe.DupWriteEnd(STDERR_FILENO);
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
    std::cerr << "process wrapper error: failed to exec the new process.\n";
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

  int err, exit_status = -1;
  do {
    err = waitpid(child_pid, &exit_status, 0);
  } while (err == -1 && errno == EINTR);

  return exit_status;
}

}  // namespace process_wrapper
