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

"""A test verifying other targets fail to be analyzed as part of a `bazel test`"""

load("//lib:unittest.bzl", "analysistest", "asserts")

def _analysis_failure_test_impl(ctx):
    """Implementation function for analysis_failure_test. """
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, expected_failure_msg = ctx.attr.error_message)
    return analysistest.end(env)

analysis_failure_test = analysistest.make(
    _analysis_failure_test_impl,
    expect_failure = True,
    attrs = {
        "error_message": attr.string(
            mandatory = True,
            doc = "The test asserts that the given string is contained in the error message of the target under test.",
        ),
    },
    doc = """A test that verifies another target fails during **analysis**.

    If the target under test does **not** fail analysis, the test **fails**.
    If `error_message` is not found in the error output, the test **fails**.
    Otherwise, the test **passes**.

    NOTE: Add the `manual` tag to the target under test to avoid failing `bazel test //...`.

    Typical usage:

    ```
    load("@bazel_skylib//rules:analysis_failure_test.bzl", "analysis_failure_test")

    rule_with_analysis_failure(
        name = "unit",
        tags = ["manual"],
    )


    analysis_failure_test(
        name = "analysis_fails_with_error",
        target_under_test = ":unit",
        error_message = _EXPECTED_ERROR_MESSAGE,
    )
    ```

    Args:
      target_under_test: Label of the target expected to fail during analysis (provided by `analysistest.make`).
      error_message: Substring that must appear in the error message.""",
)
