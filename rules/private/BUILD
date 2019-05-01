load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

bzl_library(
    name = "copy_file_private",
    srcs = ["copy_file_private.bzl"],
    visibility = ["//rules:__pkg__"],
)

bzl_library(
    name = "write_file_private",
    srcs = ["write_file_private.bzl"],
    visibility = ["//rules:__pkg__"],
)

bzl_library(
    name = "maprule",
    srcs = ["maprule.bzl"],
    visibility = ["//tests:__pkg__"],
    deps = [":maprule_private"],
)

bzl_library(
    name = "maprule_private",
    srcs = ["maprule_private.bzl"],
    deps = [
        ":maprule_util",
        "//lib:dicts",
        "//lib:paths",
    ],
)

bzl_library(
    name = "maprule_util",
    srcs = ["maprule_util.bzl"],
)
