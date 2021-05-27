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

"""Unit tests for analysis_failure_test.bzl."""

load("//rules:analysis_failure_test.bzl", "analysis_failure_test")

_EXPECTED_ERROR_MESSAGE = "The error message to assert!"

def _dummy_rule_impl(ctx):
    if ctx.attr.asserted_input != 0:
        fail(_EXPECTED_ERROR_MESSAGE)

dummy_rule = rule(
    implementation = _dummy_rule_impl,
    attrs = {
        "asserted_input": attr.int(),
    },
    doc = "This rule acts as a dummy case to ensure that analysis_failure_test works as expected",
)

# buildifier: disable=unnamed-macro
def analysis_failure_test_test_suite():
    dummy_rule(
        name = "unit",
        asserted_input = 42,
        tags = ["manual"],
    )

    analysis_failure_test(
        name = "unit_fails_to_analyse",
        target_under_test = ":unit",
        error_message = _EXPECTED_ERROR_MESSAGE,
    )
