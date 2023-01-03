<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Module extension that exposes module versions as Starlark constants.

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


