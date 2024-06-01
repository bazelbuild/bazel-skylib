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

"""Unit tests for subdirectory rules."""

load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")
load("@bazel_skylib//rules/directory:subdirectory.bzl", "subdirectory")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load(":utils.bzl", "failure_matching", "failure_test")

_NONEXISTENT_SUBDIRECTORY_ERR = """directory:root/testdata does not contain an entry named "nonexistent".
Instead, it contains the following entries:
f1
subdir
"""

def _subdirectory_test(name):
    testdata_name = "_%s_dir" % name
    subdir_name = "_%s_subdir" % name

    subdirectory(
        name = testdata_name,
        parent = ":root",
        path = "testdata",
    )

    subdirectory(
        name = subdir_name,
        parent = ":root",
        path = "testdata/subdir",
    )

    analysis_test(
        name = name,
        impl = _subdirectory_test_impl,
        targets = {
            "root": ":root",
            "testdata": testdata_name,
            "subdir": subdir_name,
            "f1": ":f1_filegroup",
            "f2": ":f2_filegroup",
        },
    )

def _subdirectory_test_impl(env, targets):
    f1 = targets.f1.files.to_list()[0]
    f2 = targets.f2.files.to_list()[0]

    root = targets.root[DirectoryInfo]
    want_dir = root.entries["testdata"]
    want_subdir = want_dir.entries["subdir"]

    # Use that_str because it supports equality checks. They're not strings.
    env.expect.that_str(targets.testdata[DirectoryInfo]).equals(want_dir)
    env.expect.that_str(targets.subdir[DirectoryInfo]).equals(want_subdir)

    env.expect.that_collection(
        targets.testdata.files.to_list(),
    ).contains_exactly([f1, f2])
    env.expect.that_collection(
        targets.subdir.files.to_list(),
    ).contains_exactly([f2])

def _nonexistent_subdirectory_test(name):
    failure_test(
        name = name,
        impl = failure_matching(matching.contains(_NONEXISTENT_SUBDIRECTORY_ERR)),
        rule = subdirectory,
        parent = ":root",
        path = "testdata/nonexistent",
    )

def _subdirectory_of_file_test(name):
    failure_test(
        name = name,
        impl = failure_matching(matching.contains("testdata/f1 to have type Directory, but got File")),
        rule = subdirectory,
        parent = ":root",
        path = "testdata/f1/foo",
    )

def _subdirectory_as_file_test(name):
    failure_test(
        name = name,
        impl = failure_matching(matching.contains("testdata/f1 to have type Directory, but got File")),
        rule = subdirectory,
        parent = ":root",
        path = "testdata/f1",
    )

# buildifier: disable=function-docstring
def subdirectory_test_suite(name):
    test_suite(
        name = name,
        tests = [
            _subdirectory_test,
            _nonexistent_subdirectory_test,
            _subdirectory_as_file_test,
            _subdirectory_of_file_test,
        ],
    )
