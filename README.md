# Skylib

[![Build status](https://badge.buildkite.com/921dc61e2d3a350ec40efb291914360c0bfa9b6196fa357420.svg?branch=main)](https://buildkite.com/bazel/bazel-skylib)

Skylib is a library of Starlark functions for manipulating collections, file paths,
and various other data types in the domain of Bazel build rules.

Each of the `.bzl` files in the `lib` directory defines a "module"&mdash;a
`struct` that contains a set of related functions and/or other symbols that can
be loaded as a single unit, for convenience.

Skylib also provides build rules under the `rules` directory.

## Getting Started

### `WORKSPACE` file

See the **WORKSPACE setup** section [for the current release](https://github.com/bazelbuild/bazel-skylib/releases).

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
* [new_sets](docs/new_sets_doc.md)
* [shell](docs/shell_doc.md)
* [structs](docs/structs_doc.md)
* [types](docs/types_doc.md)
* [unittest](docs/unittest_doc.md)
* [versions](docs/versions_doc.md)

## List of rules (in rules/)

* [analysis_test](docs/analysis_test_doc.md)
* [build_test](docs/build_test_doc.md)
* [copy_file](docs/copy_file_doc.md)
* [write_file](docs/write_file_doc.md)

## Writing a new module

The criteria for adding a new function or module to this repository are:

1. Is it widely needed? The new code must solve a problem that occurs often during the development of Bazel build rules. It is not sufficient that the new code is merely useful.  Candidate code should generally have been proven to be necessary across several projects, either because it provides indispensible common functionality, or because it requires a single standardized implementation.

1. Is its interface simpler than its implementation? A good abstraction provides a simple interface to a complex implementation, relieving the user from the burden of understanding. By contrast, a shallow abstraction provides little that the user could not easily have written out for themselves. If a function's doc comment is longer than its body, it's a good sign that the abstraction is too shallow.

1. Is its interface unimpeachable? Given the problem it tries to solve, does it have sufficient parameters or generality to address all reasonable cases, or does it make arbitrary policy choices that limit its usefulness? If the function is not general, it likely does not belong here. Conversely, if it is general thanks only to a bewildering number of parameters, it also does not belong here.

1. Is it efficient? Does it solve the problem using the asymptotically optimal algorithm, without using excessive looping, allocation, or other high constant factors? Starlark is an interpreted language with relatively expensive basic operations, and an approach that might make sense in C++ may not in Starlark.

If your new module meets all these criteria, then you should consider sending us a pull request. It is always better to discuss your plans before executing them.

Many of the declarations already in this repository do not meet this bar.


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

### Maintainer's guide

See the [maintaner's guide](docs/maintainers_guide.md) for instructions for
cutting a new release.
