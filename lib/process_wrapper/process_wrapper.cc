#include <fstream>
#include <iostream>
#include <streambuf>
#include <string>

#include "lib/process_wrapper/system.h"
#include "lib/process_wrapper/utils.h"

// Simple process wrapper allowing us to not depend on the shell to run a
// process and perform basic operations.
#if defined(RTW_WIN_UNICODE)
int wmain(int argc, const wchar_t* argv[], const wchar_t* envp[]) {
#else
int main(int argc, const char* argv[], const char* envp[]) {
#endif  // defined(RTW_WIN_UNICODE)

  using namespace process_wrapper;

  System::EnvironmentBlock environment_block;
  // Taking all environment variables from the current process
  // and sending them down to the child process
  for (int i = 0; envp[i] != nullptr; ++i) {
    environment_block.push_back(envp[i]);
  }

  System::StrType exec_path;
  System::StrType touch_file;
  System::StrType stdout_file;
  System::Arguments arguments;
  System::Arguments file_arguments;
  bool subst_pwd = false;
  // Processing current process argument list until -- is encountered
  // everthing after gets sent down to the child process
  for (int i = 1; i < argc; ++i) {
    System::StrType arg = argv[i];
    if (arg == RTW_SYS_STR_LITERAL("--subst-pwd")) {
      subst_pwd = true;
    } else {
      if (++i == argc) {
        std::cerr << "Argument \"" << ToUtf8(arg) << "\" missing parameter."
                  << std::endl;
        return -1;
      }
      if (arg == RTW_SYS_STR_LITERAL("--env-file")) {
        if (!ReadFileToArray(argv[i], environment_block)) {
          return -1;
        }
      } else if (arg == RTW_SYS_STR_LITERAL("--arg-file")) {
        if (!ReadFileToArray(argv[i], file_arguments)) {
          return -1;
        }
      } else if (arg == RTW_SYS_STR_LITERAL("--touch-file")) {
        touch_file = argv[i];
      } else if (arg == RTW_SYS_STR_LITERAL("--stdout-file")) {
        stdout_file = argv[i];
      } else if (arg == RTW_SYS_STR_LITERAL("--")) {
        exec_path = argv[i];
        for (++i; i < argc; ++i) {
          arguments.push_back(argv[i]);
        }
        // after we consume all arguments we append the files arguments
        for (const System::StrType& file_arg : file_arguments) {
          arguments.push_back(file_arg);
        }
      }
    }
  }

  if (subst_pwd) {
    const System::StrType token = RTW_SYS_STR_LITERAL("<pwd>");
    const System::StrType replacement = System::GetWorkingDirectory();
    for (System::StrType& arg : arguments) {
      ReplaceToken(arg, token, replacement);
    }

    for (System::StrType& env : environment_block) {
      ReplaceToken(env, token, replacement);
    }
  }

  int exit_code =
      System::Exec(exec_path, arguments, environment_block, stdout_file);
  if (exit_code == 0) {
    if (!touch_file.empty()) {
      std::ofstream file(touch_file);
      if (file.fail()) {
        std::cerr << "Touch file \"" << touch_file.c_str()
                  << "\" creation failed" << std::endl;
        return -1;
      }
    }
  }
  return exit_code;
}
