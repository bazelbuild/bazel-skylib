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

# rules_testing 0.6.0 leaves both test registration signatures untyped.
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load(":utils.bzl", "directory_entry", "failure_containing", "failure_test")

_NONEXISTENT_SUBDIRECTORY_ERR = """directory:root/testdata does not contain an entry named "nonexistent".
Instead, it contains the following entries:
f1
subdir
"""

# TODO: Use native annotations when Skylib requires Bazel 8.8 or newer.
def _subdirectory_test(name):
    # type: (str) -> None
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

    # ty: ignore[non-static-type]
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

def _subdirectory_test_impl(
        env,  # type: TestEnv
        # type: struct[{
        #     "root": Target,
        #     "f1": Target,
        #     "f2": Target,
        #     "testdata": Target,
        #     "subdir": Target,
        # }, ...]
        targets):
    # type: (...) -> None
    f1 = targets.f1[DefaultInfo].files.to_list()[0]
    f2 = targets.f2[DefaultInfo].files.to_list()[0]

    root = targets.root[DirectoryInfo]
    want_dir = directory_entry(root, "testdata")
    want_subdir = directory_entry(want_dir, "subdir")

    env.expect.that_collection([
        targets.testdata[DirectoryInfo],
        targets.subdir[DirectoryInfo],
    ]).contains_exactly([want_dir, want_subdir]).in_order()

    env.expect.that_collection(
        targets.testdata[DefaultInfo].files.to_list(),
    ).contains_exactly([f1, f2])
    env.expect.that_collection(
        targets.subdir[DefaultInfo].files.to_list(),
    ).contains_exactly([f2])

def _nonexistent_subdirectory_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing(_NONEXISTENT_SUBDIRECTORY_ERR),
        rule = subdirectory,
        parent = ":root",
        path = "testdata/nonexistent",
    )

def _subdirectory_of_file_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing("testdata/f1 to have type Directory, but got File"),
        rule = subdirectory,
        parent = ":root",
        path = "testdata/f1/foo",
    )

def _subdirectory_as_file_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing("testdata/f1 to have type Directory, but got File"),
        rule = subdirectory,
        parent = ":root",
        path = "testdata/f1",
    )

# buildifier: disable=function-docstring
def subdirectory_test_suite(name):
    # type: (str) -> None
    # ty: ignore[non-static-type]
    test_suite(
        name = name,
        tests = [
            _subdirectory_test,
            _nonexistent_subdirectory_test,
            _subdirectory_as_file_test,
            _subdirectory_of_file_test,
        ],
    )
