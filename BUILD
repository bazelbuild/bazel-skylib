licenses(["notice"])  # Apache 2.0

package(default_visibility = ["//visibility:public"])

load("//:skylark_library.bzl", "skylark_library")

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
    ] + glob(["*.bzl"]),
)

skylark_library(
    name = "lib",
    srcs = ["lib.bzl"],
    deps = [
        "//lib:collections",
        "//lib:dicts",
        "//lib:partial",
        "//lib:paths",
        "//lib:selects",
        "//lib:sets",
        "//lib:shell",
        "//lib:structs",
        "//lib:unittest",
        "//lib:versions",
    ],
)

skylark_library(
    name = "skylark_library",
    srcs = ["skylark_library.bzl"],
)
