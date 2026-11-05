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

# TODO: Use native annotations when Skylib requires Bazel 8.8 or newer.
def resolve_locations(ctx, strategy, d):
    # type: (ctx, struct[{"as_path": Callable[[str], str]}, ...], dict[str, str]) -> dict[str, str]
    """Expand the location and locations variables in dictionary values.

    Args:
      ctx: the 'ctx' argument of the rule implementation function
      strategy: a struct with an 'as_path(string) -> string' function
      d: {string: string} dictionary; values may contain references
        for labels declared in the rule's 'srcs' and 'tools' attributes

    Returns:
      {string: string} dict, same as 'd' but with label references replaced by paths.
    """
    location_prefix = "$(location"  # buildifier: disable=make-location
    location_expressions = []
    parts = {}
    was_anything_to_resolve = False
    for k, v in d.items():
        # Look for "$(location ...)" or "$(locations ...)", resolve if found.
        # _validate_attributes already ensured that there's at most one $(location/s ...) in "v".
        if location_prefix in v:
            tokens = v.split(location_prefix)
            was_anything_to_resolve = True
            closing_paren = tokens[1].find(")")
            location_expressions.append(location_prefix + tokens[1][:closing_paren + 1])
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

def fail_if_errors(errors):
    # type: (Sequence[str]) -> None
    """Reports errors and fails the rule.

    Args:
        errors: list of strings; the errors to report. At most 10 are reported.
    """
    if errors:
        # Don't overwhelm the user; report up to ten errors.
        fail("\n".join(errors[:10]))

def _as_windows_path(s):
    # type: (str) -> str
    """Returns the input path as a Windows path (replaces all of "/" with "\")."""
    return s.replace("/", "\\")

def _unchanged_path(s):
    # type: (str) -> str
    """Returns the input string (path) unchanged."""
    return s

# TODO(https://github.com/bazelbuild/bazel/issues/32021): Annotate the inputs
# of both action helpers natively when Bazel can express depset[File].
def _create_cmd_action(
        ctx,  # type: ctx
        outputs,  # type: Sequence[File]
        command,  # type: str
        inputs = None,  # type: Sequence[File] | depset[File] | None
        env = None,  # type: Mapping[str, str] | None
        progress_message = None,  # type: str | None
        mnemonic = None,  # type: str | None
        # type: Sequence[object] | None
        manifests_from_tools = None):
    # type: (...) -> None
    """Create one action using cmd.exe."""
    ctx.actions.run(
        inputs = inputs or [],
        outputs = outputs,
        executable = "cmd.exe",
        env = env,
        arguments = ["/C", command],
        progress_message = progress_message or "Running cmd.exe command",
        mnemonic = mnemonic or "CmdExeCommand",
        input_manifests = manifests_from_tools,
    )

def _create_bash_action(
        ctx,  # type: ctx
        outputs,  # type: Sequence[File]
        command,  # type: str
        inputs = None,  # type: Sequence[File] | depset[File] | None
        env = None,  # type: Mapping[str, str] | None
        progress_message = None,  # type: str | None
        mnemonic = None,  # type: str | None
        # type: Sequence[object] | None
        manifests_from_tools = None):
    # type: (...) -> None
    """Create one action using Bash."""
    ctx.actions.run_shell(
        inputs = inputs or [],
        outputs = outputs,
        env = env,
        command = command,
        progress_message = progress_message or "Running Bash command",
        mnemonic = mnemonic or "BashCommand",
        input_manifests = manifests_from_tools,
    )

# Action creation utilities for cmd.exe actions.
CMD_STRATEGY = struct(
    as_path = _as_windows_path,
    create_action = _create_cmd_action,
)

# Action creation utilities for Bash actions.
BASH_STRATEGY = struct(
    as_path = _unchanged_path,
    create_action = _create_bash_action,
)
