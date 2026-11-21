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

# rules_testing 0.6.0 leaves both test registration signatures untyped.
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load(":utils.bzl", "directory_entry", "failure_containing", "failure_test")

# TODO: Use native annotations when Skylib requires Bazel 8.8 or newer.
def _source_root_test(name):
    # type: (str) -> None
    # Each key in targets becomes a callback field: a label becomes a Target,
    # and a list of labels becomes a list of Targets.
    # ty: ignore[non-static-type]
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
    # type: (TestEnv, struct[{"root": Target, "f1": Target, "f2": Target}, ...]) -> None
    f1 = targets.f1[DefaultInfo].files.to_list()[0]
    f2 = targets.f2[DefaultInfo].files.to_list()[0]

    env.expect.that_collection(targets.root[DefaultInfo].files.to_list()).contains_exactly(
        [f1, f2],
    )

    human_readable = str(targets.root.label)

    root = targets.root[DirectoryInfo]
    env.expect.that_collection(root.entries.keys(), expr = "root.entries.keys()").contains_exactly(["testdata"])
    env.expect.that_collection(root.transitive_files.to_list(), expr = "root.transitive_files").contains_exactly([f1, f2]).in_order()
    env.expect.that_str(root.human_readable).equals(human_readable)
    env.expect.that_str(root.path + "/testdata/f1").equals(f1.path)

    testdata = directory_entry(root, "testdata")
    env.expect.that_collection(testdata.entries.keys(), expr = "testdata.entries.keys()").contains_exactly(["f1", "subdir"])
    env.expect.that_str(testdata.human_readable).equals(human_readable + "/testdata")

    subdir = directory_entry(testdata, "subdir")
    env.expect.that_dict(subdir.entries).contains_exactly({"f2": f2})
    env.expect.that_collection(subdir.transitive_files.to_list(), expr = "subdir.transitive_files").contains_exactly([f2])
    env.expect.that_str(subdir.path + "/f2").equals(f2.path)

    env.expect.that_str(root.get_path("testdata/f1").path).equals(f1.path)
    env.expect.that_str(root.get_path("testdata/subdir").path).equals(subdir.path)
    env.expect.that_str(root.get_file(path = "testdata/subdir/f2").path).equals(f2.path)
    env.expect.that_str(root.get_subdirectory("testdata/subdir").path).equals(subdir.path)

def _generated_root_test(name):
    # type: (str) -> None
    subject_name = "_%s_subject" % name
    directory(
        name = subject_name,
        srcs = [":generated_file"],
    )

    # ty: ignore[non-static-type]
    analysis_test(
        name = name,
        impl = _generated_root_test_impl,
        targets = {
            "root": subject_name,
            "generated": ":generated_file",
        },
    )

def _generated_root_test_impl(env, targets):
    # type: (TestEnv, struct[{"root": Target, "generated": Target}, ...]) -> None
    generated = targets.generated[DefaultInfo].files.to_list()[0]

    env.expect.that_collection(targets.root[DefaultInfo].files.to_list()).contains_exactly(
        [generated],
    )

    human_readable = str(targets.root.label)

    root = targets.root[DirectoryInfo]
    env.expect.that_collection(root.entries.keys(), expr = "root.entries.keys()").contains_exactly(["dir"])
    env.expect.that_collection(root.transitive_files.to_list(), expr = "root.transitive_files").contains_exactly([generated]).in_order()
    env.expect.that_str(root.human_readable).equals(human_readable)
    env.expect.that_str(root.path + "/dir/generated").equals(generated.path)

    dir = directory_entry(root, "dir")
    env.expect.that_str(dir.human_readable).equals(human_readable + "/dir")
    env.expect.that_dict(dir.entries).contains_exactly({"generated": generated})
    env.expect.that_collection(dir.transitive_files.to_list(), expr = "dir.transitive_files").contains_exactly([generated])
    env.expect.that_str(dir.path + "/generated").equals(generated.path)

def _no_srcs_test(name):
    # type: (str) -> None
    subject_name = "_%s_subject" % name
    directory(
        name = subject_name,
    )

    # ty: ignore[non-static-type]
    analysis_test(
        name = name,
        impl = _no_srcs_test_impl,
        targets = {
            "root": subject_name,
            "f1": ":f1_filegroup",
        },
    )

def _no_srcs_test_impl(env, targets):
    # type: (TestEnv, struct[{"root": Target, "f1": Target}, ...]) -> None
    f1 = targets.f1[DefaultInfo].files.to_list()[0]

    env.expect.that_collection(targets.root[DefaultInfo].files.to_list()).contains_exactly([])

    d = targets.root[DirectoryInfo]
    env.expect.that_dict(d.entries).contains_exactly({})
    env.expect.that_str(d.path + "/testdata/f1").equals(f1.path)

def _directory_with_self_srcs_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing("tests/directory to start with"),
        rule = directory,
        srcs = ["."],
    )

def _outside_testdata_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing("lib/paths.bzl to start with"),
        rule = directory,
        srcs = ["@bazel_skylib//lib:paths"],
    )

def _source_and_generated_root_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing(
            "Having both source and generated files in a single directory is unsupported",
        ),
        rule = directory,
        srcs = ["f1", ":generated_file"],
    )

def _get_file_impl(ctx):
    # type: (...) -> list[DefaultInfo]
    file = ctx.attr.directory[DirectoryInfo].get_file(ctx.attr.path)
    return [DefaultInfo(files = depset([file]))]

_get_file = rule(
    implementation = _get_file_impl,
    attrs = {
        "directory": attr.label(mandatory = True, providers = [DirectoryInfo]),
        "path": attr.string(mandatory = True),
    },
)

def _directory_as_file_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing("testdata/subdir to have type File, but got Directory"),
        rule = _get_file,
        directory = ":root",
        path = "testdata/subdir",
    )

# buildifier: disable=function-docstring
def directory_test_suite(name):
    # type: (str) -> None
    # The keys and values in test_kwargs must fit every callback in tests.
    # A dict[str, object] parameter would accept misspelled callback arguments.
    # ty: ignore[non-static-type]
    test_suite(
        name = name,
        tests = [
            _source_root_test,
            _generated_root_test,
            _no_srcs_test,
            _directory_with_self_srcs_test,
            _outside_testdata_test,
            _source_and_generated_root_test,
            _directory_as_file_test,
        ],
    )
