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

function import_diff_test() {
  local -r repo="$1"
  mkdir -p "${repo}/rules"
  mkdir -p "${repo}/lib"
  touch "${repo}/lib/BUILD"
  touch "${repo}/WORKSPACE"
  ln -sf "$(rlocation $TEST_WORKSPACE/rules/diff_test.bzl)" \
         "${repo}/rules/diff_test.bzl"
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/shell.bzl)" \
         "${repo}/lib/shell.bzl"
  echo "exports_files(['diff_test.bzl'])" > "${repo}/rules/BUILD"
}

function assert_simple_diff_test() {
  local -r flags="$1"
  local -r ws="${TEST_TMPDIR}/$2"
  local -r subdir="$3"

  import_diff_test "$ws"
  touch "$ws/WORKSPACE"
  cat >"$ws/MODULE.bazel" <<'eof'
bazel_dep(name = "platforms", version = "0.0.10")
eof
  mkdir -p "$ws/$subdir"
  cat >"$ws/${subdir}BUILD" <<'eof'
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
  echo foo > "$ws/$subdir/a.txt"
  echo bar > "$ws/$subdir/b.txt"

  (cd "$ws" && \
   bazel test ${flags} "//${subdir%/}:same" --test_output=errors 1>"$TEST_log" 2>&1 \
     || fail "expected success")

  (cd "$ws" && \
   bazel test ${flags} "//${subdir%/}:different" --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log "FAIL: files \"${subdir}a.txt\" and \"${subdir}b.txt\" differ"
}

function assert_from_ext_repo() {
  local -r flags="$1"
  local -r ws="${TEST_TMPDIR}/$2"

  # Import the rule to an external repository.
  import_diff_test "$ws/bzl"
  mkdir -p "$ws/ext1/foo" "$ws/main/ext1/foo" "$ws/ext2/foo" "$ws/main/ext2/foo"
  cat >"$ws/main/WORKSPACE" <<'eof'
local_repository(
    name = "bzl",
    path = "../bzl",
)

local_repository(
    name = "ext1",
    path = "../ext1",
)

local_repository(
    name = "ext2",
    path = "../ext2",
)
eof
  cat >"$ws/main/MODULE.bazel" <<'eof'
bazel_dep(name = "platforms", version = "0.0.10")
local_repository = use_repo_rule("@bazel_tools//tools/build_defs/repo:local.bzl", "local_repository")
local_repository(
    name = "bzl",
    path = "../bzl",
)
local_repository(
    name = "ext1",
    path = "../ext1",
)
local_repository(
    name = "ext2",
    path = "../ext2",
)
eof
  # @ext1 has source files
  touch "$ws/ext1/WORKSPACE"
  echo 'exports_files(["foo.txt"])' >"$ws/ext1/foo/BUILD"
  echo 'foo' > "$ws/ext1/foo/foo.txt"

  # @//ext1/foo has different files than @ext1//foo
  echo 'exports_files(["foo.txt"])' >"$ws/main/ext1/foo/BUILD"
  echo 'not foo' > "$ws/main/ext1/foo/foo.txt"

  # @ext2 has generated files
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

  # @//ext2/foo has different files than @ext2//foo
  cat >"$ws/main/ext2/foo/BUILD" <<'eof'
genrule(
    name = "gen",
    outs = ["foo.txt"],
    cmd = "echo 'not foo' > $@",
    visibility = ["//visibility:public"],
)
eof

  cat >"$ws/main/BUILD" <<'eof'
load("@bzl//rules:diff_test.bzl", "diff_test")

diff_test(
    name = "same",
    file1 = "@ext1//foo:foo.txt",
    file2 = "@ext2//foo:foo.txt",
)

diff_test(
    name = "different1",
    file1 = "@ext1//foo:foo.txt",
    file2 = "@ext2//foo:bar.txt",
)

diff_test(
    name = "different2",
    file1 = "@ext1//foo:foo.txt",
    file2 = "//ext1/foo:foo.txt",
)

diff_test(
    name = "different3",
    file1 = "//ext2/foo:foo.txt",
    file2 = "@ext2//foo:foo.txt",
)
eof

  (cd "$ws/main" && \
   bazel test ${flags} //:same --test_output=errors 1>"$TEST_log" 2>&1 \
     || fail "expected success")

  (cd "$ws/main" && \
   bazel test ${flags} //:different1 --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log 'FAIL: files "external/.*ext1/foo/foo.txt" and "external/.*ext2/foo/bar.txt" differ'

  (cd "$ws/main" && \
   bazel test ${flags} //:different2 --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log 'FAIL: files "external/.*ext1/foo/foo.txt" and "ext1/foo/foo.txt" differ'

  (cd "$ws/main" && \
   bazel test ${flags} //:different3 --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log 'FAIL: files "ext2/foo/foo.txt" and "external/.*ext2/foo/foo.txt" differ'
}

function test_simple_diff_test_with_legacy_external_runfiles() {
  assert_simple_diff_test "--enable_runfiles --legacy_external_runfiles" "${FUNCNAME[0]}" ""
}

function test_simple_diff_test_without_legacy_external_runfiles() {
  assert_simple_diff_test "--enable_runfiles --nolegacy_external_runfiles" "${FUNCNAME[0]}" ""
}

function test_simple_diff_test_with_manifest() {
  assert_simple_diff_test "--noenable_runfiles" "${FUNCNAME[0]}" ""
}

function test_directory_named_external_with_legacy_external_runfiles() {
  assert_simple_diff_test "--enable_runfiles --legacy_external_runfiles" "${FUNCNAME[0]}" "path/to/directory/external/in/name/"
}

function test_directory_named_external_without_legacy_external_runfiles() {
  assert_simple_diff_test "--enable_runfiles --nolegacy_external_runfiles" "${FUNCNAME[0]}" "path/to/directory/external/in/name/"
}

function test_directory_named_external_with_manifest() {
  assert_simple_diff_test "--noenable_runfiles" "${FUNCNAME[0]}" "path/to/directory/external/in/name/"
}

function test_from_ext_repo_with_legacy_external_runfiles() {
  assert_from_ext_repo "--enable_runfiles --legacy_external_runfiles" "${FUNCNAME[0]}"
}

function test_from_ext_repo_without_legacy_external_runfiles() {
  assert_from_ext_repo "--enable_runfiles --nolegacy_external_runfiles" "${FUNCNAME[0]}"
}

function test_from_ext_repo_with_manifest() {
  assert_from_ext_repo "--noenable_runfiles" "${FUNCNAME[0]}"
}

function test_failure_message() {
  local -r ws="${TEST_TMPDIR}/${FUNCNAME[0]}"

  import_diff_test "$ws"
  touch "$ws/WORKSPACE"
  cat >"$ws/MODULE.bazel" <<'eof'
bazel_dep(name = "platforms", version = "0.0.10")
eof
  cat >"$ws/BUILD" <<'eof'
load("//rules:diff_test.bzl", "diff_test")

diff_test(
    name = "different_with_message",
    failure_message = "This is an `$error`",  # TODO(arostovtsev): also test Windows cmd.exe escapes when https://github.com/bazelbuild/bazel-skylib/pull/363 is merged
    file1 = "a.txt",
    file2 = "b.txt",
)

diff_test(
    name = "different_without_message",
    file1 = "c.txt",
    file2 = "d.txt",
)
eof
  echo foo > "$ws/a.txt"
  echo bar > "$ws/b.txt"
  echo foo > "$ws/c.txt"
  echo bar > "$ws/d.txt"

  (cd "$ws" && \
   bazel test //:different_with_message --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  # TODO(arostovtsev): also test Windows cmd.exe escapes when https://github.com/bazelbuild/bazel-skylib/pull/363 is merged
  expect_log "FAIL: files \"a.txt\" and \"b.txt\" differ. This is an \`\$error\`"

  (cd "$ws" && \
   bazel test //:different_without_message --test_output=errors 1>"$TEST_log" 2>&1 \
     && fail "expected failure" || true)
  expect_log "FAIL: files \"c.txt\" and \"d.txt\" differ. $"
}

cd "$TEST_TMPDIR"
run_suite "diff_test_tests test suite"
