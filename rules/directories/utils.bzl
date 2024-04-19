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

"""Skylib module containing utility functions related to directories."""

visibility("public")

_DIR_NOT_FOUND = """{directory} does not contain a directory named {dirname}.
Instead, it contains the directories {children}."""

def _check_path_relative(path):
    if path.startswith("/"):
        fail("Path must be relative. Got {path}".format(path = path))

def get_direct_subdirectory(directory, dirname):
    """Gets the direct subdirectory of a directory.

    Args:
        directory: (DirectoryInfo) The directory to look within.
        dirname: (string) The name of the directory to look for.
    Returns:
        (DirectoryInfo) The directory contained within."""
    if dirname not in directory.directories:
        fail(_DIR_NOT_FOUND.format(
            directory = directory.human_readable,
            dirname = repr(dirname),
            children = repr(sorted(directory.directories)),
        ))
    return directory.directories[dirname]

def get_subdirectory(directory, path):
    """Gets a subdirectory contained within a tree of another directory.

    Args:
        directory: (DirectoryInfo) The directory to look within.
        path: (string) The path of the directory to look for within it.
    Returns:
        (DirectoryInfo) The directory contained within.
    """
    _check_path_relative(path)

    for dirname in path.split("/"):
        directory = get_direct_subdirectory(directory, dirname)
    return directory
