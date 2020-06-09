# Gazelle test cases

This directory contains a suite of test cases for the Skylark language plugin
for Gazelle.

Please note that there are no `BUILD` or `BUILD.bazel` files in subdirs, insted
there are `BUILD.in` and `BUILD.out` describing what the `BUILD` should look
like initially and what the `BUILD` file should look like after the run. These
names are special because they are not recognized by Bazel as a proper `BUILD`
file, and therefore are included in the data dependency by the recursive data
glob in `//gazelle:go_default_test`. If you would like to include any extremely
complicated tests that contain proper `BUILD` files you will need to manually
add them to the `//gazelle:go_default_test` target's `data` section.

## `simple`

Simple is a base test case that was used to validate the parser.

## `nobuildfiles`

A test just like `simple` that has no `BUILD` files at the beginning.

## `import`

Import is a test case that imports a `.bzl` from the same directory.

## `multidir`

Multidir is a test that has a `.bzl` that imports from a different dirrectory.

## `tests`

Using the skylib as an example, this test has `.bzl` files that end in
`_tests.bzl` which are `load`ed into `BUILD` files and never imported by
another repo.

## `private`

Using the skylib as an example, this test has `.bzl` files that live in a
directory called `private` which is used to indicate that they are repo private.
Note that this is distict from the expectations of go's `internal` where the
relative position in the hierarchy determines the visibility.

## `defaultvisibility`

If the package declares a `default_visibility` the generated `bzl_library`
should not set its own `visibility`.

## `external`

This test demonstrates that if you load from another repo, it is able to
generate a `deps` entry for the dependency.

## `empty`

Gazelle has the ability to remove old and unused targets. Test that.
