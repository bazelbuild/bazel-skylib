# Copyright 2023 The Bazel Authors. All rights reserved.
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

"""Module extension that exposes module versions as Starlark constants.

Add the following to your MODULE.bazel to use the extension, assuming your
module is called `my_module`:

```python
module_version = use_extension("@bazel_skylib//extensions:module_version.bzl", "module_version")
use_repo(module_version, "my_module_version")
```

Then, load a Starlark constant containing your module's version from the
`my_module_version` repo:

```python
load("@my_module_version//:version.bzl", "VERSION")
```
"""

def _module_version_repo_impl(repository_ctx):
    repository_ctx.template(
        "BUILD.bazel",
        repository_ctx.path(Label("//extensions:BUILD.version")),
    )
    repository_ctx.file("WORKSPACE.bazel")
    repository_ctx.file(
        "version.bzl",
        "VERSION = {}\n".format(repr(repository_ctx.attr.version)),
    )

_module_version_repo = repository_rule(
    implementation = _module_version_repo_impl,
    attrs = {
        "version": attr.string(),
    },
)

def _module_version_impl(module_ctx):
    # buildifier: disable=no-effect
    [
        _module_version_repo(
            name = module.name + "_version",
            version = module.version,
        )
        for module in module_ctx.modules
    ]

module_version = module_extension(
    implementation = _module_version_impl,
)
