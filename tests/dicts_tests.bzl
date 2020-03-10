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

"""Unit tests for dicts.bzl."""

load("//lib:dicts.bzl", "dicts")
load("//lib:unittest.bzl", "asserts", "unittest")

def _shared_add_tests(env, method):
    # Test zero- and one-argument behavior.
    asserts.equals(env, {}, method())
    asserts.equals(env, {"a": 1}, method({"a": 1}))
    asserts.equals(env, {"a": 1}, method(a = 1))
    asserts.equals(env, {"a": 1, "b": 2}, method({"a": 1}, b = 2))

    # Test simple two-argument behavior.
    asserts.equals(env, {"a": 1, "b": 2}, method({"a": 1}, {"b": 2}))
    asserts.equals(env, {"a": 1, "b": 2, "c": 3}, method({"a": 1}, {"b": 2}, c = 3))

    # Test simple more-than-two-argument behavior.
    asserts.equals(
        env,
        {"a": 1, "b": 2, "c": 3, "d": 4},
        method({"a": 1}, {"b": 2}, {"c": 3}, {"d": 4}),
    )
    asserts.equals(
        env,
        {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5},
        method({"a": 1}, {"b": 2}, {"c": 3}, {"d": 4}, e = 5),
    )

    # Test some other boundary cases.
    asserts.equals(env, {"a": 1}, method({"a": 1}, {}))

    # Since dictionaries are passed around by reference, make sure that the
    # result of method is always a *copy* by modifying it afterwards and
    # ensuring that the original argument doesn't also reflect the change. We do
    # this to protect against someone who might attempt to optimize the function
    # by returning the argument itself in the one-argument case.
    original = {"a": 1}
    result = method(original)
    result["a"] = 2
    asserts.equals(env, 1, original["a"])


def _add_test(ctx):
    """Unit tests for dicts.add."""
    env = unittest.begin(ctx)
    
    _shared_add_tests(env, dicts.add)

    # Test same-key overriding.
    asserts.equals(env, {"a": 100}, dicts.add({"a": 1}, {"a": 100}))
    asserts.equals(env, {"a": 100}, dicts.add({"a": 1}, a = 100))
    asserts.equals(env, {"a": 10}, dicts.add({"a": 1}, {"a": 100}, {"a": 10}))
    asserts.equals(env, {"a": 10}, dicts.add({"a": 1}, {"a": 100}, a = 10))
    asserts.equals(
        env,
        {"a": 100, "b": 10},
        dicts.add({"a": 1}, {"a": 100}, {"b": 10}),
    )
    asserts.equals(env, {"a": 10}, dicts.add({"a": 1}, {}, {"a": 10}))
    asserts.equals(env, {"a": 10}, dicts.add({"a": 1}, {}, a = 10))
    asserts.equals(
        env,
        {"a": 10, "b": 5},
        dicts.add({"a": 1}, {"a": 10, "b": 5}),
    )
    asserts.equals(
        env,
        {"a": 10, "b": 5},
        dicts.add({"a": 1}, a = 10, b = 5),
    )

    return unittest.end(env)
    
add_test = unittest.make(_add_test)
    
def _unique_add_test(ctx):
    """Unit tests for dicts.unique_add."""
    env = unittest.begin(ctx)

    _shared_add_tests(env, dicts.unique_add)

    return unittest.end(env)

unique_add_test = unittest.make(_unique_add_test)

def _without_test(ctx):
    """Unit tests for dicts.without."""
    env = unittest.begin(ctx)

    asserts.equals(env, {"a": 100, "b": "c"}, dicts.without({"a": 100, "b": "c"}))
    
    asserts.equals(env, {"a": 100, "b": "c"}, dicts.without({"a": 100, "b": "c"}, "c"))
    
    asserts.equals(env, {"b": "c"}, dicts.without({"a": 100, "b": "c"}, "a"))

    return unittest.end(env)
    
without_test = unittest.make(_without_test)

def _only_test(ctx):
    """Unit tests for dicts.only."""
    env = unittest.begin(ctx)

    asserts.equals(env, {}, dicts.only({"a": 100, "b": 100}))
    
    asserts.equals(env, {}, dicts.only({"a": 100, "b": 100}, "c"))
    
    asserts.equals(env, {"a": 100}, dicts.only({"a": 100, "b": "c"}, "a"))
    
    return unittest.end(env)
    
only_test = unittest.make(_only_test)

def dicts_test_suite():
    """Creates the test targets and test suite for dicts.bzl tests."""
    unittest.suite(
        "dicts_tests",
        add_test,
        unique_add_test,
        without_test,
        only_test,
    )
