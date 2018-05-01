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

load("//:lib.bzl", "new_sets", "asserts", "unittest")


def _is_equal_test(ctx):
  """Unit tests for new_sets.is_equal."""

  # Note that if this test fails, the results for the other `sets` tests will
  # be inconclusive because they use `asserts.new_set_equals`, which in turn
  # calls `new_sets.is_equal`.
  env = unittest.begin(ctx)

  asserts.true(env, new_sets.is_equal(new_sets.make(), new_sets.make()))
  asserts.false(env, new_sets.is_equal(new_sets.make(), new_sets.make([1])))
  asserts.false(env, new_sets.is_equal(new_sets.make([1]), new_sets.make()))
  asserts.true(env, new_sets.is_equal(new_sets.make([1]), new_sets.make([1])))
  asserts.false(env, new_sets.is_equal(new_sets.make([1]), new_sets.make([1, 2])))
  asserts.false(env, new_sets.is_equal(new_sets.make([1]), new_sets.make([2])))
  asserts.false(env, new_sets.is_equal(new_sets.make([1]), new_sets.make([1, 2])))

  # Verify that the implementation is not using == on the sets directly.
  asserts.true(env, new_sets.is_equal(new_sets.make(depset([1])), new_sets.make(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.true(env, new_sets.is_equal(new_sets.make([1, 1]), new_sets.make([1])))

  unittest.end(env)

is_equal_test = unittest.make(_is_equal_test)


def _is_subset_test(ctx):
  """Unit tests for new_sets.is_subset."""
  env = unittest.begin(ctx)

  asserts.true(env, new_sets.is_subset(new_sets.make(), new_sets.make()))
  asserts.true(env, new_sets.is_subset(new_sets.make(), new_sets.make([1])))
  asserts.false(env, new_sets.is_subset(new_sets.make([1]), new_sets.make()))
  asserts.true(env, new_sets.is_subset(new_sets.make([1]), new_sets.make([1])))
  asserts.true(env, new_sets.is_subset(new_sets.make([1]), new_sets.make([1, 2])))
  asserts.false(env, new_sets.is_subset(new_sets.make([1]), new_sets.make([2])))
  asserts.true(env, new_sets.is_subset(new_sets.make([1]), new_sets.make(depset([1, 2]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.true(env, new_sets.is_subset(new_sets.make([1, 1]), new_sets.make([1, 2])))

  unittest.end(env)

is_subset_test = unittest.make(_is_subset_test)


def _disjoint_test(ctx):
  """Unit tests for new_sets.disjoint."""
  env = unittest.begin(ctx)

  asserts.true(env, new_sets.disjoint(new_sets.make(), new_sets.make()))
  asserts.true(env, new_sets.disjoint(new_sets.make(), new_sets.make([1])))
  asserts.true(env, new_sets.disjoint(new_sets.make([1]), new_sets.make()))
  asserts.false(env, new_sets.disjoint(new_sets.make([1]), new_sets.make([1])))
  asserts.false(env, new_sets.disjoint(new_sets.make([1]), new_sets.make([1, 2])))
  asserts.true(env, new_sets.disjoint(new_sets.make([1]), new_sets.make([2])))
  asserts.true(env, new_sets.disjoint(new_sets.make([1]), new_sets.make(depset([2]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.false(env, new_sets.disjoint(new_sets.make([1, 1]), new_sets.make([1, 2])))

  unittest.end(env)

disjoint_test = unittest.make(_disjoint_test)


def _intersection_test(ctx):
  """Unit tests for new_sets.intersection."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.make(), new_sets.intersection(new_sets.make(), new_sets.make()))
  asserts.new_set_equals(env, new_sets.make(), new_sets.intersection(new_sets.make(), new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make(), new_sets.intersection(new_sets.make([1]), new_sets.make()))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.intersection(new_sets.make([1]), new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.intersection(new_sets.make([1]), new_sets.make([1, 2])))
  asserts.new_set_equals(env, new_sets.make(), new_sets.intersection(new_sets.make([1]), new_sets.make([2])))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.intersection(new_sets.make([1]), new_sets.make(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.intersection(new_sets.make([1, 1]), new_sets.make([1, 2])))

  unittest.end(env)

intersection_test = unittest.make(_intersection_test)


def _union_test(ctx):
  """Unit tests for new_sets.union."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.make(), new_sets.union())
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.union(new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make(), new_sets.union(new_sets.make(), new_sets.make()))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.union(new_sets.make(), new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.union(new_sets.make([1]), new_sets.make()))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.union(new_sets.make([1]), new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make([1, 2]), new_sets.union(new_sets.make([1]), new_sets.make([1, 2])))
  asserts.new_set_equals(env, new_sets.make([1, 2]), new_sets.union(new_sets.make([1]), new_sets.make([2])))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.union(new_sets.make([1]), new_sets.make(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.new_set_equals(env, new_sets.make([1, 2]), new_sets.union(new_sets.make([1, 1]), new_sets.make([1, 2])))

  unittest.end(env)

union_test = unittest.make(_union_test)


def _difference_test(ctx):
  """Unit tests for new_sets.difference."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.make(), new_sets.difference(new_sets.make(), new_sets.make()))
  asserts.new_set_equals(env, new_sets.make(), new_sets.difference(new_sets.make(), new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.difference(new_sets.make([1]), new_sets.make()))
  asserts.new_set_equals(env, new_sets.make(), new_sets.difference(new_sets.make([1]), new_sets.make([1])))
  asserts.new_set_equals(env, new_sets.make(), new_sets.difference(new_sets.make([1]), new_sets.make([1, 2])))
  asserts.new_set_equals(env, new_sets.make([1]), new_sets.difference(new_sets.make([1]), new_sets.make([2])))
  asserts.new_set_equals(env, new_sets.make(), new_sets.difference(new_sets.make([1]), new_sets.make(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.new_set_equals(env, new_sets.make([2]), new_sets.difference(new_sets.make([1, 2]), new_sets.make([1, 1])))

  unittest.end(env)

difference_test = unittest.make(_difference_test)


def _to_list_test(ctx):
  """Unit tests for new_sets.to_list."""
  env = unittest.begin(ctx)

  asserts.equals(env, [], new_sets.to_list(new_sets.make()))
  asserts.equals(env, [1], new_sets.to_list(new_sets.make([1, 1, 1])))
  asserts.equals(env, [1, 2, 3], new_sets.to_list(new_sets.make([1, 2, 3])))

  unittest.end(env)

to_list_test = unittest.make(_to_list_test)


def _make_test(ctx):
  """Unit tests for new_sets.make."""
  env = unittest.begin(ctx)

  asserts.equals(env, {}, new_sets.make()._values)
  asserts.equals(env, {x: None for x in [1, 2, 3]}, new_sets.make([1, 1, 2, 2, 3, 3])._values)
  asserts.equals(env, {1: None, 2: None}, new_sets.make(depset([1, 2]))._values)

  unittest.end(env)

make_test = unittest.make(_make_test)


def _copy_test(ctx):
  """Unit tests for new_sets.copy."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.copy(new_sets.make()), new_sets.make())
  asserts.new_set_equals(env, new_sets.copy(new_sets.make([1, 2, 3])), new_sets.make([1, 2, 3]))
  # Ensure mutating the copy does not mutate the original
  original = new_sets.make([1, 2, 3])
  copy = new_sets.copy(original)
  copy._values[5] = None
  asserts.false(env, new_sets.is_equal(original, copy))

  unittest.end(env)

copy_test = unittest.make(_copy_test)


def _insert_test(ctx):
  """Unit tests for new_sets.insert."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.make([1, 2, 3]), new_sets.insert(new_sets.make([1, 2]), 3))
  # Ensure mutating the inserted set does mutate the original set.
  original = new_sets.make([1, 2, 3])
  after_insert = new_sets.insert(original, 4)
  asserts.new_set_equals(env, original, after_insert,
    msg="Insert creates a new set which is an O(n) operation, insert should be O(1).")

  unittest.end(env)

insert_test = unittest.make(_insert_test)


def _contains_test(ctx):
  """Unit tests for new_sets.contains."""
  env = unittest.begin(ctx)

  asserts.false(env, new_sets.contains(new_sets.make(), 1))
  asserts.true(env, new_sets.contains(new_sets.make([1]), 1))
  asserts.true(env, new_sets.contains(new_sets.make([1, 2]), 1))
  asserts.false(env, new_sets.contains(new_sets.make([2, 3]), 1))

  unittest.end(env)

contains_test = unittest.make(_contains_test)


def _length_test(ctx):
  """Unit test for new_sets.length."""
  env = unittest.begin(ctx)

  asserts.equals(env, 0, new_sets.length(new_sets.make()))
  asserts.equals(env, 1, new_sets.length(new_sets.make([1])))
  asserts.equals(env, 2, new_sets.length(new_sets.make([1, 2])))

  unittest.end(env)

length_test = unittest.make(_length_test)


def _remove_test(ctx):
  """Unit test for new_sets.remove."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.make([1, 2]), new_sets.remove(new_sets.make([1, 2, 3]), 3))
  # Ensure mutating the inserted set does mutate the original set.
  original = new_sets.make([1, 2, 3])
  after_removal = new_sets.remove(original, 3)
  asserts.new_set_equals(env, original, after_removal)

  unittest.end(env)

remove_test = unittest.make(_remove_test)

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
  )
