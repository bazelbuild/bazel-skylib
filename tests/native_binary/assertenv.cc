#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool check(const char *var, const char *expected = nullptr);

int main() {
  bool ok = true;
  ok = ok && check("TEST_ENV_VAR", "test_env_var_value");
#ifdef _WIN32
  ok = ok && check("APPDATA");
#else
  ok = ok && check("HOME");
#endif
  ok =
      ok && check("TEST_ENV_VAR_WITH_EXPANSION", "|tests/native_binary/BUILD|");
  return ok ? 0 : 1;
}

bool check(const char *var, const char *expected) {
  const char *actual = getenv(var);
  if (actual == nullptr) {
    fprintf(stderr, "expected %s\n", var);
    return false;
  }
  if (expected && strcmp(actual, expected) != 0) {
    fprintf(stderr, "expected %s=%s, got %s\n", var, expected, actual);
    return false;
  }
  return true;
}
