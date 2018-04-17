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

"""Unit tests for new_sets.bzl."""

load("//:lib.bzl", "new_sets", "asserts", "unittest")


def _is_equal_test(ctx):
  """Unit tests for new_sets.is_equal.

  Note that if this test fails, the results for the other `sets` tests will be
  inconclusive because they use `asserts.new_set_equals`, which in turn calls
  `new_sets.is_equal`.
  """
  env = unittest.begin(ctx)

  asserts.true(env, new_sets.is_equal(new_sets.set(), new_sets.set()))
  asserts.false(env, new_sets.is_equal(new_sets.set(), new_sets.set([1])))
  asserts.false(env, new_sets.is_equal(new_sets.set([1]), new_sets.set()))
  asserts.true(env, new_sets.is_equal(new_sets.set([1]), new_sets.set([1])))
  asserts.false(env, new_sets.is_equal(new_sets.set([1]), new_sets.set([1, 2])))
  asserts.false(env, new_sets.is_equal(new_sets.set([1]), new_sets.set([2])))
  asserts.false(env, new_sets.is_equal(new_sets.set([1]), new_sets.set([1, 2])))

  # Verify that the implementation is not using == on the sets directly.
  asserts.true(env, new_sets.is_equal(new_sets.set(depset([1])), new_sets.set(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.true(env, new_sets.is_equal(new_sets.set([1, 1]), new_sets.set([1])))

  unittest.end(env)

is_equal_test = unittest.make(_is_equal_test)


def _is_subset_test(ctx):
  """Unit tests for new_sets.is_subset."""
  env = unittest.begin(ctx)

  asserts.true(env, new_sets.is_subset(new_sets.set(), new_sets.set()))
  asserts.true(env, new_sets.is_subset(new_sets.set(), new_sets.set([1])))
  asserts.false(env, new_sets.is_subset(new_sets.set([1]), new_sets.set()))
  asserts.true(env, new_sets.is_subset(new_sets.set([1]), new_sets.set([1])))
  asserts.true(env, new_sets.is_subset(new_sets.set([1]), new_sets.set([1, 2])))
  asserts.false(env, new_sets.is_subset(new_sets.set([1]), new_sets.set([2])))
  asserts.true(env, new_sets.is_subset(new_sets.set([1]), new_sets.set(depset([1, 2]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.true(env, new_sets.is_subset(new_sets.set([1, 1]), new_sets.set([1, 2])))

  unittest.end(env)

is_subset_test = unittest.make(_is_subset_test)


def _disjoint_test(ctx):
  """Unit tests for new_sets.disjoint."""
  env = unittest.begin(ctx)

  asserts.true(env, new_sets.disjoint(new_sets.set(), new_sets.set()))
  asserts.true(env, new_sets.disjoint(new_sets.set(), new_sets.set([1])))
  asserts.true(env, new_sets.disjoint(new_sets.set([1]), new_sets.set()))
  asserts.false(env, new_sets.disjoint(new_sets.set([1]), new_sets.set([1])))
  asserts.false(env, new_sets.disjoint(new_sets.set([1]), new_sets.set([1, 2])))
  asserts.true(env, new_sets.disjoint(new_sets.set([1]), new_sets.set([2])))
  asserts.true(env, new_sets.disjoint(new_sets.set([1]), new_sets.set(depset([2]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.false(env, new_sets.disjoint(new_sets.set([1, 1]), new_sets.set([1, 2])))

  unittest.end(env)

disjoint_test = unittest.make(_disjoint_test)


def _intersection_test(ctx):
  """Unit tests for new_sets.intersection."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.set(), new_sets.intersection(new_sets.set(), new_sets.set()))
  asserts.new_set_equals(env, new_sets.set(), new_sets.intersection(new_sets.set(), new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set(), new_sets.intersection(new_sets.set([1]), new_sets.set()))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.intersection(new_sets.set([1]), new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.intersection(new_sets.set([1]), new_sets.set([1, 2])))
  asserts.new_set_equals(env, new_sets.set(), new_sets.intersection(new_sets.set([1]), new_sets.set([2])))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.intersection(new_sets.set([1]), new_sets.set(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.intersection(new_sets.set([1, 1]), new_sets.set([1, 2])))

  unittest.end(env)

intersection_test = unittest.make(_intersection_test)


def _union_test(ctx):
  """Unit tests for new_sets.union."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.set(), new_sets.union())
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.union(new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set(), new_sets.union(new_sets.set(), new_sets.set()))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.union(new_sets.set(), new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.union(new_sets.set([1]), new_sets.set()))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.union(new_sets.set([1]), new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set([1, 2]), new_sets.union(new_sets.set([1]), new_sets.set([1, 2])))
  asserts.new_set_equals(env, new_sets.set([1, 2]), new_sets.union(new_sets.set([1]), new_sets.set([2])))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.union(new_sets.set([1]), new_sets.set(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.new_set_equals(env, new_sets.set([1, 2]), new_sets.union(new_sets.set([1, 1]), new_sets.set([1, 2])))

  unittest.end(env)

union_test = unittest.make(_union_test)


def _difference_test(ctx):
  """Unit tests for new_sets.difference."""
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.set(), new_sets.difference(new_sets.set(), new_sets.set()))
  asserts.new_set_equals(env, new_sets.set(), new_sets.difference(new_sets.set(), new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.difference(new_sets.set([1]), new_sets.set()))
  asserts.new_set_equals(env, new_sets.set(), new_sets.difference(new_sets.set([1]), new_sets.set([1])))
  asserts.new_set_equals(env, new_sets.set(), new_sets.difference(new_sets.set([1]), new_sets.set([1, 2])))
  asserts.new_set_equals(env, new_sets.set([1]), new_sets.difference(new_sets.set([1]), new_sets.set([2])))
  asserts.new_set_equals(env, new_sets.set(), new_sets.difference(new_sets.set([1]), new_sets.set(depset([1]))))

  # If passing a list, verify that duplicate elements are ignored.
  asserts.new_set_equals(env, new_sets.set([2]), new_sets.difference(new_sets.set([1, 2]), new_sets.set([1, 1])))

  unittest.end(env)

difference_test = unittest.make(_difference_test)


def _to_list_test(ctx):
  """Unit tests for new_sets.to_list."""
  env = unittest.begin(ctx)

  asserts.equals(env, [], new_sets.to_list(new_sets.set()))
  asserts.equals(env, [1], new_sets.to_list(new_sets.set([1, 1, 1])))
  asserts.equals(env, [1, 2, 3], new_sets.to_list(new_sets.set([1, 2, 3])))

  unittest.end(env)

to_list_test = unttest.make(_to_list_test)


def _set_test(ctx):
  """Unit tests for new_sets.set."""
  env = unittest.begin(ctx)

  asserts.equals(env, {}, new_sets.sets()._values)
  asserts.equals(env, {x: None for x in [1, 2, 3]}, new_sets.sets([1, 1, 2, 2, 3, 3])._values)
  asserts.equals(env, {1: None, 2: None}, new_sets.sets(depset(1, 2))._values)

  unittest.end(env)

set_test = unittest.make(_set_test)


def _copy_test(ctx):
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.copy(new_sets.set()), new_sets.set())
  asserts.new_set_equals(env, new_sets.copy(new_sets.set([1, 2, 3])), new_sets.set([1, 2, 3]))
  # Ensure mutating the copy does not mutate the original
  original = new_sets.set([1, 2, 3])
  copy = new_sets.copy(original)
  copy._values[5] = None
  asserts.false(env, new_sets.is_equal(original, copy))

  unittest.end(env)

copy_test = unittest.make(_copy_test)


def _insert_test(ctx):
  env = unittest.begin(ctx)

  asserts.new_set_equals(env, new_sets.set([1, 2, 3]), new_sets.insert(new_sets.set([1, 2]), 3))
  # Ensure mutating the inserted set does mutate the original set.
  original = new_sets.set([1, 2, 3])
  asserts.new_set_equals(env, new_sets.is_equal(original, new_sets.insert(original, 6)))

  unittest.end(env)

insert_test = unittest.make(_insert_test)


def _contains_test(ctx):
  env = unittest.begin(ctx)

  asserts.false(env, new_sets.contains(new_sets.set(), 1))
  asserts.true(env, new_sets.contains(new_sets.set([1]), 1))
  asserts.true(env, new_sets.contains(new_sets.set([1, 2]), 1))
  asserts.false(env, new_sets.contains(new_sets.set([2, 3]), 1))

  unittest.end(env)

contains_test = unittest.make(_contains_test)




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
      set_test,
      copy_test,
      insert_test,
      contains_test,
  )