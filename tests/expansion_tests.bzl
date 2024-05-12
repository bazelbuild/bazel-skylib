"""Unit tests for expansion.bzl."""

load("//lib:expansion.bzl", "expansion")
load("//lib:unittest.bzl", "asserts", "unittest")

# String constants

_TEST_DEP_TARGET_NAME = "expansion_tests__dummy"

_MOCK_LOCATION_PATH_OF_DUMMY = "location/path/of/dummy"
_MOCK_EXECPATH_PATH_OF_DUMMY = "execpath/path/of/dummy"
_MOCK_ROOTPATH_PATH_OF_DUMMY = "rootpath/path/of/dummy"
_MOCK_RLOCATIONPATH_PATH_OF_DUMMY = "rlocationpath/path/of/dummy"

_GENRULE_LOCATION_PATH_OF_DUMMY = "bazel-out/k8-fastbuild/bin/tests/dummy.txt"
_GENRULE_EXECPATH_PATH_OF_DUMMY = "bazel-out/k8-fastbuild/bin/tests/dummy.txt"
_GENRULE_ROOTPATH_PATH_OF_DUMMY = "tests/dummy.txt"
_GENRULE_RLOCATIONPATH_PATH_OF_DUMMY = "_main/tests/dummy.txt"

_LINUX_FASTBUILD_SUBPATH = "k8-fastbuild"
_MAC_FASTBUILD_SUBPATH = "darwin_x86_64-fastbuild"
_WIN_FASTBUILD_SUBPATH = "x64_windows-fastbuild"

# Test input dicts

_ENV_DICT = {
    "SIMPLE_VAL": "hello_world",
    "ESCAPED_SIMPLE_VAL": "$$SIMPLE_VAL",
    "LOCATION_VAL": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "EXECPATH_VAL": "$(execpath :" + _TEST_DEP_TARGET_NAME + ")",
    "ROOTPATH_VAL": "$(rootpath :" + _TEST_DEP_TARGET_NAME + ")",
    "RLOCATIONPATH_VAL": "$(rlocationpath :" + _TEST_DEP_TARGET_NAME + ")",
    "TOOLCHAIN_ENV_VAR_RAW": "$TOOLCHAIN_ENV_VAR",
    "TOOLCHAIN_ENV_VAR_PAREN": "$(TOOLCHAIN_ENV_VAR)",
    "TOOLCHAIN_ENV_VAR_CURLY": "${TOOLCHAIN_ENV_VAR}",
    "TOOLCHAIN_ENV_VAR2_RAW": "$TOOLCHAIN_ENV_VAR2",
    "TOOLCHAIN_ENV_VAR2_PAREN": "$(TOOLCHAIN_ENV_VAR2)",
    "TOOLCHAIN_ENV_VAR2_CURLY": "${TOOLCHAIN_ENV_VAR2}",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": "$TOOLCHAIN_TO_LOCATION_ENV_VAR",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": "$(TOOLCHAIN_TO_LOCATION_ENV_VAR)",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": "${TOOLCHAIN_TO_LOCATION_ENV_VAR}",
    "TOOLCHAIN_TO_ENV_DICT_ENV_VAR_RAW": "$BACK_TO_ENV_DICT_VAR_RAW",
    "TOOLCHAIN_TO_ENV_DICT_ENV_VAR_PAREN": "$(BACK_TO_ENV_DICT_VAR_PAREN)",
    "TOOLCHAIN_TO_ENV_DICT_ENV_VAR_CURLY": "${BACK_TO_ENV_DICT_VAR_CURLY}",
    "INDIRECT_SIMPLE_VAL_RAW": "$SIMPLE_VAL",
    "INDIRECT_SIMPLE_VAL_PAREN": "$(SIMPLE_VAL)",
    "INDIRECT_SIMPLE_VAL_CURLY": "${SIMPLE_VAL}",
    "INDIRECT_ESCAPED_SIMPLE_VAL_RAW": "$ESCAPED_SIMPLE_VAL",
    "INDIRECT_ESCAPED_SIMPLE_VAL_PAREN": "$(ESCAPED_SIMPLE_VAL)",
    "INDIRECT_ESCAPED_SIMPLE_VAL_CURLY": "${ESCAPED_SIMPLE_VAL}",
    "INDIRECT_LOCATION_VAL_RAW": "$LOCATION_VAL",
    "INDIRECT_LOCATION_VAL_PAREN": "$(LOCATION_VAL)",
    "INDIRECT_LOCATION_VAL_CURLY": "${LOCATION_VAL}",
    "INDIRECT_EXECPATH_VAL_RAW": "$EXECPATH_VAL",
    "INDIRECT_EXECPATH_VAL_PAREN": "$(EXECPATH_VAL)",
    "INDIRECT_EXECPATH_VAL_CURLY": "${EXECPATH_VAL}",
    "INDIRECT_ROOTPATH_VAL_RAW": "$ROOTPATH_VAL",
    "INDIRECT_ROOTPATH_VAL_PAREN": "$(ROOTPATH_VAL)",
    "INDIRECT_ROOTPATH_VAL_CURLY": "${ROOTPATH_VAL}",
    "INDIRECT_RLOCATIONPATH_VAL_RAW": "$RLOCATIONPATH_VAL",
    "INDIRECT_RLOCATIONPATH_VAL_PAREN": "$(RLOCATIONPATH_VAL)",
    "INDIRECT_RLOCATIONPATH_VAL_CURLY": "${RLOCATIONPATH_VAL}",
    "INDIRECT_TOOLCHAIN_ENV_VAR_RAW": "$TOOLCHAIN_ENV_VAR_RAW",
    "INDIRECT_TOOLCHAIN_ENV_VAR_PAREN": "$(TOOLCHAIN_ENV_VAR_RAW)",
    "INDIRECT_TOOLCHAIN_ENV_VAR_CURLY": "${TOOLCHAIN_ENV_VAR_RAW}",
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": "$TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW",
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": "$(TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW)",
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": "${TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW}",
    "MULTI_INDIRECT_RAW": (
        "$INDIRECT_SIMPLE_VAL_RAW-$INDIRECT_ESCAPED_SIMPLE_VAL_RAW-" +
        "$INDIRECT_LOCATION_VAL_RAW-$INDIRECT_RLOCATIONPATH_VAL_RAW-" +
        "$INDIRECT_TOOLCHAIN_ENV_VAR_RAW-$INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW"
    ),
    "MULTI_INDIRECT_PAREN": (
        "$(INDIRECT_SIMPLE_VAL_RAW)-$(INDIRECT_ESCAPED_SIMPLE_VAL_RAW)-" +
        "$(INDIRECT_LOCATION_VAL_RAW)-$(INDIRECT_RLOCATIONPATH_VAL_RAW)-" +
        "$(INDIRECT_TOOLCHAIN_ENV_VAR_RAW)-$(INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW)"
    ),
    "MULTI_INDIRECT_CURLY": (
        "${INDIRECT_SIMPLE_VAL_RAW}-${INDIRECT_ESCAPED_SIMPLE_VAL_RAW}-" +
        "${INDIRECT_LOCATION_VAL_RAW}-${INDIRECT_RLOCATIONPATH_VAL_RAW}-" +
        "${INDIRECT_TOOLCHAIN_ENV_VAR_RAW}-${INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW}"
    ),
    "UNRECOGNIZED_VAR": "$NOPE",
    "UNRECOGNIZED_FUNC": "$(nope :" + _TEST_DEP_TARGET_NAME + ")",
}

_TOOLCHAIN_DICT = {
    "TOOLCHAIN_ENV_VAR": "flag_value",
    "TOOLCHAIN_ENV_VAR2": "flag_value_2",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "BACK_TO_ENV_DICT_VAR_RAW": "$SIMPLE_VAL",
    "BACK_TO_ENV_DICT_VAR_PAREN": "$(SIMPLE_VAL)",
    "BACK_TO_ENV_DICT_VAR_CURLY": "${SIMPLE_VAL}",
}

# Test expected output dicts

_EXPECTED_RESOLVED_DICT_NO_LOCATION = {
    "SIMPLE_VAL": "hello_world",
    "ESCAPED_SIMPLE_VAL": "$$SIMPLE_VAL",
    "LOCATION_VAL": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "EXECPATH_VAL": "$(execpath :" + _TEST_DEP_TARGET_NAME + ")",
    "ROOTPATH_VAL": "$(rootpath :" + _TEST_DEP_TARGET_NAME + ")",
    "RLOCATIONPATH_VAL": "$(rlocationpath :" + _TEST_DEP_TARGET_NAME + ")",
    "TOOLCHAIN_ENV_VAR_RAW": "flag_value",
    "TOOLCHAIN_ENV_VAR_PAREN": "flag_value",
    "TOOLCHAIN_ENV_VAR_CURLY": "flag_value",
    "TOOLCHAIN_ENV_VAR2_RAW": "flag_value_2",
    "TOOLCHAIN_ENV_VAR2_PAREN": "flag_value_2",
    "TOOLCHAIN_ENV_VAR2_CURLY": "flag_value_2",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "TOOLCHAIN_TO_ENV_DICT_ENV_VAR_RAW": "hello_world",
    "TOOLCHAIN_TO_ENV_DICT_ENV_VAR_PAREN": "hello_world",
    "TOOLCHAIN_TO_ENV_DICT_ENV_VAR_CURLY": "hello_world",
    "INDIRECT_SIMPLE_VAL_RAW": "hello_world",
    "INDIRECT_SIMPLE_VAL_PAREN": "hello_world",
    "INDIRECT_SIMPLE_VAL_CURLY": "hello_world",
    "INDIRECT_ESCAPED_SIMPLE_VAL_RAW": "$$SIMPLE_VAL",
    "INDIRECT_ESCAPED_SIMPLE_VAL_PAREN": "$$SIMPLE_VAL",
    "INDIRECT_ESCAPED_SIMPLE_VAL_CURLY": "$$SIMPLE_VAL",
    "INDIRECT_LOCATION_VAL_RAW": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_LOCATION_VAL_PAREN": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_LOCATION_VAL_CURLY": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_EXECPATH_VAL_RAW": "$(execpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_EXECPATH_VAL_PAREN": "$(execpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_EXECPATH_VAL_CURLY": "$(execpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_ROOTPATH_VAL_RAW": "$(rootpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_ROOTPATH_VAL_PAREN": "$(rootpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_ROOTPATH_VAL_CURLY": "$(rootpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_RLOCATIONPATH_VAL_RAW": "$(rlocationpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_RLOCATIONPATH_VAL_PAREN": "$(rlocationpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_RLOCATIONPATH_VAL_CURLY": "$(rlocationpath :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_TOOLCHAIN_ENV_VAR_RAW": "flag_value",
    "INDIRECT_TOOLCHAIN_ENV_VAR_PAREN": "flag_value",
    "INDIRECT_TOOLCHAIN_ENV_VAR_CURLY": "flag_value",
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": "$(location :" + _TEST_DEP_TARGET_NAME + ")",
    "MULTI_INDIRECT_RAW": (
        "hello_world-$$SIMPLE_VAL-$(location :" +
        _TEST_DEP_TARGET_NAME +
        ")-$(rlocationpath :" +
        _TEST_DEP_TARGET_NAME +
        ")-flag_value-$(location :" +
        _TEST_DEP_TARGET_NAME +
        ")"
    ),
    "MULTI_INDIRECT_PAREN": (
        "hello_world-$$SIMPLE_VAL-$(location :" +
        _TEST_DEP_TARGET_NAME +
        ")-$(rlocationpath :" +
        _TEST_DEP_TARGET_NAME +
        ")-flag_value-$(location :" +
        _TEST_DEP_TARGET_NAME +
        ")"
    ),
    "MULTI_INDIRECT_CURLY": (
        "hello_world-$$SIMPLE_VAL-$(location :" +
        _TEST_DEP_TARGET_NAME +
        ")-$(rlocationpath :" +
        _TEST_DEP_TARGET_NAME +
        ")-flag_value-$(location :" +
        _TEST_DEP_TARGET_NAME +
        ")"
    ),
    "UNRECOGNIZED_VAR": "$NOPE",
    "UNRECOGNIZED_FUNC": "$(nope :" + _TEST_DEP_TARGET_NAME + ")",
}

_EXPECTED_RESOLVED_DICT_WITH_MOCKED_LOCATION = _EXPECTED_RESOLVED_DICT_NO_LOCATION | {
    "LOCATION_VAL": _MOCK_LOCATION_PATH_OF_DUMMY,
    "EXECPATH_VAL": _MOCK_EXECPATH_PATH_OF_DUMMY,
    "ROOTPATH_VAL": _MOCK_ROOTPATH_PATH_OF_DUMMY,
    "RLOCATIONPATH_VAL": _MOCK_RLOCATIONPATH_PATH_OF_DUMMY,
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": _MOCK_LOCATION_PATH_OF_DUMMY,
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": _MOCK_LOCATION_PATH_OF_DUMMY,
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": _MOCK_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_LOCATION_VAL_RAW": _MOCK_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_LOCATION_VAL_PAREN": _MOCK_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_LOCATION_VAL_CURLY": _MOCK_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_EXECPATH_VAL_RAW": _MOCK_EXECPATH_PATH_OF_DUMMY,
    "INDIRECT_EXECPATH_VAL_PAREN": _MOCK_EXECPATH_PATH_OF_DUMMY,
    "INDIRECT_EXECPATH_VAL_CURLY": _MOCK_EXECPATH_PATH_OF_DUMMY,
    "INDIRECT_ROOTPATH_VAL_RAW": _MOCK_ROOTPATH_PATH_OF_DUMMY,
    "INDIRECT_ROOTPATH_VAL_PAREN": _MOCK_ROOTPATH_PATH_OF_DUMMY,
    "INDIRECT_ROOTPATH_VAL_CURLY": _MOCK_ROOTPATH_PATH_OF_DUMMY,
    "INDIRECT_RLOCATIONPATH_VAL_RAW": _MOCK_RLOCATIONPATH_PATH_OF_DUMMY,
    "INDIRECT_RLOCATIONPATH_VAL_PAREN": _MOCK_RLOCATIONPATH_PATH_OF_DUMMY,
    "INDIRECT_RLOCATIONPATH_VAL_CURLY": _MOCK_RLOCATIONPATH_PATH_OF_DUMMY,
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": _MOCK_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": _MOCK_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": _MOCK_LOCATION_PATH_OF_DUMMY,
    "MULTI_INDIRECT_RAW": (
        "hello_world-$$SIMPLE_VAL-" +
        _MOCK_LOCATION_PATH_OF_DUMMY +
        "-" +
        _MOCK_RLOCATIONPATH_PATH_OF_DUMMY +
        "-flag_value-" +
        _MOCK_LOCATION_PATH_OF_DUMMY
    ),
    "MULTI_INDIRECT_PAREN": (
        "hello_world-$$SIMPLE_VAL-" +
        _MOCK_LOCATION_PATH_OF_DUMMY +
        "-" +
        _MOCK_RLOCATIONPATH_PATH_OF_DUMMY +
        "-flag_value-" +
        _MOCK_LOCATION_PATH_OF_DUMMY
    ),
    "MULTI_INDIRECT_CURLY": (
        "hello_world-$$SIMPLE_VAL-" +
        _MOCK_LOCATION_PATH_OF_DUMMY +
        "-" +
        _MOCK_RLOCATIONPATH_PATH_OF_DUMMY +
        "-flag_value-" +
        _MOCK_LOCATION_PATH_OF_DUMMY
    ),
}

_EXPECTED_RESOLVED_DICT_WITH_GENRULE_LOCATION = _EXPECTED_RESOLVED_DICT_NO_LOCATION | {
    "LOCATION_VAL": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "EXECPATH_VAL": _GENRULE_EXECPATH_PATH_OF_DUMMY,
    "ROOTPATH_VAL": _GENRULE_ROOTPATH_PATH_OF_DUMMY,
    "RLOCATIONPATH_VAL": _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY,
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_LOCATION_VAL_RAW": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_LOCATION_VAL_PAREN": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_LOCATION_VAL_CURLY": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_EXECPATH_VAL_RAW": _GENRULE_EXECPATH_PATH_OF_DUMMY,
    "INDIRECT_EXECPATH_VAL_PAREN": _GENRULE_EXECPATH_PATH_OF_DUMMY,
    "INDIRECT_EXECPATH_VAL_CURLY": _GENRULE_EXECPATH_PATH_OF_DUMMY,
    "INDIRECT_ROOTPATH_VAL_RAW": _GENRULE_ROOTPATH_PATH_OF_DUMMY,
    "INDIRECT_ROOTPATH_VAL_PAREN": _GENRULE_ROOTPATH_PATH_OF_DUMMY,
    "INDIRECT_ROOTPATH_VAL_CURLY": _GENRULE_ROOTPATH_PATH_OF_DUMMY,
    "INDIRECT_RLOCATIONPATH_VAL_RAW": _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY,
    "INDIRECT_RLOCATIONPATH_VAL_PAREN": _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY,
    "INDIRECT_RLOCATIONPATH_VAL_CURLY": _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY,
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_RAW": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_PAREN": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "INDIRECT_TOOLCHAIN_TO_LOCATION_ENV_VAR_CURLY": _GENRULE_LOCATION_PATH_OF_DUMMY,
    "MULTI_INDIRECT_RAW": (
        "hello_world-$$SIMPLE_VAL-" +
        _GENRULE_LOCATION_PATH_OF_DUMMY +
        "-" +
        _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY +
        "-flag_value-" +
        _GENRULE_LOCATION_PATH_OF_DUMMY
    ),
    "MULTI_INDIRECT_PAREN": (
        "hello_world-$$SIMPLE_VAL-" +
        _GENRULE_LOCATION_PATH_OF_DUMMY +
        "-" +
        _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY +
        "-flag_value-" +
        _GENRULE_LOCATION_PATH_OF_DUMMY
    ),
    "MULTI_INDIRECT_CURLY": (
        "hello_world-$$SIMPLE_VAL-" +
        _GENRULE_LOCATION_PATH_OF_DUMMY +
        "-" +
        _GENRULE_RLOCATIONPATH_PATH_OF_DUMMY +
        "-flag_value-" +
        _GENRULE_LOCATION_PATH_OF_DUMMY
    ),
}

# Unresolved/unterminated validation test input values and expected values

_UNRESOLVED_SUBSTRINGS = [
    "$SOME_UNEXPANDED_VAR_RAW",
    "$(SOME_UNEXPANDED_VAR_PAREN)",
    "${SOME_UNEXPANDED_VAR_CURLY}",
]

_UNRESOLVED_SUBSTRINGS_FORMAT_STRINGS = [
    "{}",
    "prefix-{}",
    "prefix {}",
    "{}-suffix",
    "{} suffix",
    "prefix-{}-suffix",
    "prefix {} suffix",
]

_UNRESOLVED_SUBSTRING_EXPECTED_ERROR_MESSAGES = [
    "Unexpanded expression ('{}' in '{}').".format(unresolved_substr, full_string)
    for unresolved_substr in _UNRESOLVED_SUBSTRINGS
    for full_string in [
        format_str.format(unresolved_substr)
        for format_str in _UNRESOLVED_SUBSTRINGS_FORMAT_STRINGS
    ]
]

_TWO_UNRESOLVED_SUBSTRINGS = [
    "{}-{}".format(a, b)
    for a in _UNRESOLVED_SUBSTRINGS
    for b in _UNRESOLVED_SUBSTRINGS
] + [
    "{} {}".format(a, b)
    for a in _UNRESOLVED_SUBSTRINGS
    for b in _UNRESOLVED_SUBSTRINGS
]

_TWO_UNRESOLVED_SUBSTRING_EXPECTED_ERROR_MESSAGES = [
    "Unexpanded expression ('{}' in '{}').".format(unresolved_substr, full_string)
    for unresolved_substr in _UNRESOLVED_SUBSTRINGS
    for full_string in _TWO_UNRESOLVED_SUBSTRINGS
    if unresolved_substr in full_string
]

_UNRESOLVED_NAMELESS_SUBSTRINGS_FORMAT_STRINGS = [
    "{}-suffix",
    "{} suffix",
    "prefix-{}-suffix",
    "prefix {} suffix",
]

_UNRESOLVED_NAMELESS_SUBSTRING_EXPECTED_ERROR_MESSAGES = [
    "Unexpanded expression ('{}' in '{}').".format("$", full_string)
    for unresolved_substr in _UNRESOLVED_SUBSTRINGS
    for full_string in [
        format_str.format("$")
        for format_str in _UNRESOLVED_NAMELESS_SUBSTRINGS_FORMAT_STRINGS
    ]
]

_UNTERMINATED_SUBSTRINGS_PAREN = [
    "$(",
    "$(VAR",
    "$(VAR ",
    "$(VAR VAL",
]

_UNTERMINATED_SUBSTRINGS_CURLY = [
    "${",
    "${VAR",
    "${VAR ",
    "${VAR VAL",
]

_UNTERMINATED_SUBSTRINGS_FORMAT_STRINGS = [
    "{}",
    "prefix-{}",
    "prefix {}",
]

_UNTERMINATED_SUBSTRING_EXPECTED_ERROR_MESSAGES_RAW = [
    "Unterminated '$' expression in '{}'.".format(full_string)
    for full_string in [
        format_str.format("$")
        for format_str in _UNTERMINATED_SUBSTRINGS_FORMAT_STRINGS
    ]
]

_UNTERMINATED_SUBSTRING_EXPECTED_ERROR_MESSAGES_PAREN = [
    "Unterminated '$(...)' expression ('{}' in '{}').".format(unresolved_substr, full_string)
    for unresolved_substr in _UNTERMINATED_SUBSTRINGS_PAREN
    for full_string in [
        format_str.format(unresolved_substr)
        for format_str in _UNTERMINATED_SUBSTRINGS_FORMAT_STRINGS
    ]
]

_UNTERMINATED_SUBSTRING_EXPECTED_ERROR_MESSAGES_CURLY = [
    "Unterminated '${{...}}' expression ('{}' in '{}').".format(unresolved_substr, full_string)
    for unresolved_substr in _UNTERMINATED_SUBSTRINGS_CURLY
    for full_string in [
        format_str.format(unresolved_substr)
        for format_str in _UNTERMINATED_SUBSTRINGS_FORMAT_STRINGS
    ]
]

# Test helper functions and rules

def _test_toolchain_impl(ctx):
    _ignore = [ctx]  # @unused
    return [platform_common.TemplateVariableInfo(_TOOLCHAIN_DICT)]

_test_toolchain = rule(
    implementation = _test_toolchain_impl,
)

def _mock_expand_location(input_str):
    return input_str.replace(
        "$(location :" + _TEST_DEP_TARGET_NAME + ")",
        _MOCK_LOCATION_PATH_OF_DUMMY,
    ).replace(
        "$(execpath :" + _TEST_DEP_TARGET_NAME + ")",
        _MOCK_EXECPATH_PATH_OF_DUMMY,
    ).replace(
        "$(rootpath :" + _TEST_DEP_TARGET_NAME + ")",
        _MOCK_ROOTPATH_PATH_OF_DUMMY,
    ).replace(
        "$(rlocationpath :" + _TEST_DEP_TARGET_NAME + ")",
        _MOCK_RLOCATIONPATH_PATH_OF_DUMMY,
    )

def _fix_platform_dependent_path_for_assertions(platform_dependent_val):
    return platform_dependent_val.replace(
        _MAC_FASTBUILD_SUBPATH,
        _LINUX_FASTBUILD_SUBPATH,
    ).replace(
        _WIN_FASTBUILD_SUBPATH,
        _LINUX_FASTBUILD_SUBPATH,
    )

# Test cases

def _expand_with_manual_dict_test_impl(ctx):
    """Test `expansion.expand_with_manual_dict()`"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(_ENV_DICT)
    toolchain_dict_copy = dict(_TOOLCHAIN_DICT)

    resolved_dict = expansion.expand_with_manual_dict(_TOOLCHAIN_DICT, _ENV_DICT)

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, _ENV_DICT)
    asserts.equals(env, toolchain_dict_copy, _TOOLCHAIN_DICT)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, _ENV_DICT.keys(), resolved_dict.keys())

    # Check all output resolved values against expected resolved values.
    for env_key, _ in _ENV_DICT.items():
        expected_val = _EXPECTED_RESOLVED_DICT_NO_LOCATION[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_manual_dict_test = unittest.make(_expand_with_manual_dict_test_impl)

def _expand_with_manual_dict_and_location_test_impl(ctx):
    """Test `expansion.expand_with_manual_dict_and_location()`"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(_ENV_DICT)
    toolchain_dict_copy = dict(_TOOLCHAIN_DICT)

    resolved_dict = expansion.expand_with_manual_dict_and_location(
        _mock_expand_location,
        _TOOLCHAIN_DICT,
        _ENV_DICT,
    )

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, _ENV_DICT)
    asserts.equals(env, toolchain_dict_copy, _TOOLCHAIN_DICT)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, _ENV_DICT.keys(), resolved_dict.keys())

    # Check all output resolved values against expected resolved values.
    for env_key, _ in _ENV_DICT.items():
        expected_val = _EXPECTED_RESOLVED_DICT_WITH_MOCKED_LOCATION[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_manual_dict_and_location_test = unittest.make(
    _expand_with_manual_dict_and_location_test_impl,
)

def _expand_with_toolchains_test_impl(ctx):
    """Test `expansion.expand_with_toolchains()` without extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(_ENV_DICT)
    toolchain_dict_copy = dict(env.ctx.var)

    resolved_dict = expansion.expand_with_toolchains(env.ctx, _ENV_DICT)

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, _ENV_DICT)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, _ENV_DICT.keys(), resolved_dict.keys())

    # Check all output resolved values against expected resolved values.
    for env_key, _ in _ENV_DICT.items():
        expected_val = _EXPECTED_RESOLVED_DICT_NO_LOCATION[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_test = unittest.make(_expand_with_toolchains_test_impl)

def _expand_with_toolchains_with_additional_dict_test_impl(ctx):
    """Test `expansion.expand_with_toolchains()` with extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(_ENV_DICT)
    toolchain_dict_copy = dict(env.ctx.var)

    additional_lookup_dict = {
        "TOOLCHAIN_ENV_VAR2": "expanded from additional dict instead",
        "NOPE": "naw, it's fine now.",
    }

    resolved_dict = expansion.expand_with_toolchains(
        env.ctx,
        _ENV_DICT,
        additional_lookup_dict = additional_lookup_dict,
    )

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, _ENV_DICT)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, _ENV_DICT.keys(), resolved_dict.keys())

    updated_expected_dict = _EXPECTED_RESOLVED_DICT_NO_LOCATION | {
        "TOOLCHAIN_ENV_VAR2_RAW": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_PAREN": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_CURLY": "expanded from additional dict instead",
        "UNRECOGNIZED_VAR": "naw, it's fine now.",
    }

    # Check all output resolved values against expected resolved values.
    for env_key, _ in _ENV_DICT.items():
        expected_val = updated_expected_dict[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_with_additional_dict_test = unittest.make(
    _expand_with_toolchains_with_additional_dict_test_impl,
)

def _expand_with_toolchains_attr_test_impl(ctx):
    """Test `expansion.expand_with_toolchains_attr()` without extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(env.ctx.attr.env)
    toolchain_dict_copy = dict(env.ctx.var)

    resolved_dict = expansion.expand_with_toolchains_attr(env.ctx)

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, env.ctx.attr.env)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, env.ctx.attr.env.keys(), resolved_dict.keys())

    # Check all output resolved values against expected resolved values.
    for env_key, _ in env.ctx.attr.env.items():
        expected_val = _EXPECTED_RESOLVED_DICT_NO_LOCATION[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_attr_test = unittest.make(
    _expand_with_toolchains_attr_test_impl,
    attrs = {
        "env": attr.string_dict(),
    },
)

def _expand_with_toolchains_attr_with_additional_dict_test_impl(ctx):
    """Test `expansion.expand_with_toolchains_attr()` with extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(env.ctx.attr.env)
    toolchain_dict_copy = dict(env.ctx.var)

    additional_lookup_dict = {
        "TOOLCHAIN_ENV_VAR2": "expanded from additional dict instead",
        "NOPE": "naw, it's fine now.",
    }

    resolved_dict = expansion.expand_with_toolchains_attr(
        env.ctx,
        additional_lookup_dict = additional_lookup_dict,
    )

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, env.ctx.attr.env)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, env.ctx.attr.env.keys(), resolved_dict.keys())

    updated_expected_dict = _EXPECTED_RESOLVED_DICT_NO_LOCATION | {
        "TOOLCHAIN_ENV_VAR2_RAW": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_PAREN": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_CURLY": "expanded from additional dict instead",
        "UNRECOGNIZED_VAR": "naw, it's fine now.",
    }

    # Check all output resolved values against expected resolved values.
    for env_key, _ in env.ctx.attr.env.items():
        expected_val = updated_expected_dict[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_attr_with_additional_dict_test = unittest.make(
    _expand_with_toolchains_attr_with_additional_dict_test_impl,
    attrs = {
        "env": attr.string_dict(),
    },
)

def _expand_with_toolchains_and_location_test_impl(ctx):
    """Test `expansion.expand_with_toolchains_and_location()` without extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(_ENV_DICT)
    toolchain_dict_copy = dict(env.ctx.var)

    resolved_dict = expansion.expand_with_toolchains_and_location(
        env.ctx,
        [ctx.attr.target],
        _ENV_DICT,
    )

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, _ENV_DICT)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, _ENV_DICT.keys(), resolved_dict.keys())

    # Check all output resolved values against expected resolved values.
    for env_key, _ in _ENV_DICT.items():
        expected_val = _EXPECTED_RESOLVED_DICT_WITH_GENRULE_LOCATION[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_and_location_test = unittest.make(
    _expand_with_toolchains_and_location_test_impl,
    attrs = {
        "target": attr.label(),
    },
)

def _expand_with_toolchains_and_location_with_additional_dict_test_impl(ctx):
    """Test `expansion.expand_with_toolchains_and_location()` with extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(_ENV_DICT)
    toolchain_dict_copy = dict(env.ctx.var)

    additional_lookup_dict = {
        "TOOLCHAIN_ENV_VAR2": "expanded from additional dict instead",
        "NOPE": "naw, it's fine now.",
    }

    resolved_dict = expansion.expand_with_toolchains_and_location(
        env.ctx,
        [ctx.attr.target],
        _ENV_DICT,
        additional_lookup_dict = additional_lookup_dict,
    )

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, _ENV_DICT)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, _ENV_DICT.keys(), resolved_dict.keys())

    updated_expected_dict = _EXPECTED_RESOLVED_DICT_WITH_GENRULE_LOCATION | {
        "TOOLCHAIN_ENV_VAR2_RAW": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_PAREN": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_CURLY": "expanded from additional dict instead",
        "UNRECOGNIZED_VAR": "naw, it's fine now.",
    }

    # Check all output resolved values against expected resolved values.
    for env_key, _ in _ENV_DICT.items():
        expected_val = updated_expected_dict[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_and_location_with_additional_dict_test = unittest.make(
    _expand_with_toolchains_and_location_with_additional_dict_test_impl,
    attrs = {
        "target": attr.label(),
    },
)

def _expand_with_toolchains_and_location_attr_test_impl(ctx):
    """Test `expansion.expand_with_toolchains_and_location_attr()` without extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(env.ctx.attr.env)
    toolchain_dict_copy = dict(env.ctx.var)

    resolved_dict = expansion.expand_with_toolchains_and_location_attr(env.ctx)

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, env.ctx.attr.env)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, env.ctx.attr.env.keys(), resolved_dict.keys())

    # Check all output resolved values against expected resolved values.
    for env_key, _ in env.ctx.attr.env.items():
        expected_val = _EXPECTED_RESOLVED_DICT_WITH_GENRULE_LOCATION[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_and_location_attr_test = unittest.make(
    _expand_with_toolchains_and_location_attr_test_impl,
    attrs = {
        "deps": attr.label_list(),
        "env": attr.string_dict(),
    },
)

def _expand_with_toolchains_and_location_attr_with_additional_dict_test_impl(ctx):
    """Test `expansion.expand_with_toolchains_and_location_attr()` with extra dict"""
    env = unittest.begin(ctx)

    env_dict_copy = dict(env.ctx.attr.env)
    toolchain_dict_copy = dict(env.ctx.var)

    additional_lookup_dict = {
        "TOOLCHAIN_ENV_VAR2": "expanded from additional dict instead",
        "NOPE": "naw, it's fine now.",
    }

    resolved_dict = expansion.expand_with_toolchains_and_location_attr(
        env.ctx,
        additional_lookup_dict = additional_lookup_dict,
    )

    # Check that the inputs are not mutated.
    asserts.equals(env, env_dict_copy, env.ctx.attr.env)
    asserts.equals(env, toolchain_dict_copy, env.ctx.var)

    # Check that the output has exact same key set as original input.
    asserts.equals(env, env.ctx.attr.env.keys(), resolved_dict.keys())

    updated_expected_dict = _EXPECTED_RESOLVED_DICT_WITH_GENRULE_LOCATION | {
        "TOOLCHAIN_ENV_VAR2_RAW": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_PAREN": "expanded from additional dict instead",
        "TOOLCHAIN_ENV_VAR2_CURLY": "expanded from additional dict instead",
        "UNRECOGNIZED_VAR": "naw, it's fine now.",
    }

    # Check all output resolved values against expected resolved values.
    for env_key, _ in env.ctx.attr.env.items():
        expected_val = updated_expected_dict[env_key]
        resolved_val = resolved_dict[env_key]
        resolved_val = _fix_platform_dependent_path_for_assertions(resolved_val)

        # Replace `expected` with proper value given bazel version (may differ for rlocation path).
        if "_main" in expected_val and "_main" not in resolved_val:
            expected_val = expected_val.replace("_main", "bazel_skylib")
        asserts.equals(env, expected_val, resolved_val)

    return unittest.end(env)

_expand_with_toolchains_and_location_attr_with_additional_dict_test = unittest.make(
    _expand_with_toolchains_and_location_attr_with_additional_dict_test_impl,
    attrs = {
        "deps": attr.label_list(),
        "env": attr.string_dict(),
    },
)

def _validate_expansions_on_fully_resolved_values_test_impl(ctx):
    """Test `expansion.validate_expansions()` with fully resolved strings"""
    env = unittest.begin(ctx)

    # Remove the values that are meant to be unexpanded in other tests.
    _values_with_mocked_location = dict(_EXPECTED_RESOLVED_DICT_WITH_MOCKED_LOCATION)
    _values_with_mocked_location.pop("UNRECOGNIZED_VAR")
    _values_with_mocked_location.pop("UNRECOGNIZED_FUNC")

    _values_with_genrule_location = dict(_EXPECTED_RESOLVED_DICT_WITH_GENRULE_LOCATION)
    _values_with_genrule_location.pop("UNRECOGNIZED_VAR")
    _values_with_genrule_location.pop("UNRECOGNIZED_FUNC")

    failure_messages = []
    for fail_on_unexpanded in (True, False):
        failure_messages += expansion.validate_expansions(
            _values_with_mocked_location.values(),
            fail_instead_of_return = fail_on_unexpanded,
        )
        failure_messages += expansion.validate_expansions(
            _values_with_genrule_location.values(),
            fail_instead_of_return = fail_on_unexpanded,
        )

        failure_messages += expansion.validate_expansions(
            [
                "$$SOME_ESCAPED_VAR",
                "prefix-$$SOME_ESCAPED_VAR",
                "$$SOME_ESCAPED_VAR-suffix",
                "prefix-$$SOME_ESCAPED_VAR-suffix",
                "$$",
                "prefix-$$",
                "$$-suffix",
                "prefix-$$-suffix",
            ],
            fail_instead_of_return = fail_on_unexpanded,
        )
    asserts.equals(env, [], failure_messages)

    return unittest.end(env)

_validate_expansions_on_fully_resolved_values_test = unittest.make(
    _validate_expansions_on_fully_resolved_values_test_impl,
)

def _validate_expansions_on_unresolved_or_unterminated_values_test_impl(ctx):
    """
    Test `expansion.validate_expansions()` with unresolved or unterminated values

    Will be used with multiple targets for specific unresolved/unterminated values.
    """
    env = unittest.begin(ctx)

    all_error_messages = []
    for bad_substring in env.ctx.attr.bad_substrings:
        for string_format in env.ctx.attr.string_formats:
            bad_str = string_format.format(bad_substring)

            # Get out error messages (instead of calling `fail()` internally).
            # This allows us to parameterize the test in this impl, instead of parameterizing the
            # test target definitions.
            # Also allows using `unittest` without `analysistest`.
            error_messages = expansion.validate_expansions(
                [bad_str],
                fail_instead_of_return = False,
            )

            expected_error_messages_per_call = ctx.attr.expected_error_messages_per_call
            asserts.true(
                env,
                len(error_messages) == expected_error_messages_per_call,
                "Wrong error message size. Expected count: {}.\n Got messages:\n{}".format(
                    expected_error_messages_per_call,
                    "\n".join(error_messages),
                ),
            )
            all_error_messages.extend(error_messages)

    for expected_failure in ctx.attr.expected_failures:
        asserts.true(
            env,
            expected_failure in all_error_messages,
            "'{}' not in:\n{}".format(expected_failure, "\n".join(all_error_messages)),
        )

    return unittest.end(env)

_validate_expansions_on_unresolved_or_unterminated_values_test = unittest.make(
    _validate_expansions_on_unresolved_or_unterminated_values_test_impl,
    attrs = {
        "bad_substrings": attr.string_list(
            mandatory = True,
            allow_empty = False,
        ),
        "expected_error_messages_per_call": attr.int(
            default = 1,
        ),
        "expected_failures": attr.string_list(
            mandatory = True,
            allow_empty = False,
        ),
        "string_formats": attr.string_list(
            mandatory = True,
            allow_empty = False,
        ),
    },
)

# buildifier: disable=unnamed-macro
def expansion_test_suite():
    """Creates the test targets and test suite for expansion.bzl tests."""

    native.genrule(
        name = _TEST_DEP_TARGET_NAME,
        outs = ["dummy.txt"],
        cmd = "touch $@",
    )

    _test_toolchain(
        name = "expansion_tests__test_toolchain",
    )

    _expand_with_manual_dict_test(
        name = "expansion_tests__expand_with_manual_dict_test",
    )
    _expand_with_manual_dict_and_location_test(
        name = "expansion_tests__expand_with_manual_dict_and_location_test",
    )
    _expand_with_toolchains_test(
        name = "expansion_tests__expand_with_toolchains_test",
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_with_additional_dict_test(
        name = "expansion_tests__expand_with_toolchains_with_additional_dict_test",
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_attr_test(
        name = "expansion_tests__expand_with_toolchains_attr_test",
        env = _ENV_DICT,
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_attr_with_additional_dict_test(
        name = "expansion_tests__expand_with_toolchains_attr_with_additional_dict_test",
        env = _ENV_DICT,
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_and_location_test(
        name = "expansion_tests__expand_with_toolchains_and_location_test",
        target = ":" + _TEST_DEP_TARGET_NAME,
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_and_location_with_additional_dict_test(
        name = "expansion_tests__expand_with_toolchains_and_location_with_additional_dict_test",
        target = ":" + _TEST_DEP_TARGET_NAME,
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_and_location_attr_test(
        name = "expansion_tests__expand_with_toolchains_and_location_attr_test",
        deps = [":" + _TEST_DEP_TARGET_NAME],
        env = _ENV_DICT,
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _expand_with_toolchains_and_location_attr_with_additional_dict_test(
        name = "expansion_tests__expand_with_toolchains_and_location_attr_with_additional_dict_test",
        deps = [":" + _TEST_DEP_TARGET_NAME],
        env = _ENV_DICT,
        toolchains = [":expansion_tests__test_toolchain"],
    )
    _validate_expansions_on_fully_resolved_values_test(
        name = "expansion_tests__validate_expansions_on_fully_resolved_values_test",
    )
    _validate_expansions_on_unresolved_or_unterminated_values_test(
        name = "expansion_tests__validate_expansions_on_unresolved_values_test",
        bad_substrings = _UNRESOLVED_SUBSTRINGS,
        expected_failures = _UNRESOLVED_SUBSTRING_EXPECTED_ERROR_MESSAGES,
        string_formats = _UNRESOLVED_SUBSTRINGS_FORMAT_STRINGS,
    )
    _validate_expansions_on_unresolved_or_unterminated_values_test(
        name = "expansion_tests__validate_expansions_on_two_unresolved_values_test",
        bad_substrings = _TWO_UNRESOLVED_SUBSTRINGS,
        expected_error_messages_per_call = 2,
        expected_failures = _TWO_UNRESOLVED_SUBSTRING_EXPECTED_ERROR_MESSAGES,
        string_formats = ["{}"],
    )
    _validate_expansions_on_unresolved_or_unterminated_values_test(
        name = "expansion_tests__validate_expansions_on_nameless_var_values_test",
        bad_substrings = ["$"],
        expected_failures = _UNRESOLVED_NAMELESS_SUBSTRING_EXPECTED_ERROR_MESSAGES,
        string_formats = _UNRESOLVED_NAMELESS_SUBSTRINGS_FORMAT_STRINGS,
    )
    _validate_expansions_on_unresolved_or_unterminated_values_test(
        name = "expansion_tests__validate_expansions_on_unterminated_values_test",
        bad_substrings = ["$"] + _UNTERMINATED_SUBSTRINGS_PAREN + _UNTERMINATED_SUBSTRINGS_CURLY,
        expected_failures = (
            _UNTERMINATED_SUBSTRING_EXPECTED_ERROR_MESSAGES_RAW +
            _UNTERMINATED_SUBSTRING_EXPECTED_ERROR_MESSAGES_PAREN +
            _UNTERMINATED_SUBSTRING_EXPECTED_ERROR_MESSAGES_CURLY
        ),
        string_formats = _UNTERMINATED_SUBSTRINGS_FORMAT_STRINGS,
    )

    native.test_suite(
        name = "expansion_tests",
        tests = [
            ":expansion_tests__expand_with_manual_dict_test",
            ":expansion_tests__expand_with_manual_dict_and_location_test",
            ":expansion_tests__expand_with_toolchains_test",
            ":expansion_tests__expand_with_toolchains_with_additional_dict_test",
            ":expansion_tests__expand_with_toolchains_attr_test",
            ":expansion_tests__expand_with_toolchains_attr_with_additional_dict_test",
            ":expansion_tests__expand_with_toolchains_and_location_test",
            ":expansion_tests__expand_with_toolchains_and_location_with_additional_dict_test",
            ":expansion_tests__expand_with_toolchains_and_location_attr_test",
            ":expansion_tests__expand_with_toolchains_and_location_attr_with_additional_dict_test",
            ":expansion_tests__validate_expansions_on_fully_resolved_values_test",
            ":expansion_tests__validate_expansions_on_unresolved_values_test",
            ":expansion_tests__validate_expansions_on_two_unresolved_values_test",
            ":expansion_tests__validate_expansions_on_nameless_var_values_test",
            ":expansion_tests__validate_expansions_on_unterminated_values_test",
        ],
    )
