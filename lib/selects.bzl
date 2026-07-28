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

"""Skylib module containing convenience interfaces for select()."""

def _with_or(input_dict, no_match_error = ""):
    """Drop-in replacement for `select()` that supports ORed keys.

    Example:

          ```build
          deps = selects.with_or({
              "//configs:one": [":dep1"],
              ("//configs:two", "//configs:three"): [":dep2or3"],
              "//configs:four": [":dep4"],
              "//conditions:default": [":default"]
          })
          ```

          Key labels may appear at most once anywhere in the input.

    Args:
      input_dict: The same dictionary `select()` takes, except keys may take
          either the usual form `"//foo:config1"` or
          `("//foo:config1", "//foo:config2", ...)` to signify
          `//foo:config1` OR `//foo:config2` OR `...`.
      no_match_error: Optional custom error to report if no condition matches.

    Returns:
      A native `select()` that expands

      `("//configs:two", "//configs:three"): [":dep2or3"]`

      to

      ```build
      "//configs:two": [":dep2or3"],
      "//configs:three": [":dep2or3"],
      ```
    """
    return select(_with_or_dict(input_dict), no_match_error = no_match_error)

def _with_or_dict(input_dict):
    """Variation of `with_or` that returns the dict of the `select()`.

    Unlike `select()`, the contents of the dict can be inspected by Starlark
    macros.

    Args:
      input_dict: Same as `with_or`.

    Returns:
      A dictionary usable by a native `select()`.
    """
    output_dict = {}
    for (key, value) in input_dict.items():
        if type(key) == type(()):
            for config_setting in key:
                if config_setting in output_dict.keys():
                    fail("key %s appears multiple times" % config_setting)
                output_dict[config_setting] = value
        else:
            if key in output_dict.keys():
                fail("key %s appears multiple times" % key)
            output_dict[key] = value
    return output_dict

def _config_setting_group(name, match_any = [], match_all = [], match_none = [], visibility = None):
    """Matches if all or any of its member `config_setting`s match.

    Members listed in `match_none` must additionally *not* match. `match_none`
    can be combined with `match_any` or `match_all` (both requirements then
    apply) or set on its own to negate conditions.

    Example:

      ```build
      config_setting(name = "one", define_values = {"foo": "true"})
      config_setting(name = "two", define_values = {"bar": "false"})
      config_setting(name = "three", define_values = {"baz": "more_false"})

      config_setting_group(
          name = "one_two_three",
          match_all = [":one", ":two", ":three"]
      )

      config_setting_group(
          name = "one_but_not_two",
          match_all = [":one"],
          match_none = [":two"],
      )

      config_setting_group(
          name = "anything_but_three",
          match_none = [":three"],
      )

      cc_binary(
          name = "myapp",
          srcs = ["myapp.cc"],
          deps = select({
              ":one_two_three": [":special_deps"],
              ":one_but_not_two": [":other_deps"],
              "//conditions:default": [":default_deps"]
          })
      ```

    Args:
      name: The group's name. This is how `select()`s reference it.
      match_any: A list of `config_settings`. This group matches if *any* member
          in the list matches. If this is set, `match_all` must not be set.
      match_all: A list of `config_settings`. This group matches if *every*
          member in the list matches. If this is set, `match_any` must be not
          set.
      match_none: A list of `config_settings`. This group matches only if *no*
          member in the list matches. This can be set by itself to negate
          conditions or combined with `match_any` or `match_all`, in which case
          both requirements must hold. `"//conditions:default"` must not appear
          in the list.
      visibility: Visibility of the config_setting_group.
    """
    empty_any = not bool(len(match_any))
    empty_all = not bool(len(match_all))
    empty_none = not bool(len(match_none))
    if not empty_any and not empty_all:
        fail('"match_any" and "match_all" cannot both be set.')
    if empty_any and empty_all and empty_none:
        fail('At least one of "match_any", "match_all", or "match_none" must be set.')
    _check_duplicates(match_any)
    _check_duplicates(match_all)
    _check_duplicates(match_none)
    _check_match_none(match_none, match_any + match_all)

    if empty_none:
        if ((len(match_any) == 1 and match_any[0] == "//conditions:default") or
            (len(match_all) == 1 and match_all[0] == "//conditions:default")):
            # If the only entry is "//conditions:default", the condition is
            # automatically true.
            _config_setting_always_true(name, visibility)
        elif not empty_any:
            _config_setting_or_group(name, match_any, visibility)
        else:
            _config_setting_and_group(name, match_all, [], visibility)
        return

    # The group matches if the positive condition (match_any / match_all, or
    # vacuously true if neither is set) matches and no member of match_none
    # matches. Since NOT (n1 OR n2 OR ...) is the same as
    # (NOT n1) AND (NOT n2) AND ..., everything reduces to a single AND chain
    # over the positive part and the negated settings.
    if not empty_any:
        if len(_remove_default_condition(match_any)) < len(match_any):
            # "//conditions:default" is a member, so the match_any part is
            # automatically true.
            positive_settings = []
        elif len(match_any) == 1:
            positive_settings = match_any
        else:
            # Compile the match_any part into its own (private) OR group and
            # AND it with the negated settings.
            _config_setting_or_group(name + "_any", match_any, ["//visibility:private"])
            positive_settings = [":" + name + "_any"]
    else:
        # _config_setting_and_group tolerates "//conditions:default" members
        # and an empty settings list.
        positive_settings = match_all
    _config_setting_and_group(name, positive_settings, match_none, visibility)

def _check_duplicates(settings):
    """Fails if any entry in settings appears more than once."""
    seen = {}
    for setting in settings:
        if setting in seen:
            fail(setting + " appears more than once. Duplicates not allowed.")
        seen[setting] = True

def _check_match_none(match_none, match_settings):
    """Validates match_none entries.

    Fails if match_none contains "//conditions:default" or shares a setting
    with match_settings (the match_any or match_all list).
    """
    if not match_none:
        return
    negated = {}
    for setting in match_none:
        if setting == "//conditions:default":
            fail('"//conditions:default" is not allowed in "match_none".')
        negated[str(native.package_relative_label(setting))] = True
    for setting in match_settings:
        if (setting != "//conditions:default" and
            str(native.package_relative_label(setting)) in negated):
            fail(setting + ' appears in both "match_none" and the match list. ' +
                 "Settings cannot be both matched and negated.")

def _remove_default_condition(settings):
    """Returns settings with "//conditions:default" entries filtered out."""
    new_settings = []
    for setting in settings:
        if setting != "//conditions:default":
            new_settings.append(setting)
    return new_settings

def _config_setting_or_group(name, settings, visibility):
    """ORs multiple config_settings together (inclusively).

    The core idea is to create a sequential chain of alias targets where each is
    select-resolved as follows: If alias n matches config_setting n, the chain
    is true so it resolves to config_setting n. Else it resolves to alias n+1
    (which checks config_setting n+1, and so on). If none of the config_settings
    match, the final alias resolves to one of them arbitrarily, which by
    definition doesn't match.
    """

    # "//conditions:default" is present, the whole chain is automatically true.
    if len(_remove_default_condition(settings)) < len(settings):
        _config_setting_always_true(name, visibility)
        return

    elif len(settings) == 1:  # One entry? Just alias directly to it.
        native.alias(
            name = name,
            actual = settings[0],
            visibility = visibility,
        )
        return

    # We need n-1 aliases for n settings. The first alias has no extension. The
    # second alias is named name + "_2", and so on. For the first n-2 aliases,
    # if they don't match they reference the next alias over. If the n-1st alias
    # doesn't match, it references the final setting (which is then evaluated
    # directly to determine the final value of the AND chain).
    actual = [name + "_" + str(i) for i in range(2, len(settings))]
    actual.append(settings[-1])

    for i in range(1, len(settings)):
        native.alias(
            name = name if i == 1 else name + "_" + str(i),
            actual = select({
                native.package_relative_label(settings[i - 1]): settings[i - 1],
                "//conditions:default": actual[i - 1],
            }),
            visibility = visibility if i == 1 else ["//visibility:private"],
        )

def _config_setting_and_group(name, positive_settings, negative_settings, visibility):
    """ANDs multiple config_settings together, optionally negating some.

    The core idea is to create a sequential chain of alias targets where each is
    select-resolved as follows: If alias n matches config_setting n, it resolves to
    alias n+1 (which evaluates config_setting n+1, and so on). Else it resolves to
    config_setting n, which doesn't match by definition. The only way to get a
    matching final result is if all config_settings match.

    Settings in `negative_settings` are chained the same way with inverted
    branches: if such a setting matches, its alias resolves to :always_false,
    so the chain can't match. Else it resolves to the next alias over. Negated
    settings are evaluated first so the chain can end by evaluating a positive
    setting directly whenever there is one.
    """

    # "//conditions:default" is automatically true so doesn't need checking.
    positive_settings = _remove_default_condition(positive_settings)

    # Each literal is a (setting, is_negated) pair the chain checks in order.
    literals = [(setting, True) for setting in negative_settings]
    literals += [(setting, False) for setting in positive_settings]

    # Every entry was "//conditions:default"? The condition is automatically
    # true.
    if len(literals) == 0:
        _config_setting_always_true(name, visibility)
        return

    # One input? Just alias directly to it, or to its negation.
    if len(literals) == 1:
        setting, is_negated = literals[0]
        if is_negated:
            _config_setting_not(name, setting, visibility)
        else:
            native.alias(
                name = name,
                actual = setting,
                visibility = visibility,
            )
        return

    # We need n-1 aliases for n literals. The first alias has no extension. The
    # second alias is named name + "_2", and so on. For the first n-2 aliases,
    # if they match they reference the next alias over. If the n-1st alias matches,
    # it references the final setting (which is then evaluated directly to determine
    # the final value of the AND chain). If the final setting is negated (which only
    # happens when there are no positive settings at all), it can't be evaluated
    # directly, so a negation alias named name + "_n" is chained instead.
    actual = [name + "_" + str(i) for i in range(2, len(literals))]
    last_setting, last_negated = literals[-1]
    if last_negated:
        not_name = name + "_" + str(len(literals))
        _config_setting_not(not_name, last_setting, ["//visibility:private"])
        actual.append(not_name)
    else:
        actual.append(last_setting)

    for i in range(1, len(literals)):
        setting, is_negated = literals[i - 1]
        if is_negated:
            # A negated setting that matches falsifies the whole chain.
            resolved = select({
                native.package_relative_label(setting): Label(":always_false"),
                "//conditions:default": actual[i - 1],
            })
        else:
            resolved = select({
                native.package_relative_label(setting): actual[i - 1],
                "//conditions:default": setting,
            })
        native.alias(
            name = name if i == 1 else name + "_" + str(i),
            actual = resolved,
            visibility = visibility if i == 1 else ["//visibility:private"],
        )

def _config_setting_not(name, setting, visibility):
    """Creates a config_setting-like target that matches iff `setting` doesn't match.

    If `setting` matches, the alias resolves to :always_false, else to
    :always_true.
    """
    native.alias(
        name = name,
        actual = select({
            native.package_relative_label(setting): Label(":always_false"),
            "//conditions:default": Label(":always_true"),
        }),
        visibility = visibility,
    )

def _config_setting_always_true(name, visibility):
    """Creates a config_setting with the given name that's always true."""
    native.alias(
        name = name,
        actual = Label(":always_true"),
        visibility = visibility,
    )

selects = struct(
    with_or = _with_or,
    with_or_dict = _with_or_dict,
    config_setting_group = _config_setting_group,
)
