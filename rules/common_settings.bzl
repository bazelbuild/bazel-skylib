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

"""Common build setting rules that return a BuildSettingInfo with the value of the build setting.
For label-typed settings, use the native label_flag and label_setting rules."""

BuildSettingInfo = provider(fields = ["value"])

def _impl(ctx):
    return BuildSettingInfo(value = ctx.build_setting_value)

int_flag = rule(
    implementation = _impl,
    build_setting = config.int(flag = True),
)

int_setting = rule(
    implementation = _impl,
    build_setting = config.int(),
)

bool_flag = rule(
    implementation = _impl,
    build_setting = config.bool(flag = True),
)

bool_setting = rule(
    implementation = _impl,
    build_setting = config.bool(),
)

string_flag = rule(
    implementation = _impl,
    build_setting = config.bool(flag = True),
)

string_setting = rule(
    implementation = _impl,
    build_setting = config.bool(),
)

string_list_flag = rule(
    implementation = _impl,
    build_setting = config.bool(flag = True),
)

string_list_setting = rule(
    implementation = _impl,
    build_setting = config.bool(),
)
