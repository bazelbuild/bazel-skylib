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

"""map_to_output() rule implementations.

This rule copies a source file to bazel-bin at the same execroot path, we avoid
label conflict with the source file by not creating label for the output
artifact.
"""

load("//rules/private:copy_file_private.bzl", "copy_bash", "copy_cmd")

def _map_to_output_impl(ctx):
  src = ctx.file.src
  if not src.is_source:
    fail("A source file must be specified in map_to_output rule, %s is not a source file." % src.path)
  dst = ctx.actions.declare_file(src.basename, sibling = src)
  if ctx.attr.is_windows:
    copy_cmd(ctx, src, dst)
  else:
    copy_bash(ctx, src, dst)
  return DefaultInfo(files = depset([dst]), runfiles = ctx.runfiles(files = [dst]))

_map_to_output = rule(
  implementation = _map_to_output_impl,
  attrs = {
    "src": attr.label(mandatory = True, allow_single_file = True),
    "is_windows": attr.bool(mandatory = True),
  }
)

def map_to_output(name, src, **kwargs):
  """Copies a source file to bazel-bin at the same execroot path
     Eg. <source_root>/foo/bar/a.txt -> <bazel-bin>/foo/bar/a.txt

     Args:
         name: Name of the rule.
         src: A Label. The file to to copy.
         **kwargs: further keyword arguments, e.g. `visibility`
  """
  _map_to_output(
    name = name,
    src = src,
    is_windows = select({
        "@bazel_tools//src/conditions:host_windows": True,
        "//conditions:default": False,
    }),
    **kwargs
  )
