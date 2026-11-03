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

"""Skylib module containing functions that operate on structs."""

_built_in_function = type(str)

def _is_built_in_function(v):
    """Returns True if v is an instance of a built-in function.

    Args:
      v: The value whose type should be checked.

    Returns:
      True if v is an instance of a built-in function, False otherwise.
    """

    return type(v) == _built_in_function

def _to_dict(s):
    """Converts a `struct` to a `dict`.

    Args:
      s: A `struct`.

    Returns:
      A `dict` whose keys and values are the same as the fields in `s`. The
      transformation is only applied to the struct's fields and not to any
      nested values.
    """

    # to_json()/to_proto() are disabled by --incompatible_struct_has_no_methods
    # and will be removed entirely in a future Bazel release.
    return {
        key: getattr(s, key)
        for key in dir(s)
        if not ((key == "to_json" or key == "to_proto") and _is_built_in_function(getattr(s, key)))
    }

def _merge(first, *rest):
    """Merges multiple `struct` instances together. Later `struct` keys overwrite early `struct` keys.

    Args:
      first: The initial `struct` to merge keys/values into.
      *rest: Other `struct` instances to merge.

    Returns:
      A merged `struct`.
    """
    map = _to_dict(first)
    for r in rest:
        map |= _to_dict(r)
    return struct(**map)

structs = struct(
    to_dict = _to_dict,
    merge = _merge,
)
