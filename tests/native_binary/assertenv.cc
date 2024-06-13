#include <stdio.h>
#include <string.h>

#ifdef _WIN32
#define OS_VAR "APPDATA"
#define strncasecmp _strnicmp
#else
#define OS_VAR "HOME"
#endif

enum vars_to_be_found {
  test_env_var = 0,
  inherited,
  test_env_var_with_expansion,
  last,
};

int main(int argc, char **argv, char **envp) {
  const char* expected[last] = {
    "TEST_ENV_VAR=test_env_var_value",
    OS_VAR "=",
    "TEST_ENV_VAR_WITH_EXPANSION=|_main/tests/native_binary/BUILD|",
  };
  for (char **env = envp; *env != NULL; ++env) {
    printf("%s\n", *env);
    if (expected[test_env_var] && strcmp(*env, expected[test_env_var]) == 0) {
      expected[test_env_var] = nullptr;
    }
    if (expected[inherited] && strncasecmp(*env, expected[inherited], strlen(expected[inherited])) == 0) {
      expected[inherited] = nullptr;
    }
    if (expected[test_env_var_with_expansion] && strcmp(*env, expected[test_env_var_with_expansion]) == 0) {
      expected[test_env_var_with_expansion] = nullptr;
    }
  }
  auto return_status = 0;
  for (auto still_expected : expected) {
    if (still_expected) {
      fprintf(stderr, "expected %s\n", still_expected);
      return_status = 1;
    }
  }
  return return_status;
}
