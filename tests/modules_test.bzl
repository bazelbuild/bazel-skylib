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
        "",
        modules.apparent_repo_name(""),
        msg = "Handles the empty string as input",
    )

    asserts.equals(
        env,
        "foo",
        modules.apparent_repo_name("foo"),
        msg = (
            "Return the original name unchanged if it doesn't start with `@`.",
        ),
    )

    asserts.equals(
        env,
        "foo",
        modules.apparent_repo_name("@foo"),
        msg = "Return the original name without `@` if already apparent.",
    )

    asserts.equals(
        env,
        "foo",
        modules.apparent_repo_name(Label("@foo").repo_name),
        msg = "Return the apparent name from a canonical name string.",
    )

    asserts.equals(
        env,
        "",
        modules.apparent_repo_name(Label("@@//:all")),
        msg = "Returns the empty string for a main repository Label.",
    )

    asserts.equals(
        env,
        "",
        modules.apparent_repo_name(Label("@bazel_skylib//:all")),
        msg = " ".join([
            "Returns the empty string for a Label containing the main",
            "repository's module name.",
        ]),
    )

    asserts.equals(
        env,
        "foo",
        modules.apparent_repo_name(Label("@foo")),
        msg = "Return the apparent name from a Label.",
    )

    asserts.equals(
        env,
        "rules_pkg",
        modules.apparent_repo_name(Label("@rules_pkg")),
        msg = " ".join([
            "Top level module repos have the canonical name delimiter at the",
            "end. Therefore, this should not return the empty string, but the",
            "name without the leading `@` and trailing delimiter.",
        ]),
    )

    asserts.equals(
        env,
        "stardoc" if _is_bzlmod_enabled else "io_bazel_stardoc",
        modules.apparent_repo_name(Label("@io_bazel_stardoc")),
        msg = " ".join([
            "Label values will already map bazel_dep repo_names to",
            "actual repo names under Bzlmod (no-op under WORKSPACE).",
        ]),
    )

    asserts.equals(
        env,
        "foo",
        modules.apparent_repo_name("foo+1.2.3"),
        msg = "Ignores version numbers in canonical repo names",
    )

    return unittest.end(env)

apparent_repo_name_test = unittest.make(_apparent_repo_name_test)

def _apparent_repo_label_string_test(ctx):
    """Unit tests for modules.apparent_repo_label_string."""
    env = unittest.begin(ctx)

    main_repo = str(Label("//:all"))
    asserts.equals(
        env,
        main_repo,
        modules.apparent_repo_label_string(Label("//:all")),
        msg = "Returns top level target with leading `@` or `@@`",
    )

    main_module_label = Label("@bazel_skylib//:all")
    asserts.equals(
        env,
        main_repo,
        modules.apparent_repo_label_string(main_module_label),
        msg = " ".join([
            "Returns top level target with leading `@` or `@@`",
            "for a Label containing the main module's name",
        ]),
    )

    rules_pkg = "@rules_pkg//:all"
    asserts.equals(
        env,
        rules_pkg,
        modules.apparent_repo_label_string(Label(rules_pkg)),
        msg = "Returns original repo name",
    )

    asserts.equals(
        env,
        "@%s//:all" % ("stardoc" if _is_bzlmod_enabled else "io_bazel_stardoc"),
        modules.apparent_repo_label_string(Label("@io_bazel_stardoc//:all")),
        msg = " ".join([
            "Returns the actual module name instead of",
            "repo_name from bazel_dep() (no-op under WORKSPACE).",
        ]),
    )

    return unittest.end(env)

apparent_repo_label_string_test = unittest.make(
    _apparent_repo_label_string_test,
)

def _adjust_main_repo_prefix_test(ctx):
    """Unit tests for modules.apparent_repo_label_string."""
    env = unittest.begin(ctx)

    expected = modules.main_repo_prefix + ":all"
    asserts.equals(
        env,
        expected,
        modules.adjust_main_repo_prefix("@//:all"),
        msg = "Normalizes a target pattern starting with `@//`.",
    )

    asserts.equals(
        env,
        expected,
        modules.adjust_main_repo_prefix("@@//:all"),
        msg = "Normalizes a target pattern starting with `@@//`.",
    )

    original = "@not_the_main_repo"
    asserts.equals(
        env,
        original,
        modules.adjust_main_repo_prefix(original),
        msg = "Returns non main repo target patterns unchanged.",
    )

    return unittest.end(env)

adjust_main_repo_prefix_test = unittest.make(
    _adjust_main_repo_prefix_test,
)

# buildifier: disable=unnamed-macro
def modules_test_suite():
    """Creates the tests for modules.bzl if Bzlmod is enabled."""

    unittest.suite(
        "modules_tests",
        apparent_repo_name_test,
        apparent_repo_label_string_test,
        adjust_main_repo_prefix_test,
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
