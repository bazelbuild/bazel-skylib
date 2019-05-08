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

load("//rules/private:copy_file_private.bzl", "copy_bash", "copy_cmd")

def _impl_rule(ctx, is_windows):
    if not ctx.attr.out:
        fail(msg = "Must not be empty", attr = "out")
    out = ctx.actions.declare_file(ctx.attr.out)
    if is_windows:
        copy_cmd(ctx, ctx.file.src, out)
    else:
        copy_bash(ctx, ctx.file.src, out)
    return DefaultInfo(
        executable = out,
        files = depset(items = [out]),
        runfiles = ctx.runfiles(
            files = [out],
            collect_data = True,
            collect_default = True,
        ),
    )

def _impl(ctx):
    return _impl_rule(ctx, ctx.attr.is_windows)

_ATTRS = {
    "src": attr.label(
        executable = True,
        allow_single_file = True,
        mandatory = True,
        cfg = "host",
    ),
    "data": attr.label_list(allow_files = True),
    "out": attr.string(mandatory = True),
    "is_windows": attr.bool(mandatory = True),
}

_native_binary = rule(
    implementation = _impl,
    attrs = _ATTRS,
    executable = True,
)

_native_test = rule(
    implementation = _impl,
    attrs = _ATTRS,
    test = True,
)

def native_binary(name, src, out, data=None, **kwargs):
    """Wraps a pre-built binary or script with a binary rule.

    You can "bazel run" this rule like any other binary rule, and use it as a tool in genrule.tools for example. You can also augment the binary with runfiles.

    Args:
      src: label; path of the pre-built executable
      out: output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)
      data: list of labels; data dependencies
      **kwargs: The <a href="https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes-binaries">common attributes for binaries</a>.
    """
    _native_binary(
        name = name,
        src = src,
        out = out,
        data = data,
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs
    )

def native_test(name, src, out, data=None, **kwargs):
    """Wraps a pre-built binary or script with a test rule.

    You can "bazel test" this rule like any other test rule. You can also augment the binary with
    runfiles.

    Args:
      src: label; path of the pre-built executable
      out: output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)
      data: list of labels; data dependencies
      **kwargs: The <a href="https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes-tests">common attributes for tests</a>.
    """
    _native_test(
        name = name,
        src = src,
        out = out,
        data = data,
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs
    )
