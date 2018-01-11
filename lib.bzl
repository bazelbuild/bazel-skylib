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

"""Index from which multiple modules can be loaded."""

load("//lib:collections.bzl", "collections")
load("//lib:dicts.bzl", "dicts")
load("//lib:paths.bzl", "paths")
load("//lib:selects.bzl", "selects")
load("//lib:sets.bzl", "sets")
load("//lib:shell.bzl", "shell")
load("//lib:structs.bzl", "structs")
load("//lib:versions.bzl", "versions")

# The unittest module is treated differently to give more convenient names to
# the assert functions, while keeping them in the same .bzl file.
load("//lib:unittest.bzl", "asserts", "unittest")
