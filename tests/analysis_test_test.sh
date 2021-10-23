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
#
# End to end tests for analysis_test.bzl.
#
# End to end tests of analysis_test.bzl cover verification that
# analysis_test tests fail when their underlying test targets fail analysis.

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

function create_pkg() {
  local -r pkg="$1"
  mkdir -p "$pkg"
  cd "$pkg"

  cat > WORKSPACE <<EOF
workspace(name = 'bazel_skylib')
EOF

  mkdir -p rules
  cat > rules/BUILD <<EOF
exports_files(["*.bzl"])
EOF

  ln -sf "$(rlocation bazel_skylib/rules/analysis_test.bzl)" rules/analysis_test.bzl

  mkdir -p fakerules
  cat > fakerules/rules.bzl <<EOF
load("//rules:analysis_test.bzl", "analysis_test")

def _fake_rule_impl(ctx):
    fail("This rule should never work")

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
  cat > testdir/dummy.cc <<EOF
int dummy() { return 0; }
EOF

  cat > testdir/BUILD <<EOF
load("//rules:analysis_test.bzl", "analysis_test")
load("//fakerules:rules.bzl", "fake_rule", "fake_depending_rule")

fake_rule(name = "target_fails")

fake_depending_rule(name = "dep_fails",
    deps = [":target_fails"])

analysis_test(
    name = "direct_target_fails",
    targets = [":target_fails"],
)

analysis_test(
    name = "transitive_target_fails",
    targets = [":dep_fails"],
)

# Use it in a non-test target
cc_library(
    name = "dummy_cc_library",
    srcs = ["dummy.cc"],
)

analysis_test(
    name = "target_succeeds",
    targets = [":dummy_cc_library"],
)
EOF
}

function test_target_succeeds() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:target_succeeds >"$TEST_log" 2>&1 || fail "Expected test to pass"

  expect_log "PASSED"
}

function test_direct_target_fails() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:direct_target_fails --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true

  expect_log "This rule should never work"
}

function test_transitive_target_fails() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:transitive_target_fails --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true

  expect_log "This rule should never work"
}

cd "$TEST_TMPDIR"
run_suite "analysis_test test suite"
