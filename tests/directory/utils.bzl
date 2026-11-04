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

"""Helper functions for testing directory rules."""

load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load("@rules_testing//lib:truth.bzl", "matching")
load("@rules_testing//lib:util.bzl", "util")

# TODO: Use native annotations when Skylib requires Bazel 8.8 or newer.
def failure_containing(message):
    # type: (str) -> Callable[[TestEnv, Target], None]
    matcher = matching.contains(message)

    def test(env, target):
        # type: (TestEnv, Target) -> None
        env.expect.that_target(target).failures().contains_exactly_predicates([
            matcher,
        ])

    return test

def directory_entry(parent, name):
    # type: (DirectoryInfo, str) -> DirectoryInfo
    """Read an expected directory independently of get_subdirectory.

    Args:
      parent: Directory whose immediate entries contain the child.
      name: The child's basename.

    Returns:
      The named child's DirectoryInfo.
    """
    entry = parent.entries[name]
    if type(entry) == "File":
        fail("%s: expected %r to be a directory, got file %s" % (parent.path, name, entry.path))
    return entry

def failure_test(*, name, impl, rule, **kwargs):
    # type: (str, Callable[[TestEnv, Target], None], rule, **object) -> None
    subject_name = "_%s_subject" % name

    # The rule passed to helper_target determines which keywords it accepts.
    # ty: ignore[non-static-type]
    util.helper_target(
        rule,
        name = subject_name,
        **kwargs
    )

    # ty: ignore[non-static-type]
    analysis_test(
        name = name,
        expect_failure = True,
        impl = impl,
        target = subject_name,
    )
