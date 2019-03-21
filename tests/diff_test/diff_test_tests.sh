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

function test_diff_test() {
  local -r ws="${TEST_TMPDIR}/${FUNCNAME[0]}"

  mkdir -p "$ws/rules"
  ln -sf "$(rlocation bazel_skylib/rules/diff_test.bzl)" "$ws/rules/diff_test.bzl"
  echo "exports_files(['diff_test.bzl'])" > "$ws/rules/BUILD"
  touch "$ws/WORKSPACE"
  cat >"$ws/BUILD" <<'eof'
load("//rules:diff_test.bzl", "diff_test")

diff_test(
    name = "same",
    file1 = "a.txt",
    file2 = "a.txt",
)

diff_test(
    name = "different",
    file1 = "a.txt",
    file2 = "b.txt",
)
eof
  echo foo > "$ws/a.txt"
  echo bar > "$ws/b.txt"

  (cd "$ws" && \
   bazel test //:same --test_output=errors 1>"$TEST_log" 2>&1 \
     || fail "expected success")

  (cd "$ws" && \
   bazel test //:different --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log 'FAIL: files "a.txt" and "b.txt" differ'
}

function test_from_ext_repo() {
  local -r ws="${TEST_TMPDIR}/${FUNCNAME[0]}"

  mkdir -p "$ws/rules" "$ws/ext1/foo" "$ws/ext2/foo" 
  ln -sf "$(rlocation bazel_skylib/rules/diff_test.bzl)" "$ws/rules/diff_test.bzl"
  echo "exports_files(['diff_test.bzl'])" > "$ws/rules/BUILD"
  cat >"$ws/WORKSPACE" <<'eof'
local_repository(
    name = "ext1",
    path = "ext1",
)

local_repository(
    name = "ext2",
    path = "ext2",
)
eof

  # ext1 has source files
  touch "$ws/ext1/WORKSPACE"
  echo 'exports_files(["foo.txt"])' >"$ws/ext1/foo/BUILD"
  echo 'foo' > "$ws/ext1/foo/foo.txt"

  # ext2 has generated files
  touch "$ws/ext2/WORKSPACE"
  cat >"$ws/ext2/foo/BUILD" <<'eof'
genrule(
    name = "gen",
    outs = [
        "foo.txt",
        "bar.txt",
    ],
    cmd = "echo 'foo' > $(location foo.txt) && echo 'bar' > $(location bar.txt)",
    visibility = ["//visibility:public"],
)
eof

  cat >"$ws/BUILD" <<'eof'
load("//rules:diff_test.bzl", "diff_test")

diff_test(
    name = "same",
    file1 = "@ext1//foo:foo.txt",
    file2 = "@ext2//foo:foo.txt",
)

diff_test(
    name = "different",
    file1 = "@ext1//foo:foo.txt",
    file2 = "@ext2//foo:bar.txt",
)
eof

  (cd "$ws" && \
   bazel test //:same --test_output=errors 1>"$TEST_log" 2>&1 \
     || fail "expected success")

  (cd "$ws" && \
   bazel test //:different --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log 'FAIL: files "external/ext1/foo/foo.txt" and "external/ext2/foo/bar.txt" differ'
}

run_suite "diff_test_tests test suite"
