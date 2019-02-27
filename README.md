# Skylib

[![Build status](https://badge.buildkite.com/921dc61e2d3a350ec40efb291914360c0bfa9b6196fa357420.svg)](https://buildkite.com/bazel/bazel-skylib)

Skylib is a standard library that provides functions useful for manipulating
collections, file paths, and other features that are useful when writing custom
build rules in Bazel.

> This library is currently under early development. Be aware that the APIs
> in these modules may change during this time.

Each of the `.bzl` files in the `lib` directory defines a "module"&mdash;a
`struct` that contains a set of related functions and/or other symbols that can
be loaded as a single unit, for convenience.

Skylib also provides build rules under the `rules` directory.

## Getting Started

### `WORKSPACE` file

Add the following to your `WORKSPACE` file to import the Skylib repository into
your workspace. Replace the version number in the `tag` attribute with the
version you wish to depend on:

```python
git_repository(
    name = "bazel_skylib",
    remote = "https://github.com/bazelbuild/bazel-skylib.git",
    tag = "0.1.0",  # change this to use a different release
)
```

If you want to use `lib/unittest.bzl` from Skylib versions released in or after
December 2018, then you also should add to the `WORKSPACE` file:

```python
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
```

### `BUILD` and `*.bzl` files

Then, in the `BUILD` and/or `*.bzl` files in your own workspace, you can load
the modules (listed [below](#list-of-modules)) and access the symbols by
dotting into those structs:

```python
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:shell.bzl", "shell")

p = paths.basename("foo.bar")
s = shell.quote(p)
```

## List of modules (in lib/)

* [collections](docs/collections_doc.md)
* [dicts](docs/dicts_doc.md)
* [partial](docs/partial_doc.md)
* [paths](docs/paths_doc.md)
* [selects](docs/selects_doc.md)
* [sets](lib/sets.bzl) - _deprecated_, use `new_sets`
* [new_sets](docs/new_sets.md)
* [shell](docs/shell_doc.md)
* [structs](docs/structs_doc.md)
* [types](docs/types_doc.md)
* [unittest](docs/unittest_doc.md)
* [versions](docs/versions_doc.md)

## List of rules (in rules/)

* [analysis_test](docs/analysis_test_doc.md)
* [build_test](docs/build_test_doc.md)
* [`cmd_maprule` and `bash_maprule`](docs/maprule_doc.md)

## Writing a new module

Steps to add a module to Skylib:

1. Create a new `.bzl` file in the `lib` directory.

1. Write the functions or other symbols (such as constants) in that file,
   defining them privately (prefixed by an underscore).

1. Create the exported module struct, mapping the public names of the symbols
   to their implementations. For example, if your module was named `things` and
   had a function named `manipulate`, your `things.bzl` file would look like
   this:

   ```python
   def _manipulate():
     ...

   things = struct(
       manipulate=_manipulate,
   )
   ```

1. Add unit tests for your module in the `tests` directory.

## `bzl_library`

The `bzl_library.bzl` rule can be used to aggregate a set of
Starlark files and its dependencies for use in test targets and
documentation generation.

## Troubleshooting

If you try to use `unittest` and you get the following error:

```
ERROR: While resolving toolchains for target //foo:bar: no matching toolchains found for types @bazel_skylib//toolchains:toolchain_type
ERROR: Analysis of target '//foo:bar' failed; build aborted: no matching toolchains found for types @bazel_skylib//toolchains:toolchain_type
```

then you probably forgot to load and call `bazel_skylib_workspace()` in your
`WORKSPACE` file.
