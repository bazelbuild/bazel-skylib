# Copyright 2023 The Bazel Authors. All rights reserved.
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

"""Tests for `lists` module."""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//lib:lists.bzl", "lists")

def _compact_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "empty list",
            items = [],
            exp = [],
        ),
        struct(
            msg = "list of None",
            items = [None, None, None],
            exp = [],
        ),
        struct(
            msg = "list with None and other",
            items = ["zebra", None, "apple"],
            exp = ["zebra", "apple"],
        ),
        struct(
            msg = "list without None",
            items = ["zebra", "apple"],
            exp = ["zebra", "apple"],
        ),
    ]
    for t in tests:
        actual = lists.compact(t.items)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

compact_test = unittest.make(_compact_test)

def _contains_test(ctx):
    env = unittest.begin(ctx)

    zebra = struct(name = "zebra")
    apple = struct(name = "apple")
    structs = [zebra, apple]

    tests = [
        struct(
            msg = "empty list",
            items = [],
            target = "apple",
            exp = False,
        ),
        struct(
            msg = "list does not contain target",
            items = ["zebra"],
            target = "apple",
            exp = False,
        ),
        struct(
            msg = "list contains target",
            items = ["zebra", "apple"],
            target = "apple",
            exp = True,
        ),
        struct(
            msg = "list with bool fn, found target",
            items = structs,
            target = lambda x: x.name == "apple",
            exp = True,
        ),
        struct(
            msg = "list with bool fn, not found target",
            items = structs,
            target = lambda x: x.name == "does_not_exist",
            exp = False,
        ),
    ]
    for t in tests:
        actual = lists.contains(t.items, t.target)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

contains_test = unittest.make(_contains_test)

def _find_test(ctx):
    env = unittest.begin(ctx)

    zebra = struct(name = "zebra")
    apple = struct(name = "apple")
    items = [zebra, apple]

    tests = [
        struct(
            msg = "target not found",
            bool_fn = lambda x: x.name == "does_not_exist",
            exp = None,
        ),
        struct(
            msg = "target found, first item",
            bool_fn = lambda x: x.name == "zebra",
            exp = zebra,
        ),
        struct(
            msg = "target found, later item",
            bool_fn = lambda x: x.name == "apple",
            exp = apple,
        ),
    ]
    for t in tests:
        actual = lists.find(items, t.bool_fn)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

find_test = unittest.make(_find_test)

def _flatten_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "not a list",
            items = "foo",
            exp = ["foo"],
        ),
        struct(
            msg = "already flat list",
            items = ["foo", "bar"],
            exp = ["foo", "bar"],
        ),
        struct(
            msg = "multi-level list",
            items = ["foo", ["alpha", ["omega"]], ["chicken", "cow"]],
            exp = ["foo", "alpha", "omega", "chicken", "cow"],
        ),
    ]
    for t in tests:
        actual = lists.flatten(t.items)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

flatten_test = unittest.make(_flatten_test)

def _filter_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "empty list",
            items = [],
            fn = lambda x: x > 0,
            exp = [],
        ),
        struct(
            msg = "some matching values",
            items = [0, 4, 3, 0],
            fn = lambda x: x > 0,
            exp = [4, 3],
        ),
    ]
    for t in tests:
        actual = lists.filter(t.items, t.fn)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

filter_test = unittest.make(_filter_test)

def _map_test(ctx):
    env = unittest.begin(ctx)

    tests = [
        struct(
            msg = "empty list",
            items = [],
            fn = lambda x: x + 1,
            exp = [],
        ),
        struct(
            msg = "non-empty list",
            items = [-1, 0, 6, 3],
            fn = lambda x: x + 1,
            exp = [0, 1, 7, 4],
        ),
    ]
    for t in tests:
        actual = lists.map(t.items, t.fn)
        asserts.equals(env, t.exp, actual, t.msg)

    return unittest.end(env)

map_test = unittest.make(_map_test)

def _avoid_recursion_test(ctx):
    env = unittest.begin(ctx)

    fruits = ["apple", "pear", "cherry"]
    fav_fruits = ["apple", "cherry", "banana"]

    # Find the first favorite fruit
    actual = lists.find(
        fruits,
        lambda x: lists.contains(fav_fruits, x),
    )
    asserts.equals(env, "apple", actual)

    # This is admittedly a very inefficient way to use these functions
    # together. It is here to ensure that a recursion error does not occur.
    actual = lists.filter(
        fruits,
        lambda x: lists.contains(lists.compact(fav_fruits), x),
    )
    asserts.equals(env, ["apple", "cherry"], actual)

    return unittest.end(env)

avoid_recursion_test = unittest.make(_avoid_recursion_test)

def lists_test_suite():
    return unittest.suite(
        "lists_tests",
        compact_test,
        contains_test,
        find_test,
        flatten_test,
        filter_test,
        map_test,
        avoid_recursion_test,
    )
