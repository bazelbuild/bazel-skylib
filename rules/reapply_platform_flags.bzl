# Copyright 2026 The Bazel Authors. All rights reserved.
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

"""A transition that applies the flags of the target platform again.

Bazel applies the [flags of a platform](https://bazel.build/reference/be/platforms-and-toolchains#platform_flags)
when a transition changes the target platform to it. Newer Bazel versions don't apply them again after a
transition that leaves the target platform unchanged, so such a transition can override flags set by the
platform. To apply the flags of the target platform after such a transition, compose it with
`reapply_platform_flags`:

```starlark
load("@bazel_skylib//rules:reapply_platform_flags.bzl", "reapply_platform_flags")

my_rule = rule(
    ...
    cfg = my_transition.and_then(reapply_platform_flags),
)
```

`reapply_platform_flags` changes the target platform to a platform without flags and back. It does nothing
with Bazel versions that don't support `transition.and_then`, which apply the flags of the target platform
after every transition.
"""

_PLATFORMS = "//command_line_option:platforms"
_ORIGINAL_PLATFORMS = str(Label("//rules/private:reapply_platform_flags_original_platforms"))
_PLATFORM_WITHOUT_FLAGS = str(Label("//rules/private:reapply_platform_flags_platform_without_flags"))

def _to_platform_without_flags_impl(settings, _attr):
    return {
        _PLATFORMS: [_PLATFORM_WITHOUT_FLAGS],
        _ORIGINAL_PLATFORMS: [str(platform) for platform in settings[_PLATFORMS]],
    }

_to_platform_without_flags = transition(
    implementation = _to_platform_without_flags_impl,
    inputs = [_PLATFORMS],
    outputs = [_PLATFORMS, _ORIGINAL_PLATFORMS],
)

def _to_original_platforms_impl(settings, _attr):
    return {
        _PLATFORMS: settings[_ORIGINAL_PLATFORMS],
        _ORIGINAL_PLATFORMS: [],
    }

_to_original_platforms = transition(
    implementation = _to_original_platforms_impl,
    inputs = [_ORIGINAL_PLATFORMS],
    outputs = [_PLATFORMS, _ORIGINAL_PLATFORMS],
)

def _noop_impl(_settings, _attr):
    return {}

_noop = transition(
    implementation = _noop_impl,
    inputs = [],
    outputs = [],
)

reapply_platform_flags = (
    _to_platform_without_flags.and_then(_to_original_platforms) if hasattr(_to_platform_without_flags, "and_then") else _noop
)
