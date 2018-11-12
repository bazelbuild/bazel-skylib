# Copyright 2018 The Bazel Authors. All rights reserved.
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

"""Skylib module containing a library rule for aggregating rules files.

Deprecated:
  Use bzl_library in bzl_library.bzl instead.
"""

load("//:bzl_library.bzl", "StarlarkLibraryInfo", "bzl_library")

print(
    "WARNING: skylark_library.bzl is deprecated and will go away in the future, please" +
    " use bzl_library.bzl instead.",
)

# These are temporary forwarding macros to facilitate migration to
# the new names for these objects.
SkylarkLibraryInfo = StarlarkLibraryInfo

skylark_library = bzl_library
