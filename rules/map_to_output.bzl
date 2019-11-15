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

"""A rule that copies a source file to bazel-bin at the same execroot path.
Eg. <source_root>/foo/bar/a.txt -> <bazel-bin>/foo/bar/a.txt

We cannot use genrule or copy_file rule to copy a source file to bazel-bin with
the same execroot path, because both rules create label for the output
artifact, which conflicts with the source file label. map_to_output rule
achieves that by avoiding creating label for the output artifact.
"""

load(
    "//rules/private:map_to_output_private.bzl",
    _map_to_output = "map_to_output",
)

map_to_output = _map_to_output
