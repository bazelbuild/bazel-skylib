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

"""Unit tests for partial.bzl."""

load("//lib:partial.bzl", "partial")
load("//lib:unittest.bzl", "asserts", "unittest")

def _make_noargs_nokwargs():
    """Test utility for no args no kwargs case"""
    return 1

def _make_args_nokwargs(arg1, arg2, arg3):
    """Test utility for args no kwargs case"""
    return arg1 + arg2 + arg3

def _make_args_kwargs(arg1, arg2, arg3, **kwargs):
    """Test utility for args and kwargs case"""
    return arg1 + arg2 + arg3 + kwargs["x"] + kwargs["y"]

def _call_noargs_nokwargs(call_arg1):
    """Test utility no args no kwargs case where values passed from call site"""
    return call_arg1

def _call_args_nokwargs(func_arg1, call_arg1):
    """Test utility for args no kwargs case where values passed from call site"""
    return func_arg1 + call_arg1

def _call_args_kwargs(func_arg1, call_arg1, func_mult, call_mult):
    """Test utility for args and kwargs case where values passed from call site"""
    return (func_arg1 + call_arg1) * func_mult * call_mult

def _make_call_test(ctx):
    """Unit tests for partial.make and partial.call."""
    env = unittest.begin(ctx)

    # Test cases where there are no args (or kwargs) at the make site, only
    # at the call site.
    foo = partial.make(_make_noargs_nokwargs)
    asserts.equals(env, 1, partial.call(foo))

    foo = partial.make(_make_args_nokwargs)
    asserts.equals(env, 6, partial.call(foo, 1, 2, 3))

    foo = partial.make(_make_args_kwargs)
    asserts.equals(env, 15, partial.call(foo, 1, 2, 3, x = 4, y = 5))

    # Test cases where there are args (and/or kwargs) at the make site and the
    # call site.
    foo = partial.make(_call_noargs_nokwargs, 100)
    asserts.equals(env, 100, partial.call(foo))

    foo = partial.make(_call_args_nokwargs, 100)
    asserts.equals(env, 112, partial.call(foo, 12))

    foo = partial.make(_call_args_kwargs, 100, func_mult = 10)
    asserts.equals(env, 2240, partial.call(foo, 12, call_mult = 2))

    # Test case where there are args and kwargs ath the make site, and the call
    # site overrides some make site args.
    foo = partial.make(_call_args_kwargs, 100, func_mult = 10)
    asserts.equals(env, 1120, partial.call(foo, 12, func_mult = 5, call_mult = 2))

    return unittest.end(env)

make_call_test = unittest.make(_make_call_test)

def _is_instance_test(ctx):
    """Unit test for partial.is_instance."""
    env = unittest.begin(ctx)

    # We happen to use make_call_test here, but it could be any valid test rule.
    asserts.true(env, partial.is_instance(partial.make(make_call_test)))
    asserts.true(env, partial.is_instance(partial.make(make_call_test, timeout = "short")))
    asserts.true(env, partial.is_instance(partial.make(make_call_test, timeout = "short", tags = ["foo"])))
    asserts.false(env, partial.is_instance(None))
    asserts.false(env, partial.is_instance({}))
    asserts.false(env, partial.is_instance(struct(foo = 1)))
    asserts.false(env, partial.is_instance(struct(function = "not really function")))

    return unittest.end(env)

is_instance_test = unittest.make(_is_instance_test)

def partial_test_suite():
    """Creates the test targets and test suite for partial.bzl tests."""
    unittest.suite(
        "partial_tests",
        make_call_test,
        is_instance_test,
    )
