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

  mkdir -p rules
  cat > rules/BUILD <<EOF
exports_files(["*.bzl"])
EOF

  mkdir -p lib
  cat > lib/BUILD <<EOF
exports_files(["*.bzl"])
EOF
  cat > lib/types.bzl <<EOF
_a_tuple_type = type(())

def _is_tuple(v):
    return type(v) == _a_tuple_type

types = struct(
    is_tuple = _is_tuple,
)
EOF

  ln -sf "$(rlocation $TEST_WORKSPACE/rules/analysis_test.bzl)" rules/analysis_test.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/unittest.bzl)" lib/unittest.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/new_sets.bzl)" lib/new_sets.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/partial.bzl)" lib/partial.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/types.bzl)" lib/types.bzl
  ln -sf "$(rlocation $TEST_WORKSPACE/lib/dicts.bzl)" lib/dicts.bzl

  mkdir -p toolchains/unittest
  ln -sf "$(rlocation $TEST_WORKSPACE/toolchains/unittest/BUILD)" toolchains/unittest/BUILD

  mkdir -p fakerules
  cat > fakerules/rules.bzl <<EOF
load("//rules:analysis_test.bzl", "analysis_test")
load("//lib:unittest.bzl", "analysistest")

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

############################################
####### inspect actions failure tests ######
############################################

def _inspect_actions_fake_rule(ctx):
    out1_file = ctx.actions.declare_file("out1.txt")
    ctx.actions.run_shell(
        command = "echo 'hello 1' > %s" % out1_file.basename,
        outputs = [out1_file],
        mnemonic = "MnemonicA",
    )
    out2_file = ctx.actions.declare_file("out2.txt")
    ctx.actions.run_shell(
        command = "echo 'hello 1' > %s" % out2_file.basename,
        outputs = [out2_file],
        mnemonic = "MnemonicA",
    )
    return [
        DefaultInfo(files = depset([out1_file, out2_file]))
    ]

inspect_actions_fake_rule = rule(
    implementation = _inspect_actions_fake_rule,
)

def _inspect_actions_no_mnemonic_test(ctx):
    env = analysistest.begin(ctx)
    # Should fail, no actions with MnemonicC
    mnemonic_c_actions = analysistest.target_action(
        env, mnemonic = "MnemonicC")
    return analysistest.end(env)

inspect_actions_no_mnemonic_test = analysistest.make(
    _inspect_actions_no_mnemonic_test,
)

def _inspect_actions_multiple_actions_with_mnemonic_test(ctx):
    env = analysistest.begin(ctx)
    # Should fail, multiple actions with same mnemonic
    output_foo_actions = analysistest.target_action(
        env, mnemonic = "MnemonicA")
    return analysistest.end(env)

inspect_actions_multiple_actions_with_mnemonic_test = analysistest.make(
    _inspect_actions_multiple_actions_with_mnemonic_test,
)

def _inspect_actions_no_output_test(ctx):
    env = analysistest.begin(ctx)
    # Should fail, no actions with output foo
    output_foo_actions = analysistest.target_action(
        env, output_ending_with = "foo")
    return analysistest.end(env)

inspect_actions_no_output_test = analysistest.make(
    _inspect_actions_no_output_test,
)

def _inspect_actions_no_filter_test(ctx):
    env = analysistest.begin(ctx)
    # Should fail, need filter
    output_foo_actions = analysistest.target_action(env)
    return analysistest.end(env)

inspect_actions_no_filter_test = analysistest.make(
    _inspect_actions_no_filter_test,
)

def _inspect_actions_too_many_filters_test(ctx):
    env = analysistest.begin(ctx)
    # Should fail, can't specify both mnemonic and output_ending_with
    output_foo_actions = analysistest.target_action(
        env, mnemonic = "MnemonicC", output_ending_with = "out1.txt")
    return analysistest.end(env)

inspect_actions_too_many_filters_test = analysistest.make(
    _inspect_actions_too_many_filters_test,
)

def action_inspection_failure_tests():
  inspect_actions_fake_rule(name = "inspect_actions_fake_rule")

  inspect_actions_no_mnemonic_test(
      name = "inspect_actions_no_mnemonic_test",
      target_under_test = "inspect_actions_fake_rule"
  )
  inspect_actions_no_output_test(
      name = "inspect_actions_no_output_test",
      target_under_test = "inspect_actions_fake_rule"
  )
  inspect_actions_multiple_actions_with_mnemonic_test(
      name = "inspect_actions_multiple_actions_with_mnemonic_test",
      target_under_test = "inspect_actions_fake_rule"
  )
  inspect_actions_no_filter_test(
      name = "inspect_actions_no_filter_test",
      target_under_test = "inspect_actions_fake_rule"
  )
  inspect_actions_too_many_filters_test(
      name = "inspect_actions_too_many_filters_test",
      target_under_test = "inspect_actions_fake_rule"
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
load("//fakerules:rules.bzl", "action_inspection_failure_tests")

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

action_inspection_failure_tests()
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

function test_inspect_actions_fails() {
  local -r pkg="${FUNCNAME[0]}"
  create_pkg "$pkg"

  bazel test testdir:inspect_actions_no_mnemonic_test --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true
  expect_log "No action with mnemonic 'MnemonicC' found."

  bazel test testdir:inspect_actions_multiple_actions_with_mnemonic_test --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true
  expect_log "Multiple actions with mnemonic 'MnemonicA' found."

  bazel test testdir:inspect_actions_no_output_test --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true
  expect_log "No action with an output ending with 'foo' found."

  bazel test testdir:inspect_actions_no_filter_test --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true
  expect_log "One of mnemonic or output_ending_with must be provided."

  bazel test testdir:inspect_actions_too_many_filters_test --test_output=all --verbose_failures \
      >"$TEST_log" 2>&1 && fail "Expected test to fail" || true
  expect_log "Only one of mnemonic or output_ending_with may be provided."
}

cd "$TEST_TMPDIR"
run_suite "analysis_test test suite"
