# Copyright 2022 The Bazel Authors. All rights reserved.
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

# This package aids testing the 'diff_test' rule.

load("//rules:expand_template.bzl", "expand_template")

expand_template(
    name = "filled_template",
    out = "foo/test.yaml",
    substitutions = {
        "@name@": "test",
        "@version@": "1.1.1",
    },
    template = "test.tpl.yaml",
)

sh_test(
    name = "template_test",
    srcs = ["template_test.sh"],
    data = [
        "foo/test.yaml",
        ":filled_template",
        "//tests:unittest.bash",
    ],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
    ],
)

expand_template(
    name = "version",
    out = "version.h",
    substitutions = {
        "@VERSION@": "2.3.4",
    },
    template = "version.h.in",
)

cc_test(
    name = "test",
    srcs = [
        "test.cc",
        ":version",
    ],
)
