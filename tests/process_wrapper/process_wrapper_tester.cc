#include <chrono>
#include <fstream>
#include <iostream>
#include <string>
#include <thread>

int main(int argc, const char *argv[], const char *envp[]) {
  std::ofstream env_file(argv[1]);
  for (int i = 0; envp[i] != nullptr; ++i) {
    env_file << envp[i] << std::endl;
  }

  std::ofstream arg_file(argv[2]);
  for (int i = 3; i < argc; ++i) {
    arg_file << argv[i] << std::endl;
  }

  std::this_thread::sleep_for(std::chrono::seconds(10));

  for (int i = 0; i < 10000; ++i) {
    std::cout << "Child process to stdout : " << i << std::endl;
  }
}
