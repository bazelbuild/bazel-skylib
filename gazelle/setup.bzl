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

"""Dependency registration helpers for the gazelle plugin."""

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

def bazel_skylib_gazelle_plugin_setup(go_version = "1.20.5", register_go_toolchains = True):
    """Set up the dependencies needed by the Gazelle plugin.

    Args:
      go_version: The version of Go registered as part of the build as a string
      register_go_toolchains: A boolean indicating whether or not to register the Go toolchains. Defaults to `True`
    """
    go_rules_dependencies()

    if register_go_toolchains:
        go_register_toolchains(version = go_version)

    gazelle_dependencies()
