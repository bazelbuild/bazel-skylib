licenses(["notice"])

package(default_visibility = ["//visibility:public"])

load("//:starlark_library.bzl", "starlark_library")

filegroup(
    name = "test_deps",
    testonly = True,
    srcs = ["BUILD"] + glob(["*.bzl"]),
)

starlark_library(
    name = "collections",
    srcs = ["collections.bzl"],
)

starlark_library(
    name = "dicts",
    srcs = ["dicts.bzl"],
)

starlark_library(
    name = "partial",
    srcs = ["partial.bzl"],
)

starlark_library(
    name = "paths",
    srcs = ["paths.bzl"],
)

starlark_library(
    name = "selects",
    srcs = ["selects.bzl"],
)

starlark_library(
    name = "sets",
    srcs = ["sets.bzl"],
)

starlark_library(
    name = "new_sets",
    srcs = ["new_sets.bzl"],
)

starlark_library(
    name = "shell",
    srcs = ["shell.bzl"],
)

starlark_library(
    name = "structs",
    srcs = ["structs.bzl"],
)

starlark_library(
    name = "types",
    srcs = ["types.bzl"],
)

starlark_library(
    name = "unittest",
    srcs = ["unittest.bzl"],
    deps = [":sets"],
)

starlark_library(
    name = "versions",
    srcs = ["versions.bzl"],
)
