load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

# export bzl files for the documentation
exports_files(
    glob(["*.bzl"]),
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "glob",
    srcs = ["glob.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "paths",
    srcs = ["paths.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//lib:paths",
    ],
)
