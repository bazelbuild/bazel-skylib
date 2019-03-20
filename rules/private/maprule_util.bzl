# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""Utilities for maprule."""

def resolve_locations(ctx, strategy, d):
    """Resolve $(location) references in the values of a dictionary.

    Args:
      ctx: the 'ctx' argument of the rule implementation function
      strategy: a struct with an 'as_path(string) -> string' function
      d: {string: string} dictionary; values may contain $(location) references
        for labels declared in the rule's 'srcs' and 'tools' attributes

    Returns:
      {string: string} dict, same as 'd' except "$(location)" references are
      resolved.
    """
    location_expressions = []
    parts = {}
    was_anything_to_resolve = False
    for k, v in d.items():
        # Look for "$(location ...)" or "$(locations ...)", resolve if found.
        # _validate_attributes already ensured that there's at most one $(location/s ...) in "v".
        if "$(location" in v:
            tokens = v.split("$(location")
            was_anything_to_resolve = True
            closing_paren = tokens[1].find(")")
            location_expressions.append("$(location" + tokens[1][:closing_paren + 1])
            parts[k] = (tokens[0], tokens[1][closing_paren + 1:])
        else:
            location_expressions.append("")

    resolved = {}
    if was_anything_to_resolve:
        # Resolve all $(location) expressions in one go.  Should be faster than resolving them
        # one-by-one.
        all_location_expressions = "<split_here>".join(location_expressions)
        all_resolved_locations = ctx.expand_location(all_location_expressions)
        resolved_locations = strategy.as_path(all_resolved_locations).split("<split_here>")

        i = 0

        # Starlark dictionaries have a deterministic order of iteration, so the element order in
        # "resolved_locations" matches the order in "location_expressions", i.e. the previous
        # iteration order of "d".
        for k, v in d.items():
            if location_expressions[i]:
                head, tail = parts[k]
                resolved[k] = head + resolved_locations[i] + tail
            else:
                resolved[k] = v
            i += 1
    else:
        resolved = d

    return resolved
