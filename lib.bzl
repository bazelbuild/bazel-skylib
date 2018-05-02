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

load("//lib:collections.bzl", _collections="collections")
load("//lib:dicts.bzl", _dicts="dicts")
load("//lib:new_sets.bzl", _new_sets="sets")
load("//lib:partial.bzl", _partial="partial")
load("//lib:paths.bzl", _paths="paths")
load("//lib:selects.bzl", _selects="selects")
load("//lib:sets.bzl", _sets="sets")
load("//lib:shell.bzl", _shell="shell")
load("//lib:strings.bzl", _strings="strings")
load("//lib:structs.bzl", _structs="structs")
load("//lib:versions.bzl", _versions="versions")

# The unittest module is treated differently to give more convenient names to
# the assert functions, while keeping them in the same .bzl file.
load("//lib:unittest.bzl", _asserts="asserts", _unittest="unittest")


collections = _collections
dicts = _dicts
new_sets = _new_sets
partial = _partial
paths = _paths
selects = _selects
sets = _sets
shell = _shell
strings = _strings
structs = _structs
versions = _versions

asserts = _asserts
unittest = _unittest
