"""Skylib module of convenience functions for `target_compatible_with`.

Load the macros as follows in your `BUILD` files:
```python
load("@bazel_skylib//lib:compatibility.bzl", "compatibility")
```

See the [Platform docs](https://bazel.build/docs/platforms#skipping-incompatible-targets) for
more information.
"""

load(":selects.bzl", "selects")

def _get_name_from_target_list(targets, joiner = " or "):
    """Join a list of strings into a string which is suitable as a target name.

    The return value has a hash appended so that it is different between multiple "targets" values
    that have the same name portion. For readability, we keep only the name portion of the
    specified targets. But for uniqueness we need the hash. For example, the following two calls
    may return strings as follows. The hashes are arbitrary in this example.

        >>> _get_name_from_target_list(["@platforms//os:linux", "@platforms//cpu:x86_64"])
        "linux or x86_64 (3ef2349)"
        >>> _get_name_from_target_list(["//some/custom:linux", "//some/custom:x86_64"])
        "linux or x86_64 (98ab64)"

    Args:
      targets: A list of target names.
      joiner: An optional string to use for joining the list.

    Returns:
      A string which is a valid target name.
    """

    # Compute absolute labels from the user-specified ones. They can be
    # relative or absolute. We do this to make the final name as unique as
    # possible via a hash.
    package_label = Label("//" + native.package_name())
    absolute_targets = sorted([package_label.relative(target) for target in targets])
    joined_names = joiner.join([target.name for target in absolute_targets])
    name = "%s (%x)" % (joined_names, hash(str(absolute_targets)))
    return name

def _maybe_make_unique_incompatible_value(name):
    """Creates a `native.constraint_value` which is "incompatible."

    When composing selects which could all resolve to "incompatible" we need distinct labels.
    This will create a `constraint_value` with the given name, if it does not already exist.

    Args:
      name: A target name to check and use.
    """
    if not native.existing_rule(name):
        native.constraint_value(
            name = name,
            constraint_setting = "@platforms//:incompatible_setting",
        )

def _none_of(settings):
    """Create a `select()` for `target_compatible_with` which matches none of the given settings.

    Any of the settings will resolve to an incompatible `constraint_value` for the
    purpose of target skipping.

    In other words, use this function to make target incompatible if any of the settings are true.

    ```python
    cc_binary(
        name = "bin",
        srcs = ["bin.cc"],
        # This target cannot be built for Linux or Mac, but can be built for
        # everything else.
        target_compatible_with = compatibility.none_of([
            "@platforms//os:linux",
            "@platforms//os:macos",
        ]),
    )
    ```

    Args:
      settings: A list of `config_setting` or `constraint_value` targets.

    Returns:
      A native `select()` which maps any of the settings to the incompatible target.
    """
    compat_name = " incompatible with " + _get_name_from_target_list(settings)
    _maybe_make_unique_incompatible_value(compat_name)

    return selects.with_or({
        "//conditions:default": [],
        tuple(settings): [":" + compat_name],
    })

def _any_of(settings):
    """Create a `select()` for `target_compatible_with` which matches any of the given settings.

    Any of the settings will resolve to an empty list, while the default condition will map to
    an incompatible `constraint_value` for the purpose of target skipping.

    In other words, use this function to make target incompatible unless one or more of the
    settings are true.

    ```python
    cc_binary(
        name = "bin",
        srcs = ["bin.cc"],
        # This target can only be built for Linux or Mac.
        target_compatible_with = compatibility.any_of([
            "@platforms//os:linux",
            "@platforms//os:macos",
        ]),
    )
    ```

    Args:
      settings: A list of `config_settings` or `constraint_value` targets.

    Returns:
      A native `select()` which maps any of the settings an empty list.
    """
    compat_name = " compatible with any of " + _get_name_from_target_list(settings)
    _maybe_make_unique_incompatible_value(compat_name)

    return selects.with_or({
        tuple(settings): [],
        "//conditions:default": [":" + compat_name],
    })

def _all_of(settings):
    """Create a `select()` for `target_compatible_with` which matches all of the given settings.

    All of the settings must be true to get an empty list. Failure to match will result
    in an incompatible `constraint_value` for the purpose of target skipping.

    In other words, use this function to make a target incompatible unless all of the settings are
    true.

    Example:

    ```python
    config_setting(
        name = "dbg",
        values = {"compilation_mode": "dbg"},
    )

    cc_binary(
        name = "bin",
        srcs = ["bin.cc"],
        # This target can only be built for Linux in debug mode.
        target_compatible_with = compatibility.all_of([
            ":dbg",
            "@platforms//os:linux",
        ]),
    )
    ```

    See also: `selects.config_setting_group(match_all)`

    Args:
      settings: A list of `config_setting` or `constraint_value` targets.

    Returns:
      A native `select()` which is "incompatible" unless all settings are true.
    """
    group_name = _get_name_from_target_list(settings, joiner = " and ")
    compat_name = " compatible with all of " + group_name
    _maybe_make_unique_incompatible_value(compat_name)

    # all_of can only be accomplished with a config_setting_group.match_all.
    if not native.existing_rule(group_name):
        selects.config_setting_group(
            name = group_name,
            match_all = settings,
        )

    return select({
        ":" + group_name: [],
        "//conditions:default": [":" + compat_name],
    })

compatibility = struct(
    all_of = _all_of,
    any_of = _any_of,
    none_of = _none_of,
)
