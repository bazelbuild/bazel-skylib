#include "lib/process_wrapper/system.h"
#include "lib/process_wrapper/utils.h"

// posix headers
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <iostream>
#include <vector>

namespace process_wrapper {

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
                 const System::EnvironmentBlock& environment_block) {
  pid_t child_pid = fork();
  if (child_pid < 0) {
    std::cerr << "error: Failed to fork the current process." << std::endl;
    return -1;
  } else if (child_pid == 0) {
    std::vector<char*> argv;
    std::string argv0 = JoinPaths(GetWorkingDirectory(), executable);
    argv.push_back(&argv0[0]);
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
    std::cerr << "error: Failed to exec the new process." << std::endl;
    return -1;
  }

  int err, exit_status = -1;
  do {
    err = waitpid(child_pid, &exit_status, 0);
  } while (err == -1 && errno == EINTR);

  return exit_status;
}

}  // namespace process_wrapper
