#!/usr/bin/env bash

# Copyright 2022 The Bazel Authors. All rights reserved.
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

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
    source "$0.runfiles/$f" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
    { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

source "$(rlocation $TEST_WORKSPACE/tests/unittest.bash)" \
  || { echo "Could not source bazel_skylib/tests/unittest.bash" >&2; exit 1; }

function test_make_vars_expansion() {
  cat "$(rlocation $TEST_WORKSPACE/tests/expand_template/make_vars.txt)" >"$TEST_log"

  # Verify that make variables were expanded (not literal strings)
  # The expanded values should contain actual paths, not the literal "$(BINDIR)" etc.
  if grep -q '\$(' "$TEST_log"; then
    echo "ERROR: Make variables were not expanded" >&2
    cat "$TEST_log" >&2
    fail "Make variables should be expanded, but found literal \$(...) in output"
  fi

  # Verify that each line contains the expected prefix and some non-empty value.
  expect_log '^BINDIR: ..*'
  expect_log '^GENDIR: ..*'
  expect_log '^TARGET_CPU: ..*'
}

run_suite "make_vars_expansion test suite"
