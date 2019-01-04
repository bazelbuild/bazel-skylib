load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

exports_files(
    ["maprule_testing.bzl"],
    visibility = ["//tests:__pkg__"],
)

bzl_library(
    name = "maprule",
    srcs = ["maprule.bzl"],
    visibility = ["//visibility:public"],
    deps = [":maprule_private"],
)

bzl_library(
    name = "maprule_private",
    srcs = ["maprule_private.bzl"],
    visibility = ["//visibility:private"],
    deps = [
        "//lib:dicts",
        "//lib:paths",
    ],
)
