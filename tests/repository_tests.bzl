# Copyright 2018 The Bazel Authors. All rights reserved.
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
"""Unit tests for repository.bzl."""

load("//lib:repository.bzl", "repository")
load("//lib:unittest.bzl", "asserts", "unittest")

_existing_rules = {}
def _dummy_function(name):
    """Used to validate the maybe function is/isn't called."""
    _existing_rules[name] = (_existing_rules[name] or 0) + 1

def _calls_rule_function(ctx):
    """Unit tests for repository.maybe."""

    env = unittest.begin(ctx)
    

    # It should insert the first time.
    repository.maybe(_dummy_function, "foo")
    asserts.equals(env, _existing_rules, {"foo": 1})

    # And find a preexisting entry the second and not change it.
    repository.maybe(_dummy_function, "foo")
    asserts.equals(env, _existing_rules, {"foo": 1})

    unittest.end(env)

calls_rule_function = unittest.make(_calls_rule_function)

def repository_test_suite():
    """Creates the test targets and test suite for repository.bzl tests."""
    unittest.suite(
        "repository_tests",
        calls_rule_function,
    )
