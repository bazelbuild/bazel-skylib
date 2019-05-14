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
#include <string.h>

int main(int argc, char** argv) {
  static const char* kExpected[] = {
    "a b",
    "c d",
    "tests/native_binary/testdata.txt",
    "$(location",
    "testdata.txt)",
    "tests/native_binary/testdata.txt",
    "tests/native_binary/testdata.txt $(location testdata.txt) tests/native_binary/testdata.txt",
    "$TEST_SRCDIR",

    // TODO(laszlocsomor): uncomment this (and its counterpart in the BUILD
    // file) after https://github.com/bazelbuild/bazel/issues/6622 is resolved
    // and the Bash-less test wrapper is the default on Windows.
    // "${TEST_SRCDIR}",

    "",
  };

  for (int i = 1; i < argc; ++i) {
    if (!kExpected[i - 1][0]) {
      fprintf(stderr, "too many arguments, expected only %d\n", i);
      return 1;
    }
    if (argc < i) {
      fprintf(stderr, "expected more than %d arguments\n", i);
      return 1;
    }
    if (strcmp(argv[i], kExpected[i - 1]) != 0) {
      fprintf(stderr, "argv[%d]=(%s), expected (%s)\n", i, argv[i],
              kExpected[i - 1]);
      return 1;
    }
  }
  return 0;
}
