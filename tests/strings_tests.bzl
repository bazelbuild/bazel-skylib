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

"""Unit tests for structs.bzl."""

load("//:lib.bzl", "strings", "asserts", "unittest")


def _strip_margin_test(ctx):
  """Unit tests for dicts.add."""
  env = unittest.begin(ctx)

  io_pairs = []

  input = """"""
  output = """"""
  io_pairs.append((input, output, None))

  input = """|"""
  output = """"""
  io_pairs.append((input, output, None))

  input = """|"""
  output = """|"""
  io_pairs.append((input, output, ':'))

  input = """   :a
   :b
:c"""
  output = """a
b
c"""
  io_pairs.append((input, output, ':'))

  input = """
    |hello
    |world
    |"""
  output = """
hello
world
"""
  io_pairs.append((input, output, None))

  input = """
    |TIME_MS=`awk -F '=' '$1 == "build_time" {{ print $2 }}' $STATSFILE`
    |
    |if [ ! -z "$TIME_MS" ]; then
    |  TIME_S=`awk "BEGIN {{ printf \\"%.3f\\n\\", $TIME_MS / 1000 }}"`
    |  LOC_PER_S=`awk "BEGIN {{ printf \\"%.2f\\n\\", $N_LINES / $TIME_S }}"`
    |fi
    |"""
  output = """
TIME_MS=`awk -F '=' '$1 == "build_time" {{ print $2 }}' $STATSFILE`

if [ ! -z "$TIME_MS" ]; then
  TIME_S=`awk "BEGIN {{ printf \\"%.3f\\n\\", $TIME_MS / 1000 }}"`
  LOC_PER_S=`awk "BEGIN {{ printf \\"%.2f\\n\\", $N_LINES / $TIME_S }}"`
fi
"""
  io_pairs.append((input, output, None))

  for i, o, d in io_pairs:
      if d == None:
          asserts.equals(env, o, strings.strip_margin(i))
      else:
          asserts.equals(env, o, strings.strip_margin(i, d))

  unittest.end(env)

strip_margin_test = unittest.make(_strip_margin_test)


def strings_test_suite():
  """Creates the test targets and test suite for strings.bzl tests."""
  unittest.suite(
      "strings_tests",
      strip_margin_test,
  )
