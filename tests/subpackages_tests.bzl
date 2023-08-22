# Copyright 2022 The Bazel Authors. All rights reserved.
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

"""Unit tests for subpackages.bzl."""

load("//lib:subpackages.bzl", "subpackages")
load("//lib:unittest.bzl", "loadingtest")

def _all_test(env):
    """Unit tests for subpackages.all."""

    all_pkgs = [
        "common_settings",
        "copy_directory",
        "copy_file",
        "diff_test",
        "expand_template",
        "select_file",
        "write_file",
    ]

    # Not all pkgs exist in all test environments.
    if subpackages.exists("run_binary"):
        all_pkgs.append("run_binary")

    if subpackages.exists("native_binary"):
        all_pkgs.append("native_binary")

    # These exist in all cases
    filtered_pkgs = [
        "common_settings",
        "copy_directory",
        "copy_file",
        "expand_template",
        "select_file",
        "write_file",
    ]

    # subpackages is always in sorted order:
    all_pkgs = sorted(all_pkgs)

    # test defaults
    loadingtest.equals(
        env,
        "all",
        ["//tests/" + pkg for pkg in all_pkgs],
        subpackages.all(),
    )

    # test non-fully-qualified output
    loadingtest.equals(
        env,
        "all_not_fully_qualified",
        all_pkgs,
        subpackages.all(fully_qualified = False),
    )

    # test exclusion
    loadingtest.equals(
        env,
        "all_w_exclude",
        filtered_pkgs,
        subpackages.all(exclude = ["diff_test", "run_binary", "native_binary"], fully_qualified = False),
    )

def _exists_test(env):
    """Unit tests for subpackages.exists."""
    loadingtest.equals(env, "exists_yes", True, subpackages.exists("copy_file"))
    loadingtest.equals(env, "exists_no", False, subpackages.exists("never_existed"))

def subpackages_test_suite():
    """Creates the test targets and test suite for subpackages.bzl tests."""

    if subpackages.supported():
        env = loadingtest.make("subpackages")
        _all_test(env)
        _exists_test(env)
