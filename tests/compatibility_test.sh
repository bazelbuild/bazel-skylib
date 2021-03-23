#!/bin/bash
#
# Copyright 2021 The Bazel Authors. All rights reserved.
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
# Test building targets that are declared as compatible only with certain
# platforms (see the "target_compatible_with" common build rule attribute).

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

function set_up() {
  mkdir -p target_skipping || fail "couldn't create directory"
  cat > target_skipping/pass.sh <<EOF || fail "couldn't create pass.sh"
#!/bin/bash
exit 0
EOF
  chmod +x target_skipping/pass.sh

  cat > target_skipping/fail.sh <<EOF|| fail "couldn't create fail.sh"
#!/bin/bash
exit 1
EOF
  chmod +x target_skipping/fail.sh

# Platforms
default_host_platform="@local_config_platform//:host"

  cat > WORKSPACE <<EOF
workspace(name = 'bazel_skylib')

load("//lib:unittest.bzl", "register_unittest_toolchains")

register_unittest_toolchains()
EOF

  mkdir -p lib
  cat > lib/BUILD <<EOF
exports_files(["*.bzl"])
EOF

  cat > target_skipping/BUILD <<EOF || fail "couldn't create BUILD file"
# We're not validating visibility here. Let everything access these targets.
package(default_visibility = ["//visibility:public"])

constraint_setting(name = "not_compatible_setting")

constraint_setting(name = "foo_version")

constraint_value(
    name = "foo1",
    constraint_setting = ":foo_version",
)

constraint_value(
    name = "foo2",
    constraint_setting = ":foo_version",
)

constraint_value(
    name = "foo3",
    constraint_setting = ":foo_version",
)

constraint_setting(name = "bar_version")

constraint_value(
    name = "bar1",
    constraint_setting = "bar_version",
)

constraint_value(
    name = "bar2",
    constraint_setting = "bar_version",
)

platform(
    name = "foo1_bar1_platform",
    parents = ["${default_host_platform}"],
    constraint_values = [
        ":foo1",
        ":bar1",
    ],
)

platform(
    name = "foo2_bar1_platform",
    parents = ["${default_host_platform}"],
    constraint_values = [
        ":foo2",
        ":bar1",
    ],
)

platform(
    name = "foo1_bar2_platform",
    parents = ["${default_host_platform}"],
    constraint_values = [
        ":foo1",
        ":bar2",
    ],
)

platform(
    name = "foo3_platform",
    parents = ["${default_host_platform}"],
    constraint_values = [
        ":foo3",
    ],
)

sh_test(
    name = "pass_on_foo1",
    srcs = ["pass.sh"],
    target_compatible_with = [":foo1"],
)

sh_test(
    name = "fail_on_foo2",
    srcs = ["fail.sh"],
    target_compatible_with = [":foo2"],
)

sh_test(
    name = "pass_on_foo1_bar2",
    srcs = ["pass.sh"],
    target_compatible_with = [
        ":foo1",
        ":bar2",
    ],
)

sh_binary(
    name = "some_foo3_target",
    srcs = ["pass.sh"],
    target_compatible_with = [
        ":foo3",
    ],
)
EOF
}

function tear_down() {
  bazel shutdown
}

# Validates that we can express targets being compatible with A _or_ B.
function test_or_logic() {
  cat >> target_skipping/BUILD <<EOF
load("//lib:compatibility.bzl", "compatibility")

sh_test(
    name = "pass_on_foo1_or_foo2_but_not_on_foo3",
    srcs = [":pass.sh"],
    target_compatible_with = compatibility.any_of(
	(":foo1", ":foo2")
    ),
)
EOF

  cd target_skipping || fail "couldn't cd into workspace"

  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo1_bar1_platform \
    --platforms=@//target_skipping:foo1_bar1_platform \
    --nocache_test_results \
    //target_skipping:pass_on_foo1_or_foo2_but_not_on_foo3 &> "${TEST_log}" \
    || fail "Bazel failed unexpectedly."
  expect_log '^//target_skipping:pass_on_foo1_or_foo2_but_not_on_foo3  *  PASSED in'

  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo2_bar1_platform \
    --platforms=@//target_skipping:foo2_bar1_platform \
    --nocache_test_results \
    //target_skipping:pass_on_foo1_or_foo2_but_not_on_foo3 &> "${TEST_log}" \
    || fail "Bazel failed unexpectedly."
  expect_log '^//target_skipping:pass_on_foo1_or_foo2_but_not_on_foo3  *  PASSED in'

  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo3_platform \
    --platforms=@//target_skipping:foo3_platform \
    //target_skipping:pass_on_foo1_or_foo2_but_not_on_foo3 &> "${TEST_log}" \
    && fail "Bazel passed unexpectedly."

  expect_log 'ERROR: Target //target_skipping:pass_on_foo1_or_foo2_but_not_on_foo3 is incompatible and cannot be built, but was explicitly requested'
  expect_log 'FAILED: Build did NOT complete successfully'
}

# Validates that we can express targets being compatible with everything _but_
# A and B.
function test_inverse_logic() {

  cat >> target_skipping/BUILD <<EOF
load("//lib:compatibility.bzl", "compatibility")

sh_test(
    name = "pass_on_everything_but_foo1_and_foo2",
    srcs = [":pass.sh"],
    target_compatible_with = compatibility.none_of(
	(":foo1", ":foo2")),
)
EOF

  cd target_skipping || fail "couldn't cd into workspace"

  # Try with :foo1. This should fail.
  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo1_bar1_platform \
    --platforms=@//target_skipping:foo1_bar1_platform \
    //target_skipping:pass_on_everything_but_foo1_and_foo2  &> "${TEST_log}" \
    && fail "Bazel passed unexpectedly."
  expect_log 'ERROR: Target //target_skipping:pass_on_everything_but_foo1_and_foo2 is incompatible and cannot be built, but was explicitly requested'
  expect_log 'FAILED: Build did NOT complete successfully'

  # Try with :foo2. This should fail.
  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo2_bar1_platform \
    --platforms=@//target_skipping:foo2_bar1_platform \
    //target_skipping:pass_on_everything_but_foo1_and_foo2 &> "${TEST_log}" \
    && fail "Bazel passed unexpectedly."
  expect_log 'ERROR: Target //target_skipping:pass_on_everything_but_foo1_and_foo2 is incompatible and cannot be built, but was explicitly requested'
  expect_log 'FAILED: Build did NOT complete successfully'

  # Now with :foo3. This should pass.
  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo3_platform \
    --platforms=@//target_skipping:foo3_platform \
    --nocache_test_results \
    //target_skipping:pass_on_everything_but_foo1_and_foo2 &> "${TEST_log}" \
    || fail "Bazel failed unexpectedly."
  expect_log '^//target_skipping:pass_on_everything_but_foo1_and_foo2  *  PASSED in'
}

# Validates that we can express targets being compatible with _only_ A and B,
# and nothing else.
function test_all_of_logic() {

  cat >> target_skipping/BUILD <<EOF
load("//lib:compatibility.bzl", "compatibility")

sh_test(
    name = "pass_on_only_foo1_and_bar1",
    srcs = [":pass.sh"],
    target_compatible_with = compatibility.all_of(
	[":foo1", ":bar1"]),
)
EOF

  cd target_skipping || fail "couldn't cd into workspace"

  # Try with :foo1. This should fail.
  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo1_bar1_platform \
    --platforms=@//target_skipping:foo1_bar1_platform \
    //target_skipping:pass_on_only_foo1_and_bar1  &> "${TEST_log}" \
    && fail "Bazel passed unexpectedly."
  expect_log 'ERROR: Target //target_skipping:pass_on_only_foo1_and_bar1 is incompatible and cannot be built, but was explicitly requested'
  expect_log 'FAILED: Build did NOT complete successfully'

  # Try with :foo2. This should fail.
  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo2_bar1_platform \
    --platforms=@//target_skipping:foo2_bar1_platform \
    //target_skipping:pass_on_only_foo1_and_bar1  &> "${TEST_log}" \
    && fail "Bazel passed unexpectedly."
  expect_log 'ERROR: Target //target_skipping:pass_on_only_foo1_and_bar1 is incompatible and cannot be built, but was explicitly requested'
  expect_log 'FAILED: Build did NOT complete successfully'

  # Now with :foo3. This should pass.
  bazel test \
    --show_result=10 \
    --host_platform=@//target_skipping:foo3_platform \
    --platforms=@//target_skipping:foo3_platform \
    --nocache_test_results \
    //target_skipping:pass_on_only_foo1_and_bar1  &> "${TEST_log}" \
    || fail "Bazel failed unexpectedly."
  expect_log '^//target_skipping:pass_on_only_foo1_and_bar1  *  PASSED in'
}

run_suite "compatibility tests"
