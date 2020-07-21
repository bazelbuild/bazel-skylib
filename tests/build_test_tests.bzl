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

"""Unit tests for build_test.bzl."""

load("//rules:build_test.bzl", "build_test")
load("@rules_cc//cc:defs.bzl", "cc_library")

# buildifier: disable=unnamed-macro
def build_test_test_suite():
    # Since the rules doesn't do anything really, it just makes some targets
    # to get Bazel to build other targets via a `bazel test`, just make some
    # targets to exercise the rule.

    # Make a source file
    native.genrule(
        name = "build_test__make_src",
        outs = ["build_test__src.cc"],
        cmd = "echo 'int dummy() { return 0; }' > $@",
    )

    # Use it in a non-test target
    cc_library(
        name = "build_test__build_target",
        srcs = [":build_test__make_src"],
    )

    # Wrap a build test around the target.
    build_test(
        name = "build_test__test",
        targets = [":build_test__build_target"],
    )
