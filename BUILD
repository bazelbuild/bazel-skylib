load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

exports_files([
    "LICENSE",
    "lib.bzl",
])

filegroup(
    name = "test_deps",
    testonly = True,
    srcs = [
        "BUILD",
        "//lib:test_deps",
        "//rules:test_deps",
        "//toolchains/unittest:test_deps",
    ] + glob(["*.bzl"]),
)

bzl_library(
    name = "lib",
    srcs = ["lib.bzl"],
    deprecation = (
        "lib.bzl will go away in the future, please directly depend on the" +
        " module(s) needed as it is more efficient."
    ),
    deps = [
        "//lib:collections",
        "//lib:dicts",
        "//lib:new_sets",
        "//lib:partial",
        "//lib:paths",
        "//lib:selects",
        "//lib:sets",
        "//lib:shell",
        "//lib:structs",
        "//lib:types",
        "//lib:unittest",
        "//lib:versions",
    ],
)

bzl_library(
    name = "bzl_library",
    srcs = ["bzl_library.bzl"],
)

# The files needed for distribution.
# TODO(aiuto): We should strip this from the release, but there is no
# capability now to generate BUILD.foo from BUILD and have it appear in the
# tarball as BUILD.
filegroup(
    name = "distribution",
    srcs = [
        "LICENSE",
        "BUILD",
        "CODEOWNERS",
        "CONTRIBUTORS",
        "//lib:distribution",
        "//rules:distribution",
        "//rules/private:distribution",
        "//toolchains/unittest:distribution",
    ] + glob(["*.bzl"]),
)

filegroup(
    name = "bins",
    srcs = [
        "//rules:bins",
    ],
)
