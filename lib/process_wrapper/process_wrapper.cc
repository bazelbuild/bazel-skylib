#include <fstream>
#include <iostream>
#include <string>

#include "lib/process_wrapper/system.h"
#include "lib/process_wrapper/utils.h"

using CharType = process_wrapper::System::StrType::value_type;

// Simple process wrapper allowing us to not depend on the shell to run a
// process to perform basic operations like capturing the output or having
// the $pwd used in command line arguments or environment variables
int PW_MAIN(int argc, const CharType* argv[], const CharType* envp[]) {
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
    if (arg == PW_SYS_STR("--subst-pwd")) {
      subst_pwd = true;
    } else {
      // All argument in the else block have a parameter
      if (++i == argc) {
        std::cerr << "process wrapper error: argument \"" << ToUtf8(arg)
                  << "\" missing parameter." << std::endl;
        return -1;
      }
      if (arg == PW_SYS_STR("--env-file")) {
        if (!ReadFileToArray(argv[i], environment_block)) {
          return -1;
        }
      } else if (arg == PW_SYS_STR("--arg-file")) {
        if (!ReadFileToArray(argv[i], file_arguments)) {
          return -1;
        }
      } else if (arg == PW_SYS_STR("--touch-file")) {
        if (!touch_file.empty()) {
          std::cerr << "process wrapper error: \"--touch-file\" appears more "
                       "than once"
                    << std::endl;
          return -1;
        }
        touch_file = argv[i];
      } else if (arg == PW_SYS_STR("--stdout-file")) {
        if (!stdout_file.empty()) {
          std::cerr << "process wrapper error: \"--stdout-file\" appears more "
                       "than once"
                    << std::endl;
          return -1;
        }
        stdout_file = argv[i];
      } else if (arg == PW_SYS_STR("--")) {
        exec_path = argv[i];
        for (++i; i < argc; ++i) {
          arguments.push_back(argv[i]);
        }
        // after we consume all arguments we append the files arguments
        for (const System::StrType& file_arg : file_arguments) {
          arguments.push_back(file_arg);
        }
      } else {
        std::cerr << "process wrapper error: unknow argument \"" << ToUtf8(arg)
                  << "\"." << std::endl;
        return -1;
      }
    }
  }

  if (subst_pwd) {
    const System::StrType token = PW_SYS_STR("<pwd>");
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
