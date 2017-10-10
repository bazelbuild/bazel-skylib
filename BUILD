licenses(["notice"])

exports_files([
    "LICENSE",
    "lib.bzl",
])

filegroup(
    name = "test_deps",
    srcs = [
        "BUILD",
        "//lib:test_deps",
    ] + glob(["*.bzl"]),
    test_only = True,
    visibility = ["//visibility:public"],
)
