"""Skylib module of convenience functions for `target_compatible_with`.

Load the macros as follows in your `BUILD` files:
```python
load("@bazel_skylib//lib:compatibility.bzl", "compatibility")
```

See the [Platform docs](https://bazel.build/docs/platforms#skipping-incompatible-targets) for
more information.
"""

load(":selects.bzl", "selects")
load("//lib/compatibility:defs.bzl", "MAX_NUM_ALL_OF_SETTINGS")

def _none_of(*settings):
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
        target_compatible_with = compatibility.none_of(
            "@platforms//os:linux",
            "@platforms//os:macos",
        ),
    )
    ```

    Args:
      *settings: The `config_setting` or `constraint_value` targets.

    Returns:
      A native `select()` which maps any of the settings to the incompatible target.
    """
    return selects.with_or({
        "//conditions:default": [],
        tuple(settings): ["@bazel_skylib//lib/compatibility:none_of"],
    })

def _any_of(*settings):
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
        target_compatible_with = compatibility.any_of(
            "@platforms//os:linux",
            "@platforms//os:macos",
        ),
    )
    ```

    Args:
      *settings: The `config_settings` or `constraint_value` targets.

    Returns:
      A native `select()` which maps any of the settings an empty list.
    """
    return selects.with_or({
        tuple(settings): [],
        "//conditions:default": ["@bazel_skylib//lib/compatibility:any_of"],
    })

def _all_of(*settings):
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
        target_compatible_with = compatibility.all_of(
            ":dbg",
            "@platforms//os:linux",
        ),
    )
    ```

    See also: `selects.config_setting_group(match_all)`

    Args:
      *settings: The `config_setting` or `constraint_value` targets.

    Returns:
      A native series of `select()`s. The result is "incompatible" unless all settings are true.
    """
    if len(settings) > MAX_NUM_ALL_OF_SETTINGS:
        fail("Cannot support more than {} arguments. Use selects.config_setting_group() instead.".format(MAX_NUM_ALL_OF_SETTINGS))

    result = []
    for i, setting in enumerate(settings):
        result += select({
            setting: [],
            "//conditions:default": ["@bazel_skylib//lib/compatibility:all_of_{}".format(i)],
        })
    return result

compatibility = struct(
    all_of = _all_of,
    any_of = _any_of,
    none_of = _none_of,
)
