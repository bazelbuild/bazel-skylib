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

"""Skylib module containing functions that operate on strings."""


def _strip_margin(str, delim = "|"):
    """Strips a leading margin from each line in a multiline string.

    For each line in `str`:
      Strip a leading prefix consisting of spaces followed by `delim` from the line.

    This is extremely similar to Scala's .stripMargin

    Args:
      str: An input string.
      delim: The margin delimiter, defaulting to `|`.

    Returns:
      The input string with a margin prefix removed from each line.
    """
    return "\n".join([
        _strip_margin_line(line, delim)
        for line in str.splitlines()
    ])

def _strip_margin_line(line, delim):
    trimmed = line.lstrip(" ")
    pos = trimmed.find(delim, end = 1)
    if pos == 0:
        return trimmed[1:]
    else:
        return line

strings = struct(
    strip_margin = _strip_margin
)
