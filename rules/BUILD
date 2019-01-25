load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

bzl_library(
    name = "build_test",
    srcs = ["build_test.bzl"],
    visibility = ["//visibility:public"],
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

# Exported for build_test.bzl to make sure of, it is an implementation detail
# of the rule and should not be directly used by anything else.
exports_files(["empty_test.sh"])
