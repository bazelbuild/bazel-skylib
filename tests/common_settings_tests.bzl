# Copyright 2023 The Bazel Authors. All rights reserved.
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

"""Analysis tests for common_settings.bzl."""

load("//lib:unittest.bzl", "analysistest", "asserts")
load("//rules:common_settings.bzl", "int_flag", "int_setting", "string_flag", "string_setting")

def _template_variable_info_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    if ctx.attr.expected:
        asserts.equals(
            env,
            expected = ctx.attr.expected,
            actual = target_under_test[platform_common.TemplateVariableInfo].variables,
        )
    else:
        asserts.false(env, platform_common.TemplateVariableInfo in target_under_test)

    return analysistest.end(env)

_template_variable_info_contents_test = analysistest.make(
    _template_variable_info_contents_test_impl,
    attrs = {
        "expected": attr.string_dict(),
    },
)

def _test_template_variable_info_contents():
    int_flag(
        name = "my_int_flag",
        build_setting_default = 42,
        make_variable = "MY_INT_1",
    )

    _template_variable_info_contents_test(
        name = "my_int_flag_test",
        target_under_test = ":my_int_flag",
        expected = {
            "MY_INT_1": "42",
        },
    )

    int_setting(
        name = "my_int_setting",
        build_setting_default = 21,
        make_variable = "MY_INT_2",
    )

    _template_variable_info_contents_test(
        name = "my_int_setting_test",
        target_under_test = ":my_int_setting",
        expected = {
            "MY_INT_2": "21",
        },
    )

    string_flag(
        name = "my_string_flag",
        build_setting_default = "foo",
        make_variable = "MY_STRING_1",
    )

    _template_variable_info_contents_test(
        name = "my_string_flag_test",
        target_under_test = ":my_string_flag",
        expected = {
            "MY_STRING_1": "foo",
        },
    )

    string_setting(
        name = "my_string_setting",
        build_setting_default = "bar",
        make_variable = "MY_STRING_2",
    )

    _template_variable_info_contents_test(
        name = "my_string_setting_test",
        target_under_test = ":my_string_setting",
        expected = {
            "MY_STRING_2": "bar",
        },
    )

    string_flag(
        name = "my_string_flag_without_make_variable",
        build_setting_default = "foo",
    )

    _template_variable_info_contents_test(
        name = "my_string_flag_without_make_variable_test",
        target_under_test = ":my_string_flag_without_make_variable",
        expected = {},
    )

def _failure_test_impl(ctx):
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, ctx.attr.expected_failure)

    return analysistest.end(env)

_failure_test = analysistest.make(
    _failure_test_impl,
    attrs = {
        "expected_failure": attr.string(),
    },
    expect_failure = True,
)

def _test_make_variable_name_failures():
    int_flag(
        name = "my_failing_int_flag",
        build_setting_default = 42,
        make_variable = "my_int_1",
        tags = ["manual"],
    )

    _failure_test(
        name = "my_failing_int_flag_test",
        target_under_test = ":my_failing_int_flag",
        expected_failure = "Error setting //tests:my_failing_int_flag: invalid make variable name 'my_int_1'. Make variable names may only contain uppercase letters, digits, and underscores.",
    )

    string_flag(
        name = "my_failing_string_flag",
        build_setting_default = "foo",
        make_variable = "MY STRING",
        tags = ["manual"],
    )

    _failure_test(
        name = "my_failing_string_flag_test",
        target_under_test = ":my_failing_string_flag",
        expected_failure = "Error setting //tests:my_failing_string_flag: invalid make variable name 'MY STRING'. Make variable names may only contain uppercase letters, digits, and underscores.",
    )

def common_settings_test_suite(name = "common_settings_test_suite"):
    _test_template_variable_info_contents()
    _test_make_variable_name_failures()

    native.test_suite(
        name = "common_settings_test_suite",
        tests = [
            "my_int_flag_test",
            "my_int_setting_test",
            "my_string_flag_test",
            "my_string_setting_test",
            "my_string_flag_without_make_variable_test",
            "my_failing_int_flag_test",
            "my_failing_string_flag_test",
        ],
    )
