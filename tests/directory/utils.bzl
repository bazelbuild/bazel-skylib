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
load("@rules_testing//lib:truth.bzl", "subjects")
load("@rules_testing//lib:util.bzl", "util")

_depset_as_list_subject = lambda value, *, meta: subjects.collection(
    value.to_list(),
    meta = meta,
)

directory_info_subject = lambda value, *, meta: subjects.struct(
    value,
    meta = meta,
    attrs = dict(
        entries = subjects.dict,
        transitive_files = _depset_as_list_subject,
        path = subjects.str,
        human_readable = subjects.str,
    ),
)

def failure_matching(matcher):
    def test(env, target):
        env.expect.that_target(target).failures().contains_exactly_predicates([
            matcher,
        ])

    return test

def directory_subject(env, directory_info):
    return env.expect.that_value(
        value = directory_info,
        expr = "DirectoryInfo(%r)" % directory_info.path,
        factory = directory_info_subject,
    )

def failure_test(*, name, impl, rule, **kwargs):
    subject_name = "_%s_subject" % name
    util.helper_target(
        rule,
        name = subject_name,
        **kwargs
    )

    analysis_test(
        name = name,
        expect_failure = True,
        impl = impl,
        target = subject_name,
    )
