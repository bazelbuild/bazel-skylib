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

"""Skylib module containing utilities for Bazel modules and module extensions."""

def _as_extension(macro, doc = None):
    """Wraps a WORKSPACE dependency macro into a module extension.

    Example:
    ```starlark
    def rules_foo_deps(optional_arg = True):
        some_repo_rule(name = "foobar")
        http_archive(name = "bazqux")

    rules_foo_deps_ext = modules.as_extension(rules_foo_deps)
    ```

    Args:
      macro: A [WORKSPACE dependency macro](https://bazel.build/rules/deploying#dependencies), i.e.,
          a function with no required parameters that instantiates one or more repository rules.
      doc: A description of the module extension that can be extracted by documentation generating
          tools.

    Returns:
      A module extension that generates the repositories instantiated by the given macro and also
      uses [`use_all_repos`](#use_all_repos) to indicate that all of those repositories should be
      imported via `use_repo`. The extension is marked as reproducible if supported by the current
      version of Bazel and thus doesn't result in a lockfile entry.
    """

    def _ext_impl(module_ctx):
        macro()

        # Setting `reproducible` is safe since `macro`, as a function without parameters, must be
        # deterministic.
        return _use_all_repos(module_ctx, reproducible = True)

    kwargs = {}
    if doc != None:
        kwargs["doc"] = doc

    return module_extension(
        implementation = _ext_impl,
        **kwargs
    )

def _use_all_repos(module_ctx, reproducible = False):
    """Return from a module extension that should have all its repositories imported via `use_repo`.

    Example:
    ```starlark
    def _ext_impl(module_ctx):
        some_repo_rule(name = "foobar")
        http_archive(name = "bazqux")
        return modules.use_all_repos(module_ctx)

    ext = module_extension(_ext_impl)
    ```

    Args:
      module_ctx: The [`module_ctx`](https://bazel.build/rules/lib/builtins/module_ctx) object
          passed to the module extension's implementation function.
      reproducible: The value of the `reproducible` parameter to pass to the
          [`extension_metadata`](https://bazel.build/rules/lib/builtins/extension_metadata.html)
          object returned by this function. This is safe to set with Bazel versions that don't
          support this parameter and will be ignored in that case.

    Returns:
      An [`extension_metadata`](https://bazel.build/rules/lib/builtins/extension_metadata.html)
      object that, when returned from a module extension implementation function, specifies that all
      repositories generated by this extension should be imported via `use_repo`. If the current
      version of Bazel doesn't support `extension_metadata`, returns `None` instead, which can
      safely be returned from a module extension implementation function in all versions of Bazel.
    """

    # module_ctx.extension_metadata is available in Bazel 6.2.0 and later.
    # If not available, returning None from a module extension is equivalent to not returning
    # anything.
    extension_metadata = getattr(module_ctx, "extension_metadata", None)
    if not extension_metadata:
        return None

    # module_ctx.root_module_has_non_dev_dependency is available in Bazel 6.3.0 and later.
    root_module_has_non_dev_dependency = getattr(
        module_ctx,
        "root_module_has_non_dev_dependency",
        None,
    )
    if root_module_has_non_dev_dependency == None:
        return None

    # module_ctx.extension_metadata has the paramater `reproducible` as of Bazel 7.1.0. We can't
    # test for it directly and would ideally use bazel_features to check for it, but adding a
    # dependency on it would require complicating the WORKSPACE setup for skylib. Thus, test for
    # it by checking the availability of another feature introduced in 7.1.0.
    extension_metadata_kwargs = {}
    if hasattr(module_ctx, "watch"):
        extension_metadata_kwargs["reproducible"] = reproducible

    return extension_metadata(
        root_module_direct_deps = "all" if root_module_has_non_dev_dependency else [],
        root_module_direct_dev_deps = [] if root_module_has_non_dev_dependency else "all",
        **extension_metadata_kwargs
    )

_repo_attr = (
    "repo_name" if hasattr(Label("//:all"), "repo_name") else "workspace_name"
)

def _apparent_repo_name(label_or_name):
    """Return a repository's apparent repository name.

    Args:
        label_or_name: a Label or repository name string

    Returns:
        The apparent repository name
    """
    repo_name = getattr(label_or_name, _repo_attr, label_or_name).lstrip("@")
    delimiter_indices = []

    # Bazed on this pattern from the Bazel source:
    # com.google.devtools.build.lib.cmdline.RepositoryName.VALID_REPO_NAME
    for i in range(len(repo_name)):
        c = repo_name[i]
        if not (c.isalnum() or c in "_-."):
            delimiter_indices.append(i)

    if len(delimiter_indices) == 0:
        # Already an apparent repo name, apparently.
        return repo_name

    if len(delimiter_indices) == 1:
        # The name is for a top level module, possibly containing a version ID.
        return repo_name[:delimiter_indices[0]]

    return repo_name[delimiter_indices[-1] + 1:]

modules = struct(
    as_extension = _as_extension,
    use_all_repos = _use_all_repos,
    apparent_repo_name = _apparent_repo_name,
)
