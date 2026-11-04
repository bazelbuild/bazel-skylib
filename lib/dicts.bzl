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

"""Skylib module containing functions that operate on dictionaries."""

# TODO(https://github.com/bazelbuild/bazel/issues/32381): Use native annotations
# once Bazel can express bounded dictionary keys and read-only access to
# dictionaries with different key and value types.
# add() can copy a dict[str, int] and a dict[str, Label] into the same result.
# Neither input accepts the other dictionary's values.
# type _AddInput[K: Hashable, V] = Top[dict[Intersection[K, Unknown], Intersection[V, Unknown]]]

# The return type covers both add({1: 2}) and add({1: 2}, extra = 3).
# Only the second call introduces a string key.
def _add(*dictionaries, **kwargs):
    # type: [K: Hashable = Never, V = Never](*_AddInput[K, V], **V) -> dict[K | str, V]
    """Returns a new `dict` that has all the entries of the given dictionaries.

    If the same key is present in more than one of the input dictionaries, the
    last of them in the argument list overrides any earlier ones.

    This function is designed to take zero or one arguments as well as multiple
    dictionaries, so that it follows arithmetic identities and callers can avoid
    special cases for their inputs: the sum of zero dictionaries is the empty
    dictionary, and the sum of a single dictionary is a copy of itself.

    Args:
      *dictionaries: Zero or more dictionaries to be added.
      **kwargs: Additional dictionary passed as keyword args.

    Returns:
      A new `dict` that has all the entries of the given dictionaries.
    """
    result = {}
    for d in dictionaries:
        result.update(d)
    result.update(kwargs)
    return result

def _omit(dictionary, keys):
    # type: [K: Hashable, V](dict[K, V], Collection[Hashable]) -> dict[K, V]
    """Returns a new `dict` that has all the entries of `dictionary` with keys not in `keys`.

    Args:
      dictionary: A `dict`.
      keys: A sequence.

    Returns:
      A new `dict` that has all the entries of `dictionary` with keys not in `keys`.
    """
    keys_set = {k: None for k in keys}
    return {k: dictionary[k] for k in dictionary if k not in keys_set}

def _pick(dictionary, keys):
    # type: [K: Hashable, V, L: Hashable](dict[K, V], Collection[L]) -> dict[L, V]
    """Returns a new `dict` that has all the entries of `dictionary` with keys in `keys`.

    Args:
      dictionary: A `dict`.
      keys: A sequence.

    Returns:
      A new `dict` that has all the entries of `dictionary` with keys in `keys`.
    """
    return {k: dictionary[k] for k in keys if k in dictionary}

dicts = struct(
    add = _add,
    omit = _omit,
    pick = _pick,
)
