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

"""Unit tests for the directory rule."""

load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("@rules_testing//lib:truth.bzl", "matching")
load(":utils.bzl", "directory_subject", "failure_matching", "failure_test")

def _source_root_test(name):
    analysis_test(
        name = name,
        impl = _source_root_test_impl,
        targets = {
            "root": ":root",
            "f1": ":f1_filegroup",
            "f2": ":f2_filegroup",
        },
    )

def _source_root_test_impl(env, targets):
    f1 = targets.f1.files.to_list()[0]
    f2 = targets.f2.files.to_list()[0]

    env.expect.that_collection(targets.root.files.to_list()).contains_exactly(
        [f1, f2],
    )

    human_readable = str(targets.root.label)

    root = directory_subject(env, targets.root[DirectoryInfo])
    root.entries().keys().contains_exactly(["testdata"])
    root.transitive_files().contains_exactly([f1, f2]).in_order()
    root.human_readable().equals(human_readable)
    env.expect.that_str(root.actual.path + "/testdata/f1").equals(f1.path)

    testdata = directory_subject(env, root.actual.entries["testdata"])
    testdata.entries().keys().contains_exactly(["f1", "subdir"])
    testdata.human_readable().equals(human_readable + "/testdata")

    subdir = directory_subject(env, testdata.actual.entries["subdir"])
    subdir.entries().contains_exactly({"f2": f2})
    subdir.transitive_files().contains_exactly([f2])
    env.expect.that_str(subdir.actual.path + "/f2").equals(f2.path)

def _generated_root_test(name):
    subject_name = "_%s_subject" % name
    directory(
        name = subject_name,
        srcs = [":generated_file"],
    )

    analysis_test(
        name = name,
        impl = _generated_root_test_impl,
        targets = {
            "root": subject_name,
            "generated": ":generated_file",
        },
    )

def _generated_root_test_impl(env, targets):
    generated = targets.generated.files.to_list()[0]

    env.expect.that_collection(targets.root.files.to_list()).contains_exactly(
        [generated],
    )

    human_readable = str(targets.root.label)

    root = directory_subject(env, targets.root[DirectoryInfo])
    root.entries().keys().contains_exactly(["dir"])
    root.transitive_files().contains_exactly([generated]).in_order()
    root.human_readable().equals(human_readable)
    env.expect.that_str(root.actual.path + "/dir/generated").equals(generated.path)

    dir = directory_subject(env, root.actual.entries["dir"])
    dir.human_readable().equals(human_readable + "/dir")
    dir.entries().contains_exactly({"generated": generated})
    dir.transitive_files().contains_exactly([generated])
    env.expect.that_str(dir.actual.path + "/generated").equals(generated.path)

def _no_srcs_test(name):
    subject_name = "_%s_subject" % name
    directory(
        name = subject_name,
    )

    analysis_test(
        name = name,
        impl = _no_srcs_test_impl,
        targets = {
            "root": subject_name,
            "f1": ":f1_filegroup",
        },
    )

def _no_srcs_test_impl(env, targets):
    f1 = targets.f1.files.to_list()[0]

    env.expect.that_collection(targets.root.files.to_list()).contains_exactly([])

    d = directory_subject(env, targets.root[DirectoryInfo])
    d.entries().contains_exactly({})
    env.expect.that_str(d.actual.path + "/testdata/f1").equals(f1.path)

def _directory_with_self_srcs_test(name):
    failure_test(
        name = name,
        impl = failure_matching(matching.contains("tests/directory to start with")),
        rule = directory,
        srcs = ["."],
    )

def _outside_testdata_test(name):
    failure_test(
        name = name,
        impl = failure_matching(matching.contains("lib/paths.bzl to start with")),
        rule = directory,
        srcs = ["@bazel_skylib//lib:paths"],
    )

def _source_and_generated_root_test(name):
    failure_test(
        name = name,
        impl = failure_matching(matching.contains(
            "Having both source and generated files in a single directory is unsupported",
        )),
        rule = directory,
        srcs = ["f1", ":generated_file"],
    )

# buildifier: disable=function-docstring
def directory_test_suite(name):
    test_suite(
        name = name,
        tests = [
            _source_root_test,
            _generated_root_test,
            _no_srcs_test,
            _directory_with_self_srcs_test,
            _outside_testdata_test,
            _source_and_generated_root_test,
        ],
    )
