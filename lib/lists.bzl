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

"""Module for managing Starlark `list` values."""

def _compact(items):
    """Returns a new `list` with any `None` values removed.

    Args:
        items: A `list` of items to evaluate.

    Returns:
        A new `list` of items with the `None` values removed.
    """

    # We are intentionally not calling _filter(). We want to avoid recursion
    # errors, if these functions are used together.
    return [item for item in items if item != None]

def _contains(items, target_or_fn):
    """Determines if a value exists in the provided `list`.

    If a boolean function is provided as the second argument, the function is
    evaluated against the items in the list starting from the first item. If
    the result of the boolean function call is `True`, processing stops and
    this function returns `True`. If no items satisfy the boolean function,
    this function returns `False`.

    If the second argument is not a `function` (i.e., the target), each item in
    the list is evaluated for equality (==) with the target. If the equality
    evaluation returns `True` for an item in the list, processing stops and
    this function returns `True`. If no items are found to be equal to the
    target, this function returns `False`.

    Args:
        items: A `list` of items to evaluate.
        target_or_fn: An item to be evaluated for equality or a boolean
            `function`. A boolean `function` is defined as one that takes a
            single argument and returns a `bool` value.

    Returns:
        A `bool` indicating whether an item was found in the list.
    """
    if type(target_or_fn) == "function":
        bool_fn = target_or_fn
    else:
        bool_fn = lambda x: x == target_or_fn

    # We are intentionally not calling _find(). We want to be able to use the
    # lists functions together. For instance, we want to be able to use
    # lists.contains inside the lambda for lists.find.
    for item in items:
        if bool_fn(item):
            return True
    return False

def _find(items, bool_fn):
    """Returns the list item that satisfies the provided boolean `function`.

    The boolean `function` is evaluated against the items in the list starting
    from the first item. If the result of the boolean function call is `True`,
    processing stops and this function returns item. If no items satisfy the
    boolean function, this function returns `None`.

    Args:
        items: A `list` of items to evaluate.
        bool_fn: A `function` that takes a single parameter and returns a `bool`
            value.

    Returns:
        A list item or `None`.
    """
    for item in items:
        if bool_fn(item):
            return item
    return None

def _flatten(items, max_iterations = 10000):
    """Flattens a `list` containing an arbitrary number of child `list` values \
    to a new `list` with the items from the original `list` values.

    Every effort is made to preserve the order of the flattened list items
    relative to their order in the child `list` values. For instance, an input
    of `["foo", ["alpha", ["omega"]], ["chicken", "cow"]]` to this function
    returns `["foo", "alpha", "omega", "chicken", "cow"]`.

    If provided a `list` value, each item in the `list` is evaluated for
    inclusion in the result.  If the item is not a `list`, the item is added to
    the result. If the item is a `list`, the items in the child `list` are
    added to the result and the result is marked for another round of
    processing. Once the result has been processed without detecting any child
    `list` values, the result is returned.

    If provided a value that is not a `list`, the value is wrapped in a list
    and returned.

    Because Starlark does not support recursion or boundless looping, the
    processing of the input is restricted to a fixed number of processing
    iterations. The default for the maximum number of iterations should be
    sufficient for processing most multi-level `list` values. However, if you
    need to change this value, you can specify the `max_iterations` value to
    suit your needs.

    Args:
        items: A `list` or a single item.
        max_iterations: Optional. The maximum number of processing iterations.

    Returns:
        A `list` with all of the items flattened (i.e., no items in the result
        are an item of type `list`).
    """
    if type(items) == "list":
        results = items
    else:
        results = [items]

    finished = False
    for _ in range(max_iterations):
        if finished:
            break
        finished = True
        to_process = list(results)
        results = []
        for item in to_process:
            if type(item) == "list":
                results.extend(item)
                finished = False
            else:
                results.append(item)

    if not finished:
        fail("Exceeded the maximum number of iterations to flatten the items.")

    return results

def _filter(items, bool_fn):
    """Returns a new `list` containing the items from the original that \
    satisfy the specified boolean `function`.

    Args:
        items: A `list` of items to evaluate.
        bool_fn: A `function` that takes a single parameter returns a `bool`
            value.

    Returns:
        A new `list` containing the items that satisfy the provided boolean
        `function`.
    """
    return [item for item in items if bool_fn(item)]

def _map(items, map_fn):
    """Returns a new `list` where each item is the result of calling the map \
    `function` on each item in the original `list`.

    Args:
        items: A `list` of items to evaluate.
        map_fn: A `function` that takes a single parameter returns a value that
            will be added to the new list at the correspnding location.

    Returns:
        A `list` with the transformed values.
    """
    return [map_fn(item) for item in items]

lists = struct(
    compact = _compact,
    contains = _contains,
    filter = _filter,
    find = _find,
    flatten = _flatten,
    map = _map,
)
