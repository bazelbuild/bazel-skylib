#!/usr/bin/env bash

# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# --- begin runfiles.bash initialization ---
# Copy-pasted from Bazel's Bash runfiles library (tools/bash/runfiles/runfiles.bash).
set -euo pipefail
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  if [[ -f "$0.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
  elif [[ -f "$0.runfiles/MANIFEST" ]]; then
    export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
  elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
    export RUNFILES_DIR="$0.runfiles"
  fi
fi
if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash " \
            "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
  echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
  exit 1
fi
# --- end runfiles.bash initialization ---

source "$(rlocation bazel_skylib/tests/unittest.bash)" \
  || { echo "Could not source bazel_skylib/tests/unittest.bash" >&2; exit 1; }

function test_copy_src() {
  cat "$(rlocation bazel_skylib/tests/copy_file/out/a-out.txt)" >"$TEST_log"
  expect_log '^#!/usr/bin/env bash$'
  expect_log '^echo aaa$'
}

function test_copy_src_symlink() {
  cat "$(rlocation bazel_skylib/tests/copy_file/out/a-out-symlink.txt)" >"$TEST_log"
  expect_log '^#!/usr/bin/env bash$'
  expect_log '^echo aaa$'
}

function test_copy_gen() {
  cat "$(rlocation bazel_skylib/tests/copy_file/out/gen-out.txt)" >"$TEST_log"
  expect_log '^#!/usr/bin/env bash$'
  expect_log '^echo potato$'
}

function test_copy_gen_symlink() {
  cat "$(rlocation bazel_skylib/tests/copy_file/out/gen-out-symlink.txt)" >"$TEST_log"
  expect_log '^#!/usr/bin/env bash$'
  expect_log '^echo potato$'
}

function test_copy_xsrc() {
  cat "$(rlocation bazel_skylib/tests/copy_file/xsrc-out.txt)" >"$TEST_log"
  expect_log '^aaa$'
}

function test_copy_xsrc_symlink() {
  cat "$(rlocation bazel_skylib/tests/copy_file/xsrc-out-symlink.txt)" >"$TEST_log"
  expect_log '^aaa$'
}

function test_copy_xgen() {
  cat "$(rlocation bazel_skylib/tests/copy_file/xgen-out.txt)" >"$TEST_log"
  expect_log '^potato$'
}

function test_copy_xgen_symlink() {
  cat "$(rlocation bazel_skylib/tests/copy_file/xgen-out-symlink.txt)" >"$TEST_log"
  expect_log '^potato$'
}

run_suite "copy_file_tests test suite"
