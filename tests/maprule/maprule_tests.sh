#!/bin/bash

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

function test_bash_maprule() {
  local -r out1foo="$(rlocation bazel_skylib/tests/maprule/mr_bash_out/tests/maprule/foo.txt.out1)"
  local -r out1bar="$(rlocation bazel_skylib/tests/maprule/mr_bash_out/tests/maprule/b/bar.txt.out1)"
  local -r out2foo="$(rlocation bazel_skylib/tests/maprule/mr_bash_out/out2/foo)"
  local -r out2bar="$(rlocation bazel_skylib/tests/maprule/mr_bash_out/out2/bar)"

  cat "$out1foo" | tr '\n\r' ' ' > "$TEST_log"
  expect_log "^tests/maprule/common.txt *tests/maprule/foo.txt *$"

  cat "$out1bar" | tr '\n\r' ' ' > "$TEST_log"
  expect_log "^tests/maprule/common.txt *tests/maprule/b/bar.txt *$"

  cat "$out2foo" | tr '\n\r' ' ' > "$TEST_log"
  expect_log "^common file *foo file *$"

  cat "$out2bar" | tr '\n\r' ' ' > "$TEST_log"
  expect_log "^common file *bar file *$"
}

run_suite "maprule test suite"
