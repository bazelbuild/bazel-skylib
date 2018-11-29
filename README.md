# Skylib

[![Build Status](https://travis-ci.org/bazelbuild/bazel-skylib.svg?branch=master)](https://travis-ci.org/bazelbuild/bazel-skylib)
[![Build status](https://badge.buildkite.com/921dc61e2d3a350ec40efb291914360c0bfa9b6196fa357420.svg)](https://buildkite.com/bazel/bazel-skylib)

Skylib is a standard library that provides functions useful for manipulating
collections, file paths, and other features that are useful when writing custom
build rules in Bazel.

> This library is currently under early development. Be aware that the APIs
> in these modules may change during this time.

Each of the `.bzl` files in the `lib` directory defines a "module"&mdash;a
`struct` that contains a set of related functions and/or other symbols that can
be loaded as a single unit, for convenience.

## Getting Started

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

* [collections](lib/collections.bzl)
* [dicts](lib/dicts.bzl)
* [partial](lib/partial.bzl)
* [paths](lib/paths.bzl)
* [selects](lib/selects.bzl)
* [sets](lib/sets.bzl) - _deprecated_, use `new_sets`
* [new_sets](lib/new_sets.bzl)
* [shell](lib/shell.bzl)
* [structs](lib/structs.bzl)
* [types](lib/types.bzl)
* [unittest](lib/unittest.bzl)
* [versions](lib/versions.bzl)

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
