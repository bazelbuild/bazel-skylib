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

"""Implementation of copy_file macro and underlying rules.

These rules copy a file to another location using Bash (on Linux/macOS) or
cmd.exe (on Windows). '_copy_xfile' marks the resulting file executable,
'_copy_file' does not.
"""

def _common_impl(ctx, is_executable):
    if ctx.attr.is_windows:
        # Most Windows binaries built with MSVC use a certain argument quoting
        # scheme. Bazel uses that scheme too to quote arguments. However,
        # cmd.exe uses different semantics, so Bazel's quoting is wrong here.
        # To fix that we write the command to a .bat file so no command line
        # quoting or escaping is required.
        bat = ctx.actions.declare_file(ctx.label.name + "-cmd.bat")
        ctx.actions.write(
            output = bat,
            content = "@copy /Y \"%s\" \"%s\" >NUL" % (
                ctx.file.src.path.replace("/", "\\"),
                ctx.outputs.out.path.replace("/", "\\"),
            ),
            is_executable = True,
        )
        ctx.actions.run(
            inputs = [ctx.file.src, bat],
            outputs = [ctx.outputs.out],
            executable = "cmd.exe",
            arguments = ["/C", bat.path.replace("/", "\\")],
            mnemonic = "CopyFile",
            progress_message = "Copying files",
            use_default_shell_env = True,
        )
    else:
        ctx.actions.run_shell(
            inputs = [ctx.file.src],
            outputs = [ctx.outputs.out],
            command = "cp -f \"$1\" \"$2\"",
            arguments = [ctx.file.src.path, ctx.outputs.out.path],
            mnemonic = "CopyFile",
            progress_message = "Copying files",
            use_default_shell_env = True,
        )

    files = depset(direct = [ctx.outputs.out])
    runfiles = ctx.runfiles(files = [ctx.outputs.out])
    if is_executable:
        return [DefaultInfo(files = files, runfiles = runfiles, executable = ctx.outputs.out)]
    else:
        return [DefaultInfo(files = files, runfiles = runfiles)]

def _impl(ctx):
    return _common_impl(ctx, False)

def _ximpl(ctx):
    return _common_impl(ctx, True)

_ATTRS = {
    "src": attr.label(
        mandatory = True,
        allow_single_file = True,
        doc = "The file to make a copy of.",
    ),
    "out": attr.output(
        mandatory = True,
        doc = "Path of the output file, relative to this package.",
    ),
    "is_windows": attr.bool(mandatory = True),
}

_copy_file = rule(
    implementation = _impl,
    provides = [DefaultInfo],
    attrs = _ATTRS,
    doc = "Copies a file to another location.",
)

_copy_xfile = rule(
    implementation = _ximpl,
    executable = True,
    provides = [DefaultInfo],
    attrs = _ATTRS,
    doc = "Copies a file to another location and makes the new file executable.",
)

def copy_file(name, src, out, is_executable=False, **kwargs):
    if is_executable:
        _copy_xfile(
            name = name,
            src = src,
            out = out,
            is_windows = select({
                "@bazel_tools//src/conditions:host_windows": True,
                "//conditions:default": False,
            }),
            **kwargs
        )
    else:
        _copy_file(
            name = name,
            src = src,
            out = out,
            is_windows = select({
                "@bazel_tools//src/conditions:host_windows": True,
                "//conditions:default": False,
            }),
            **kwargs
        )
