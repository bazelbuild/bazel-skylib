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

"""Unit tests for structs.bzl."""

load("@bazel_features//:features.bzl", "bazel_features")
load("//lib:structs.bzl", "structs")
load("//lib:unittest.bzl", "asserts", "unittest")

def _placeholder():
    pass

def _to_dict_test(ctx):
    """Unit tests for structs.to_dict."""
    env = unittest.begin(ctx)

    # Test zero- and one-argument behavior.
    asserts.equals(env, {}, structs.to_dict(struct()))
    asserts.equals(env, {"a": 1}, structs.to_dict(struct(a = 1)))

    # Test simple two-argument behavior.
    asserts.equals(env, {"a": 1, "b": 2}, structs.to_dict(struct(a = 1, b = 2)))

    # Test simple more-than-two-argument behavior.
    asserts.equals(
        env,
        {"a": 1, "b": 2, "c": 3, "d": 4},
        structs.to_dict(struct(a = 1, b = 2, c = 3, d = 4)),
    )

    # Test transformation is not applied transitively.
    asserts.equals(
        env,
        {"a": 1, "b": struct(bb = 1)},
        structs.to_dict(struct(a = 1, b = struct(bb = 1))),
    )

    # Older Bazel denied creating `struct` with `to_json`/`to_proto`
    if not bazel_features.rules.no_struct_field_denylist:
        return unittest.end(env)

    # Test `to_json`/`to_proto` values are propagated
    asserts.equals(
        env,
        {"to_json": 1, "to_proto": 2},
        structs.to_dict(struct(to_json = 1, to_proto = 2)),
    )

    # Test `to_json`/`to_proto` functions are propagated
    asserts.equals(
        env,
        {"to_json": _placeholder, "to_proto": _placeholder},
        structs.to_dict(struct(to_json = _placeholder, to_proto = _placeholder)),
    )

    return unittest.end(env)

to_dict_test = unittest.make(_to_dict_test)

def _merge_test(ctx):
    """Unit tests for structs.merge."""
    env = unittest.begin(ctx)

    # Fixtures
    a = struct(a = 1)
    b = struct(b = 2)
    c = struct(a = 3)

    # Test one argument
    asserts.equals(env, {"a": 1}, structs.to_dict(structs.merge(a)))

    # Test two arguments
    asserts.equals(env, {"a": 1}, structs.to_dict(structs.merge(a, a)))
    asserts.equals(env, {"a": 1, "b": 2}, structs.to_dict(structs.merge(a, b)))

    # Test overwrite
    asserts.equals(env, {"a": 3}, structs.to_dict(structs.merge(a, c)))

    return unittest.end(env)

merge_test = unittest.make(_merge_test)

def structs_test_suite():
    """Creates the test targets and test suite for structs.bzl tests."""
    unittest.suite(
        "structs_tests",
        to_dict_test,
        merge_test,
    )
