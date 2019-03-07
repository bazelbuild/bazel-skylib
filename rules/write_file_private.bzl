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

"""Implementation of write_file macro and underlying rules.

These rules write a UTF-8 encoded text file, using Bazel's FileWriteAction.
'_write_xfile' marks the resulting file executable, '_write_file' does not.
"""

def _common_impl(ctx, is_executable):
    # ctx.actions.write creates a FileWriteAction which uses UTF-8 encoding.
    ctx.actions.write(
        output = ctx.outputs.out,
        content = "\n".join(ctx.attr.content) if ctx.attr.content else "",
        is_executable = is_executable,
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
    "content": attr.string_list(
        mandatory = False,
        allow_empty = True,
        doc = ("Lines of text: the contents of the file. Newlines are added " +
               "automatically after every line except the last one."),
    ),
    "out": attr.output(
        mandatory = True,
        doc = "Path of the output file, relative to this package.",
    ),
}

_write_file = rule(
    implementation = _impl,
    provides = [DefaultInfo],
    attrs = _ATTRS,
    doc = "Creates a UTF-8 encoded text file.",
)

_write_xfile = rule(
    implementation = _ximpl,
    executable = True,
    provides = [DefaultInfo],
    attrs = _ATTRS,
    doc = "Creates a UTF-8 encoded text file and makes it executable.",
)

def write_file(name, out, content = None, is_executable = False, **kwargs):
    if is_executable:
        _write_xfile(
            name = name,
            content = content,
            out = out,
            **kwargs
        )
    else:
        _write_file(
            name = name,
            content = content,
            out = out,
            **kwargs
        )
