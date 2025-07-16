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

"""A test verifying that another target fails to analyse as part of a `bazel test`

This analysistest is mostly aimed at rule authors that want to assert certain error conditions.
If the target under test does not fail the analysis phase, the test will evaluate to FAILED.
If the given error_message is not contained in the otherwise printed ERROR message, the test evaluates to FAILED.
If the given error_message is contained in the otherwise printed ERROR message, the test evaluates to PASSED.

NOTE:
Adding the `manual` tag  to the target-under-test is recommended.
It prevents analysis failure of that target if `bazel test //...` is used.

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
  target_under_test: The target that is expected to cause an anlysis failure
  error_message: The asserted error message in the (normally printed) ERROR."""

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
)
