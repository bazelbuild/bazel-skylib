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

"""Skylib module containing rules to create metadata about subdirectories."""

load(":providers.bzl", "DirectoryInfo")
load(":utils.bzl", "get_subdirectory")

visibility("public")

def _subdirectory_impl(ctx):
    dir = get_subdirectory(ctx.attr.parent[DirectoryInfo], ctx.attr.path)
    return [
        dir,
        DefaultInfo(files = dir.transitive_files),
    ]

subdirectory = rule(
    implementation = _subdirectory_impl,
    attrs = {
        "parent": attr.label(providers = [DirectoryInfo], mandatory = True),
        "path": attr.string(mandatory = True),
    },
    provides = [DirectoryInfo],
)
