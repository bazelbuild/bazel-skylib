# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""Dependency registration helpers for repositories which need to load bazel-skylib."""

load("@bazel_skylib//lib:unittest.bzl", "register_unittest_toolchains")
load("@bazel_skylib//lib:versions.bzl", "versions")

def _globals_repo_impl(repository_ctx):
    globals = {
        "RunEnvironmentInfo": "5.3.0",
    }
    globals = {
        k: k if versions.is_at_least(v, versions.get()) else "None"
        for k, v in globals.items()
    }

    repository_ctx.file(
        "globals.bzl",
        "globals = struct(\n%s\n)\n" % "\n".join(
            ["    %s = %s" % item for item in globals.items()],
        ),
    )
    repository_ctx.file("BUILD.bazel", "exports_files(['globals.bzl'])\n")

_globals_repo = repository_rule(
    implementation = _globals_repo_impl,
    local = True,  # required to make sure the version is updated if the bazel server restarts
)

def globals_repo():
    _globals_repo(name = "bazel_skylib_globals")

def bazel_skylib_workspace():
    """Registers toolchains and declares repository dependencies of the bazel_skylib repository."""
    register_unittest_toolchains()
    globals_repo()
