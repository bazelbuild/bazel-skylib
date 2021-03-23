"""Skylib module of convenience functions for `target_compatible_with`."""

load(":selects.bzl", "selects")

# TODO(trybka): switch this to @platforms:incompatible.
INCOMPATIBLE_SETTING=":not_compatible_setting"

def _get_name_from_target_list(targets, joiner=" or "):
    """Join a list of strings into a string which is suitable as a target name.

    Removes/replaces characters which are not valid as target names.

    Args:
      target_list: A list of target names.
      joiner: An optional string to use for joining the list.

    Returns:
      A string which is a valid target name.
    """
    targets_name = joiner.join([s.split(":")[1] for s in targets])
    name = targets_name.replace("//", "").replace(":", "_").replace("/", "_").replace(".", "_")
    return name

def _maybe_make_unique_incompatible_value(name):
    """Creates a `native.constraint_value` which is "incompatible."

    When composing selects which could all resolve to "incompatible" we need distinct labels.
    This will create a constraint_value with the given name, if it does not already exist.

    Args:
      name: A target name to check and use.
    """
    if not native.existing_rule(name):
        native.constraint_value(name = name, constraint_setting = INCOMPATIBLE_SETTING)

def _none_of(settings):
    """Create a `select()` which matches none of the given config_settings.

    Any of the settings will resolve to an incompatible constraint_value for the
    purpose of target skipping.

    Args:
      settings: A list of `config_settings`.

    Returns:
      A native `select()` which maps any of the settings to the incompatible target.
    """
    compat_name = " incompatible with " + _get_name_from_target_list(settings)
    _maybe_make_unique_incompatible_value(compat_name)
    return selects.with_or({"//conditions:default": [], tuple(settings): [":" + compat_name]})

def _any_of(settings):
    """Create a `select()` which matches any of the given config_settings.

    Any of the settings will resolve to an empty list, while the default condition will map to
    an incompatible constraint_value for the purpose of target skipping.

    Args:
      settings: A list of `config_settings`.

    Returns:
      A native `select()` which maps any of the settings an empty list.
    """
    compat_name = " compatible with any of " + _get_name_from_target_list(settings)
    _maybe_make_unique_incompatible_value(compat_name)
    return selects.with_or({tuple(settings): [], "//conditions:default": [":" + compat_name]})

def _all_of(settings):
    """Create a `select()` which matches all of the given config_settings.

    All of the settings must be true to get an empty list. Failure to match will result
    in an incompatible constraint_value for the purpose of target skipping.

    See also: `selects.config_setting_group(match_all)`

    Args:
      settings: A list of `config_settings`.

    Returns:
      A native `select()` which is "incompatible" unless all `config_settings` are true.
    """
    group_name = _get_name_from_target_list(settings, joiner=" and ")
    # All of can only be accomplished with a config_setting_group.match_all.
    if not native.existing_rule(group_name):
        selects.config_setting_group(name = group_name, match_all = settings)
    compat_name = " compatible with all of " + group_name
    _maybe_make_unique_incompatible_value(compat_name)
    return select({":" + group_name: [], "//conditions:default": [":" + compat_name]})

compatibility = struct(
    all_of = _all_of,
    any_of = _any_of,
    none_of = _none_of,
)


