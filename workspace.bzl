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
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_skylib_workspace():
    """Registers toolchains and declares repository dependencies of the bazel_skylib repository."""
    register_unittest_toolchains()
    maybe(
        http_archive,
        name = "bazel_features",
        sha256 = "b8789c83c893d7ef3041d3f2795774936b27ff61701a705df52fd41d6ddbf692",
        strip_prefix = "bazel_features-1.2.0",
        url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.2.0/bazel_features-v1.2.0.tar.gz",
    )
