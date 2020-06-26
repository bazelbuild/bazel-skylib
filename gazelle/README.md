# Gazelle

Gazelle is a `BUILD` file generator for Bazel. This directory contains a
language extension for the Gazelle generator that allows it to automatically
parse valid `bzl_library` targets for all `.bzl` files in a repo in which it
runs. It will additionally include a `deps` entry tracking every `.bzl` that is
`load`ed into the primary file.

This can be used, for example, to generate
[`stardoc`](https://github.com/bazelbuild/stardoc) documentation for your
`.bzl` files, both simplify the task of and improve the quality of
documentation.

