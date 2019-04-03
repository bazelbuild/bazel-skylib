# Copyright 2018 The Bazel Authors. All rights reserved.
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

"""Unit tests for maprule.bzl."""

load("//lib:unittest.bzl", "asserts", "unittest")
load("//rules/private:maprule_testing.bzl", "maprule_testing")

def _dummy_generating_action(ctx, path):
    ctx.actions.write(path, "hello")

def _mock_file(ctx, path):
    f = ctx.actions.declare_file(path)
    _dummy_generating_action(ctx, f)
    return f

def _lstrip_until(s, until):
    return s[s.find(until):]

def _assert_dict_keys(env, expected, actual, msg):
    asserts.equals(env, {k: None for k in expected}, {k: None for k in actual}, msg)

def _assert_ends_with(env, expected_ending, s, msg):
    if not s.endswith(expected_ending):
        unittest.fail(env, msg + ": expected \"%s\" to end with \"%s\"" % (s, expected_ending))

def _assert_no_error(env, errors, msg):
    if errors:
        unittest.fail(env, msg + ": expected no errors, got: [%s]" % "\n".join(errors))

def _assert_error(env, errors, expected_fragment, msg):
    for e in errors:
        if expected_fragment in e:
            return
    unittest.fail(env, msg + ": did not find \"%s\" in: [%s]" % (expected_fragment, "\n".join(errors)))

def _contains_substrings_in_order(s, substrings):
    index = 0
    for ss in substrings:
        index = s.find(ss, index)
        if index < 0:
            return False
        index += len(ss)
    return True

def _assert_error_fragments(env, errors, expected_fragments, msg):
    for e in errors:
        if _contains_substrings_in_order(e, expected_fragments):
            return
    unittest.fail(env, msg + ": did not find expected fragments in \"%s\" in order" % "\n".join(errors))

def _src_placeholders_test(ctx):
    env = unittest.begin(ctx)

    for language, strategy in [
        ("cmd", maprule_testing.cmd_strategy),
        ("bash", maprule_testing.bash_strategy),
    ]:
        for basename, basename_noext in [("bar.txt", "bar"), ("bar.pb.h", "bar.pb")]:
            actual = maprule_testing.src_placeholders(
                _mock_file(ctx, language + "/foo/" + basename),
                strategy,
            )
            _assert_dict_keys(
                env,
                ["src", "src_dir", "src_name", "src_name_noext"],
                actual,
                "assertion #1 (language: %s, basename: %s)" % (language, basename),
            )
            _assert_ends_with(
                env,
                strategy.as_path(language + "/foo/" + basename),
                actual["src"],
                "assertion #2 (language: %s, basename: %s)" % (language, basename),
            )
            _assert_ends_with(
                env,
                strategy.as_path(language + "/foo/"),
                actual["src_dir"],
                "assertion #3 (language: %s, basename: %s)" % (language, basename),
            )
            asserts.equals(
                env,
                basename,
                actual["src_name"],
                "assertion #4 (language: %s, basename: %s)" % (language, basename),
            )
            asserts.equals(
                env,
                basename_noext,
                actual["src_name_noext"],
                "assertion #5 (language: %s, basename: %s)" % (language, basename),
            )

    return unittest.end(env)

src_placeholders_test = unittest.make(_src_placeholders_test)

def _validate_attributes_test(ctx):
    """Unit tests for maprule_testing.validate_attributes."""
    env = unittest.begin(ctx)
    _assert_no_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {"BAR": "value1"}),
        "assertion #1",
    )
    _assert_no_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {}),
        "assertion #2",
    )

    _assert_error(
        env,
        maprule_testing.validate_attributes({}, {}),
        "\"outs_templates\" must not be empty",
        "assertion #3",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"": "foo"}, {}),
        "name should not be empty",
        "assertion #4",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"foo": "bar"}, {}),
        "name should be all upper-case",
        "assertion #5",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"SRC": "bar"}, {}),
        "conflicting with the environment variable of the source file",
        "assertion #6",
    )

    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": ""}, {}),
        "output path should not be empty",
        "assertion #7",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "/usr/bin"}, {}),
        "output path should be relative",
        "assertion #8",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "c:/usr/bin"}, {}),
        "output path should be relative",
        "assertion #9",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "../foo"}, {}),
        "output path should not contain uplevel references",
        "assertion #10",
    )
    _assert_no_error(
        env,
        maprule_testing.validate_attributes({"FOO": "./foo"}, {}),
        "assertion #11",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"BAR": "foo", "FOO": "foo"}, {}),
        "output path is already used for \"BAR\"",
        "assertion #12",
    )

    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {"": "baz"}),
        "name should not be empty",
        "assertion #13",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {"Bar": "baz"}),
        "name should be all upper-case",
        "assertion #14",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {"FOO": "baz"}),
        "conflicting with the environment variable of the \"FOO\" output file",
        "assertion #15",
    )

    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {"BAR": "$(location x) $(location y)"}),
        "use only one $(location)",
        "assertion #16",
    )
    _assert_error(
        env,
        maprule_testing.validate_attributes({"FOO": "bar"}, {"BAR": "a $(location b"}),
        "missing closing parenthesis",
        "assertion #17",
    )

    return unittest.end(env)

validate_attributes_test = unittest.make(_validate_attributes_test)

def _as_path_test(ctx):
    """Unit tests for maprule_testing.as_path."""
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        "Foo\\Bar\\Baz\\Qux",
        maprule_testing.cmd_strategy.as_path("Foo/Bar/Baz\\Qux"),
        msg = "assertion #1",
    )
    asserts.equals(
        env,
        "Foo/Bar/Baz\\Qux",
        maprule_testing.bash_strategy.as_path("Foo/Bar/Baz\\Qux"),
        msg = "assertion #2",
    )
    return unittest.end(env)

as_path_test = unittest.make(_as_path_test)

def _assert_relative_path(env, path, index):
    asserts.true(
        env,
        maprule_testing.is_relative_path(path),
        msg = "assertion #%d" % index,
    )

def _assert_not_relative_path(env, path, index):
    asserts.false(
        env,
        maprule_testing.is_relative_path(path),
        msg = "assertion #%d" % index,
    )

def _is_relative_path_test(ctx):
    """Unit tests for maprule_testing.is_relative_path."""
    env = unittest.begin(ctx)
    _assert_relative_path(env, "Foo/Bar/Baz", 1)
    _assert_relative_path(env, "Foo\\Bar\\Baz", 2)
    _assert_relative_path(env, "Foo/Bar\\Baz", 3)
    _assert_not_relative_path(env, "d:/Foo/Bar", 4)
    _assert_not_relative_path(env, "D:/Foo/Bar", 5)
    _assert_not_relative_path(env, "/Foo/Bar", 6)
    _assert_not_relative_path(env, "\\Foo\\Bar", 7)
    return unittest.end(env)

is_relative_path_test = unittest.make(_is_relative_path_test)

def _custom_envmap_test(ctx):
    """Unit tests for maprule_testing.custom_envmap."""
    env = unittest.begin(ctx)

    actual = {}

    for language, strategy in [
        ("cmd", maprule_testing.cmd_strategy),
        ("bash", maprule_testing.bash_strategy),
    ]:
        actual[language] = maprule_testing.custom_envmap(
            ctx,
            strategy,
            src_placeholders = {"src_ph1": "Src/Ph1-value", "src_ph2": "Src/Ph2-value"},
            outs_dict = {
                "out1": _mock_file(ctx, language + "/Foo/Out1"),
                "out2": _mock_file(ctx, language + "/Foo/Out2"),
            },
            resolved_add_env = {"ENV1": "Env1"},
        )
        _assert_dict_keys(
            env,
            ["MAPRULE_SRC_PH1", "MAPRULE_SRC_PH2", "MAPRULE_OUT1", "MAPRULE_OUT2", "MAPRULE_ENV1"],
            actual[language],
            msg = "assertion #1 (language: %s)" % language,
        )
        actual[language]["MAPRULE_OUT1"] = _lstrip_until(actual[language]["MAPRULE_OUT1"], "Foo")
        actual[language]["MAPRULE_OUT2"] = _lstrip_until(actual[language]["MAPRULE_OUT2"], "Foo")

    asserts.equals(
        env,
        {
            "MAPRULE_ENV1": "Env1",
            "MAPRULE_OUT1": "Foo\\Out1",
            "MAPRULE_OUT2": "Foo\\Out2",
            "MAPRULE_SRC_PH1": "Src\\Ph1-value",
            "MAPRULE_SRC_PH2": "Src\\Ph2-value",
        },
        actual["cmd"],
        msg = "assertion #2",
    )

    asserts.equals(
        env,
        {
            "MAPRULE_ENV1": "Env1",
            "MAPRULE_OUT1": "Foo/Out1",
            "MAPRULE_OUT2": "Foo/Out2",
            "MAPRULE_SRC_PH1": "Src/Ph1-value",
            "MAPRULE_SRC_PH2": "Src/Ph2-value",
        },
        actual["bash"],
        msg = "assertion #3",
    )

    return unittest.end(env)

custom_envmap_test = unittest.make(_custom_envmap_test)

def _create_outputs_test(ctx):
    """Unit tests for maprule_testing.create_outputs."""
    env = unittest.begin(ctx)

    for language, strategy in [
        ("cmd", maprule_testing.cmd_strategy),
        ("bash", maprule_testing.bash_strategy),
    ]:
        src1 = _mock_file(ctx, language + "/foo/src1.txt")
        src2 = _mock_file(ctx, language + "/foo/src2.pb.h")
        src3 = _mock_file(ctx, language + "/bar/src1.txt")
        foreach_srcs = [src1, src2, src3]

        outs_dicts, all_output_files, _, errors = (
            maprule_testing.create_outputs(
                ctx,
                "my_maprule",
                {
                    "OUT1": "{src}.out1",
                    "OUT2": "{src_dir}/out2/{src_name_noext}.out2",
                },
                strategy,
                foreach_srcs,
            )
        )

        _assert_no_error(env, errors, "assertion #1 (language: %s)" % language)

        for output in all_output_files:
            _dummy_generating_action(ctx, output)

        _assert_dict_keys(
            env,
            foreach_srcs,
            outs_dicts,
            "assertion #2 (language: %s)" % language,
        )
        for src in foreach_srcs:
            _assert_dict_keys(
                env,
                ["OUT1", "OUT2"],
                outs_dicts[src],
                "assertion #3 (language: %s, src: %s)" % (language, src),
            )

        _assert_ends_with(
            env,
            "my_maprule_out/tests/%s/foo/src1.txt.out1" % language,
            outs_dicts[src1]["OUT1"].path,
            "assertion #4 (language: %s)" % language,
        )
        _assert_ends_with(
            env,
            "my_maprule_out/tests/%s/foo/out2/src1.out2" % language,
            outs_dicts[src1]["OUT2"].path,
            "assertion #5 (language: %s)" % language,
        )

        _assert_ends_with(
            env,
            "my_maprule_out/tests/%s/foo/src2.pb.h.out1" % language,
            outs_dicts[src2]["OUT1"].path,
            "assertion #6 (language: %s)" % language,
        )
        _assert_ends_with(
            env,
            "my_maprule_out/tests/%s/foo/out2/src2.pb.out2" % language,
            outs_dicts[src2]["OUT2"].path,
            "assertion #7 (language: %s)" % language,
        )

        _assert_ends_with(
            env,
            "my_maprule_out/tests/%s/bar/src1.txt.out1" % language,
            outs_dicts[src3]["OUT1"].path,
            "assertion #8 (language: %s)" % language,
        )
        _assert_ends_with(
            env,
            "my_maprule_out/tests/%s/bar/out2/src1.out2" % language,
            outs_dicts[src3]["OUT2"].path,
            "assertion #9 (language: %s)" % language,
        )

        expected = [
            "my_maprule_out/tests/%s/foo/src1.txt.out1" % language,
            "my_maprule_out/tests/%s/foo/out2/src1.out2" % language,
            "my_maprule_out/tests/%s/foo/src2.pb.h.out1" % language,
            "my_maprule_out/tests/%s/foo/out2/src2.pb.out2" % language,
            "my_maprule_out/tests/%s/bar/src1.txt.out1" % language,
            "my_maprule_out/tests/%s/bar/out2/src1.out2" % language,
        ]
        for i in range(0, len(all_output_files)):
            actual = _lstrip_until(all_output_files[i].path, "my_maprule_out")
            asserts.equals(
                env,
                expected[i],
                actual,
                "assertion #10 (language: %s, index: %d)" % (language, i),
            )

    return unittest.end(env)

create_outputs_test = unittest.make(_create_outputs_test)

def _conflicting_outputs_test(ctx):
    """Unit tests for maprule_testing.create_outputs catching conflicting outputs."""
    env = unittest.begin(ctx)

    for language, strategy in [
        ("cmd", maprule_testing.cmd_strategy),
        ("bash", maprule_testing.bash_strategy),
    ]:
        src1 = _mock_file(ctx, language + "/foo/src1.txt")
        src2 = _mock_file(ctx, language + "/foo/src2.pb.h")
        src3 = _mock_file(ctx, language + "/bar/src1.txt")
        foreach_srcs = [src1, src2, src3]

        _, all_output_files, _, errors = (
            maprule_testing.create_outputs(
                ctx,
                "my_maprule",
                {
                    "OUT1": "out1",  # 3 conflicts
                    "OUT2": "{src_dir}/out2",  # 2 conflicts
                    "OUT3": "out3/{src_name}",  # 2 conflicts
                },
                strategy,
                foreach_srcs,
            )
        )

        for output in all_output_files:
            _dummy_generating_action(ctx, output)

        _assert_error_fragments(
            env,
            errors,
            ["out1", language + "/foo/src1.txt", "OUT1", language + "/foo/src2.pb.h", "OUT1"],
            msg = "assertion #1 (language: %s)" % language,
        )

        _assert_error_fragments(
            env,
            errors,
            ["out2", language + "/foo/src1.txt", "OUT2", language + "/foo/src2.pb.h", "OUT2"],
            msg = "assertion #2 (language: %s)" % language,
        )

        _assert_error_fragments(
            env,
            errors,
            ["out3/src1.txt", language + "/foo/src1.txt", "OUT3", language + "/bar/src1.txt", "OUT3"],
            msg = "assertion #5 (language: %s)" % language,
        )

    return unittest.end(env)

conflicting_outputs_test = unittest.make(_conflicting_outputs_test)

def maprule_test_suite():
    """Creates the test targets and test suite for maprule.bzl tests."""

    unittest.suite(
        "maprule_tests",
        src_placeholders_test,
        validate_attributes_test,
        as_path_test,
        is_relative_path_test,
        custom_envmap_test,
        conflicting_outputs_test,
    )
