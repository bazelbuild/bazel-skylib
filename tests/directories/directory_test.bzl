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

"""Unit tests for directory rules."""

load("@rules_testing//lib:truth.bzl", "matching", "subjects")
load("//rules/directories:providers.bzl", "DirectoryInfo")

visibility("private")

_depset_as_list_subject = lambda value, *, meta: subjects.collection(
    value.to_list(),
    meta = meta,
)

_directory_info_subject = lambda value, *, meta: subjects.struct(
    value,
    meta = meta,
    attrs = dict(
        directories = subjects.dict,
        files = subjects.dict,
        direct_files = _depset_as_list_subject,
        transitive_files = _depset_as_list_subject,
        source_path = subjects.str,
        generated_path = subjects.str,
        human_readable = subjects.str,
    ),
)

def _directory_subject(env, directory_info):
    return env.expect.that_value(
        value = directory_info,
        expr = "DirectoryInfo(%r)" % directory_info.source_path,
        factory = _directory_info_subject,
    )

# buildifier: disable=function-docstring
def outside_testdata_test(env, target):
    env.expect.that_target(target).failures().contains_exactly_predicates([
        matching.contains("tests/directories/BUILD is not contained within @@//tests/directories/testdata"),
    ])

# buildifier: disable=function-docstring
def directory_test(env, targets):
    f1 = targets.f1.files.to_list()[0]
    f2 = targets.f2.files.to_list()[0]
    f3 = targets.f3.files.to_list()[0]

    env.expect.that_collection(targets.root.files.to_list()).contains_exactly(
        [f1, f2, f3],
    )

    root = _directory_subject(env, targets.root[DirectoryInfo])
    root.directories().keys().contains_exactly(["dir", "newdir"])
    root.files().contains_exactly({"f1": f1})
    root.direct_files().contains_exactly([f1])
    root.transitive_files().contains_exactly([f1, f2, f3]).in_order()
    root.human_readable().equals("@@//tests/directories/testdata")
    env.expect.that_str(root.actual.source_path + "/f1").equals(f1.path)

    dir = _directory_subject(env, root.actual.directories["dir"])
    dir.directories().keys().contains_exactly(["subdir"])
    dir.human_readable().equals("@@//tests/directories/testdata/dir")

    subdir = _directory_subject(env, dir.actual.directories["subdir"])
    subdir.directories().keys().contains_exactly([])
    subdir.files().contains_exactly({"f2": f2})
    subdir.direct_files().contains_exactly([f2])
    subdir.transitive_files().contains_exactly([f2]).in_order()
    env.expect.that_str(subdir.actual.source_path + "/f2").equals(f2.path)

    newdir = _directory_subject(env, root.actual.directories["newdir"])
    newdir.directories().keys().contains_exactly([])
    newdir.files().contains_exactly({"f3": f3})
    newdir.direct_files().contains_exactly([f3])
    newdir.transitive_files().contains_exactly([f3]).in_order()
    env.expect.that_str(newdir.actual.generated_path + "/f3").equals(f3.path)
