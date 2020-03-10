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

def _add(*dictionaries, **kwargs):
    """Returns a new `dict` that has all the entries of the given dictionaries.

    If the same key is present in more than one of the input dictionaries, the
    last of them in the argument list overrides any earlier ones. If you want
    to be alerted when there is an override see `dicts.unique_add`.

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
    
def _update_checking_uniqueness(result, d):
    for k, v in d.items():
        if k in result:
            fail("Key '{}' is already in the dictionary".format(k))
        result[k] = v
    
def _unique_add(*dictionaries, **kwargs):
    """Like `dicts.add` but fails when there is a duplicate key.

    Args:
      *dictionaries: Zero or more dictionaries to be added.
      **kwargs: Additional dictionary passed as keyword args.

    Returns:
      A new `dict` that has all the entries of the given dictionaries.
    """
    result = {}
    for d in dictionaries:
        _update_checking_uniqueness(result, d)
    _update_checking_uniqueness(result, kwargs)
    return result
    
def _without(dictionary, *keys):
    """Returns a new `dict` that has all the keys except the ones you specified.
    
    Args:
      dictionary: The dictionary to operate on.
      *keys: The keys in the dictionary you want removed.

    Returns:
      A new `dict` that has all the keys except the ones you specified.
    """
    result = {}
    for k, v in dictionary.items():
        if k not in keys:
            result[k] = v
    return result

def _only(dictionary, *keys):
    """Returns a new `dict` that only has the keys you specified.
      
    Args:
      dictionary: The dictionary to operate on.
      *keys: The keys in the dictionary you want to keep.

    Returns:
      A new `dict` that only has the keys you specified.
    """
    result = {}
    for k, v in dictionary.items():
        if k in keys:
            result[k] = v
    return result

dicts = struct(
    add = _add,
    unique_add = _unique_add,
    without = _without,
    only = _only,
)
