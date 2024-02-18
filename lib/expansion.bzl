"""Skylib module containing functions that aid in environment variable expansion."""

_CONSIDERED_KEY_FORMATS = ("${}", "${{{}}}", "$({})")

def _valid_char_for_env_var_name(char):
    """
    Determines if the given character could be used as a part of variable name.

    Args:
        char:   (Required) A string (intended to be length 1) to be checked.

    Returns:
        True if the character could be a part of a variable name. False otherwise.
    """
    return char.isalnum() or char == "_"

def _find_env_var_name_index_index(
        string,
        str_len,
        search_start_index,
        special_ending_char = None):
    """
    Searches for the end of a variable name in the given string, starting from the given index.

    Search will start from `search_start_index` and conclude once a character, which cannot be part
    of a variable name, is encountered or until the end of the string is reached.

    Args:
        string:     (Required) The string to search through.
        str_len:    (Required) The precomputed length of the given `string` parameter.
        search_start_index: (Required) The index to start searching from. This is intended to be
                            somewhere within (the start?) of a variable name.
        special_ending_char:    (Optional) A special character which will count as the end of the
                                variable name. This can be used for `$(VAR)`, `${VAR}`, or similar.
                                This replaces the "valid variable name character" checking,
                                allowing for other characters to occur before the given special
                                ending character.
                                If set to `None`, no special character will be checked for
                                (only checking for non-variable characters or the end of the
                                string).
                                The default value is `None`.

    Returns:
        The index (with respect to the start of `string`) of the last character of the variable
        name.
    """
    for offset in range(str_len - search_start_index):
        index = search_start_index + offset
        char = string[index]
        if special_ending_char:
            if char == special_ending_char:
                return index
        elif not _valid_char_for_env_var_name(char):
            return index - 1
    return str_len - 1

def _even_count_dollar_sign_repeat(containing_str, end_of_dollar_signs_index):
    """
    Searches backwards through the given string, counting the contiguous `$` characters.

    An even number of `$` characters is indicative of escaped variables, which should not be
    expanded (left as is in a string).

    Args:
        containing_str: (Required) The string to search through.
        end_of_dollar_signs_index:  (Required) The index of the end of the contiguous `$`
                                    characters in `containing_str`. This is the starting
                                    index for the backwards search.

    Returns:
        True if the set of contiguous `$` characters has even length. False if the length is odd.
    """
    dollar_sign_count = 0
    for index in range(end_of_dollar_signs_index, -1, -1):
        if containing_str[index] != "$":
            break
        dollar_sign_count += 1
    return (dollar_sign_count % 2) == 0

def _key_to_be_expanded(str_with_key, key, start_of_key_index):
    """
    Examines the given string and determines if the given "key" should be expanded.

    The "key" was located within the given string (as a substring). This function
    determines whether the key is complete and is to be expanded.

    Args:
        str_with_key:   (Required) The string that `key` is found within.
        key:            (Required) The found substring in `str_with_key` which needs to possibly be
                        expanded.
        start_of_key_index: (Required) The index where `key` was found within `str_with_key`.

    Returns:
        True if the found key is complete (not a substring of another potential key) and is not
        escaped (even number of preceding `$`).
    """

    # Check that the string at index is prefixed with an even number of `$`.
    # An even number means that the last `$` is escaped.
    if _even_count_dollar_sign_repeat(str_with_key, start_of_key_index):
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
    """
    This is called when a failure has occured and handles propagation of a failure message.

    Will either call `fail()` with the given failure message (to hard fail immediately) or append
    the given failure message to the given list.

    Args:
        fail_instead_of_return: (Required) If set to True, `fail()` will be called (will not
                                return). If set to False, `found_errors_list` will be appended to
                                and the function will return normally.
        found_errors_list:      (Required) In/out list for error messages to be appended into. Will
                                only be used if `fail_instead_of_return` is False.
        failure_message:        (Required) Failure message to be either passed to `fail()` or
                                appended into `found_errors_list`.
    """
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
    """
    Checks if given string contains an unterminated expression of the form `$(VAR)` or `${VAR}`.

    If the given variable/expression is of the correct form, and unterminated, an error will be
    noted (either by calling `fail()` or by appending it into the given error list).

    Args:
        expanded_val:   (Required) The string which contains a `$` preceding a variable (to be
                        expanded).
        fail_instead_of_return: (Required) If set to True, `fail()` will be called (will not
                                return) when an unterminated variable is found. If set to False,
                                `found_errors` will be appended to and the function will return
                                normally.
        found_errors:   (Required) In/out list for error messages to be appended into. Will only be
                        used if `fail_instead_of_return` is False.
        dollar_sign_index:  (Required) The index of the `$` at the start of the expression.
        next_char_after_dollar_sign:    (Required) The character that immediately follows the `$`.

    Returns:
        The validaity of the string.
        Returns False if the variable was of the form and unterminated. Returns True otherwise.
    """
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
    """
    Always generates an error for the given string (containing unexpanded variable).

    The given string contains a variable which unexpanded (and is not escaped), an error will be
    noted (either by calling `fail()` or by appending it into the given error list).

    Args:
        expanded_val:   (Required) The string which contains a `$` preceding a variable (to be
                        expanded).
        fail_instead_of_return: (Required) If set to True, `fail()` will be called (will not
                                return). If set to False, `found_errors` will be appended to and
                                the function will return normally.
        str_len:        (Required) The precomputed length of the given `expanded_val` parameter.
        found_errors:   (Required) In/out list for error messages to be appended into. Will only be
                        used if `fail_instead_of_return` is False.
        dollar_sign_index:  (Required) The index of the `$` at the start of the unexpanded
                            expression.
        next_char_after_dollar_sign:    (Required) The character that immediately follows the `$`.
    """

    # Find special ending char, if wrapped expression.
    special_ending_char = None
    if next_char_after_dollar_sign == "(":
        special_ending_char = ")"
    elif next_char_after_dollar_sign == "{":
        special_ending_char = "}"

    # Find info for unexpanded expression and fail.
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
    """
    Iterates over the entire given string, searching for any unexpanded variables/expressions.

    If any unexpanded/unterminated variables/expressions are found, an error will be noted (either
    by calling `fail()` and hard failing immediately, or by collecting all such found errors and
    returning it in a list).

    Args:
        expanded_val:   (Required) The string to be checked for any potentially unescaped and
                        unexpanded/unterminated variables/expressions.
        fail_instead_of_return: (Required) If set to True, `fail()` will be called (will not
                                return) when the first error has been found. If set to False, the
                                function will return normally and return a list of all found
                                errors.

    Returns:
        A list of found errors. Each element in the list is a failure message with details about
        the unescaped and unexpanded/unterminated variable/expression. The list will be empty if
        no such expressions were found. This function does not return if `fail_instead_of_return`
        was set to True (`fail()` will be called).
    """
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
            if not _even_count_dollar_sign_repeat(expanded_val, next_dollar_sign_index):
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
        if _even_count_dollar_sign_repeat(expanded_val, next_dollar_sign_index):
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
    """
    Expand the given key, by replacing it with the given value, in the given string.

    The given `key` may or may not be contained in the given string `unexpanded_str`.
    If the given key is found, it will be expanded/replaced by the given `val` string.
    The key is given in its full formatted form with preceding `$` (`$VAR`, `$(VAR)`, `${VAR}`,
    `$(VAR VAL)`, etc).
    The key will not be expanded if it is escaped (an even number of contiguous `$` characters at
    the start) or if the found key is a substring of another potential key (e.g. `$VAR` will not be
    expanded if the found location is `$VARIABLE`).
    The given key will be replaced (as appropriate) for all occurences within the given string.

    Args:
        key:    (Required) The key to search for (within the given string, `unexpanded_str`) and
                replace all occurences of the key with the given replacement value, `val`.
        val:    (Required) The value to replace all found occurences of the given key, `key`, into
                the given string, `unexpanded_str`.
        unexpanded_str: (Required) The string to search for `key` and replace with `val`.

    Returns:
        A copy of `unexpanded_str` with all occurences of `key` replaced with `val` (as necessary).
        The returned string will be `unexpanded_str` (not a copy), if `key` is not found/expanded.
    """
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
    """
    Uses the given dictionary to replace keys with values in the given string.

    Each key is intended to be a variable name (e.g. `VARIABLE_NAME`), which can be wrapped with
    `$`, `$( )`, or `${ }` (to express the given example key as the "formatted key"
    `$VARIABLE_NAME`, `$(VARIABLE_NAME)`, or `${VARIABLE_NAME}`). The corresponding value (in the
    dict) is to be used as the intended replacement string when any matching formatted key (of the
    given variable name key) is found within the given string, `unexpanded_str`.

    Args:
        replacement_dict:   (Required) The set of key/value pairs to be used for search/replacement
                            within the given `unexpanded_str` string.
        unexpanded_str:     (Required) The string to search for the formatted versions of each key
                            set within `replacement_dict`, where each found occurence will be
                            expanded/replaced with the associated value.

    Returns:
        A copy of `unexpanded_str` with all occurences of each key (when formatted into an
        unexpanded variable) within `replacement_dict` replaced with corresponding value (as
        necessary).
        The returned string will be `unexpanded_str` (not a copy), if no expansion occurs.
    """

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
    """
    Uses the given dictionaries to replace keys with values in the given string.

    Each key, in the given dictionaries, is intended to be a variable name (e.g. `VARIABLE_NAME`),
    which can be wrapped with `$`, `$( )`, or `${ }` (to express the given example key as the
    "formatted key" `$VARIABLE_NAME`, `$(VARIABLE_NAME)`, or `${VARIABLE_NAME}`). The corresponding
    value (in the dict) is to be used as the intended replacement string when any matching
    formatted key (of the given variable name key) is found within the given string,
    `unexpanded_str`.

    Expansion happens iteratively. In each iteration, three steps occur:
    1) If `expand_location` is not `None`, it will be invoked to replace any occurrences of
        `$(location ...)` (or similar). Technically, this function can execute any high-priority
        expansion logic -- but it is intended for functionality similar to `ctx.expand_location()`.
    2) Each variable name key in `env_replacement_dict` will be searched for (in `unexpanded_str`)
        and expanded into the corresponding value within the dict for the given found variable
        name. This is intended for the use with the `env` attribute for a given target (but
        supports any general "higher priority" dict replacement).
    3) Each variable name key in `resolved_replacement_dict` will be searched for (in
        `unexpanded_str`) and expanded into the corresponding value within the dict for the given
        found variable name. This is intended for the use with `ctx.var` which contains toolchain
        resolved key/values (but supports any general "lower priority" dict replacement).

    Args:
        expand_location:            (Required) A None-able function used for optional "location"
                                    expansion logic (`$(location ...)` or similar).
        resolved_replacement_dict:  (Required) A set of key/value pairs to be used for
                                    search/replacement within the given `unexpanded_str` string.
                                    Replacement logic will occur after (lower priority) replacement
                                    for `env_replacement_dict`.
        env_replacement_dict:   (Required) A set of key/value pairs to be used for
                                search/replacement within the given `unexpanded_str` string.
                                Replacement logic will occur before (higher priority) replacement
                                for `resolved_replacement_dict`.
        unexpanded_str:     (Required) The string to perform expansion variable upon (optionally
                            invoke `expand_location`, and search for the formatted versions of each
                            key set within `env_replacement_dict` and `resolved_replacement_dict`,
                            where each found occurence will be expanded/replaced with the
                            associated value).

    Returns:
        A copy of `unexpanded_str` with all occurences of each key (when formatted into an
        unexpanded variable) within `replacement_dict` replaced with corresponding value (as
        necessary).
        The returned string will be `unexpanded_str` (not a copy), if no expansion occurs.
    """
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
                `ctx.attr.<attr_name>`.
        deps_attr_name: (Optional) The name of the attribute which contains the set of targets used
                        with `ctx.expand_location` for expanding `$(location ...)` (and similar)
                        expressions.
                        Default value is "deps".
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
