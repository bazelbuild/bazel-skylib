# Copyright 2026 The Bazel Authors. All rights reserved.
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

"""Analysis tests for reapply_platform_flags.bzl."""

load("//lib:unittest.bzl", "analysistest", "asserts")
load("//rules:common_settings.bzl", "BuildSettingInfo", "string_flag")
load("//rules:reapply_platform_flags.bzl", "reapply_platform_flags")

_FLAG = str(Label(":flag"))
_PLATFORM_WITH_FLAG = Label(":platform_with_flag")

_FlagInfo = provider(
    doc = "The value of :flag and the target platform in a configuration.",
    fields = ["value", "platform"],
)

def _flag_reader_impl(ctx):
    return [_FlagInfo(
        value = ctx.attr._flag[BuildSettingInfo].value,
        platform = ctx.fragments.platform.platform,
    )]

_flag_reader = rule(
    implementation = _flag_reader_impl,
    attrs = {
        "_flag": attr.label(default = _FLAG),
    },
    fragments = ["platform"],
)

def _set_flag_impl(_settings, _attr):
    return {_FLAG: "from_transition"}

_set_flag = transition(
    implementation = _set_flag_impl,
    inputs = [],
    outputs = [_FLAG],
)

def _forward_impl(ctx):
    # Attributes with Starlark transitions are lists.
    return [ctx.attr.dep[0][_FlagInfo]]

# The flag set by this rule's transition may override the one set by the target platform. The
# dependency edge applies the flags of the target platform again.
_set_flag_with_reapplied_dep = rule(
    implementation = _forward_impl,
    cfg = _set_flag,
    attrs = {
        "dep": attr.label(cfg = reapply_platform_flags),
    },
)

def _reapply_platform_flags_test_impl(ctx):
    env = analysistest.begin(ctx)
    info = analysistest.target_under_test(env)[_FlagInfo]
    asserts.equals(env, "from_platform", info.value)
    asserts.equals(env, _PLATFORM_WITH_FLAG, info.platform)
    return analysistest.end(env)

_reapply_platform_flags_test = analysistest.make(
    _reapply_platform_flags_test_impl,
    config_settings = {
        "//command_line_option:platforms": str(_PLATFORM_WITH_FLAG),
    },
)

def _noop_test_impl(ctx):
    env = analysistest.begin(ctx)
    info = analysistest.target_under_test(env)[_FlagInfo]
    asserts.equals(env, "from_transition", info.value)
    return analysistest.end(env)

_noop_test = analysistest.make(_noop_test_impl)

def reapply_platform_flags_test_suite(name):
    """Creates the test targets and test suite for reapply_platform_flags.bzl.

    Args:
        name: the name of the test suite
    """
    string_flag(
        name = "flag",
        build_setting_default = "default",
    )

    _flag_reader(
        name = "flag_reader",
    )

    _set_flag_with_reapplied_dep(
        name = "set_flag_with_reapplied_dep",
        dep = ":flag_reader",
    )

    # Bazel versions without transition.and_then apply the flags of the target platform after every
    # transition and may not support platform flags at all.
    if hasattr(reapply_platform_flags, "and_then"):
        native.platform(
            name = "platform_with_flag",
            flags = ["--{}=from_platform".format(_FLAG)],
        )

        _reapply_platform_flags_test(
            name = "reapply_platform_flags_test",
            target_under_test = ":set_flag_with_reapplied_dep",
        )
    else:
        _noop_test(
            name = "reapply_platform_flags_test",
            target_under_test = ":set_flag_with_reapplied_dep",
        )

    native.test_suite(
        name = name,
        tests = [":reapply_platform_flags_test"],
    )
