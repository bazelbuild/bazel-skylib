load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

# export bzl files for the documentation
exports_files(
    glob(["*.bzl"]),
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "directory",
    srcs = ["directory.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":providers",
        "//lib:paths",
    ],
)

bzl_library(
    name = "providers",
    srcs = ["providers.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//rules/directory/private:paths",
    ],
)

bzl_library(
    name = "subdirectory",
    srcs = ["subdirectory.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":providers",
    ],
)
