#include <cstdlib>
#include <iostream>
#include <string>

void basic_part1_test(std::string current_dir_arg) {
  if (current_dir_arg != "--current-dir") {
    std::cerr << "error: argument \"--current-dir\" not found." << std::endl;
    std::exit(1);
  }
}

void basic_part2_test(std::string current_dir, const char* envp[]) {
  if (current_dir != "<pwd>") {
    std::cerr << "error: Unsubsituted <pwd> not found." << std::endl;
    std::exit(1);
  }
  const std::string current_dir_env = "CURRENT_DIR=<pwd>/test_path";
  bool found = false;
  for (int i = 0; envp[i] != nullptr; ++i) {
    if (current_dir_env == envp[i]) {
      found = true;
      break;
    }
  }
  if (!found) {
    std::cerr << "Unsubsituted CURRENT_DIR not found." << std::endl;
    std::exit(1);
  }
}

void subst_pwd_test(std::string current_dir, const char* envp[]) {
  if (current_dir == "<pwd>") {
    std::cerr << "error: argument <pwd> substitution failed." << std::endl;
    std::exit(1);
  }
  bool found = false;
  for (int i = 0; envp[i] != nullptr; ++i) {
    const std::string env = envp[i];
    if (env.rfind("CURRENT_DIR", 0) == 0) {
      found = true;
      if (env.find("<pwd>") == 0) {
        std::cerr << "error: environment variable <pwd> substitution failed"
                  << std::endl;
        std::exit(1);
      }
      break;
    }
  }
  if (!found) {
    std::cerr << "CURRENT_DIR not found." << std::endl;
    std::exit(1);
  }
}

void env_files_test(const char* envp[]) {
  const std::string must_exist[] = {
      "FOO=BAR",
      "FOOBAR=BARFOO",
      "BAR=FOO",
  };

  for (const std::string& env : must_exist) {
    bool found = false;
    for (int i = 0; envp[i] != nullptr; ++i) {
      if (env == envp[i]) {
        found = true;
        break;
      }
    }
    if (!found) {
      std::cerr << "Environment variable \"" << env << "\" not found."
                << std::endl;
      std::exit(1);
    }
  }
}

void arg_files_test(int argc, const char* argv[]) {
  const std::string must_exist[] = {
      "--arg1=foo", "--arg2", "foo bar", "--arg2=bar", "--arg3", "foobar",
  };

  for (const std::string& arg : must_exist) {
    bool found = false;
    for (int i = 0; i < argc; ++i) {
      if (arg == argv[i]) {
        found = true;
        break;
      }
    }
    if (!found) {
      std::cerr << "Argument \"" << arg << "\" not found." << std::endl;
      std::exit(1);
    }
  }
}

void test_stdout() {
  for (int i = 0; i < 10000; ++i) {
    std::cout << "Child process to stdout : " << i << "\n";
  }
}

int main(int argc, const char* argv[], const char* envp[]) {
  if (argc < 4) {
    std::cerr << "error: Invalid number of args exected at least 4 got " << argc
              << "." << std::endl;
    return 1;
  }
  std::string test_config = argv[1];
  bool combined = test_config == "combined";
  if (combined || test_config == "basic") {
    basic_part1_test(argv[2]);
  }

  if (combined || test_config == "subst-pwd") {
    subst_pwd_test(argv[3], envp);
  } else if (test_config == "basic") {
    basic_part2_test(argv[3], envp);
  }

  if (combined || test_config == "env-files") {
    env_files_test(envp);
  }

  if (combined || test_config == "arg-files") {
    arg_files_test(argc, argv);
  }

  if (combined || test_config == "stdout") {
    test_stdout();
  }
}
