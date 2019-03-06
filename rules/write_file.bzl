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

"""A rule that writes a UTF-8 encoded text file from user-specified contents.

native.genrule() is sometimes used to create a text file. The 'write_file' and
'write_xfile' rules do this with a simpler interface than genrule.

These rules do not use Bash or any other shell to write the file. Instead they
use Starlark's built-in file writing action (ctx.actions.write).
"""

load(
    ":write_file_private.bzl",
    _write_file = "write_file",
    _write_xfile = "write_xfile",
)

write_file = _write_file
write_xfile = _write_xfile
