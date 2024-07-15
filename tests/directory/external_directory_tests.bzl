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

"""Generates tests for the directory rules from outside the repository."""

_ROOT_BUILD_FILE_CONTENTS = """
load("@bazel_skylib//rules/directory:directory.bzl", "directory")

directory(
    name = "root",
    srcs = ["BUILD"],
)
"""

def _external_directory_tests_impl(repo_ctx):
    for f in repo_ctx.attr.files:
        repo_ctx.symlink(repo_ctx.path(f), f.package + "/" + f.name)

    repo_ctx.file("BUILD", _ROOT_BUILD_FILE_CONTENTS)

# Directory paths work differently while inside and outside the repository.
# To properly test this, we copy all our test code to an external
# repository.
external_directory_tests = repository_rule(
    implementation = _external_directory_tests_impl,
    attrs = {
        "files": attr.label_list(default = [
            "//tests/directory:BUILD",
            "//tests/directory:directory_test.bzl",
            "//tests/directory:glob_test.bzl",
            "//tests/directory:subdirectory_test.bzl",
            "//tests/directory:testdata/f1",
            "//tests/directory:testdata/subdir/f2",
            "//tests/directory:utils.bzl",
        ]),
    },
)

def _external_directory_tests_ext_impl(_module_ctx):
    external_directory_tests(name = "external_directory_tests")

# use_repo_rule would be preferred, but it isn't supported in bazel 6.
external_directory_tests_ext = module_extension(
    implementation = _external_directory_tests_ext_impl,
)
