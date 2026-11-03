# Copyright 2025 The Bazel Authors. All rights reserved.
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

"""Unit tests for itertools.bzl."""

load("//lib:itertools.bzl", "itertools")
load("//lib:unittest.bzl", "asserts", "unittest")

def _accumulate_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(env, [1, 3, 6, 10, 15], itertools.accumulate([1, 2, 3, 4, 5]))
    asserts.equals(
        env,
        [1, 2, 6, 24, 120],
        itertools.accumulate([1, 2, 3, 4, 5], lambda x, y: x * y),
    )
    asserts.equals(
        env,
        [100, 101, 103, 106, 110, 115],
        itertools.accumulate([1, 2, 3, 4, 5], initial = 100),
    )
    return unittest.end(env)

def _unique_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, [2, 1, 0], itertools._unique([2, 1, 0, 1]))
    return unittest.end(env)

def _is_sorted_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, False, itertools._is_sorted([1, 0, 2], strict = True))
    asserts.equals(env, False, itertools._is_sorted([0, 1, 1, 2], strict = True))
    asserts.equals(env, True, itertools._is_sorted([0, 1, 2], strict = True))
    asserts.equals(env, False, itertools._is_sorted([1, 0, 2], strict = False))
    asserts.equals(env, True, itertools._is_sorted([0, 1, 1, 2], strict = False))
    asserts.equals(env, True, itertools._is_sorted([0, 1, 2], strict = False))
    return unittest.end(env)

def _pairwise_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, [(1, 2), (2, 3), (3, 4)], itertools.pairwise([1, 2, 3, 4]))
    return unittest.end(env)

def _product_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [(0, 2), (0, 3), (1, 2), (1, 3)],
        itertools.product([0, 1], [2, 3]),
    )
    asserts.equals(
        env,
        [(0, 0), (0, 1), (1, 0), (1, 1)],
        itertools.product([0, 1], repeat = 2),
    )
    asserts.equals(
        env,
        [
            (0, 1, 0, 1),
            (0, 1, 0, 2),
            (0, 1, 1, 1),
            (0, 1, 1, 2),
            (0, 2, 0, 1),
            (0, 2, 0, 2),
            (0, 2, 1, 1),
            (0, 2, 1, 2),
            (1, 1, 0, 1),
            (1, 1, 0, 2),
            (1, 1, 1, 1),
            (1, 1, 1, 2),
            (1, 2, 0, 1),
            (1, 2, 0, 2),
            (1, 2, 1, 1),
            (1, 2, 1, 2),
        ],
        itertools.product([0, 1], [1, 2], repeat = 2),
    )
    return unittest.end(env)

def _permutations_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [(0, 1), (0, 2), (1, 0), (1, 2), (2, 0), (2, 1)],
        itertools.permutations([0, 1, 2], 2),
    )
    asserts.equals(
        env,
        [
            (0, 1, 2),
            (0, 2, 1),
            (1, 0, 2),
            (1, 2, 0),
            (2, 0, 1),
            (2, 1, 0),
        ],
        itertools.permutations([0, 1, 2]),
    )
    return unittest.end(env)

def _chain_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, [1, 2, 3, 4, 5, 6], itertools.chain([1, 2], [3, 4], [5, 6]))
    return unittest.end(env)

def _chain_from_iterable_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, [1, 2, 3, 4, 5, 6], itertools.chain([[1, 2], [3, 4], [5, 6]]))
    return unittest.end(env)

def _combinations_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, [(0, 1), (0, 2), (1, 2)], itertools.combinations([0, 1, 2], 2))
    return unittest.end(env)

def _combinations_with_replacement_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [(0, 0), (0, 1), (0, 2), (1, 1), (1, 2), (2, 2)],
        itertools.combinations_with_replacement([0, 1, 2], 2),
    )
    return unittest.end(env)

def _compress_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [0, 2, 4, 5],
        itertools.compress([0, 1, 2, 3, 4, 5], [1, 0, 1, 0, 1, 1]),
    )
    return unittest.end(env)

def _dropwhile_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [6, 4, 1],
        itertools.dropwhile(lambda x: x < 5, [1, 4, 6, 4, 1]),
    )
    return unittest.end(env)

def _filterfalse_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [1, 3, 5, 7, 9],
        itertools.filterfalse(lambda x: x % 2 == 0, range(10)),
    )
    asserts.equals(
        env,
        [0, False, None, ""],
        itertools.filterfalse(None, [0, 1, False, True, None, "A", ""]),
    )
    return unittest.end(env)

def _groupby_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [
            (0, [0, 0, 0]),
            (1, [1, 1]),
            (2, [2, 2]),
            (3, [3]),
            (0, [0, 0]),
            (1, [1, 1, 1]),
        ],
        itertools.groupby([0, 0, 0, 1, 1, 2, 2, 3, 0, 0, 1, 1, 1]),
    )
    asserts.equals(
        env,
        [(3, ["red"]), (4, ["blue"]), (5, ["green", "black", "azure"])],
        itertools.groupby(["red", "blue", "green", "black", "azure"], key = len),
    )
    return unittest.end(env)

def _starmap_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [10, 21, 30],
        itertools.starmap(lambda x, y: x * y, [(2, 5), (3, 7), (10, 3)]),
    )

    return unittest.end(env)

def _takewhile_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [1, 4],
        itertools.takewhile(lambda x: x < 5, [1, 4, 6, 4, 1]),
    )
    return unittest.end(env)

def _zip_longest_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        [(1, 4, 8), (2, 5, 9), (3, 6, 0), (0, 7, 0)],
        itertools.zip_longest([1, 2, 3], [4, 5, 6, 7], [8, 9], fillvalue = 0),
    )
    return unittest.end(env)

accumulate_test = unittest.make(_accumulate_test)
unique_test = unittest.make(_unique_test)
is_sorted_test = unittest.make(_is_sorted_test)
pairwise_test = unittest.make(_pairwise_test)
product_test = unittest.make(_product_test)
permutations_test = unittest.make(_permutations_test)
chain_test = unittest.make(_chain_test)
chain_from_iterable_test = unittest.make(_chain_from_iterable_test)
combinations_test = unittest.make(_combinations_test)
combinations_with_replacement_test = unittest.make(_combinations_with_replacement_test)
compress_test = unittest.make(_compress_test)
dropwhile_test = unittest.make(_dropwhile_test)
filterfalse_test = unittest.make(_filterfalse_test)
groupby_test = unittest.make(_groupby_test)
starmap_test = unittest.make(_starmap_test)
takewhile_test = unittest.make(_takewhile_test)
zip_longest_test = unittest.make(_zip_longest_test)

def itertools_test_suite():
    """Creates the test targets and test suite for itertools.bzl tests."""
    unittest.suite(
        "itertools_tests",
        accumulate_test,
        unique_test,
        is_sorted_test,
        pairwise_test,
        product_test,
        permutations_test,
        chain_test,
        combinations_test,
        combinations_with_replacement_test,
        compress_test,
        dropwhile_test,
        filterfalse_test,
        groupby_test,
        starmap_test,
        takewhile_test,
        zip_longest_test,
    )
