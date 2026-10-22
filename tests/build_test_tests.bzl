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

load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("//lib:unittest.bzl", "loadingtest")
load("//rules:build_test.bzl", "build_test")

# buildifier: disable=unnamed-macro
def build_test_test_suite():
    """Exercises build_test targets and forwarded tags."""

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

    env = loadingtest.make("build_test_tags")
    for kind, tags, expected_test_tags, expected_deps_tags in [
        ("list", ["build_test_input"], ["build_test_input"], ["build_test_input", "manual"]),
        ("tuple", ("build_test_input",), ["build_test_input"], ["build_test_input", "manual"]),
        ("depset", depset(["build_test_input"]), ["build_test_input"], ["build_test_input", "manual"]),
        ("none", None, [], ["manual"]),
        ("manual", ["manual"], ["manual"], ["manual"]),
    ]:
        name = "build_test_%s_tags_test" % kind
        build_test(
            name = name,
            targets = [":build_test__build_target"],
            tags = tags,
        )
        loadingtest.equals(
            env,
            kind,
            (expected_test_tags, expected_deps_tags),
            (
                list(native.existing_rule(name)["tags"]),
                sorted(native.existing_rule(name + "_0__deps")["tags"]),
            ),
        )
