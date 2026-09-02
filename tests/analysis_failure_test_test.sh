#!/bin/bash

# Copyright 2025 The Bazel Authors. All rights reserved.
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
#
# End to end tests for analysis_failure_test.bzl.
#
# End to end tests of analysis_failure_test.bzl cover verification that
# analysis_failure_test tests succeed when their underlying test targets fail analysis with
# a given error message.

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

source "$(rlocation $TEST_WORKSPACE/tests/unittest.bash)" \
  || { echo "Could not source bazel_skylib/tests/unittest.bash" >&2; exit 1; }

function create_pkg() {
  local -r pkg="$1"
  mkdir -p "$pkg"
  cd "$pkg"

  cat > WORKSPACE <<EOF
workspace(name = 'bazel_skylib')
load("//lib:unittest.bzl", "register_unittest_toolchains")
register_unittest_toolchains()
EOF

  touch WORKSPACE.bzlmod
  cat > MODULE.bazel <<EOF
module(name="bazel_skylib_test", repo_name="bazel_skylib")
bazel_dep(name = "platforms", version = "0.0.10")
register_toolchains(
    "//toolchains/unittest:cmd_toolchain",
    "//toolchains/unittest:bash_toolchain",
)
EOF

  mkdir -p rules
  cat > rules/BUILD <<EOF
exports_files(["*.bzl"])
EOF
  ln -sf "$(rlocation $TEST_WORKSPACE/rules/analysis_failure_test.bzl)" rules/analysis_failure_test.bzl

  mkdir -p lib
  cat > lib/BUILD <<EOF
exports_files(["*.bzl"])
EOF
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/unittest.bzl)" lib/unittest.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/types.bzl)" lib/types.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/partial.bzl)" lib/partial.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/new_sets.bzl)" lib/new_sets.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/dicts.bzl)" lib/dicts.bzl

  mkdir -p toolchains/unittest
  # Remove `package(default_applicable_license = ...)` line to avoid depending on rules_license inside this test
  sed -e '/package(default_applicable_licenses = .*)/d' \
    "$(rlocation $TEST_WORKSPACE/toolchains/unittest/BUILD)" \
    > toolchains/unittest/BUILD

  mkdir -p fakerules
  cat > fakerules/rules.bzl <<EOF
load("//rules:analysis_failure_test.bzl", "analysis_failure_test")

def _fake_rule_impl(ctx):
    fail("This rule fails at analysis phase")

fake_rule = rule(
    implementation = _fake_rule_impl,
)

def _fake_depending_rule_impl(ctx):
    return []

fake_depending_rule = rule(
    implementation = _fake_depending_rule_impl,
    attrs = {"deps" : attr.label_list()},
)
EOF

  cat > fakerules/BUILD <<EOF
exports_files(["*.bzl"])
EOF

  mkdir -p testdir
  cat > testdir/BUILD <<EOF
load("//rules:analysis_failure_test.bzl", "analysis_failure_test")
load("//fakerules:rules.bzl", "fake_rule", "fake_depending_rule")

fake_rule(name = "target_fails")

fake_depending_rule(
    name = "dep_fails",
    deps = [":target_fails"],
)

fake_depending_rule(
    name = "rule_that_does_not_fail",
    deps = [],
)

analysis_failure_test(
    name = "direct_target_fails",
    target_under_test = ":target_fails",
    error_message = "This rule fails at analysis phase",
)

analysis_failure_test(
    name = "transitive_target_fails",
    target_under_test = ":dep_fails",
    error_message = "This rule fails at analysis phase",
)

analysis_failure_test(
    name = "fails_with_wrong_error_message",
    target_under_test = ":dep_fails",
    error_message = "This is the wrong error message",
)

analysis_failure_test(
    name = "fails_with_target_that_does_not_fail",
    target_under_test = ":rule_that_does_not_fail",
    error_message = "This rule fails at analysis phase",
)
EOF
}


function test_direct_target_succeeds() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:direct_target_fails >"$TEST_log" 2>&1 || fail "Expected test to pass"

  expect_log "PASSED"
}

function test_transitive_target_succeeds() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:transitive_target_fails  >"$TEST_log" 2>&1 || fail "Expected test to pass"

  expect_log "PASSED"
}

function test_with_wrong_error_message_fails() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:fails_with_wrong_error_message --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true

  expect_log "Expected errors to contain 'This is the wrong error message' but did not. Actual errors:"
}

function test_with_rule_that_does_not_fail_fails() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:fails_with_target_that_does_not_fail --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true

  expect_log "Expected failure of target_under_test, but found success"
}


cd "$TEST_TMPDIR"
run_suite "analysis_failure_test test suite"
