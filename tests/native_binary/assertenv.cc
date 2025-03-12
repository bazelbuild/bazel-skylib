// Copyright 2019 The Bazel Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <utility>

int main(int argc, char** argv) {
  static const std::pair<const char*, const char*> kExpected[] = {
      {"TEST_ENV_VAR", "ENV_VALUE"}};

  for (auto expected : kExpected) {
    const char* key = expected.first;
    const char* value = expected.second;
    if (strcmp(getenv(key), value)) {
      fprintf(stderr, "Expected %s to be %s, but it was %s\n", key, value,
              getenv(key));
      return 1;
    } else {
      printf("key[%s]=(%s) OK\n", key, value);
    }
  }
  return 0;
}

