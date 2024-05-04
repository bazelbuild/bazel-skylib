# Copyright 2024 The Bazel Authors. All rights reserved.
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

"""
select_files_by_extension() build rule implementation.

Selects a set of files from the outputs of a target by file extension.
"""

load("//lib:paths.bzl", "paths")

def _impl(ctx):
    if ctx.attr.extension and len(ctx.attr.extension) == 0:
        fail("Subpath can not be empty.")

    extension = ctx.attr.extension
    if extension[0] != ".":
        extension = "." + extension

    out = []
    for f in ctx.attr.srcs.files.to_list():
        _, extension = paths.split_extension(f.path)
        if extension == ctx.attr.extension:
            out += [f]

    return [DefaultInfo(files = depset(out))]

select_files_by_extension = rule(
    implementation = _impl,
    doc = "Selects a single file from the outputs of a target by given relative path",
    attrs = {
        "srcs": attr.label(
            allow_files = True,
            mandatory = True,
            doc = "The target producing the file among other outputs",
        ),
        "extension": attr.string(
            mandatory = True,
            doc = "Extension to select by",
        ),
    },
)
