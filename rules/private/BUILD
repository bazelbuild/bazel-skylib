load("//:bzl_library.bzl", "bzl_library")

package(default_applicable_licenses = ["//:license"])

licenses(["notice"])

bzl_library(
    name = "bzl_library",
    srcs = ["bzl_library.bzl"],
    visibility = [
        "//:__pkg__",
        "//docs:__pkg__",
    ],
)

exports_files(
    ["bzl_library.bzl"],
    visibility = ["//docs:__pkg__"],
)

bzl_library(
    name = "copy_common",
    srcs = ["copy_common.bzl"],
    visibility = ["//rules:__pkg__"],
)

bzl_library(
    name = "copy_directory_private",
    srcs = ["copy_directory_private.bzl"],
    visibility = ["//rules:__pkg__"],
    deps = [":copy_common"],
)

bzl_library(
    name = "copy_file_private",
    srcs = ["copy_file_private.bzl"],
    visibility = ["//rules:__pkg__"],
    deps = [":copy_common"],
)

bzl_library(
    name = "write_file_private",
    srcs = ["write_file_private.bzl"],
    visibility = ["//rules:__pkg__"],
)

bzl_library(
    name = "maprule_util",
    srcs = ["maprule_util.bzl"],
)

# The files needed for distribution
filegroup(
    name = "distribution",
    srcs = glob(["*"]),
    visibility = [
        "//:__subpackages__",
    ],
)
