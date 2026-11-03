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

"""Analysis tests for constraint declarations and platform matching."""

load("//lib:unittest.bzl", "analysistest", "asserts")
load("//rules:constraints.bzl", "constraint")

_MatchesInfo = provider("Constraint values matched by the target platform.", fields = ["values"])

def _platform_matches_impl(ctx):
    return [_MatchesInfo(values = [
        str(value.label)
        for value in ctx.attr.values
        if ctx.target_platform_has_constraint(value[platform_common.ConstraintValueInfo])
    ])]

_platform_matches = rule(
    implementation = _platform_matches_impl,
    attrs = {
        "values": attr.label_list(providers = [platform_common.ConstraintValueInfo]),
    },
)

def _platform_match_test_impl(ctx):
    env = analysistest.begin(ctx)
    actual = analysistest.target_under_test(env)[_MatchesInfo].values
    asserts.equals(env, [str(target.label) for target in ctx.attr.expected], actual)
    return analysistest.end(env)

_empty_platform_test = analysistest.make(
    _platform_match_test_impl,
    attrs = {"expected": attr.label_list()},
    config_settings = {"//command_line_option:platforms": "//tests:constraints_empty_platform"},
)

_network_platform_test = analysistest.make(
    _platform_match_test_impl,
    attrs = {"expected": attr.label_list()},
    config_settings = {"//command_line_option:platforms": "//tests:constraints_network_platform"},
)

_debug_platform_test = analysistest.make(
    _platform_match_test_impl,
    attrs = {"expected": attr.label_list()},
    config_settings = {"//command_line_option:platforms": "//tests:constraints_debug_platform"},
)

_optimized_platform_test = analysistest.make(
    _platform_match_test_impl,
    attrs = {"expected": attr.label_list()},
    config_settings = {"//command_line_option:platforms": "//tests:constraints_optimized_platform"},
)

_full_platform_test = analysistest.make(
    _platform_match_test_impl,
    attrs = {"expected": attr.label_list()},
    config_settings = {"//command_line_option:platforms": "//tests:constraints_full_platform"},
)

def constraints_test_suite(name = "constraints_test_suite"):
    """Tests opt-in capabilities, alternatives, and default values.

    Args:
        name: Name of the test suite.
    """
    constraint(
        name = "network_support",
        values = ["network"],
        tags = ["manual"],
        testonly = True,
        visibility = ["//visibility:public"],
    )
    constraint(
        name = "build_mode",
        values = ["debug", "optimized"],
    )
    constraint(
        name = "runtime",
        values = ["minimal", "full"],
        default = "minimal",
    )

    for fixture_name, values in {
        "empty": [],
        "network": [":network"],
        "debug": [":debug"],
        "optimized": [":optimized"],
        "full": [":full"],
    }.items():
        native.platform(
            name = "constraints_" + fixture_name + "_platform",
            constraint_values = values,
        )

    for fixture_name, values in {
        "capability": [":network"],
        "alternatives": [":debug", ":optimized"],
        "default": [":minimal", ":full"],
    }.items():
        _platform_matches(
            name = "constraints_" + fixture_name + "_probe",
            values = values,
            tags = ["manual"],
        )

    cases = [
        struct(name = "capability_absent", test = _empty_platform_test, probe = "capability", expected = []),
        struct(name = "capability_present", test = _network_platform_test, probe = "capability", expected = [":network"]),
        struct(name = "alternatives_absent", test = _empty_platform_test, probe = "alternatives", expected = []),
        struct(name = "debug_selected", test = _debug_platform_test, probe = "alternatives", expected = [":debug"]),
        struct(name = "optimized_selected", test = _optimized_platform_test, probe = "alternatives", expected = [":optimized"]),
        struct(name = "omitted_setting_uses_default", test = _empty_platform_test, probe = "default", expected = [":minimal"]),
        struct(name = "explicit_value_overrides_default", test = _full_platform_test, probe = "default", expected = [":full"]),
    ]
    for case in cases:
        case.test(
            name = "constraints_" + case.name + "_test",
            target_under_test = ":constraints_" + case.probe + "_probe",
            expected = case.expected,
        )

    native.test_suite(
        name = name,
        tests = [":constraints_" + case.name + "_test" for case in cases],
    )
