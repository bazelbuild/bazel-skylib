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

"""Dependencies that are needed for running skylib tests, doc generation, and release process."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def bazel_skylib_internal_deps():
    maybe(
        http_archive,
        name = "io_bazel_stardoc",
        sha256 = "c9794dcc8026a30ff67cf7cf91ebe245ca294b20b071845d12c192afe243ad72",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
            "https://github.com/bazelbuild/stardoc/releases/download/0.5.0/stardoc-0.5.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "rules_pkg",
        sha256 = "a89e203d3cf264e564fcb96b6e06dd70bc0557356eb48400ce4b5d97c2c3720d",
        urls = [
            "https://github.com/bazelbuild/rules_pkg/releases/download/0.5.1/rules_pkg-0.5.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.5.1/rules_pkg-0.5.1.tar.gz",
        ],
    )

    maybe(
        name = "rules_cc",
        repo_rule = http_archive,
        sha256 = "b4b2a2078bdb7b8328d843e8de07d7c13c80e6c89e86a09d6c4b424cfd1aaa19",
        strip_prefix = "rules_cc-cb2dfba6746bfa3c3705185981f3109f0ae1b893",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
            "https://github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
        ],
    )
