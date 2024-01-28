"""Skylib module containing functions that aid in environment variable expansion."""

_CONSIDERED_KEY_FORMATS = ("${}", "${{{}}}", "$({})")

def _valid_char_for_env_var_name(char):
    return char.isalnum() or char == "_"

def _find_env_var_name_index_index(
        string,
        str_len,
        search_start,
        special_ending_char = None):
    for offset in range(str_len - search_start):
        index = search_start + offset
        char = string[index]
        if special_ending_char:
            if char == special_ending_char:
                return index
        elif not _valid_char_for_env_var_name(char):
            return index - 1
    return str_len - 1

def _odd_count_dollar_sign_repeat(containing_str, end_of_dollar_signs_index):
    dollar_sign_count = 0
    for index in range(end_of_dollar_signs_index, -1, -1):
        if containing_str[index] != "$":
            break
        dollar_sign_count += 1
    return (dollar_sign_count % 2) == 1

def _key_to_be_expanded(str_with_key, key, start_of_key_index):
    # Check that the string at index is prefixed with an odd number of `$`.
    # Odd number means that the last `$` is not escaped.
    odd_count = _odd_count_dollar_sign_repeat(str_with_key, start_of_key_index)

    if not odd_count:
        return False

    # Check that the key is correctly matched.
    # Specifically, check the key isn't matching to another key (substring).
    key_mismatch = False
    if key[-1] not in (")", "}"):
        index_after_key = start_of_key_index + len(key)
        key_mismatch = (
            (index_after_key < len(str_with_key)) and
            _valid_char_for_env_var_name(str_with_key[index_after_key])
        )

    return not key_mismatch

def _fail_validation(fail_instead_of_return, found_errors_list, failure_message):
    if fail_instead_of_return:
        fail(failure_message)
    else:
        found_errors_list.append(failure_message)

def _validate_unterminated_expression(
        expanded_val,
        fail_instead_of_return,
        found_errors,
        dollar_sign_index,
        next_char_after_dollar_sign):
    if next_char_after_dollar_sign == "(":
        if expanded_val.find(")", dollar_sign_index + 1) < 0:
            unterminated_expr = expanded_val[dollar_sign_index:]
            _fail_validation(
                fail_instead_of_return,
                found_errors,
                "Unterminated '$(...)' expression ('{}' in '{}').".format(unterminated_expr, expanded_val),
            )
            return False
    elif next_char_after_dollar_sign == "{":
        if expanded_val.find("}", dollar_sign_index + 1) < 0:
            unterminated_expr = expanded_val[dollar_sign_index:]
            _fail_validation(
                fail_instead_of_return,
                found_errors,
                "Unterminated '${{...}}' expression ('{}' in '{}').".format(unterminated_expr, expanded_val),
            )
            return False
    return True

def _validate_unexpanded_expression(
        expanded_val,
        fail_instead_of_return,
        str_len,
        found_errors,
        dollar_sign_index,
        next_char_after_dollar_sign):
    # Find special ending char, if wrapped expression.
    special_ending_char = None
    if next_char_after_dollar_sign == "(":
        special_ending_char = ")"
    elif next_char_after_dollar_sign == "{":
        special_ending_char = "}"

    # Check for unexpanded expressions.
    name_end_index = _find_env_var_name_index_index(
        expanded_val,
        str_len,
        dollar_sign_index + 1,
        special_ending_char = special_ending_char,
    )
    _fail_validation(
        fail_instead_of_return,
        found_errors,
        "Unexpanded expression ('{}' in '{}').".format(
            expanded_val[dollar_sign_index:name_end_index + 1],
            expanded_val,
        ),
    )

def _validate_all_keys_expanded(expanded_val, fail_instead_of_return):
    str_len = len(expanded_val)
    str_iter = 0
    found_errors = []

    # Max iterations at the length of the str; will likely break out earlier.
    for _ in range(str_len):
        if str_iter >= str_len:
            break
        next_dollar_sign_index = expanded_val.find("$", str_iter)
        if next_dollar_sign_index < 0:
            break
        str_iter = next_dollar_sign_index + 1

        # Check for unterminated (non-escaped) ending dollar sign(s).
        if next_dollar_sign_index == str_len - 1:
            if _odd_count_dollar_sign_repeat(expanded_val, next_dollar_sign_index):
                _fail_validation(
                    fail_instead_of_return,
                    found_errors,
                    "Unterminated '$' expression in '{}'.".format(expanded_val),
                )

            # No error if escaped. Still at end of string, break out.
            break

        next_char_after_dollar_sign = expanded_val[next_dollar_sign_index + 1]

        # Check for continued dollar signs string (no need to handle yet).
        if next_char_after_dollar_sign == "$":
            continue

        # Check for escaped dollar signs (which are ok).
        if not _odd_count_dollar_sign_repeat(expanded_val, next_dollar_sign_index):
            continue

        # Check for unterminated expressions.
        if _validate_unterminated_expression(
            expanded_val,
            fail_instead_of_return,
            found_errors,
            next_dollar_sign_index,
            next_char_after_dollar_sign,
        ):
            # If not unterminated, it's unexpanded.
            _validate_unexpanded_expression(
                expanded_val,
                fail_instead_of_return,
                str_len,
                found_errors,
                next_dollar_sign_index,
                next_char_after_dollar_sign,
            )

    return found_errors

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
        formatted_keys = [key_format.format(avail_key) for key_format in _CONSIDERED_KEY_FORMATS]

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

def _expand_with_manual_dict(resolution_dict, source_env_dict, validate_expansion = False):
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
        validate_expansion: (Optional) If set to True, all expanded strings will be validated to
                            ensure that no unexpanded (but seemingly expandable) values remain. If
                            any unexpanded values are found, `fail()` will be called. The
                            validation logic is the same as
                            `expansion.validate_expansions_in_dict()`.
                            Default value is False.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """
    expanded_envs = {}
    for env_key, unexpanded_val in source_env_dict.items():
        expanded_val = _expand_all_keys_in_str(
            None,  # No `expand_location` available
            resolution_dict,
            source_env_dict,
            unexpanded_val,
        )
        if validate_expansion:
            _validate_all_keys_expanded(expanded_val, fail_instead_of_return = True)
        expanded_envs[env_key] = expanded_val
    return expanded_envs

def _expand_with_manual_dict_and_location(
        expand_location,
        resolution_dict,
        source_env_dict,
        validate_expansion = False):
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
        validate_expansion: (Optional) If set to True, all expanded strings will be validated to
                            ensure that no unexpanded (but seemingly expandable) values remain. If
                            any unexpanded values are found, `fail()` will be called. The
                            validation logic is the same as
                            `expansion.validate_expansions_in_dict()`.
                            Default value is False.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """
    expanded_envs = {}
    for env_key, unexpanded_val in source_env_dict.items():
        expanded_val = _expand_all_keys_in_str(
            expand_location,
            resolution_dict,
            source_env_dict,
            unexpanded_val,
        )
        if validate_expansion:
            _validate_all_keys_expanded(expanded_val, fail_instead_of_return = True)
        expanded_envs[env_key] = expanded_val
    return expanded_envs

def _expand_with_toolchains(
        ctx,
        source_env_dict,
        additional_lookup_dict = None,
        validate_expansion = False):
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
        validate_expansion:     (Optional) If set to True, all expanded strings will be validated
                                to ensure that no unexpanded (but seemingly expandable) values
                                remain. If any unexpanded values are found, `fail()` will be
                                called. The validation logic is the same as
                                `expansion.validate_expansions_in_dict()`.
                                Default value is False.

    Returns:
      A new dict with all key/values from `source_env_dict`, where all values have been recursively
      expanded.
    """
    additional_lookup_dict = additional_lookup_dict or {}
    return _expand_with_manual_dict(
        ctx.var | additional_lookup_dict,
        source_env_dict,
        validate_expansion = validate_expansion,
    )

def _expand_with_toolchains_and_location(
        ctx,
        deps,
        source_env_dict,
        additional_lookup_dict = None,
        validate_expansion = False):
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
        validate_expansion:     (Optional) If set to True, all expanded strings will be validated
                                to ensure that no unexpanded (but seemingly expandable) values
                                remain. If any unexpanded values are found, `fail()` will be
                                called. The validation logic is the same as
                                `expansion.validate_expansions_in_dict()`.
                                Default value is False.

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
        validate_expansion = validate_expansion,
    )

def _expand_with_toolchains_attr(
        ctx,
        env_attr_name = "env",
        additional_lookup_dict = None,
        validate_expansion = False):
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
        validate_expansion:     (Optional) If set to True, all expanded strings will be validated
                                to ensure that no unexpanded (but seemingly expandable) values
                                remain. If any unexpanded values are found, `fail()` will be
                                called. The validation logic is the same as
                                `expansion.validate_expansions_in_dict()`.
                                Default value is False.

    Returns:
      A new dict with all key/values from source attribute (default "env" attribute), where all
      values have been recursively expanded.
    """
    return _expand_with_toolchains(
        ctx,
        getattr(ctx.attr, env_attr_name),
        additional_lookup_dict = additional_lookup_dict,
        validate_expansion = validate_expansion,
    )

def _expand_with_toolchains_and_location_attr(
        ctx,
        deps_attr_name = "deps",
        env_attr_name = "env",
        additional_lookup_dict = None,
        validate_expansion = False):
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
        validate_expansion:     (Optional) If set to True, all expanded strings will be validated
                                to ensure that no unexpanded (but seemingly expandable) values
                                remain. If any unexpanded values are found, `fail()` will be
                                called. The validation logic is the same as
                                `expansion.validate_expansions_in_dict()`.
                                Default value is False.

    Returns:
      A new dict with all key/values from source attribute (default "env" attribute), where all
      values have been recursively expanded.
    """
    return _expand_with_toolchains_and_location(
        ctx,
        getattr(ctx.attr, deps_attr_name),
        getattr(ctx.attr, env_attr_name),
        additional_lookup_dict = additional_lookup_dict,
        validate_expansion = validate_expansion,
    )

def _validate_expansions(expanded_values, fail_instead_of_return = True):
    """
    Validates all given strings to no longer have unexpanded expressions.

    Validates all expanded strings in `expanded_values` to ensure that no unexpanded (but seemingly
    expandable) values remain.
    Any unterminated or unexpanded expressions of the form `$VAR`, $(VAR)`, or `${VAR}` will result
    in an error (with fail message).

    Args:
        expanded_values:            (Required) List of string values to validate.
        fail_instead_of_return:     (Optional) If set to True, `fail()` will be called upon first
                                    invalid (unexpanded) value found. If set to False, error
                                    messages will be collected and returned (no failure will
                                    occur); it will be the caller's responsibility to check the
                                    returned list.
                                    Default value is True.

    Returns:
      A list with all found invalid (unexpanded) values. Will be an empty list if all values are
      completely expanded. This function will not return if there were unexpanded substrings and if
      `fail_instead_of_return` is set to True (due to `fail()` being called).
    """
    found_errors = []
    for expanded_val in expanded_values:
        found_errors += _validate_all_keys_expanded(expanded_val, fail_instead_of_return)
    return found_errors

expansion = struct(
    expand_with_manual_dict = _expand_with_manual_dict,
    expand_with_manual_dict_and_location = _expand_with_manual_dict_and_location,
    expand_with_toolchains = _expand_with_toolchains,
    expand_with_toolchains_attr = _expand_with_toolchains_attr,
    expand_with_toolchains_and_location = _expand_with_toolchains_and_location,
    expand_with_toolchains_and_location_attr = _expand_with_toolchains_and_location_attr,
    validate_expansions = _validate_expansions,
)
