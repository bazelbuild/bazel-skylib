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
# End to end tests for common_settings.bzl

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

function create_volcano_pkg() {
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

  ln -sf "$(rlocation bazel_skylib/rules/common_settings.bzl)" rules/common_settings.bzl

  mkdir -p volcano
  cat > volcano/rules.bzl <<EOF
load("//rules:common_settings.bzl", "BuildSettingInfo")

def _volcano_impl(ctx):
  description = struct(
    height = ctx.attr.height[BuildSettingInfo].value,
    active = ctx.attr.active[BuildSettingInfo].value,
    namer = ctx.attr.namer[BuildSettingInfo].value,
    nicknames = ctx.attr.nicknames[BuildSettingInfo].value
  )
  print(description)

volcano = rule(
  implementation = _volcano_impl,
  attrs = {
    "height" : attr.label(),
    "active" : attr.label(),
    "namer": attr.label(),
    "nicknames": attr.label(),
  }
)
EOF

  cat > volcano/BUILD <<EOF
load(
  "//rules:common_settings.bzl",
  "int_flag",
  "int_setting",
  "bool_flag",
  "string_flag",
  "string_list_flag",
)
load("//volcano:rules.bzl", "volcano")

int_flag(
  name = "height-flag",
  build_setting_default = 9677 # pre-1980 explosion
)

bool_flag(
  name = "active-flag",
  build_setting_default = True
)

string_flag(
  name = "namer-flag",
  build_setting_default = "cpt-george-vancouver",
  values = ["cpt-george-vancouver", "puyallup-tribe"]
)

string_list_flag(
  name = "nicknames-flag",
  build_setting_default = ["loowit", "loowitiatkla", "lavelatla"]
)

int_setting(
  name = "height-setting",
  build_setting_default = 9677
)

volcano(
  name = "mt-st-helens",
  height = ":height-flag",
  active = ":active-flag",
  namer = ":namer-flag",
  nicknames = ":nicknames-flag",
)
EOF

}

function test_can_set_flags() {
  local -r pkg="${FUNCNAME[0]}"
  create_volcano_pkg "$pkg"

  bazel build volcano:mt-st-helens --//volcano:height-flag=8366 \
    --//volcano:active-flag=False --//volcano:namer-flag=puyallup-tribe \
    --//volcano:nicknames-flag=volcano-mc-volcanoface \
    >"$TEST_log" 2>&1 || fail "Expected test to pass"

  expect_log "active = False"
  expect_log "height = 8366"
  expect_log "namer = \"puyallup-tribe\""
  expect_log "nicknames = \[\"volcano-mc-volcanoface\"\]"
}

function test_cannot_set_settings() {
  local -r pkg="${FUNCNAME[0]}"
  create_volcano_pkg "$pkg"

  bazel build volcano:mt-st-helens --//volcano:height-setting=8366 \
    >"$TEST_log" 2>&1 && fail "Expected test to fail" || true

  expect_log "Unrecognized option: //volcano:height-setting"
}

function test_not_allowed_value() {
  local -r pkg="${FUNCNAME[0]}"
  create_volcano_pkg "$pkg"

  bazel build volcano:mt-st-helens --//volcano:namer-flag=me \
    >"$TEST_log" 2>&1 && fail "Expected test to fail" || true

  expect_log "Error setting //volcano:namer-flag: invalid value 'me'. Allowed values are"
}


cd "$TEST_TMPDIR"
run_suite "common_settings test suite"
