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

"""Skylib module containing providers for directories."""

visibility("public")

DirectoryInfo = provider(
    doc = "Information about a directory",
    # @unsorted-dict-items
    fields = {
        "directories": "(Dict[str, DirectoryInfo]) The subdirectories contained directly within",
        "files": "(Dict[str, File]) The files contained directly within the directory, keyed by their path relative to this directory.",
        "direct_files": "(Depset[File])",
        # A transitive_directories would be useful here, but is blocked on
        # https://github.com/bazelbuild/starlark/issues/272
        "transitive_files": "(Depset[File])",
        "source_path": "(string) Path to all source files contained within this directory",
        "generated_path": "(string) Path to all generated files contained within this directory",
        "human_readable": "(string) A human readable identifier for a directory. Useful for providing error messages to a user.",
    },
)
