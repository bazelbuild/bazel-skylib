#include <fstream>
#include <iostream>
#include <string>
#include <utility>

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

  using Subst = std::pair<System::StrType, System::StrType>;

  System::StrType exec_path;
  std::vector<Subst> subst_mappings;
  System::StrType stdout_file;
  System::StrType stderr_file;
  System::StrType touch_file;
  System::Arguments arguments;
  System::Arguments file_arguments;

  // Processing current process argument list until -- is encountered
  // everthing after gets sent down to the child process
  for (int i = 1; i < argc; ++i) {
    System::StrType arg = argv[i];
    if (++i == argc) {
      std::cerr << "process wrapper error: argument \"" << ToUtf8(arg)
                << "\" missing parameter.\n";
      return -1;
    }
    if (arg == PW_SYS_STR("--subst")) {
      System::StrType subst = argv[i];
      size_t equal_pos = subst.find('=');
      if (equal_pos == std::string::npos) {
        std::cerr << "process wrapper error: wrong substituion format for \""
                  << ToUtf8(subst) << "\".\n";
        return -1;
      }
      System::StrType key = subst.substr(0, equal_pos);
      if (key.empty()) {
        std::cerr << "process wrapper error: empty key for substituion \""
                  << ToUtf8(subst) << "\".\n";
        return -1;
      }
      System::StrType value = subst.substr(equal_pos, subst.size());
      if (value == PW_SYS_STR("${pwd}")) {
        value = System::GetWorkingDirectory();
      }
      subst_mappings.push_back({std::move(key), std::move(value)});
    } else if (arg == PW_SYS_STR("--env-file")) {
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
                     "than once\n";
        return -1;
      }
      touch_file = argv[i];
    } else if (arg == PW_SYS_STR("--stdout-file")) {
      if (!stdout_file.empty()) {
        std::cerr << "process wrapper error: \"--stdout-file\" appears more "
                     "than once\n";
        return -1;
      }
      stdout_file = argv[i];
    } else if (arg == PW_SYS_STR("--stderr-file")) {
      if (!stderr_file.empty()) {
        std::cerr << "process wrapper error: \"--stderr-file\" appears more "
                     "than once\n";
        return -1;
      }
      stderr_file = argv[i];
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
                << "\"." << '\n';
      return -1;
    }
  }

  if (subst_mappings.size()) {
    for (const Subst& subst : subst_mappings) {
      System::StrType token = PW_SYS_STR("${");
      token += subst.first;
      token.push_back('}');
      for (System::StrType& arg : arguments) {
        ReplaceToken(arg, token, subst.second);
      }

      for (System::StrType& env : environment_block) {
        ReplaceToken(env, token, subst.second);
      }
    }
  }

  int exit_code =
      System::Exec(exec_path, arguments, environment_block, stdout_file, stderr_file);
  if (exit_code == 0) {
    if (!touch_file.empty()) {
      std::ofstream file(touch_file);
      if (file.fail()) {
        std::cerr << "Touch file \"" << touch_file.c_str()
                  << "\" creation failed" << '\n';
        return -1;
      }
    }
  }
  return exit_code;
}
