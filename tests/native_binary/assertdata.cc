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

#include <memory>
#include <string>

#include "tools/cpp/runfiles/runfiles.h"

using bazel::tools::cpp::runfiles::Runfiles;

int main(int argc, char** argv) {
  std::string error;
  std::unique_ptr<Runfiles> runfiles(Runfiles::Create(argv[0], &error));
  if (runfiles == nullptr) {
    fprintf(stderr, "ERROR(" __FILE__ ":%d): Could not init runfiles\n",
            __LINE__);
    return 1;
  }

  // Even though this cc_binary rule has no data-dependencies, the
  // native_binary that wraps a copy of this binary does, so we have some
  // runfiles.
  std::string path =
      runfiles->Rlocation("bazel_skylib/tests/native_binary/testdata.txt");
  if (path.empty()) {
    fprintf(stderr, "ERROR(" __FILE__ ":%d): Could not find runfile\n",
            __LINE__);
  }

  FILE* f = fopen(path.c_str(), "rt");
  char buf[6];
  size_t s = fread(buf, 1, 5, f);
  fclose(f);
  buf[5] = 0;
  if (s != 5 || std::string("hello") != std::string(buf, 5)) {
    fprintf(stderr, "ERROR(" __FILE__ ":%d): bad runfile contents (%s)\n",
            __LINE__, buf);
    return 1;
  }

  return 0;
}

