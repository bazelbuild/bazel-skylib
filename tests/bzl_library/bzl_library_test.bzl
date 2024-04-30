# Copyright 2024 The Bazel Authors. All rights reserved.
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

"""Unit tests for bzl_library"""

load("//:bzl_library.bzl", "StarlarkLibraryInfo")
load("//lib:sets.bzl", "sets")
load("//lib:unittest.bzl", "analysistest", "asserts")

def _assert_same_files(env, expected_file_targets, actual_files):
    """Assertion that a list of expected file targets and an actual list or depset of files contain the same files"""
    expected_files = []
    for target in expected_file_targets:
        target_files = target[DefaultInfo].files.to_list()
        asserts.true(env, len(target_files) == 1, "expected_file_targets must contain only file targets")
        expected_files.append(target_files[0])
    if type(actual_files) == "depset":
        actual_files = actual_files.to_list()
    asserts.set_equals(env = env, expected = sets.make(expected_files), actual = sets.make(actual_files))

def _bzl_library_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    _assert_same_files(env, ctx.attr.expected_srcs, target_under_test[StarlarkLibraryInfo].srcs)
    _assert_same_files(env, ctx.attr.expected_transitive_srcs, target_under_test[StarlarkLibraryInfo].transitive_srcs)
    _assert_same_files(env, ctx.attr.expected_transitive_srcs, target_under_test[DefaultInfo].files)
    return analysistest.end(env)

bzl_library_test = analysistest.make(
    impl = _bzl_library_test_impl,
    attrs = {
        "expected_srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "Expected direct srcs in target_under_test's providers",
        ),
        "expected_transitive_srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "Expected transitive srcs in target_under_test's providers",
        ),
    },
)
