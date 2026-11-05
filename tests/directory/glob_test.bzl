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

"""Unit tests for the directory_glob rule."""

load("@bazel_skylib//rules/directory:glob.bzl", "directory_glob")
load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo", "create_directory_info")

# buildifier: disable=bzl-visibility
load("@bazel_skylib//rules/directory/private:glob.bzl", "directory_glob_chunk", "transitive_entries")

# rules_testing 0.6.0 leaves both test registration signatures untyped.
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load(":utils.bzl", "directory_entry", "failure_containing", "failure_test")

# TODO: Use native annotations when Skylib requires Bazel 8.8 or newer.
def _expect_glob_chunk(env, directory, chunk):
    # type: (TestEnv, DirectoryInfo, str) -> CollectionSubject
    return env.expect.that_collection(
        directory_glob_chunk(directory, chunk),
        expr = "directory_glob_chunk({}, {})".format(directory.human_readable, repr(chunk)),
    )

def _expect_glob(env, directory, include, allow_empty = False):
    # type: (TestEnv, DirectoryInfo, Sequence[str], bool) -> CollectionSubject
    return env.expect.that_collection(
        directory.glob(include, allow_empty = allow_empty),
        expr = "directory_glob({}, {}, allow_empty={})".format(directory.human_readable, include, allow_empty),
    )

def _glob_test(name):
    # type: (str) -> None
    simple_name = "_simple_%s" % name
    exclude_name = "_exclude_%s" % name
    directory_glob(
        name = simple_name,
        srcs = ["testdata/f1"],
        data = ["testdata/subdir/f2"],
        directory = ":root",
    )

    directory_glob(
        name = exclude_name,
        srcs = [
            "testdata/f1",
            "nonexistent",
        ],
        allow_empty = True,
        data = ["**"],
        directory = ":root",
        exclude = ["testdata/f1"],
    )

    # ty: ignore[non-static-type]
    analysis_test(
        name = name,
        impl = _glob_test_impl,
        targets = {
            "root": ":root",
            "f1": ":f1_filegroup",
            "f2": ":f2_filegroup",
            "simple_glob": simple_name,
            "glob_with_exclude": exclude_name,
        },
    )

def _glob_test_impl(
        env,  # type: TestEnv
        # type: struct[{
        #     "root": Target,
        #     "f1": Target,
        #     "f2": Target,
        #     "simple_glob": Target,
        #     "glob_with_exclude": Target,
        # }, ...]
        targets):
    # type: (...) -> None
    f1 = targets.f1[DefaultInfo].files.to_list()[0]
    f2 = targets.f2[DefaultInfo].files.to_list()[0]
    root = targets.root[DirectoryInfo]
    testdata = directory_entry(root, "testdata")
    subdir = directory_entry(testdata, "subdir")

    env.expect.that_collection(transitive_entries(root)).contains_exactly([
        root,
        testdata,
        subdir,
        f1,
        f2,
    ])

    _expect_glob_chunk(env, testdata, "f1").contains_exactly([f1])
    _expect_glob_chunk(env, root, "nonexistent").contains_exactly([])
    _expect_glob_chunk(env, testdata, "f2").contains_exactly([])
    _expect_glob_chunk(env, root, "testdata").contains_exactly([testdata])
    _expect_glob_chunk(env, testdata, "*").contains_exactly(
        [f1, subdir],
    )

    for names, chunk, expected in [
        (["a", "d", "abc", "abbc", "ab.bc", ".abbc", "abbc."], "ab*bc", ["abbc", "ab.bc"]),
        (["abbc", "abbbc", "ab.b.bc"], "ab*b*bc", ["abbbc", "ab.b.bc"]),
        (["a", "ab", "ba"], "a*", ["a", "ab"]),
        (["a", "ab", "a.b.", "ba."], "a*b*", ["ab", "a.b."]),
    ]:
        directory = create_directory_info(
            entries = {
                name: create_directory_info(entries = {}, transitive_files = depset(), path = name, human_readable = name)
                for name in names
            },
            transitive_files = depset(),
            path = "",
            human_readable = repr(names),
        )
        _expect_glob_chunk(env, directory, chunk).contains_exactly([directory.entries[name] for name in expected])

    _expect_glob(env, root, ["testdata/f1"]).contains_exactly([f1])
    _expect_glob(env, root, ["testdata/subdir/f2"]).contains_exactly([f2])
    _expect_glob(env, root, ["**"]).contains_exactly([f1, f2])
    _expect_glob(env, root, ["**/f1"]).contains_exactly([f1])
    _expect_glob(env, root, ["**/**/f1"]).contains_exactly([f1])
    _expect_glob(env, root, ["testdata/*/f1"], allow_empty = True).contains_exactly([])

    simple_glob = env.expect.that_target(targets.simple_glob)
    with_exclude = env.expect.that_target(targets.glob_with_exclude)

    env.expect.that_collection(
        simple_glob.actual[DefaultInfo].files.to_list(),
        expr = "simple_glob's files",
    ).contains_exactly([f1])
    env.expect.that_collection(
        with_exclude.actual[DefaultInfo].files.to_list(),
        expr = "with_exclude's files",
    ).contains_exactly([])

    # target.runfiles().contains_exactly() doesn't do what we want - it converts
    # it to a string corresponding to the runfiles import path.
    env.expect.that_collection(
        simple_glob.runfiles().actual.files.to_list(),
        expr = "simple_glob's runfiles",
    ).contains_exactly([f1, f2])
    env.expect.that_collection(
        with_exclude.runfiles().actual.files.to_list(),
        expr = "with_exclude's runfiles",
    ).contains_exactly([f2])

def _glob_with_no_match_test(name):
    # type: (str) -> None
    failure_test(
        name = name,
        impl = failure_containing('"nonexistent" failed to match any files in'),
        rule = directory_glob,
        srcs = [
            "testdata/f1",
            "nonexistent",
        ],
        data = ["testdata/f1"],
        directory = ":root",
    )

# buildifier: disable=function-docstring
def glob_test_suite(name):
    # type: (str) -> None
    # ty: ignore[non-static-type]
    test_suite(
        name = name,
        tests = [
            _glob_test,
            _glob_with_no_match_test,
        ],
    )
