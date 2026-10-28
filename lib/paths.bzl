# Copyright 2017 The Bazel Authors. All rights reserved.
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

"""Skylib module containing file path manipulation functions.

NOTE: The functions in this module currently only support paths with Unix-style
path separators (forward slash, "/"); they do not handle Windows-style paths
with backslash separators or drive letters.
"""

load(":paths.scl", _paths = "paths")

paths = _paths
