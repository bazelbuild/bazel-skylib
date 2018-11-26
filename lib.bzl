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

load("//lib:collections.bzl", _collections = "collections")
load("//lib:dicts.bzl", _dicts = "dicts")
load("//lib:new_sets.bzl", _new_sets = "sets")
load("//lib:partial.bzl", _partial = "partial")
load("//lib:paths.bzl", _paths = "paths")
load("//lib:selects.bzl", _selects = "selects")
load("//lib:sets.bzl", _sets = "sets")
load("//lib:shell.bzl", _shell = "shell")
load("//lib:structs.bzl", _structs = "structs")
load("//lib:types.bzl", _types = "types")
load("//lib:unittest.bzl", _asserts = "asserts", _unittest = "unittest")
load("//lib:versions.bzl", _versions = "versions")

print(
    "WARNING: lib.bzl is deprecated and will go away in the future, please" +
    " directly load the bzl file(s) of the module(s) needed as it is more" +
    " efficient.",
)

collections = _collections
dicts = _dicts
new_sets = _new_sets
partial = _partial
paths = _paths
selects = _selects
sets = _sets
shell = _shell
structs = _structs
types = _types
versions = _versions

asserts = _asserts
unittest = _unittest
