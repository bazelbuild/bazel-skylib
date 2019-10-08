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

"""Unit tests for unittest.bzl."""

load("//lib:unittest.bzl", "analysistest", "asserts", "unittest")

###################################
####### fail_basic_test ###########
###################################
def _basic_failing_test(ctx):
    """Unit tests for a basic library verification test that fails."""
    env = unittest.begin(ctx)

    asserts.equals(env, 1, 2)

    return unittest.end(env)

basic_failing_test = unittest.make(_basic_failing_test)

###################################
####### basic_passing_test ########
###################################
def _basic_passing_test(ctx):
    """Unit tests for a basic library verification test."""
    env = unittest.begin(ctx)

    asserts.equals(env, 1, 1)

    return unittest.end(env)

basic_passing_test = unittest.make(_basic_passing_test)

###################################
####### change_setting_test #######
###################################
def _change_setting_test(ctx):
    """Test to verify that an analysis test may change configuration."""
    env = analysistest.begin(ctx)

    dep_min_os_version = analysistest.target_under_test(env)[_ChangeSettingInfo].min_os_version
    asserts.equals(env, "1234.5678", dep_min_os_version)

    return analysistest.end(env)

_ChangeSettingInfo = provider()

def _change_setting_fake_rule(ctx):
    return [_ChangeSettingInfo(min_os_version = ctx.fragments.cpp.minimum_os_version())]

change_setting_fake_rule = rule(
    implementation = _change_setting_fake_rule,
    fragments = ["cpp"],
)

change_setting_test = analysistest.make(
    _change_setting_test,
    config_settings = {
        "//command_line_option:minimum_os_version": "1234.5678",
    },
)

####################################
####### failure_testing_test #######
####################################
def _failure_testing_test(ctx):
    """Test to verify that an analysis test may verify a rule fails with fail()."""
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "This rule should never work")

    return analysistest.end(env)

def _failure_testing_fake_rule(ctx):
    ignore = [ctx]
    fail("This rule should never work")

failure_testing_fake_rule = rule(
    implementation = _failure_testing_fake_rule,
)

failure_testing_test = analysistest.make(
    _failure_testing_test,
    expect_failure = True,
)

############################################
####### fail_unexpected_passing_test #######
############################################
def _fail_unexpected_passing_test(ctx):
    """Test that fails by expecting an error that never occurs."""
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "Oh no, going to fail")

    return analysistest.end(env)

def _fail_unexpected_passing_fake_rule(ctx):
    _ignore = [ctx]
    return []

fail_unexpected_passing_fake_rule = rule(
    implementation = _fail_unexpected_passing_fake_rule,
)

fail_unexpected_passing_test = analysistest.make(
    _fail_unexpected_passing_test,
    expect_failure = True,
)

################################################
####### change_setting_with_failure_test #######
################################################
def _change_setting_with_failure_test(ctx):
    """Test verifying failure while changing configuration."""
    env = analysistest.begin(ctx)

    asserts.expect_failure(env, "unexpected minimum_os_version!!!")

    return analysistest.end(env)

def _change_setting_with_failure_fake_rule(ctx):
    if ctx.fragments.cpp.minimum_os_version() == "error_error":
        fail("unexpected minimum_os_version!!!")
    return []

change_setting_with_failure_fake_rule = rule(
    implementation = _change_setting_with_failure_fake_rule,
    fragments = ["cpp"],
)

change_setting_with_failure_test = analysistest.make(
    _change_setting_with_failure_test,
    expect_failure = True,
    config_settings = {
        "//command_line_option:minimum_os_version": "error_error",
    },
)

####################################
####### inspect_actions_test #######
####################################
def _inspect_actions_test(ctx):
    """Test verifying actions registered by a target."""
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 1, len(actions))
    action_output = actions[0].outputs.to_list()[0]
    asserts.equals(env, "out.txt", action_output.basename)
    return analysistest.end(env)

def _inspect_actions_fake_rule(ctx):
    out_file = ctx.actions.declare_file("out.txt")
    ctx.actions.run_shell(
        command = "echo 'hello' > %s" % out_file.basename,
        outputs = [out_file],
    )
    return [DefaultInfo(files = depset([out_file]))]

inspect_actions_fake_rule = rule(
    implementation = _inspect_actions_fake_rule,
)

inspect_actions_test = analysistest.make(
    _inspect_actions_test,
)

########################################
####### inspect_output_dirs_test #######
########################################
_OutputDirInfo = provider(fields = ["bin_path", "genfiles_path"])

def _inspect_output_dirs_test(ctx):
    """Test verifying output directories used by a test."""
    env = analysistest.begin(ctx)

    # Assert that the output dirs observed by the aspect added by analysistest
    # are the same as those observed by the rule directly, even when that's
    # under a config transition and therefore not the same as the output
    # dirs used by the test rule.
    bin_path = analysistest.target_bin_dir_path(env)
    genfiles_path = analysistest.target_genfiles_dir_path(env)
    target_under_test = analysistest.target_under_test(env)
    asserts.false(env, not bin_path, "bin dir path not found.")
    asserts.false(env, not genfiles_path, "genfiles path not found.")
    asserts.false(
        env,
        bin_path == ctx.bin_dir.path,
        "bin dir path expected to differ between test and target_under_test.",
    )
    asserts.false(
        env,
        genfiles_path == ctx.genfiles_dir.path,
        "genfiles dir path expected to differ between test and target_under_test.",
    )
    asserts.equals(env, bin_path, target_under_test[_OutputDirInfo].bin_path)
    asserts.equals(
        env,
        genfiles_path,
        target_under_test[_OutputDirInfo].genfiles_path,
    )
    return analysistest.end(env)

def _inspect_output_dirs_fake_rule(ctx):
    return [
        _OutputDirInfo(
            bin_path = ctx.bin_dir.path,
            genfiles_path = ctx.genfiles_dir.path,
        ),
    ]

inspect_output_dirs_fake_rule = rule(
    implementation = _inspect_output_dirs_fake_rule,
)

inspect_output_dirs_test = analysistest.make(
    _inspect_output_dirs_test,
    # The output directories differ between the test and target under test when
    # the target under test is under a config transition.
    config_settings = {
        "//command_line_option:compilation_mode": "fastbuild",
    },
)

#########################################

def unittest_passing_tests_suite():
    """Creates the test targets and test suite for passing unittest.bzl tests.

    Not all tests are included. Some unittest.bzl tests verify a test fails
    when assertions are not met. Such tests must be run in an e2e shell test.
    This suite only includes tests which verify success tests.
    """
    unittest.suite(
        "unittest_tests",
        basic_passing_test,
    )

    change_setting_test(
        name = "change_setting_test",
        target_under_test = ":change_setting_fake_target",
    )
    change_setting_fake_rule(
        name = "change_setting_fake_target",
        tags = ["manual"],
    )

    failure_testing_test(
        name = "failure_testing_test",
        target_under_test = ":failure_testing_fake_target",
    )
    failure_testing_fake_rule(
        name = "failure_testing_fake_target",
        tags = ["manual"],
    )

    change_setting_with_failure_test(
        name = "change_setting_with_failure_test",
        target_under_test = ":change_setting_with_failure_fake_target",
    )
    change_setting_with_failure_fake_rule(
        name = "change_setting_with_failure_fake_target",
        tags = ["manual"],
    )

    inspect_actions_test(
        name = "inspect_actions_test",
        target_under_test = ":inspect_actions_fake_target",
    )
    inspect_actions_fake_rule(
        name = "inspect_actions_fake_target",
        tags = ["manual"],
    )

    inspect_output_dirs_test(
        name = "inspect_output_dirs_test",
        target_under_test = ":inspect_output_dirs_fake_target",
    )
    inspect_output_dirs_fake_rule(
        name = "inspect_output_dirs_fake_target",
        tags = ["manual"],
    )
