# Copyright 2023 The Bazel Authors. All rights reserved.
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

"""Helper utilities for generating distribution tarballs."""

# TODO(https://github.com/bazelbuild/bazel/issues/32343): Express the forwarded
# genrule keywords in a native function annotation once Bazel supports them.
def remove_internal_only(
        name,  # type: str
        src,  # type: str | Label
        out,  # type: str | Label
        # type: Unpack[KeywordArgs[native.genrule]]
        **kwargs):
    # type: (...) -> None
    """Removes '### INTERNAL ONLY' line and all lines below from a file.

    Args:
        name: Name of the rule.
        src: File to process.
        out: Path of the output file.
        **kwargs: further keyword arguments passed to native.genrule.
    """
    native.genrule(
        name = name,
        srcs = [src],
        outs = [out],
        cmd = "sed -e '/### INTERNAL ONLY/,$$d' $< >$@",
        **kwargs
    )
