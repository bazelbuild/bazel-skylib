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

"""
Iterator building blocks, matching python's `itertools`. See
https://docs.python.org/3/library/itertools.html for details.
"""

def _accumulate(iterable, func = None, initial = None):
    """
    Returns a list of accumulated results.

    Args:
        iterable: Input iterable.
        func: Two-argument function to combine values. Defaults to addition.
        initial: Initial value placed before the items of iterable. Defaults to None.

    Returns:
        List of accumulated results.

    Examples:
        >>> itertools.accumulate([1, 2, 3, 4, 5])
        [1, 3, 6, 10, 15]

        >>> itertools.accumulate([1, 2, 3, 4, 5], lambda x, y: x * y)
        [1, 2, 6, 24, 120]

        >>> itertools.accumulate([1, 2, 3, 4, 5], initial=100)
        [100, 101, 103, 106, 110, 115]
    """
    func = func or (lambda x, y: x + y)
    total = None
    result = []
    for i, x in enumerate(iterable):
        if i == 0:
            if initial == None:
                total = x
            else:
                result.append(initial)
                total = func(initial, x)
        else:
            total = func(total, x)
        result.append(total)
    return result

def _unique(values):
    """
    Returns a list of unique values.

    Args:
        values: Input values.

    Returns:
        List of unique among the input values in order of appearance.

    Examples:
        >>> itertools.unique(["C", "B", "A", "B"])
        ["C", "B", "A"]

    Note:
        unique is not implemented in Python's itertools.
    """
    unique_values = []
    for value in values:
        if value not in unique_values:
            unique_values.append(value)
    return unique_values

def _is_sorted(values, strict):
    """
    Returns if the values are sorted in ascending order.

    Args:
        values: Input values.
        strict: If the ordering should be strict (a < b for successive elements) or not
            (a <= b for successive elements).

    Returns:
        True if the values are sorted, otherwise False.

    Examples:
        >>> itertools.is_sorted([0, 1, 1, 2], strict=False)
        True

        >>> itertools.is_sorted([2, 1, 0], strict=False)
        False

        >>> itertools.is_sorted([0, 1, 1, 2], strict=True)
        False

    Note:
        is_sorted is not implemented in Python's itertools.
    """
    for a, b in _pairwise(values):
        if (strict and b <= a) or (not strict and b < a):
            return False
    return True

def _pairwise(iterable):
    """
    Returns a list of overlapping pairs from the input iterable.

    Args:
        iterable: Input iterable.

    Returns:
        List of tuples containing consecutive pairs of elements.

    Examples:
        >>> itertools.pairwise([1, 2, 3, 4])
        [(1, 2), (2, 3), (3, 4)]
    """
    previous = None
    result = []
    for i, value in enumerate(iterable):
        if i > 0:
            result.append((previous, value))
        previous = value
    return result

def _product(*iterables, repeat = 1):
    """
    Returns the cartesian product of input iterables as a list.

    Args:
        *iterables: Variable length argument list of iterables.
        repeat: Number of times to repeat the iterables. Defaults to 1.

    Returns:
        List of tuples, where the i-th element comes from the i-th iterable or repeated
        iterable.

    Examples:
        >>> itertools.product(["A", "B"], ["C", "D"])
        [("A", "C"), ("A", "D"), ("B", "C"), ("B", "D")]

        >>> itertools.product(["A", "B"], repeat=2)
        [("A", "A"), ("A", "B"), ("B", "A"), ("B", "B")]

        >>> itertools.product(["A", "B"], [1, 2], repeat=2)
        [("A", 1, "A", 1), ("A", 1, "A", 2), ..., ("B", 2, "B", 1), ("B", 2, "B", 2)]
    """
    pools = iterables * repeat
    result = [[]]
    for pool in pools:
        result = [x + [y] for x in result for y in pool]
    return [tuple(x) for x in result]

def _permutations(iterable, r = None):
    """
    Returns a list of successive r-length permutations of elements in the iterable.

    Args:
        iterable: Input iterable.
        r: Length of the permutations. If None, defaults to the length of the iterable.

    Returns:
        List of tuples containing all possible r-length permutations
        of elements in iterable.

    Examples:
        >>> itertools.permutations(["A", "B", "C"], 2)
        [("A", "B"), ("A", "C"), ("B", "A"), ("B", "C"), ("C", "A"), ("C", "B")]

        >>> itertools.permutations([1, 2, 3])
        [(1, 2, 3), (1, 3, 2), (2, 1, 3), (2, 3, 1), (3, 1, 2), (3, 2, 1)]
    """
    n = len(iterable)
    r = n if r == None else r
    return [
        values
        for values in _product(iterable, repeat = r)
        if len(_unique(values)) == r
    ]

def _chain(*iterables):
    """
    Returns a list that chains multiple iterables together.

    Args:
        *iterables: Variable length argument list of iterables.

    Returns:
        List containing elements from the first iterable, followed by elements
        from the next iterable, and so on.

    Examples:
        >>> itertools.chain([1, 2], [3, 4], [5, 6])
        [1, 2, 3, 4, 5, 6]
    """
    return _chain_from_iterable(iterables)

def _chain_from_iterable(iterables):
    """
    Creates a single list from an iterable of iterables.

    Args:
        iterables: An iterable that yields iterables.

    Returns:
        List that contains elements from each nested iterable in sequence.

    Examples:
        >>> itertools.chain.from_iterable([[1, 2], [3, 4], [5, 6]])
        [1, 2, 3, 4, 5, 6]
    """
    return [x for iterable in iterables for x in iterable]

def _combinations(iterable, r, with_replacement = False):
    """
    Returns a list of r-length subsequences of elements from the input iterable.

    Args:
        iterable: Input iterable.
        r: Length of the subsequences.
        with_replacement: Form combinations with replacement.

    Returns:
        List of tuples containing all possible r-length subsequences from iterable.

    Examples:
        >>> itertools.combinations([0, 1, 2], 2)
        [(0, 1), (0, 2), (1, 2)]
    """
    n = len(iterable)
    return [
        tuple([iterable[i] for i in indices])
        for indices in _product(range(n), repeat = r)
        if _is_sorted(indices, not with_replacement)
    ]

def _combinations_with_replacement(iterable, r):
    """
    Returns a list of r-length subsequences of elements from the input iterable, allowing elements to repeat.

    Args:
        iterable: Input iterable.
        r: Length of the subsequences.

    Returns:
        List of tuples containing all possible r-length subsequences from iterable with
        replacement.

    Examples:
        >>> itertools.combinations_with_replacement([0, 1, 2], 2)
        [(0, 0), (0, 1), (0, 2), (1, 1), (1, 2), (2, 2)]
    """
    return _combinations(iterable, r, with_replacement = True)

def _compress(data, selectors):
    """
    Filters elements from data based on corresponding values in selectors.

    Args:
        data: Iterable of elements to filter.
        selectors: Iterable of boolean values.

    Returns:
        List containing elements from data where the corresponding selector evaluates to
        True.

    Examples:
        >>> itertools.compress(["A", "B", "C", "D", "E", "F"], [1, 0, 1, 0, 1, 1])
        ["A", "C", "E", "F"]
    """
    return [d for d, s in zip(data, selectors) if s]

def _dropwhile(predicate, iterable):
    """
    Drop items from iterable while predicate is true; afterward, return all items.

    Args:
        predicate: Function that returns a boolean value.
        iterable: Input iterable.

    Returns:
        List that first skips items as long as predicate(item) is True, then contains
        the remaining items.

    Examples:
        >>> itertools.dropwhile(lambda x: x < 5, [1, 4, 6, 4, 1])
        [6, 4, 1]
    """
    result = []
    y = True
    for x in iterable:
        y = y and predicate(x)
        if not y:
            result.append(x)
    return result

def _filterfalse(predicate, iterable):
    """
    Returns elements from iterable for which predicate returns False.

    Args:
        predicate: Function that returns a boolean value. If None, returns elements that
            are "falsy".
        iterable: Input iterable.

    Returns:
        List of elements that do not satisfy the predicate.

    Examples:
        >>> itertools.filterfalse(lambda x: x % 2 == 0, range(10))
        [1, 3, 5, 7, 9]

        >>> itertools.filterfalse(None, [0, 1, False, True, None, "A", ""])
        [0, False, None, ""]
    """
    if predicate == None:
        predicate = bool
    return [x for x in iterable if not predicate(x)]

def _groupby(iterable, key = None):
    """
    Groups consecutive elements from the iterable by key.

    Args:
        iterable: Input iterable. Elements should be sorted by the key function.
        key: Function to compute a key value for each element. If None, the identity
            function is used.

    Returns:
        List of tuples where each tuple contains a key and a list of
        elements that share that key.

    Examples:
        >>> itertools.groupby([0, 0, 0, 1, 1, 2, 2, 3, 0, 0, 1, 1])
        [(0, [0, 0, 0]), (1, [1, 1]), (2, [2, 2]), (3, [3]), (0, [0, 0]), (1, [1, 1])]

        >>> itertools.sorted(["red", "blue", "green", "black", "azure"], key=len)
        [(3, ["red"]), (4, ["blue"]), (5, ["green", "black", "azure"])]

    Notes:
        The input iterable should be sorted on the same key function to group all
        elements with the same key.
    """
    if not iterable:
        return [(), ()]

    key = key or (lambda x: x)
    result = []
    group = [iterable[0]]
    previous = key(iterable[0])
    current = key(iterable[0])
    for x in iterable[1:]:
        current = key(x)
        if current != previous:
            result.append((previous, group))
            group = []
        group.append(x)
        previous = current
    result.append((current, group))
    return result

def _starmap(function, iterable):
    """
    Returns a list of results after applying function using unpacked arguments from iterable.

    Args:
        function: Function to apply to each tuple of arguments.
        iterable: Iterable of tuples or other iterables to be unpacked as arguments.

    Returns:
        List containing results of applying function to each item in iterable.

    Examples:
        >>> itertools.starmap(lambda x, y: x * y, [(2, 5), (3, 7), (10, 3)])
        [10, 21, 30]
    """
    return [function(*args) for args in iterable]

def _takewhile(predicate, iterable):
    """
    Returns elements from iterable as long as predicate is true.

    Args:
        predicate: Function that returns a boolean value.
        iterable: Input iterable.

    Returns:
        List containing elements until predicate returns False.

    Examples:
        >>> itertools.takewhile(lambda x: x < 5, [1, 4, 6, 4, 1])
        [1, 4]
    """
    result = []
    for x in iterable:
        if predicate(x):
            result.append(x)
        else:
            break
    return result

def _zip_longest(*iterables, fillvalue = None):
    """
    Returns a list that aggregates elements from iterables.

    Args:
        *iterables: Variable length argument list of iterables.
        fillvalue: Value to use when an iterable is exhausted. Defaults to None.

    Returns:
        List of tuples with elements from each iterable, using fillvalue for exhausted
        iterables.

    Examples:
        >>> itertools.zip_longest([1, 2, 3], [4, 5, 6, 7], [8, 9], fillvalue=0)
        [(1, 4, 8), (2, 5, 9), (3, 6, 0), (0, 7, 0)]
    """
    longest = max([len(iterable) for iterable in iterables])
    return [
        tuple(
            [iterable[i] if i < len(iterable) else fillvalue for iterable in iterables],
        )
        for i in range(longest)
    ]

itertools = struct(
    _is_sorted = _is_sorted,
    _unique = _unique,
    accumulate = _accumulate,
    chain = _chain,
    chain_from_iterable = _chain_from_iterable,
    combinations = _combinations,
    combinations_with_replacement = _combinations_with_replacement,
    compress = _compress,
    dropwhile = _dropwhile,
    filterfalse = _filterfalse,
    groupby = _groupby,
    pairwise = _pairwise,
    permutations = _permutations,
    product = _product,
    starmap = _starmap,
    takewhile = _takewhile,
    zip_longest = _zip_longest,
)
