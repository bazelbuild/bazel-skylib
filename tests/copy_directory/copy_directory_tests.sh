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

source "$(rlocation $TEST_WORKSPACE/tests/unittest.bash)" \
  || { echo "Could not source bazel_skylib/tests/unittest.bash" >&2; exit 1; }

function test_copy_dir_with_subdir__copies_a() {
  cat "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_copy)/a" >"$TEST_log"
  expect_log '^foo$'
}

function test_copy_dir_with_subdir__copies_b() {
  cat "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_copy)/b" >"$TEST_log"
  expect_log '^bar$'
}

function test_copy_dir_with_subdir__copies_c() {
  cat "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_copy)/subdir/c" >"$TEST_log"
  expect_log '^moocow$'
}

function test_copy_dir_with_subdir__correct_filecounts() {
  local -r dir_filecount=$(ls "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_copy)" | wc -l)
  assert_equals $dir_filecount 3
  local -r subdir_filecount=$(ls "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_copy)/subdir" | wc -l)
  assert_equals $subdir_filecount 1
}

function test_copy_empty_dir() {
  local -r filecount=$(ls "$(rlocation $TEST_WORKSPACE/tests/copy_directory/empty_dir_copy)" | wc -l)
  assert_equals $filecount 0
}

function test_copy_dir_with_symlink__copies_file() {
  cat "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_with_symlink_copy)/file" >"$TEST_log"
  expect_log '^foo$'
}

function test_copy_dir_with_symlink__copies_symlink() {
  cat "$(rlocation $TEST_WORKSPACE/tests/copy_directory/dir_with_symlink_copy)/symlink" >"$TEST_log"
  expect_log '^foo$'
}


run_suite "copy_directory test suite"
