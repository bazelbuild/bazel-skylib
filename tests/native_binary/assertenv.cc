#include <stdio.h>
#include <string.h>

#ifdef _WIN32
bool is_home_env(const char *env) {
  return _strnicmp(env, "HOMEPATH=", strlen("HOMEPATH=")) == 0;
}
#else
bool is_home_env(const char *env) {
  return strncmp(env, "HOME=", strlen("HOME=")) == 0;
}
#endif

int main(int argc, char **argv, char **envp) {
  bool test_env_found = false;
  bool home_found = false;
  for (char **env = envp; *env != NULL; ++env) {
    if (strcmp(*env, "TEST_ENV_VAR=test_env_var_value") == 0) {
      test_env_found = true;
    }
    if (is_home_env(*env)) {
      home_found = true;
    }
  }
  if (!test_env_found) {
    fprintf(stderr,
            "expected TEST_ENV_VAR=test_env_var_value in environment\n");
  }
  if (!home_found) {
    fprintf(stderr, "expected HOME or HOMEPATH in environment\n");
  }
  return test_env_found && home_found ? 0 : 1;
}
