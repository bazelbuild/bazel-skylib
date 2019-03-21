# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""A test rule that compares two binary files.

The rule uses a Bash command (diff) on Linux/macOS/non-Windows, and a cmd.exe
command (fc.exe) on Windows (no Bash is required).
"""

def _runfiles_path(f):
    if f.root.path:
        return f.path[len(f.root.path) + 1:]  # generated file
    else:
        return f.path  # source file

def _diff_test_impl(ctx):
    if ctx.attr.is_windows:
        test_bin = ctx.actions.declare_file(ctx.label.name + "-test.bat")
        ctx.actions.write(
            output = test_bin,
            content = r"""@echo off
setlocal enableextensions
set MF=%RUNFILES_MANIFEST_FILE:/=\%
set PATH=%SYSTEMROOT%\system32
for /F "tokens=2* usebackq" %%i in (`findstr.exe /l /c:"%TEST_WORKSPACE%/{file1} " "%MF%"`) do (
  set RF1=%%i
  set RF1=%RF1:/=\%
)
if "%RF1%" equ "" (
  echo>&2 ERROR: {file1} not found
  exit /b 1
)
for /F "tokens=2* usebackq" %%i in (`findstr.exe /l /c:"%TEST_WORKSPACE%/{file2} " "%MF%"`) do (
  set RF2=%%i
  set RF2=%RF2:/=\%
)
if "%RF2%" equ "" (
  echo>&2 ERROR: {file2} not found
  exit /b 1
)
fc.exe 2>NUL 1>NUL /B "%RF1%" "%RF2%"
if %ERRORLEVEL% equ 2 (
  echo>&2 FAIL: "{file1}" and/or "{file2}" not found
  exit /b 1
) else (
  if %ERRORLEVEL% equ 1 (
    echo>&2 FAIL: files "{file1}" and "{file2}" differ
    exit /b 1
  )
)
""".format(
                file1 = _runfiles_path(ctx.file.file1),
                file2 = _runfiles_path(ctx.file.file2),
            ),
            is_executable = True,
        )
    else:
        test_bin = ctx.actions.declare_file(ctx.label.name + "-test.sh")
        ctx.actions.write(
            output = test_bin,
            content = r"""#!/bin/bash
set -euo pipefail
if [[ -d "${{RUNFILES_DIR:-/dev/null}}" ]]; then
  RF1="$RUNFILES_DIR/$TEST_WORKSPACE/{file1}"
  RF2="$RUNFILES_DIR/$TEST_WORKSPACE/{file2}"
elif [[ -f "${{RUNFILES_MANIFEST_FILE:-/dev/null}}" ]]; then
  RF1="$(grep -F -m1 '{file1} ' "$RUNFILES_MANIFEST_FILE" | sed 's/^[^ ]* //')"
  RF2="$(grep -F -m1 '{file2} ' "$RUNFILES_MANIFEST_FILE" | sed 's/^[^ ]* //'))"
else
  echo >&2 "ERROR: could not find \"{file1}\" and \"{file2}\""
fi
if ! diff "$RF1" "$RF2"; then
  echo >&2 "FAIL: files \"{file1}\" and \"{file2}\" differ"
  exit 1
fi
""".format(
                file1 = _runfiles_path(ctx.file.file1),
                file2 = _runfiles_path(ctx.file.file2),
            ),
            is_executable = True,
        )
    return DefaultInfo(
        executable = test_bin,
        files = depset(direct = [test_bin]),
        runfiles = ctx.runfiles(files = [test_bin, ctx.file.file1, ctx.file.file2]),
    )

_diff_test = rule(
    attrs = {
        "file1": attr.label(
            allow_files = True,
            mandatory = True,
            single_file = True,
        ),
        "file2": attr.label(
            allow_files = True,
            mandatory = True,
            single_file = True,
        ),
        "is_windows": attr.bool(mandatory = True),
    },
    test = True,
    implementation = _diff_test_impl,
)

def diff_test(name, file1, file2, **kwargs):
    """A test that compares two files.

    The test succeeds if the files' contents match.

    Args:
      name: The name of the test rule.
      file1: Label of the file to compare to <code>file2</code>.
      file2: Label of the file to compare to <code>file1</code>.
      **kwargs: The <a href="https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes-tests">common attributes for tests</a>.
    """
    _diff_test(
        name = name,
        file1 = file1,
        file2 = file2,
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs
    )
