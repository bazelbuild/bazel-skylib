# Copyright 2018 The Bazel Authors. All rights reserved.
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

"""Unit tests for versions.bzl."""

load("//lib:unittest.bzl", "asserts", "unittest")
load("//lib:versions.bzl", "versions")

def _parse_test(ctx):
    """Unit tests for versions.parse"""
    env = unittest.begin(ctx)

    asserts.equals(env, (0, 10, 0), versions.parse("0.10.0rc1 abcd123"))
    asserts.equals(env, (0, 4, 0), versions.parse("0.4.0 abcd123"))
    asserts.equals(env, (0, 4, 0), versions.parse("0.4.0"))
    asserts.equals(env, (0, 4, 0), versions.parse("0.4.0rc"))

    return unittest.end(env)

def _version_comparison_test(ctx):
    """Unit tests for versions.is_at_least and is_at_most"""
    env = unittest.begin(ctx)

    asserts.false(env, versions.is_at_least("0.11.0 123abcd", "0.10.0rc1 abcd123"))
    asserts.true(env, versions.is_at_least("0.9.0", "0.10.0rc2"))
    asserts.true(env, versions.is_at_least("0.9.0", "0.9.0rc3"))
    asserts.true(env, versions.is_at_least("0.9.0", "1.2.3"))

    asserts.false(env, versions.is_at_most("0.4.0 123abcd", "0.10.0rc1 abcd123"))
    asserts.true(env, versions.is_at_most("0.4.0", "0.3.0rc2"))
    asserts.true(env, versions.is_at_most("0.4.0", "0.4.0rc3"))
    asserts.true(env, versions.is_at_most("1.4.0", "0.4.0rc3"))

    return unittest.end(env)

def _check_test(ctx):
    """Unit tests for versions.check"""
    env = unittest.begin(ctx)

    asserts.equals(env, None, versions.check("0.4.5 abcdef", bazel_version = "0.10.0rc1 abcd123"))
    asserts.equals(env, None, versions.check("0.4.5", bazel_version = "0.4.5"))
    asserts.equals(env, None, versions.check("0.4.5", bazel_version = "0.10.0rc1 abcd123"))
    asserts.equals(env, None, versions.check("0.4.5", maximum_bazel_version = "1.0.0", bazel_version = "0.10.0rc1 abcd123"))

    return unittest.end(env)

parse_test = unittest.make(_parse_test)
version_comparison_test = unittest.make(_version_comparison_test)
check_test = unittest.make(_check_test)

def versions_test_suite():
    """Creates the test targets and test suite for versions.bzl tests."""
    unittest.suite(
        "versions_tests",
        parse_test,
        version_comparison_test,
        check_test,
    )
