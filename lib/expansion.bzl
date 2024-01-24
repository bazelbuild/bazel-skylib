"""Skylib module containing functions that aid in environment variable expansion."""

def _valid_char_for_env_var_name(char):
    return char.isalnum() or char == "_"

def _key_to_be_expanded(str_with_key, key, start_of_key_index):
    # Check that the string at index is prefixed with an odd number of `$`.
    # Odd number means that the last `$` is not escaped.
    dollar_sign_count = 0
    for index in range(start_of_key_index, -1, -1):
        if str_with_key[index] != "$":
            break
        dollar_sign_count += 1

    # Check that the key is correctly matched.
    # Specifically, check the key isn't matching to another key (substring).
    key_mismatch = False
    if key[-1] not in (")", "}"):
        end_of_key_index = start_of_key_index + len(key)
        key_mismatch = (
            (end_of_key_index < len(str_with_key)) and
            _valid_char_for_env_var_name(str_with_key[end_of_key_index])
        )

    return (not key_mismatch) and (dollar_sign_count % 2) == 1

def _expand_key_in_str(key, val, unexpanded_str):
    key_len = len(key)
    val_len = len(val)
    searched_index = 0
    expanded_str = unexpanded_str

    # Max iterations at the length of the str; will likely break out earlier.
    for _ in range(len(expanded_str)):
        used_key_index = expanded_str.find(key, searched_index)
        if used_key_index < 0:
            break
        if _key_to_be_expanded(expanded_str, key, used_key_index):
            # Only replace this one instance that we have verified (count = 1).
            # Avoid extra string splicing, if possible.
            if searched_index == 0:
                expanded_str = expanded_str.replace(key, val, 1)
            else:
                expanded_str = (
                    expanded_str[0:searched_index - 1] +
                    expanded_str[searched_index:].replace(key, val, 1)
                )
            searched_index += val_len
        else:
            searched_index += key_len
    return expanded_str

def _expand_all_keys_in_str_from_dict(replacement_dict, unexpanded_str):
    # Manually expand variables based on the var dict.
    # Do not use `ctx.expand_make_variables()` as it will error out if any variable expands to
    # `$(location <name>)` (or similar) instead of leaving it untouched.
    expanded_val = unexpanded_str
    for avail_key, corresponding_val in replacement_dict.items():
        if expanded_val.find(avail_key) < 0:
            continue
        considered_key_formats = ("${}", "${{{}}}", "$({})")
        formatted_keys = [key_format.format(avail_key) for key_format in considered_key_formats]

        # Skip self-references (e.g. {"VAR": "$(VAR)"})
        # This may happen (and is ok) for the `env` attribute, where keys can be reused to be
        # expanded by the resolved dict.
        if corresponding_val in formatted_keys:
            continue

        # Expand each format style of this key, if it exists.
        for formatted_key in formatted_keys:
            expanded_val = _expand_key_in_str(formatted_key, corresponding_val, expanded_val)
    return expanded_val

def _expand_all_keys_in_str(
        expand_location,
        resolved_replacement_dict,
        env_replacement_dict,
        unexpanded_str):
    if unexpanded_str.find("$") < 0:
        return unexpanded_str

    expanded_val = unexpanded_str
    prev_val = expanded_val

    # Max iterations at the length of the str; will likely break out earlier.
    for _ in range(len(expanded_val)):
        # First let's try the safe `location` (et al) expansion logic.
        # `$VAR`, `$(VAR)`, and `${VAR}` will be left untouched.
        if expand_location:
            expanded_val = expand_location(expanded_val)

        # Break early if nothing left to expand.
        if expanded_val.find("$") < 0:
            break

        # Expand values first from the `env` attribute, then by the toolchain resolved values.
        expanded_val = _expand_all_keys_in_str_from_dict(env_replacement_dict, expanded_val)
        expanded_val = _expand_all_keys_in_str_from_dict(resolved_replacement_dict, expanded_val)

        # Break out early if nothing changed in this iteration.
        if prev_val == expanded_val:
            break
        prev_val = expanded_val

    return expanded_val

def _expand_with_manual_dict(resolution_dict, source_env_dict):
    """
    Recursively expands all values in `source_env_dict` using the given lookup data.

    All keys of `source_env_dict` are returned in the resultant dict with values expanded by
    lookups via `resolution_dict` dict.
    This function does not modify any of the given parameters.

    Args:
        resolution_dict:    (Required) A dictionary with resolved key/value pairs to be used for
                            lookup when resolving values. This may come from toolchains (via
                            `ctx.var`) or other sources.
        source_env_dict:    (Required) The source for all desired expansions. All key/value pairs
                            will appear within the returned dictionary, with all values fully
                            expanded by lookups in `resolution_dict`.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """
    expanded_envs = {}
    for env_key, unexpanded_val in source_env_dict.items():
        expanded_envs[env_key] = (
            _expand_all_keys_in_str(
                None,  # No `expand_location` available
                resolution_dict,
                source_env_dict,
                unexpanded_val,
            )
        )
    return expanded_envs

def _expand_with_manual_dict_and_location(expand_location, resolution_dict, source_env_dict):
    """
    Recursively expands all values in `source_env_dict` using the given logic / lookup data.

    All keys of `source_env_dict` are returned in the resultant dict with values expanded by
    location expansion logic via `expand_location` and by lookups via `resolution_dict` dict.
    This function does not modify any of the given parameters.

    Args:
        expand_location:    (Required) A function that takes in a string and properly replaces
                            `$(location ...)` (and similar) with the corresponding values. This
                            likely should correspond to `ctx.expand_location()`.
        resolution_dict:    (Required) A dictionary with resolved key/value pairs to be used for
                            lookup when resolving values. This may come from toolchains (via
                            `ctx.var`) or other sources.
        source_env_dict:    (Required) The source for all desired expansions. All key/value pairs
                            will appear within the returned dictionary, with all values fully
                            expanded by the logic expansion logic of `expand_location` and by
                            lookup in `resolution_dict`.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """
    expanded_envs = {}
    for env_key, unexpanded_val in source_env_dict.items():
        expanded_envs[env_key] = (
            _expand_all_keys_in_str(
                expand_location,
                resolution_dict,
                source_env_dict,
                unexpanded_val,
            )
        )
    return expanded_envs

def _expand_with_toolchains(ctx, source_env_dict, additional_lookup_dict = None):
    """
    Recursively expands all values in `source_env_dict` using the given lookup data.

    All keys of `source_env_dict` are returned in the resultant dict with values expanded by
    lookups via `ctx.var` dict (unioned with optional `additional_lookup_dict` parameter).
    Expansion occurs recursively through all given dicts.
    This function does not modify any of the given parameters.

    Args:
        ctx:    (Required) The bazel context object. This is used to access the `ctx.var` member
                for use as the "resolution dict". This makes use of providers from toolchains for
                environment variable expansion.
        source_env_dict:    (Required) The source for all desired expansions. All key/value pairs
                            will appear within the returned dictionary, with all values fully
                            expanded by lookups in `ctx.var` and optional `additional_lookup_dict`.
        additional_lookup_dict: (Optional) Additional dict to be used with `ctx.var` (union) for
                                variable expansion.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """
    additional_lookup_dict = additional_lookup_dict or {}
    return _expand_with_manual_dict(
        ctx.var | additional_lookup_dict,
        source_env_dict,
    )

def _expand_with_toolchains_and_location(
        ctx,
        deps,
        source_env_dict,
        additional_lookup_dict = None):
    """
    Recursively expands all values in `source_env_dict` using the `ctx` logic / lookup data.

    All keys of `source_env_dict` are returned in the resultant dict with values expanded by
    location expansion logic via `ctx.expand_location` and by lookups via `ctx.var` dict (unioned
    with optional `additional_lookup_dict` parameter).
    This function does not modify any of the given parameters.

    Args:
        ctx:    (Required) The bazel context object. This is used to access the `ctx.var` member
                for use as the "resolution dict". This makes use of providers from toolchains for
                environment variable expansion. This object is also used for the
                `ctx.expand_location` method to handle `$(location ...)` (and similar) expansion
                logic.
        deps:   (Required) The set of targets used with `ctx.expand_location` for expanding
                `$(location ...)` (and similar) expressions.
        source_env_dict:    (Required) The source for all desired expansions. All key/value pairs
                            will appear within the returned dictionary, with all values fully
                            expanded by the logic expansion logic of `expand_location` and by
                            lookups in `ctx.var` and optional `additional_lookup_dict`.
        additional_lookup_dict: (Optional) Additional dict to be used with `ctx.var` (union) for
                                variable expansion.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """

    def _simpler_expand_location(input_str):
        return ctx.expand_location(input_str, deps)

    additional_lookup_dict = additional_lookup_dict or {}
    return _expand_with_manual_dict_and_location(
        _simpler_expand_location,
        ctx.var | additional_lookup_dict,
        source_env_dict,
    )

def _expand_with_toolchains_attr(ctx, env_attr_name = "env", additional_lookup_dict = None):
    """
    Recursively expands all values in "env" attr dict using the `ctx` lookup data.

    All keys of `env` attribute are returned in the resultant dict with values expanded by
    lookups via `ctx.var` dict (unioned with optional `additional_lookup_dict` parameter).
    The attribute used can be changed (instead of `env`) via the optional `env_attr_name` paramter.
    This function does not modify any of the given parameters.

    Args:
        ctx:    (Required) The bazel context object. This is used to access the `ctx.var` member
                for use as the "resolution dict". This makes use of providers from toolchains for
                environment variable expansion. This object is also used to retrieve various
                necessary attributes via `ctx.attr.<attr_name>`.
        env_attr_name:  (Optional) The name of the attribute that is used as the source for all
                        desired expansions. All key/value pairs will appear within the returned
                        dictionary, with all values fully expanded by lookups in `ctx.var` and
                        optional `additional_lookup_dict`.
                        Default value is "env".
        additional_lookup_dict: (Optional) Additional dict to be used with `ctx.var` (union) for
                                variable expansion.

    Returns:
      A new dict with all key/values from source attribute (default "env" attribute), where all
      values have been recursively expanded.
    """
    return _expand_with_toolchains(
        ctx,
        getattr(ctx.attr, env_attr_name),
        additional_lookup_dict = additional_lookup_dict,
    )

def _expand_with_toolchains_and_location_attr(
        ctx,
        deps_attr_name = "deps",
        env_attr_name = "env",
        additional_lookup_dict = None):
    """
    Recursively expands all values in "env" attr dict using the `ctx` logic / lookup data.

    All keys of `env` attribute are returned in the resultant dict with values expanded by
    location expansion logic via `ctx.expand_location` and by lookups via `ctx.var` dict (unioned
    with optional `additional_lookup_dict` parameter).
    This function does not modify any of the given parameters.

    Args:
        ctx:    (Required) The bazel context object. This is used to access the `ctx.var` member
                for use as the "resolution dict". This makes use of providers from toolchains for
                environment variable expansion. This object is also used for the
                `ctx.expand_location` method to handle `$(location ...)` (and similar) expansion
                logic. This object is also used to retrieve various necessary attributes via
                `ctx.attr.<attr_name>`. Default value is "deps".
        deps_attr_name: (Optional) The name of the attribute which contains the set of targets used
                        with `ctx.expand_location` for expanding `$(location ...)` (and similar)
                        expressions.
        env_attr_name:  (Optional) The name of the attribute that is used as the source for all
                        desired expansions. All key/value pairs will appear within the returned
                        dictionary, with all values fully expanded by lookups in `ctx.var` and
                        optional `additional_lookup_dict`.
                        Default value is "env".
        additional_lookup_dict: (Optional) Additional dict to be used with `ctx.var` (union) for
                                variable expansion.

    Returns:
      A new dict with all key/values from source attribute (default "env" attribute), where all
      values have been recursively expanded.
    """
    return _expand_with_toolchains_and_location(
        ctx,
        getattr(ctx.attr, deps_attr_name),
        getattr(ctx.attr, env_attr_name),
        additional_lookup_dict = additional_lookup_dict,
    )

expansion = struct(
    expand_with_manual_dict = _expand_with_manual_dict,
    expand_with_manual_dict_and_location = _expand_with_manual_dict_and_location,
    expand_with_toolchains = _expand_with_toolchains,
    expand_with_toolchains_attr = _expand_with_toolchains_attr,
    expand_with_toolchains_and_location = _expand_with_toolchains_and_location,
    expand_with_toolchains_and_location_attr = _expand_with_toolchains_and_location_attr,
)
