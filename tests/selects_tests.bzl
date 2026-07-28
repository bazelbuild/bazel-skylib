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

"""Unit tests for selects.bzl."""

load("//lib:selects.bzl", "selects")
load("//lib:unittest.bzl", "analysistest", "asserts", "unittest")

###################################################
# with_or_test
###################################################
def _with_or_test(ctx):
    """Unit tests for with_or."""
    env = unittest.begin(ctx)

    # We actually test on with_or_dict because Starlark can't get the
    # dictionary from a select().

    # Test select()-compatible input syntax.
    input_dict = {":foo": ":d1", "//conditions:default": ":d1"}
    asserts.equals(env, input_dict, selects.with_or_dict(input_dict))

    # Test OR syntax.
    or_dict = {(":foo", ":bar"): ":d1"}
    asserts.equals(
        env,
        {":bar": ":d1", ":foo": ":d1"},
        selects.with_or_dict(or_dict),
    )

    # Test mixed syntax.
    mixed_dict = {
        ":foo": ":d1",
        (":bar", ":baz"): ":d2",
        "//conditions:default": ":d3",
    }
    asserts.equals(
        env,
        {
            ":bar": ":d2",
            ":baz": ":d2",
            ":foo": ":d1",
            "//conditions:default": ":d3",
        },
        selects.with_or_dict(mixed_dict),
    )

    return unittest.end(env)

with_or_test = unittest.make(_with_or_test)

###################################################
# BUILD declarations for config_setting_group tests
###################################################

# TODO: redefine these config_settings with Starlark build flags when
# they're available non-experimentally.
def _create_config_settings():
    native.config_setting(
        name = "condition1",
        values = {"stamp": "1"},
    )
    native.config_setting(
        name = "condition2",
        values = {"compilation_mode": "opt"},
    )
    native.config_setting(
        name = "condition3",
        values = {"features": "myfeature"},
    )

def _create_config_setting_groups():
    selects.config_setting_group(
        name = "1_and_2_and_3",
        match_all = [":condition1", ":condition2", ":condition3"],
    )
    selects.config_setting_group(
        name = "1_and_nothing_else",
        match_all = [":condition1"],
    )
    selects.config_setting_group(
        name = "1_or_2_or_3",
        match_any = [":condition1", ":condition2", ":condition3"],
    )
    selects.config_setting_group(
        name = "1_or_nothing_else",
        match_any = [":condition1"],
    )
    selects.config_setting_group(
        name = "1_and_2_and_not_3",
        match_all = [":condition1", ":condition2"],
        match_none = [":condition3"],
    )
    selects.config_setting_group(
        name = "1_and_not_2_and_not_3",
        match_all = [":condition1"],
        match_none = [":condition2", ":condition3"],
    )
    selects.config_setting_group(
        name = "1_or_2_and_not_3",
        match_any = [":condition1", ":condition2"],
        match_none = [":condition3"],
    )
    selects.config_setting_group(
        name = "any_1_and_not_2",
        match_any = [":condition1"],
        match_none = [":condition2"],
    )
    selects.config_setting_group(
        name = "not_1",
        match_none = [":condition1"],
    )
    selects.config_setting_group(
        name = "not_1_and_not_2",
        match_none = [":condition1", ":condition2"],
    )
    selects.config_setting_group(
        name = "any_default_and_not_1",
        match_any = ["//conditions:default"],
        match_none = [":condition1"],
    )
    selects.config_setting_group(
        name = "all_default_and_not_1",
        match_all = ["//conditions:default"],
        match_none = [":condition1"],
    )

###################################################
# Support code for config_setting_group tests
###################################################

def _set_conditions(condition_list):
    """Returns an argument for config_settings that sets specific options.

    Args:
      condition_list: a list of three booleans

    Returns:
      a dictionary parameter for config_settings such that ":conditionN" is True
          iff condition_list[N + 1] is True
    """
    if len(condition_list) != 3:
        fail("condition_list must be a list of 3 booleans")
    ans = {}
    if condition_list[0]:
        ans["//command_line_option:stamp"] = "1"
    else:
        ans["//command_line_option:stamp"] = "0"
    if condition_list[1]:
        ans["//command_line_option:compilation_mode"] = "opt"
    else:
        ans["//command_line_option:compilation_mode"] = "dbg"
    if condition_list[2]:
        ans["//command_line_option:features"] = ["myfeature"]
    else:
        ans["//command_line_option:features"] = ["notmyfeature"]
    return ans

_BooleanInfo = provider(
    doc = "value for boolean tests",
    fields = ["value"],
)

def _boolean_attr_impl(ctx):
    return [_BooleanInfo(value = ctx.attr.myboolean)]

boolean_attr_rule = rule(
    implementation = _boolean_attr_impl,
    attrs = {"myboolean": attr.bool()},
)

def _expect_matches(ctx):
    """Generic test implementation expecting myboolean == True."""
    env = analysistest.begin(ctx)
    attrval = analysistest.target_under_test(env)[_BooleanInfo].value
    asserts.equals(env, True, attrval)
    return analysistest.end(env)

def _expect_doesnt_match(ctx):
    """Generic test implementation expecting myboolean == False."""
    env = analysistest.begin(ctx)
    attrval = analysistest.target_under_test(env)[_BooleanInfo].value
    asserts.equals(env, False, attrval)
    return analysistest.end(env)

###################################################
# and_config_setting_group_matches_test
###################################################
and_config_setting_group_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([True, True, True]),
)

def _and_config_setting_group_matches_test():
    """Test verifying match on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_matches_rule",
        myboolean = select(
            {
                ":1_and_2_and_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_matches_test(
        name = "and_config_setting_group_matches_test",
        target_under_test = ":and_config_setting_group_matches_rule",
    )

###################################################
# and_config_setting_group_first_match_fails_test
###################################################
and_config_setting_group_first_match_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, True, True]),
)

def _and_config_setting_group_first_match_fails_test():
    """Test verifying first condition mismatch on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_first_match_fails_rule",
        myboolean = select(
            {
                ":1_and_2_and_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_first_match_fails_test(
        name = "and_config_setting_group_first_match_fails_test",
        target_under_test = ":and_config_setting_group_first_match_fails_rule",
    )

###################################################
# and_config_setting_group_middle_match_fails_test
###################################################
and_config_setting_group_middle_match_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, False, True]),
)

def _and_config_setting_group_middle_match_fails_test():
    """Test verifying middle condition mismatch on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_middle_match_fails_rule",
        myboolean = select(
            {
                ":1_and_2_and_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_middle_match_fails_test(
        name = "and_config_setting_group_middle_match_fails_test",
        target_under_test = ":and_config_setting_group_middle_match_fails_rule",
    )

###################################################
# and_config_setting_group_last_match_fails_test
###################################################
and_config_setting_group_last_match_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, True, False]),
)

def _and_config_setting_group_last_match_fails_test():
    """Test verifying last condition mismatch on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_last_match_fails_rule",
        myboolean = select(
            {
                ":1_and_2_and_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_last_match_fails_test(
        name = "and_config_setting_group_last_match_fails_test",
        target_under_test = ":and_config_setting_group_last_match_fails_rule",
    )

###################################################
# and_config_setting_group_multiple_matches_fail_test
###################################################
and_config_setting_group_multiple_matches_fail_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, False, False]),
)

def _and_config_setting_group_multiple_matches_fail_test():
    """Test verifying multiple conditions mismatch on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_multiple_matches_fail_rule",
        myboolean = select(
            {
                ":1_and_2_and_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_multiple_matches_fail_test(
        name = "and_config_setting_group_multiple_matches_fail_test",
        target_under_test = ":and_config_setting_group_multiple_matches_fail_rule",
    )

###################################################
# and_config_setting_group_all_matches_fail_test
###################################################
and_config_setting_group_all_matches_fail_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, False, False]),
)

def _and_config_setting_group_all_matches_fail_test():
    """Test verifying all conditions mismatch on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_all_matches_fail_rule",
        myboolean = select(
            {
                ":1_and_2_and_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_all_matches_fail_test(
        name = "and_config_setting_group_all_matches_fail_test",
        target_under_test = ":and_config_setting_group_all_matches_fail_rule",
    )

###################################################
# and_config_setting_group_single_setting_matches_test
###################################################
and_config_setting_group_single_setting_matches_test = analysistest.make(
    _expect_matches,
    config_settings = {"//command_line_option:stamp": "1"},
)

def _and_config_setting_group_single_setting_matches_test():
    """Test verifying match on single-entry ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_single_setting_matches_rule",
        myboolean = select(
            {
                ":1_and_nothing_else": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_single_setting_matches_test(
        name = "and_config_setting_group_single_setting_matches_test",
        target_under_test = ":and_config_setting_group_single_setting_matches_rule",
    )

###################################################
# and_config_setting_group_single_setting_fails_test
###################################################
and_config_setting_group_single_setting_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = {"//command_line_option:stamp": "0"},
)

def _and_config_setting_group_single_setting_fails_test():
    """Test verifying no match on single-entry ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_config_setting_group_single_setting_fails_rule",
        myboolean = select(
            {
                ":1_and_nothing_else": True,
                "//conditions:default": False,
            },
        ),
    )
    and_config_setting_group_single_setting_fails_test(
        name = "and_config_setting_group_single_setting_fails_test",
        target_under_test = ":and_config_setting_group_single_setting_fails_rule",
    )

###################################################
# or_config_setting_group_no_match_test
###################################################
or_config_setting_group_no_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, False, False]),
)

def _or_config_setting_group_no_matches_test():
    """Test verifying no matches on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_no_matches_rule",
        myboolean = select(
            {
                ":1_or_2_or_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_no_matches_test(
        name = "or_config_setting_group_no_matches_test",
        target_under_test = ":or_config_setting_group_no_matches_rule",
    )

###################################################
# or_config_setting_group_first_cond_matches_test
###################################################
or_config_setting_group_first_cond_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([True, False, False]),
)

def _or_config_setting_group_first_cond_matches_test():
    """Test verifying first condition matching on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_first_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_or_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_first_cond_matches_test(
        name = "or_config_setting_group_first_cond_matches_test",
        target_under_test = ":or_config_setting_group_first_cond_matches_rule",
    )

###################################################
# or_config_setting_group_middle_cond_matches_test
###################################################
or_config_setting_group_middle_cond_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, True, False]),
)

def _or_config_setting_group_middle_cond_matches_test():
    """Test verifying middle condition matching on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_middle_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_or_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_middle_cond_matches_test(
        name = "or_config_setting_group_middle_cond_matches_test",
        target_under_test = ":or_config_setting_group_middle_cond_matches_rule",
    )

###################################################
# or_config_setting_group_last_cond_matches_test
###################################################
or_config_setting_group_last_cond_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, False, True]),
)

def _or_config_setting_group_last_cond_matches_test():
    """Test verifying last condition matching on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_last_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_or_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_last_cond_matches_test(
        name = "or_config_setting_group_last_cond_matches_test",
        target_under_test = ":or_config_setting_group_last_cond_matches_rule",
    )

###################################################
# or_config_setting_group_multiple_conds_match_test
###################################################
or_config_setting_group_multiple_conds_match_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, True, True]),
)

def _or_config_setting_group_multiple_conds_match_test():
    """Test verifying multiple conditions matching on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_multiple_conds_match_rule",
        myboolean = select(
            {
                ":1_or_2_or_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_multiple_conds_match_test(
        name = "or_config_setting_group_multiple_conds_match_test",
        target_under_test = ":or_config_setting_group_multiple_conds_match_rule",
    )

###################################################
# or_config_setting_group_all_conds_match_test
###################################################
or_config_setting_group_all_conds_match_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, True, True]),
)

def _or_config_setting_group_all_conds_match_test():
    """Test verifying all conditions matching on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_all_conds_match_rule",
        myboolean = select(
            {
                ":1_or_2_or_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_all_conds_match_test(
        name = "or_config_setting_group_all_conds_match_test",
        target_under_test = ":or_config_setting_group_all_conds_match_rule",
    )

###################################################
# or_config_setting_group_single_setting_matches_test
###################################################
or_config_setting_group_single_setting_matches_test = analysistest.make(
    _expect_matches,
    config_settings = {"//command_line_option:stamp": "1"},
)

def _or_config_setting_group_single_setting_matches_test():
    """Test verifying match on single-entry ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_single_setting_matches_rule",
        myboolean = select(
            {
                ":1_or_nothing_else": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_single_setting_matches_test(
        name = "or_config_setting_group_single_setting_matches_test",
        target_under_test = ":or_config_setting_group_single_setting_matches_rule",
    )

###################################################
# or_config_setting_group_single_setting_fails_test
###################################################
or_config_setting_group_single_setting_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = {"//command_line_option:stamp": "0"},
)

def _or_config_setting_group_single_setting_fails_test():
    """Test verifying no match on single-entry ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_config_setting_group_single_setting_fails_rule",
        myboolean = select(
            {
                ":1_or_nothing_else": True,
                "//conditions:default": False,
            },
        ),
    )
    or_config_setting_group_single_setting_fails_test(
        name = "or_config_setting_group_single_setting_fails_test",
        target_under_test = ":or_config_setting_group_single_setting_fails_rule",
    )

###################################################
# always_true_match_all_test
###################################################
always_true_match_all_test = analysistest.make(_expect_matches)

def _always_true_match_all_test():
    """Tests that "match_all=['//conditions:default']" always matches."""
    selects.config_setting_group(
        name = "all_always_match",
        match_all = ["//conditions:default"],
    )
    boolean_attr_rule(
        name = "match_always_true_rule",
        myboolean = select(
            {
                ":all_always_match": True,
            },
        ),
    )
    always_true_match_all_test(
        name = "always_true_match_all_test",
        target_under_test = ":match_always_true_rule",
    )

###################################################
# always_true_match_any_test
###################################################
always_true_match_any_test = analysistest.make(_expect_matches)

def _always_true_match_any_test():
    """Tests that "match_any=['//conditions:default']" always matches."""
    selects.config_setting_group(
        name = "any_always_match",
        match_any = ["//conditions:default"],
    )
    boolean_attr_rule(
        name = "match_any_always_true_rule",
        myboolean = select(
            {
                ":any_always_match": True,
            },
        ),
    )
    always_true_match_any_test(
        name = "always_true_match_any_test",
        target_under_test = ":match_any_always_true_rule",
    )

###################################################
# and_not_config_setting_group_matches_test
###################################################
and_not_config_setting_group_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([True, True, False]),
)

def _and_not_config_setting_group_matches_test():
    """Test verifying match on an ANDing config_setting_group with match_none."""
    boolean_attr_rule(
        name = "and_not_config_setting_group_matches_rule",
        myboolean = select(
            {
                ":1_and_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_not_config_setting_group_matches_test(
        name = "and_not_config_setting_group_matches_test",
        target_under_test = ":and_not_config_setting_group_matches_rule",
    )

###################################################
# and_not_config_setting_group_negated_cond_matches_test
###################################################
and_not_config_setting_group_negated_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, True, True]),
)

def _and_not_config_setting_group_negated_cond_matches_test():
    """Test verifying a matching match_none condition on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_not_config_setting_group_negated_cond_matches_rule",
        myboolean = select(
            {
                ":1_and_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_not_config_setting_group_negated_cond_matches_test(
        name = "and_not_config_setting_group_negated_cond_matches_test",
        target_under_test = ":and_not_config_setting_group_negated_cond_matches_rule",
    )

###################################################
# and_not_config_setting_group_positive_cond_fails_test
###################################################
and_not_config_setting_group_positive_cond_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, True, False]),
)

def _and_not_config_setting_group_positive_cond_fails_test():
    """Test verifying a match_all condition mismatch on an ANDing config_setting_group with match_none."""
    boolean_attr_rule(
        name = "and_not_config_setting_group_positive_cond_fails_rule",
        myboolean = select(
            {
                ":1_and_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_not_config_setting_group_positive_cond_fails_test(
        name = "and_not_config_setting_group_positive_cond_fails_test",
        target_under_test = ":and_not_config_setting_group_positive_cond_fails_rule",
    )

###################################################
# and_multiple_not_config_setting_group_matches_test
###################################################
and_multiple_not_config_setting_group_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([True, False, False]),
)

def _and_multiple_not_config_setting_group_matches_test():
    """Test verifying match on an ANDing config_setting_group with multiple match_none entries."""
    boolean_attr_rule(
        name = "and_multiple_not_config_setting_group_matches_rule",
        myboolean = select(
            {
                ":1_and_not_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_multiple_not_config_setting_group_matches_test(
        name = "and_multiple_not_config_setting_group_matches_test",
        target_under_test = ":and_multiple_not_config_setting_group_matches_rule",
    )

###################################################
# and_multiple_not_config_setting_group_first_negated_cond_matches_test
###################################################
and_multiple_not_config_setting_group_first_negated_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, True, False]),
)

def _and_multiple_not_config_setting_group_first_negated_cond_matches_test():
    """Test verifying the first match_none condition matching on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_multiple_not_config_setting_group_first_negated_cond_matches_rule",
        myboolean = select(
            {
                ":1_and_not_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_multiple_not_config_setting_group_first_negated_cond_matches_test(
        name = "and_multiple_not_config_setting_group_first_negated_cond_matches_test",
        target_under_test = ":and_multiple_not_config_setting_group_first_negated_cond_matches_rule",
    )

###################################################
# and_multiple_not_config_setting_group_last_negated_cond_matches_test
###################################################
and_multiple_not_config_setting_group_last_negated_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, False, True]),
)

def _and_multiple_not_config_setting_group_last_negated_cond_matches_test():
    """Test verifying the last match_none condition matching on an ANDing config_setting_group."""
    boolean_attr_rule(
        name = "and_multiple_not_config_setting_group_last_negated_cond_matches_rule",
        myboolean = select(
            {
                ":1_and_not_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_multiple_not_config_setting_group_last_negated_cond_matches_test(
        name = "and_multiple_not_config_setting_group_last_negated_cond_matches_test",
        target_under_test = ":and_multiple_not_config_setting_group_last_negated_cond_matches_rule",
    )

###################################################
# and_multiple_not_config_setting_group_positive_cond_fails_test
###################################################
and_multiple_not_config_setting_group_positive_cond_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, False, False]),
)

def _and_multiple_not_config_setting_group_positive_cond_fails_test():
    """Test verifying the match_all condition mismatch on an ANDing config_setting_group with multiple match_none entries."""
    boolean_attr_rule(
        name = "and_multiple_not_config_setting_group_positive_cond_fails_rule",
        myboolean = select(
            {
                ":1_and_not_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    and_multiple_not_config_setting_group_positive_cond_fails_test(
        name = "and_multiple_not_config_setting_group_positive_cond_fails_test",
        target_under_test = ":and_multiple_not_config_setting_group_positive_cond_fails_rule",
    )

###################################################
# or_not_config_setting_group_first_cond_matches_test
###################################################
or_not_config_setting_group_first_cond_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([True, False, False]),
)

def _or_not_config_setting_group_first_cond_matches_test():
    """Test verifying the first match_any condition matching on an ORing config_setting_group with match_none."""
    boolean_attr_rule(
        name = "or_not_config_setting_group_first_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_not_config_setting_group_first_cond_matches_test(
        name = "or_not_config_setting_group_first_cond_matches_test",
        target_under_test = ":or_not_config_setting_group_first_cond_matches_rule",
    )

###################################################
# or_not_config_setting_group_second_cond_matches_test
###################################################
or_not_config_setting_group_second_cond_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, True, False]),
)

def _or_not_config_setting_group_second_cond_matches_test():
    """Test verifying the second match_any condition matching on an ORing config_setting_group with match_none."""
    boolean_attr_rule(
        name = "or_not_config_setting_group_second_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_not_config_setting_group_second_cond_matches_test(
        name = "or_not_config_setting_group_second_cond_matches_test",
        target_under_test = ":or_not_config_setting_group_second_cond_matches_rule",
    )

###################################################
# or_not_config_setting_group_no_positive_cond_matches_test
###################################################
or_not_config_setting_group_no_positive_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, False, False]),
)

def _or_not_config_setting_group_no_positive_cond_matches_test():
    """Test verifying no match_any condition matching on an ORing config_setting_group with match_none."""
    boolean_attr_rule(
        name = "or_not_config_setting_group_no_positive_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_not_config_setting_group_no_positive_cond_matches_test(
        name = "or_not_config_setting_group_no_positive_cond_matches_test",
        target_under_test = ":or_not_config_setting_group_no_positive_cond_matches_rule",
    )

###################################################
# or_not_config_setting_group_negated_cond_matches_test
###################################################
or_not_config_setting_group_negated_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, True, True]),
)

def _or_not_config_setting_group_negated_cond_matches_test():
    """Test verifying a matching match_none condition on an ORing config_setting_group."""
    boolean_attr_rule(
        name = "or_not_config_setting_group_negated_cond_matches_rule",
        myboolean = select(
            {
                ":1_or_2_and_not_3": True,
                "//conditions:default": False,
            },
        ),
    )
    or_not_config_setting_group_negated_cond_matches_test(
        name = "or_not_config_setting_group_negated_cond_matches_test",
        target_under_test = ":or_not_config_setting_group_negated_cond_matches_rule",
    )

###################################################
# single_or_not_config_setting_group_matches_test
###################################################
single_or_not_config_setting_group_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([True, False, False]),
)

def _single_or_not_config_setting_group_matches_test():
    """Test verifying match on a single-entry ORing config_setting_group with match_none."""
    boolean_attr_rule(
        name = "single_or_not_config_setting_group_matches_rule",
        myboolean = select(
            {
                ":any_1_and_not_2": True,
                "//conditions:default": False,
            },
        ),
    )
    single_or_not_config_setting_group_matches_test(
        name = "single_or_not_config_setting_group_matches_test",
        target_under_test = ":single_or_not_config_setting_group_matches_rule",
    )

###################################################
# single_or_not_config_setting_group_negated_cond_matches_test
###################################################
single_or_not_config_setting_group_negated_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, True, False]),
)

def _single_or_not_config_setting_group_negated_cond_matches_test():
    """Test verifying a matching match_none condition on a single-entry ORing config_setting_group."""
    boolean_attr_rule(
        name = "single_or_not_config_setting_group_negated_cond_matches_rule",
        myboolean = select(
            {
                ":any_1_and_not_2": True,
                "//conditions:default": False,
            },
        ),
    )
    single_or_not_config_setting_group_negated_cond_matches_test(
        name = "single_or_not_config_setting_group_negated_cond_matches_test",
        target_under_test = ":single_or_not_config_setting_group_negated_cond_matches_rule",
    )

###################################################
# single_not_config_setting_group_matches_test
###################################################
single_not_config_setting_group_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, False, False]),
)

def _single_not_config_setting_group_matches_test():
    """Test verifying match on a match_none-only config_setting_group."""
    boolean_attr_rule(
        name = "single_not_config_setting_group_matches_rule",
        myboolean = select(
            {
                ":not_1": True,
                "//conditions:default": False,
            },
        ),
    )
    single_not_config_setting_group_matches_test(
        name = "single_not_config_setting_group_matches_test",
        target_under_test = ":single_not_config_setting_group_matches_rule",
    )

###################################################
# single_not_config_setting_group_fails_test
###################################################
single_not_config_setting_group_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, False, False]),
)

def _single_not_config_setting_group_fails_test():
    """Test verifying no match on a match_none-only config_setting_group."""
    boolean_attr_rule(
        name = "single_not_config_setting_group_fails_rule",
        myboolean = select(
            {
                ":not_1": True,
                "//conditions:default": False,
            },
        ),
    )
    single_not_config_setting_group_fails_test(
        name = "single_not_config_setting_group_fails_test",
        target_under_test = ":single_not_config_setting_group_fails_rule",
    )

###################################################
# multiple_not_config_setting_group_matches_test
###################################################
multiple_not_config_setting_group_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, False, True]),
)

def _multiple_not_config_setting_group_matches_test():
    """Test verifying match on a multi-entry match_none-only config_setting_group."""
    boolean_attr_rule(
        name = "multiple_not_config_setting_group_matches_rule",
        myboolean = select(
            {
                ":not_1_and_not_2": True,
                "//conditions:default": False,
            },
        ),
    )
    multiple_not_config_setting_group_matches_test(
        name = "multiple_not_config_setting_group_matches_test",
        target_under_test = ":multiple_not_config_setting_group_matches_rule",
    )

###################################################
# multiple_not_config_setting_group_first_cond_matches_test
###################################################
multiple_not_config_setting_group_first_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, False, False]),
)

def _multiple_not_config_setting_group_first_cond_matches_test():
    """Test verifying the first condition matching on a match_none-only config_setting_group."""
    boolean_attr_rule(
        name = "multiple_not_config_setting_group_first_cond_matches_rule",
        myboolean = select(
            {
                ":not_1_and_not_2": True,
                "//conditions:default": False,
            },
        ),
    )
    multiple_not_config_setting_group_first_cond_matches_test(
        name = "multiple_not_config_setting_group_first_cond_matches_test",
        target_under_test = ":multiple_not_config_setting_group_first_cond_matches_rule",
    )

###################################################
# multiple_not_config_setting_group_last_cond_matches_test
###################################################
multiple_not_config_setting_group_last_cond_matches_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([False, True, False]),
)

def _multiple_not_config_setting_group_last_cond_matches_test():
    """Test verifying the last condition matching on a match_none-only config_setting_group."""
    boolean_attr_rule(
        name = "multiple_not_config_setting_group_last_cond_matches_rule",
        myboolean = select(
            {
                ":not_1_and_not_2": True,
                "//conditions:default": False,
            },
        ),
    )
    multiple_not_config_setting_group_last_cond_matches_test(
        name = "multiple_not_config_setting_group_last_cond_matches_test",
        target_under_test = ":multiple_not_config_setting_group_last_cond_matches_rule",
    )

###################################################
# match_any_default_with_match_none_matches_test
###################################################
match_any_default_with_match_none_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, True, True]),
)

def _match_any_default_with_match_none_matches_test():
    """Tests match_any=['//conditions:default'] with match_none reduces to pure negation."""
    boolean_attr_rule(
        name = "match_any_default_with_match_none_matches_rule",
        myboolean = select(
            {
                ":any_default_and_not_1": True,
                "//conditions:default": False,
            },
        ),
    )
    match_any_default_with_match_none_matches_test(
        name = "match_any_default_with_match_none_matches_test",
        target_under_test = ":match_any_default_with_match_none_matches_rule",
    )

###################################################
# match_any_default_with_match_none_fails_test
###################################################
match_any_default_with_match_none_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, True, True]),
)

def _match_any_default_with_match_none_fails_test():
    """Tests match_any=['//conditions:default'] with a matching match_none condition."""
    boolean_attr_rule(
        name = "match_any_default_with_match_none_fails_rule",
        myboolean = select(
            {
                ":any_default_and_not_1": True,
                "//conditions:default": False,
            },
        ),
    )
    match_any_default_with_match_none_fails_test(
        name = "match_any_default_with_match_none_fails_test",
        target_under_test = ":match_any_default_with_match_none_fails_rule",
    )

###################################################
# match_all_default_with_match_none_matches_test
###################################################
match_all_default_with_match_none_matches_test = analysistest.make(
    _expect_matches,
    config_settings = _set_conditions([False, True, True]),
)

def _match_all_default_with_match_none_matches_test():
    """Tests match_all=['//conditions:default'] with match_none reduces to pure negation."""
    boolean_attr_rule(
        name = "match_all_default_with_match_none_matches_rule",
        myboolean = select(
            {
                ":all_default_and_not_1": True,
                "//conditions:default": False,
            },
        ),
    )
    match_all_default_with_match_none_matches_test(
        name = "match_all_default_with_match_none_matches_test",
        target_under_test = ":match_all_default_with_match_none_matches_rule",
    )

###################################################
# match_all_default_with_match_none_fails_test
###################################################
match_all_default_with_match_none_fails_test = analysistest.make(
    _expect_doesnt_match,
    config_settings = _set_conditions([True, True, True]),
)

def _match_all_default_with_match_none_fails_test():
    """Tests match_all=['//conditions:default'] with a matching match_none condition."""
    boolean_attr_rule(
        name = "match_all_default_with_match_none_fails_rule",
        myboolean = select(
            {
                ":all_default_and_not_1": True,
                "//conditions:default": False,
            },
        ),
    )
    match_all_default_with_match_none_fails_test(
        name = "match_all_default_with_match_none_fails_test",
        target_under_test = ":match_all_default_with_match_none_fails_rule",
    )

###################################################
# empty_config_setting_group_not_allowed_test
###################################################

# config_setting_group with no parameters triggers a failure.
# TODO: how do we test this? This requires catching macro
# evaluation failure.

###################################################
# and_and_or_not_allowed_together_test
###################################################

# config_setting_group: setting both match_any and match_or
# triggers a failure.
# TODO: how do we test this? This requires catching macro
# evaluation failure.

###################################################

# buildifier: disable=unnamed-macro
def selects_test_suite():
    """Creates the test targets and test suite for selects.bzl tests."""
    unittest.suite(
        "selects_tests",
        with_or_test,
    )

    _create_config_settings()
    _create_config_setting_groups()

    _and_config_setting_group_matches_test()
    _and_config_setting_group_first_match_fails_test()
    _and_config_setting_group_middle_match_fails_test()
    _and_config_setting_group_last_match_fails_test()
    _and_config_setting_group_multiple_matches_fail_test()
    _and_config_setting_group_all_matches_fail_test()
    _and_config_setting_group_single_setting_matches_test()
    _and_config_setting_group_single_setting_fails_test()

    _or_config_setting_group_no_matches_test()
    _or_config_setting_group_first_cond_matches_test()
    _or_config_setting_group_middle_cond_matches_test()
    _or_config_setting_group_last_cond_matches_test()
    _or_config_setting_group_multiple_conds_match_test()
    _or_config_setting_group_all_conds_match_test()
    _or_config_setting_group_single_setting_matches_test()
    _or_config_setting_group_single_setting_fails_test()

    _always_true_match_all_test()
    _always_true_match_any_test()

    _and_not_config_setting_group_matches_test()
    _and_not_config_setting_group_negated_cond_matches_test()
    _and_not_config_setting_group_positive_cond_fails_test()
    _and_multiple_not_config_setting_group_matches_test()
    _and_multiple_not_config_setting_group_first_negated_cond_matches_test()
    _and_multiple_not_config_setting_group_last_negated_cond_matches_test()
    _and_multiple_not_config_setting_group_positive_cond_fails_test()

    _or_not_config_setting_group_first_cond_matches_test()
    _or_not_config_setting_group_second_cond_matches_test()
    _or_not_config_setting_group_no_positive_cond_matches_test()
    _or_not_config_setting_group_negated_cond_matches_test()
    _single_or_not_config_setting_group_matches_test()
    _single_or_not_config_setting_group_negated_cond_matches_test()

    _single_not_config_setting_group_matches_test()
    _single_not_config_setting_group_fails_test()
    _multiple_not_config_setting_group_matches_test()
    _multiple_not_config_setting_group_first_cond_matches_test()
    _multiple_not_config_setting_group_last_cond_matches_test()

    _match_any_default_with_match_none_matches_test()
    _match_any_default_with_match_none_fails_test()
    _match_all_default_with_match_none_matches_test()
    _match_all_default_with_match_none_fails_test()

    # _empty_config_setting_group_not_allowed_test()
    # _and_and_or_not_allowed_together_test()
