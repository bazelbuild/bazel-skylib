#include <chrono>
#include <fstream>
#include <iostream>
#include <string>

void FindString(const char *strings[]) {

}

int main(int argc, const char *argv[], const char *envp[]) {
  if (argc < 4) {
    std::cerr << "Invalid number of args exected at least 4 got " << argc << "."
              << std::endl;
    return 1;
  }
  std::string test_config = argv[1];

  bool combined = test_config == "combined";
  if (combined || test_config == "basic") {
    std::string current_dir_arg = argv[2];
    if (current_dir_arg != "--current-dir") {
      std::cerr << "Argument \"--current-dir\" not found." << std::endl;
      return 1;
    }
  }

  std::string current_dir_arg = argv[2];
  if (current_dir_arg != "--current-dir") {
    std::cerr << "Argument \"--current-dir\" not found." << std::endl;
    return 1;
  }

  std::string current_dir = argv[3];
  if (combined || test_config == "subst-pwd") {
    if (current_dir == "<pwd>") {
      std::cerr << "Expected <pwd> substitution." << std::endl;
      return 1;
    }
  } else {
    if (current_dir != "<pwd>") {
      std::cerr << "Expected <pwd>." << std::endl;
      return 1;
    }
  }

  if (combined || test_config == "env-files") {
  }
  std::ofstream env_file(argv[1]);
  for (int i = 0; envp[i] != nullptr; ++i) {
    env_file << envp[i] << std::endl;
  }

  std::ofstream arg_file(argv[2]);
  for (int i = 3; i < argc; ++i) {
    arg_file << argv[i] << std::endl;
  }

  if (combined || test_config == "stdout") {
    for (int i = 0; i < 10000; ++i) {
      std::cout << "Child process to stdout : " << i << std::endl;
    }
  }
}
