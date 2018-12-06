load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

exports_files(["maprule.bzl"])

bzl_library(
    name = "maprule",
    srcs = ["maprule.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//lib:dicts",
        "//lib:paths",
    ],
)
