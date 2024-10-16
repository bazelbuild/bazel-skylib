# Copyright 2017 The Bazel Authors. All rights reserved.
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

"""Test usage of modules.bzl."""

load("@apparent-repo-name-test//:repo-name.bzl", "REPO_NAME")
load("//lib:modules.bzl", "modules")
load("//lib:unittest.bzl", "asserts", "unittest")
load("//rules:build_test.bzl", "build_test")

_is_bzlmod_enabled = str(Label("//tests:module_tests.bzl")).startswith("@@")

def _repo_rule_impl(repository_ctx):
    repository_ctx.file("WORKSPACE")
    repository_ctx.file("BUILD", """exports_files(["hello"])""")
    repository_ctx.file("hello", "Hello, Bzlmod!")

_repo_rule = repository_rule(_repo_rule_impl)

def _workspace_macro(register_toolchains = False):
    _repo_rule(name = "foo")
    _repo_rule(name = "bar")
    if register_toolchains:
        native.register_toolchains()

as_extension_test_ext = modules.as_extension(
    _workspace_macro,
    doc = "Only used for testing modules.as_extension().",
)

def _use_all_repos_ext_impl(module_ctx):
    _repo_rule(name = "baz")
    _repo_rule(name = "qux")
    return modules.use_all_repos(module_ctx)

use_all_repos_test_ext = module_extension(
    _use_all_repos_ext_impl,
    doc = "Only used for testing modules.use_all_repos().",
)

def _apparent_repo_name_test(ctx):
    """Unit tests for modules.apparent_repo_name."""
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        "apparent-repo-name-test",
        REPO_NAME,
        msg = " ".join([
            "Returns the original name unchanged under WORKSPACE, and",
            "the apparent repo name under Bzlmod.",
        ]),
    )

    return unittest.end(env)

apparent_repo_name_test = unittest.make(_apparent_repo_name_test)

# buildifier: disable=unnamed-macro
def modules_test_suite():
    """Creates the tests for modules.bzl if Bzlmod is enabled."""

    unittest.suite(
        "modules_tests",
        apparent_repo_name_test,
    )

    if not _is_bzlmod_enabled:
        return

    build_test(
        name = "modules_as_extension_test",
        targets = [
            "@foo//:hello",
            "@bar//:hello",
        ],
    )

    build_test(
        name = "modules_use_all_repos_test",
        targets = [
            "@baz//:hello",
            "@qux//:hello",
        ],
    )
