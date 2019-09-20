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
"""Unit tests for types.bzl."""

load("//lib:types.bzl", "types")
load("//lib:unittest.bzl", "asserts", "unittest")
load("//lib:new_sets.bzl", "sets")

def _a_function():
    """A dummy function for testing."""
    pass

def _is_string_test(ctx):
    """Unit tests for types.is_string."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_string(""))
    asserts.true(env, types.is_string("string"))

    asserts.false(env, types.is_string(4))
    asserts.false(env, types.is_string([1]))
    asserts.false(env, types.is_string({}))
    asserts.false(env, types.is_string(()))
    asserts.false(env, types.is_string(True))
    asserts.false(env, types.is_string(None))
    asserts.false(env, types.is_string(_a_function))
    asserts.false(env, types.is_string(depset()))

    return unittest.end(env)

is_string_test = unittest.make(_is_string_test)

def _is_bool_test(ctx):
    """Unit tests for types.is_bool."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_bool(True))
    asserts.true(env, types.is_bool(False))

    asserts.false(env, types.is_bool(4))
    asserts.false(env, types.is_bool([1]))
    asserts.false(env, types.is_bool({}))
    asserts.false(env, types.is_bool(()))
    asserts.false(env, types.is_bool(""))
    asserts.false(env, types.is_bool(None))
    asserts.false(env, types.is_bool(_a_function))
    asserts.false(env, types.is_bool(depset()))

    return unittest.end(env)

is_bool_test = unittest.make(_is_bool_test)

def _is_list_test(ctx):
    """Unit tests for types.is_list."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_list([]))
    asserts.true(env, types.is_list([1]))

    asserts.false(env, types.is_list(4))
    asserts.false(env, types.is_list("s"))
    asserts.false(env, types.is_list({}))
    asserts.false(env, types.is_list(()))
    asserts.false(env, types.is_list(True))
    asserts.false(env, types.is_list(None))
    asserts.false(env, types.is_list(_a_function))
    asserts.false(env, types.is_list(depset()))

    return unittest.end(env)

is_list_test = unittest.make(_is_list_test)

def _is_none_test(ctx):
    """Unit tests for types.is_none."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_none(None))

    asserts.false(env, types.is_none(4))
    asserts.false(env, types.is_none("s"))
    asserts.false(env, types.is_none({}))
    asserts.false(env, types.is_none(()))
    asserts.false(env, types.is_none(True))
    asserts.false(env, types.is_none([]))
    asserts.false(env, types.is_none([1]))
    asserts.false(env, types.is_none(_a_function))
    asserts.false(env, types.is_none(depset()))

    return unittest.end(env)

is_none_test = unittest.make(_is_none_test)

def _is_int_test(ctx):
    """Unit tests for types.is_int."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_int(1))
    asserts.true(env, types.is_int(-1))

    asserts.false(env, types.is_int("s"))
    asserts.false(env, types.is_int({}))
    asserts.false(env, types.is_int(()))
    asserts.false(env, types.is_int(True))
    asserts.false(env, types.is_int([]))
    asserts.false(env, types.is_int([1]))
    asserts.false(env, types.is_int(None))
    asserts.false(env, types.is_int(_a_function))
    asserts.false(env, types.is_int(depset()))

    return unittest.end(env)

is_int_test = unittest.make(_is_int_test)

def _is_tuple_test(ctx):
    """Unit tests for types.is_tuple."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_tuple(()))
    asserts.true(env, types.is_tuple((1,)))

    asserts.false(env, types.is_tuple(1))
    asserts.false(env, types.is_tuple("s"))
    asserts.false(env, types.is_tuple({}))
    asserts.false(env, types.is_tuple(True))
    asserts.false(env, types.is_tuple([]))
    asserts.false(env, types.is_tuple([1]))
    asserts.false(env, types.is_tuple(None))
    asserts.false(env, types.is_tuple(_a_function))
    asserts.false(env, types.is_tuple(depset()))

    return unittest.end(env)

is_tuple_test = unittest.make(_is_tuple_test)

def _is_dict_test(ctx):
    """Unit tests for types.is_dict."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_dict({}))
    asserts.true(env, types.is_dict({"key": "value"}))

    asserts.false(env, types.is_dict(1))
    asserts.false(env, types.is_dict("s"))
    asserts.false(env, types.is_dict(()))
    asserts.false(env, types.is_dict(True))
    asserts.false(env, types.is_dict([]))
    asserts.false(env, types.is_dict([1]))
    asserts.false(env, types.is_dict(None))
    asserts.false(env, types.is_dict(_a_function))
    asserts.false(env, types.is_dict(depset()))

    return unittest.end(env)

is_dict_test = unittest.make(_is_dict_test)

def _is_function_test(ctx):
    """Unit tests for types.is_function."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_function(_a_function))

    asserts.false(env, types.is_function({}))
    asserts.false(env, types.is_function(1))
    asserts.false(env, types.is_function("s"))
    asserts.false(env, types.is_function(()))
    asserts.false(env, types.is_function(True))
    asserts.false(env, types.is_function([]))
    asserts.false(env, types.is_function([1]))
    asserts.false(env, types.is_function(None))
    asserts.false(env, types.is_function(depset()))

    return unittest.end(env)

is_function_test = unittest.make(_is_function_test)

def _is_depset_test(ctx):
    """Unit tests for types.is_depset."""

    env = unittest.begin(ctx)

    asserts.true(env, types.is_depset(depset()))
    asserts.true(env, types.is_depset(depset(["foo"])))
    asserts.true(env, types.is_depset(
        depset(["foo"], transitive = [depset(["bar", "baz"])]),
    ))

    asserts.false(env, types.is_depset({}))
    asserts.false(env, types.is_depset(1))
    asserts.false(env, types.is_depset("s"))
    asserts.false(env, types.is_depset(()))
    asserts.false(env, types.is_depset(True))
    asserts.false(env, types.is_depset([]))
    asserts.false(env, types.is_depset([1]))
    asserts.false(env, types.is_depset(None))

    return unittest.end(env)

is_depset_test = unittest.make(_is_depset_test)

def _is_set_test(ctx):
    """Unit test for types.is_set."""
    env = unittest.begin(ctx)

    asserts.true(env, types.is_set(sets.make()))
    asserts.true(env, types.is_set(sets.make([1])))
    asserts.false(env, types.is_set(None))
    asserts.false(env, types.is_set({}))
    asserts.false(env, types.is_set(struct(foo = 1)))
    asserts.false(env, types.is_set(struct(_values = "not really values")))

    return unittest.end(env)

is_set_test = unittest.make(_is_set_test)

def types_test_suite():
    """Creates the test targets and test suite for types.bzl tests."""
    unittest.suite(
        "types_tests",
        is_list_test,
        is_string_test,
        is_bool_test,
        is_none_test,
        is_int_test,
        is_tuple_test,
        is_dict_test,
        is_function_test,
        is_depset_test,
        is_set_test,
    )
