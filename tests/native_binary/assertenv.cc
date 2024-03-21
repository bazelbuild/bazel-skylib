#include <stdio.h>
#include <string.h>

#ifdef _WIN32
#define OS_VAR "APPDATA"
#define strncasecmp _strnicmp
#else
#define OS_VAR "HOME"
#endif

int main(int argc, char **argv, char **envp) {
  bool test_env_found = false;
  bool inherited_var_found = false;
  for (char **env = envp; *env != NULL; ++env) {
    printf("%s\n", *env);
    if (strcmp(*env, "TEST_ENV_VAR=test_env_var_value") == 0) {
      test_env_found = true;
    }
	if (strncasecmp(*env, OS_VAR "=", strlen(OS_VAR "=")) == 0) {
      inherited_var_found = true;
    }
  }
  if (!test_env_found) {
    fprintf(stderr,
            "expected TEST_ENV_VAR=test_env_var_value in environment\n");
  }
  if (!inherited_var_found) {
    fprintf(stderr, "expected " OS_VAR " in environment\n");
  }
  return test_env_found && inherited_var_found ? 0 : 1;
}
