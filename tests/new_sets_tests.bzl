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

"""Unit tests for new_sets.bzl."""

load("//lib:new_sets.bzl", "sets")
load("//lib:unittest.bzl", "asserts", "unittest")

def _is_equal_test(ctx):
    """Unit tests for sets.is_equal."""

    # Note that if this test fails, the results for the other `sets` tests will
    # be inconclusive because they use `asserts.new_set_equals`, which in turn
    # calls `sets.is_equal`.
    env = unittest.begin(ctx)

    asserts.true(env, sets.is_equal(sets.make(), sets.make()))
    asserts.false(env, sets.is_equal(sets.make(), sets.make([1])))
    asserts.false(env, sets.is_equal(sets.make([1]), sets.make()))
    asserts.true(env, sets.is_equal(sets.make([1]), sets.make([1])))
    asserts.false(env, sets.is_equal(sets.make([1]), sets.make([1, 2])))
    asserts.false(env, sets.is_equal(sets.make([1]), sets.make([2])))
    asserts.false(env, sets.is_equal(sets.make([1]), sets.make([1, 2])))

    # If passing a list, verify that duplicate elements are ignored.
    asserts.true(env, sets.is_equal(sets.make([1, 1]), sets.make([1])))

    return unittest.end(env)

is_equal_test = unittest.make(_is_equal_test)

def _is_subset_test(ctx):
    """Unit tests for sets.is_subset."""
    env = unittest.begin(ctx)

    asserts.true(env, sets.is_subset(sets.make(), sets.make()))
    asserts.true(env, sets.is_subset(sets.make(), sets.make([1])))
    asserts.false(env, sets.is_subset(sets.make([1]), sets.make()))
    asserts.true(env, sets.is_subset(sets.make([1]), sets.make([1])))
    asserts.true(env, sets.is_subset(sets.make([1]), sets.make([1, 2])))
    asserts.false(env, sets.is_subset(sets.make([1]), sets.make([2])))

    # If passing a list, verify that duplicate elements are ignored.
    asserts.true(env, sets.is_subset(sets.make([1, 1]), sets.make([1, 2])))

    return unittest.end(env)

is_subset_test = unittest.make(_is_subset_test)

def _disjoint_test(ctx):
    """Unit tests for sets.disjoint."""
    env = unittest.begin(ctx)

    asserts.true(env, sets.disjoint(sets.make(), sets.make()))
    asserts.true(env, sets.disjoint(sets.make(), sets.make([1])))
    asserts.true(env, sets.disjoint(sets.make([1]), sets.make()))
    asserts.false(env, sets.disjoint(sets.make([1]), sets.make([1])))
    asserts.false(env, sets.disjoint(sets.make([1]), sets.make([1, 2])))
    asserts.true(env, sets.disjoint(sets.make([1]), sets.make([2])))

    # If passing a list, verify that duplicate elements are ignored.
    asserts.false(env, sets.disjoint(sets.make([1, 1]), sets.make([1, 2])))

    return unittest.end(env)

disjoint_test = unittest.make(_disjoint_test)

def _intersection_test(ctx):
    """Unit tests for sets.intersection."""
    env = unittest.begin(ctx)

    asserts.new_set_equals(env, sets.make(), sets.intersection(sets.make(), sets.make()))
    asserts.new_set_equals(env, sets.make(), sets.intersection(sets.make(), sets.make([1])))
    asserts.new_set_equals(env, sets.make(), sets.intersection(sets.make([1]), sets.make()))
    asserts.new_set_equals(env, sets.make([1]), sets.intersection(sets.make([1]), sets.make([1])))
    asserts.new_set_equals(env, sets.make([1]), sets.intersection(sets.make([1]), sets.make([1, 2])))
    asserts.new_set_equals(env, sets.make(), sets.intersection(sets.make([1]), sets.make([2])))

    # If passing a list, verify that duplicate elements are ignored.
    asserts.new_set_equals(env, sets.make([1]), sets.intersection(sets.make([1, 1]), sets.make([1, 2])))

    return unittest.end(env)

intersection_test = unittest.make(_intersection_test)

def _union_test(ctx):
    """Unit tests for sets.union."""
    env = unittest.begin(ctx)

    asserts.new_set_equals(env, sets.make(), sets.union())
    asserts.new_set_equals(env, sets.make([1]), sets.union(sets.make([1])))
    asserts.new_set_equals(env, sets.make(), sets.union(sets.make(), sets.make()))
    asserts.new_set_equals(env, sets.make([1]), sets.union(sets.make(), sets.make([1])))
    asserts.new_set_equals(env, sets.make([1]), sets.union(sets.make([1]), sets.make()))
    asserts.new_set_equals(env, sets.make([1]), sets.union(sets.make([1]), sets.make([1])))
    asserts.new_set_equals(env, sets.make([1, 2]), sets.union(sets.make([1]), sets.make([1, 2])))
    asserts.new_set_equals(env, sets.make([1, 2]), sets.union(sets.make([1]), sets.make([2])))

    # If passing a list, verify that duplicate elements are ignored.
    asserts.new_set_equals(env, sets.make([1, 2]), sets.union(sets.make([1, 1]), sets.make([1, 2])))

    return unittest.end(env)

union_test = unittest.make(_union_test)

def _difference_test(ctx):
    """Unit tests for sets.difference."""
    env = unittest.begin(ctx)

    asserts.new_set_equals(env, sets.make(), sets.difference(sets.make(), sets.make()))
    asserts.new_set_equals(env, sets.make(), sets.difference(sets.make(), sets.make([1])))
    asserts.new_set_equals(env, sets.make([1]), sets.difference(sets.make([1]), sets.make()))
    asserts.new_set_equals(env, sets.make(), sets.difference(sets.make([1]), sets.make([1])))
    asserts.new_set_equals(env, sets.make(), sets.difference(sets.make([1]), sets.make([1, 2])))
    asserts.new_set_equals(env, sets.make([1]), sets.difference(sets.make([1]), sets.make([2])))

    # If passing a list, verify that duplicate elements are ignored.
    asserts.new_set_equals(env, sets.make([2]), sets.difference(sets.make([1, 2]), sets.make([1, 1])))

    return unittest.end(env)

difference_test = unittest.make(_difference_test)

def _to_list_test(ctx):
    """Unit tests for sets.to_list."""
    env = unittest.begin(ctx)

    asserts.equals(env, [], sets.to_list(sets.make()))
    asserts.equals(env, [1], sets.to_list(sets.make([1, 1, 1])))
    asserts.equals(env, [1, 2, 3], sets.to_list(sets.make([1, 2, 3])))

    return unittest.end(env)

to_list_test = unittest.make(_to_list_test)

def _make_test(ctx):
    """Unit tests for sets.make."""
    env = unittest.begin(ctx)

    asserts.equals(env, {}, sets.make()._values)
    asserts.equals(env, {x: None for x in [1, 2, 3]}, sets.make([1, 1, 2, 2, 3, 3])._values)

    return unittest.end(env)

make_test = unittest.make(_make_test)

def _copy_test(ctx):
    """Unit tests for sets.copy."""
    env = unittest.begin(ctx)

    asserts.new_set_equals(env, sets.copy(sets.make()), sets.make())
    asserts.new_set_equals(env, sets.copy(sets.make([1, 2, 3])), sets.make([1, 2, 3]))

    # Ensure mutating the copy does not mutate the original
    original = sets.make([1, 2, 3])
    copy = sets.copy(original)
    copy._values[5] = None
    asserts.false(env, sets.is_equal(original, copy))

    return unittest.end(env)

copy_test = unittest.make(_copy_test)

def _insert_test(ctx):
    """Unit tests for sets.insert."""
    env = unittest.begin(ctx)

    asserts.new_set_equals(env, sets.make([1, 2, 3]), sets.insert(sets.make([1, 2]), 3))

    # Ensure mutating the inserted set does mutate the original set.
    original = sets.make([1, 2, 3])
    after_insert = sets.insert(original, 4)
    asserts.new_set_equals(
        env,
        original,
        after_insert,
        msg = "Insert creates a new set which is an O(n) operation, insert should be O(1).",
    )

    return unittest.end(env)

insert_test = unittest.make(_insert_test)

def _contains_test(ctx):
    """Unit tests for sets.contains."""
    env = unittest.begin(ctx)

    asserts.false(env, sets.contains(sets.make(), 1))
    asserts.true(env, sets.contains(sets.make([1]), 1))
    asserts.true(env, sets.contains(sets.make([1, 2]), 1))
    asserts.false(env, sets.contains(sets.make([2, 3]), 1))

    return unittest.end(env)

contains_test = unittest.make(_contains_test)

def _length_test(ctx):
    """Unit test for sets.length."""
    env = unittest.begin(ctx)

    asserts.equals(env, 0, sets.length(sets.make()))
    asserts.equals(env, 1, sets.length(sets.make([1])))
    asserts.equals(env, 2, sets.length(sets.make([1, 2])))

    return unittest.end(env)

length_test = unittest.make(_length_test)

def _remove_test(ctx):
    """Unit test for sets.remove."""
    env = unittest.begin(ctx)

    asserts.new_set_equals(env, sets.make([1, 2]), sets.remove(sets.make([1, 2, 3]), 3))

    # Ensure mutating the inserted set does mutate the original set.
    original = sets.make([1, 2, 3])
    after_removal = sets.remove(original, 3)
    asserts.new_set_equals(env, original, after_removal)

    return unittest.end(env)

remove_test = unittest.make(_remove_test)

def _repr_str_test(ctx):
    """Unit test for sets.repr and sets.str."""
    env = unittest.begin(ctx)

    asserts.equals(env, "[]", sets.repr(sets.make()))
    asserts.equals(env, "[1]", sets.repr(sets.make([1])))
    asserts.equals(env, "[1, 2]", sets.repr(sets.make([1, 2])))

    asserts.equals(env, "[]", sets.str(sets.make()))
    asserts.equals(env, "[1]", sets.str(sets.make([1])))
    asserts.equals(env, "[1, 2]", sets.str(sets.make([1, 2])))

    return unittest.end(env)

repr_str_test = unittest.make(_repr_str_test)

def new_sets_test_suite():
    """Creates the test targets and test suite for new_sets.bzl tests."""
    unittest.suite(
        "new_sets_tests",
        disjoint_test,
        intersection_test,
        is_equal_test,
        is_subset_test,
        difference_test,
        union_test,
        to_list_test,
        make_test,
        copy_test,
        insert_test,
        contains_test,
        length_test,
        remove_test,
        repr_str_test,
    )
