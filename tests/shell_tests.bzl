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

"""Unit tests for shell.bzl."""

load("//lib:shell.bzl", "shell")
load("//lib:unittest.bzl", "asserts", "unittest")
load("//rules:write_file.bzl", "write_file")
load("//rules:diff_test.bzl", "diff_test")

def _shell_array_literal_test(ctx):
    """Unit tests for shell.array_literal."""
    env = unittest.begin(ctx)

    asserts.equals(env, "()", shell.array_literal([]))
    asserts.equals(env, "('1')", shell.array_literal([1]))
    asserts.equals(env, "('1' '2' '3')", shell.array_literal([1, 2, 3]))
    asserts.equals(env, "('$foo')", shell.array_literal(["$foo"]))
    asserts.equals(env, "('qu\"o\"te')", shell.array_literal(['qu"o"te']))

    return unittest.end(env)

shell_array_literal_test = unittest.make(_shell_array_literal_test)

def _shell_quote_test(ctx):
    """Unit tests for shell.quote."""
    env = unittest.begin(ctx)

    asserts.equals(env, "'foo'", shell.quote("foo"))
    asserts.equals(env, "'foo bar'", shell.quote("foo bar"))
    asserts.equals(env, "'three   spaces'", shell.quote("three   spaces"))
    asserts.equals(env, "'  leading'", shell.quote("  leading"))
    asserts.equals(env, "'trailing  '", shell.quote("trailing  "))
    asserts.equals(env, "'new\nline'", shell.quote("new\nline"))
    asserts.equals(env, "'tab\tcharacter'", shell.quote("tab\tcharacter"))
    asserts.equals(env, "'$foo'", shell.quote("$foo"))
    asserts.equals(env, "'qu\"o\"te'", shell.quote('qu"o"te'))
    asserts.equals(env, "'it'\\''s'", shell.quote("it's"))
    asserts.equals(env, "'foo\\bar'", shell.quote("foo\\bar"))
    asserts.equals(env, "'back`echo q`uote'", shell.quote("back`echo q`uote"))

    return unittest.end(env)

shell_quote_test = unittest.make(_shell_quote_test)

def _shell_escape_for_bat_test(ctx):
    """Unit tests for shell.escape_cmd."""
    env = unittest.begin(ctx)

    asserts.equals(env, "foo", shell.escape_for_bat("foo"))
    asserts.equals(env, "%%foo%%", shell.escape_for_bat("%foo%"))
    asserts.equals(env, '"%%foo%%"', shell.escape_for_bat('"%foo%"'))
    asserts.equals(env, "^^foo", shell.escape_for_bat("^foo"))
    asserts.equals(env, '"^foo"', shell.escape_for_bat('"^foo"'))
    asserts.equals(env, "^>foo.txt", shell.escape_for_bat(">foo.txt"))
    asserts.equals(env, "^<foo.txt", shell.escape_for_bat("<foo.txt"))
    asserts.equals(env, "^& ECHO foo", shell.escape_for_bat("& ECHO foo"))
    asserts.equals(env, "^| ECHO foo", shell.escape_for_bat("| ECHO foo"))
    asserts.equals(env, '^^"^<foo>^"^^', shell.escape_for_bat('^"^<foo>^"^'))
    asserts.equals(env, "hello^\nworld", shell.escape_for_bat("hello\nworld"))

    asserts.equals(env, "!delay!", shell.escape_for_bat("!delay!"))
    asserts.equals(env, "^^!delay^^!", shell.escape_for_bat("!delay!", delayed_expansion = True))
    asserts.equals(env, '"^^!delay^^!"', shell.escape_for_bat('"!delay!"', delayed_expansion = True))

    asserts.equals(env, 'hello^, "world"', shell.escape_for_bat('hello, "world"'))
    asserts.equals(env, 'hello^, \\"world\\"', shell.escape_for_bat('hello, "world"', escape_quotes = True))

    return unittest.end(env)

shell_escape_for_bat_test = unittest.make(_shell_escape_for_bat_test)

def _shell_args_test_gen_impl(ctx):
    """Test argument escaping: this rule writes a script for a sh_test."""
    args = [
        "foo",
        "foo bar",
        "three   spaces",
        "  leading",
        "trailing  ",
        "new\nline",
        "tab\tcharacter",
        "$foo",
        'qu"o"te',
        "it's",
        "foo\\bar",
        "back`echo q`uote",
    ]
    script_content = "\n".join([
        "#!/usr/bin/env bash",
        "myarray=" + shell.array_literal(args),
        'output=$(echo "${myarray[@]}")',
        # For logging:
        'echo "DEBUG: output=[${output}]" >&2',
        # The following is a shell representation of what the echo of the quoted
        # array will look like.  It looks a bit confusing considering it's shell
        # quoted into Python.  Shell using single quotes to minimize shell
        # escaping, so only the single quote needs to be escaped as '\'', all
        # others are essentially kept literally.
        "expected='foo foo bar three   spaces   leading trailing   new",
        "line tab\tcharacter $foo qu\"o\"te it'\\''s foo\\bar back`echo q`uote'",
        '[[ "${output}" == "${expected}" ]]',
    ])
    out = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = out,
        content = script_content,
        is_executable = True,
    )
    return [DefaultInfo(files = depset([out]))]

shell_args_test_gen = rule(
    implementation = _shell_args_test_gen_impl,
)

def _shell_windows_bat_echo_escaped_string_impl(ctx):
    """Test Windows .bat file argument escaping.

    This rule writes and executes a .bat file which echoes an escaped string.
    """
    script_content = "\r\n".join([
        "@echo off",
        "setlocal ENABLEDELAYEDEXPANSION",
        "echo {escaped}>%1",
    ]).format(escaped = shell.escape_for_bat(ctx.attr.escape, delayed_expansion = True))
    script = ctx.actions.declare_file(ctx.label.name + ".bat")
    ctx.actions.write(
        output = script,
        content = script_content,
        is_executable = True,
    )
    ctx.actions.run(
        outputs = [ctx.outputs.out],
        executable = script,
        arguments = [ctx.outputs.out.path],
        mnemonic = "ShellWindowsBatEchoEscapedString",
    )
    return [DefaultInfo()]

_shell_windows_bat_echo_escaped_string = rule(
    attrs = {
        "escape": attr.string(),
        "out": attr.output(mandatory = True),
    },
    implementation = _shell_windows_bat_echo_escaped_string_impl,
)

def shell_windows_bat_e2e_test(name, **kwargs):
    """Test Windows .bat file argument escaping.

    Args:
      name: Name of the test rule.
      **kwargs: Common attributes for the test, e.g. `tags`.

    This macro writes and executes a .bat file which echoes an escaped string, and
    verifies that the output is identical to the original string.
    """
    evil_string = '>out.txt <in.txt %path%, !path! "(x,y,z)" & echo foo | echo \\"bar\\"'
    write_file(
        name = "_%s_original" % name,
        content = [evil_string + "\r\n"],
        out = "_%s_original.txt" % name,
    )
    _shell_windows_bat_echo_escaped_string(
        name = "_%s_echo_escaped" % name,
        escape = evil_string,
        out = "_%s_echo_escaped.txt" % name,
        **kwargs
    )
    diff_test(
        name = name,
        file1 = "_%s_original" % name,
        file2 = "_%s_echo_escaped" % name,
        **kwargs
    )

def shell_test_suite():
    """Creates the test targets and test suite for shell.bzl tests."""
    unittest.suite(
        "shell_tests",
        shell_array_literal_test,
        shell_quote_test,
        shell_escape_for_bat_test,
    )
