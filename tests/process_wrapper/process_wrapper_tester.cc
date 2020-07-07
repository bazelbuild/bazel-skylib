#include <fstream>
#include <iostream>
#include <streambuf>
#include <string>

int main(int argc, const char *argv[], const char *envp[]) {
  std::ofstream env_file(argv[1]);
  env_file << "Envs:" << std::endl;
  for (int i = 0; envp[i] != nullptr; ++i) {
    env_file << envp[i] << std::endl;
  }

  std::ofstream arg_file(argv[2]);
  arg_file << "Args:" << std::endl;
  for (int i = 3; i < argc; ++i) {
    arg_file << argv[i] << std::endl;
  }

  std::cout << "Child process to stdout" << std::endl;
}
