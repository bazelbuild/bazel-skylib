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

"""Maprule implementation in Starlark.

This module exports the cmd_maprule() and bash_maprule() build rules.

They are the same except for the interpreter they use (cmd.exe and Bash respectively) and for the
expected language of their `cmd` attribute.

You can read more about these rules in "maprule_private.bzl".
"""

load(":maprule_private.bzl", _bash_maprule = "bash_maprule", _cmd_maprule = "cmd_maprule")

cmd_maprule = _cmd_maprule
bash_maprule = _bash_maprule
