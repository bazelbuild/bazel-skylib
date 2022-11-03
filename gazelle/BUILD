load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

# The files needed for distribution
filegroup(
    name = "distribution",
    srcs = glob(
        ["*"],
        allow_empty = True,
    ),
    visibility = [
        "//:__pkg__",
    ],
)

bzl_library(
    name = "setup",
    srcs = ["setup.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "@bazel_gazelle//:deps",
        "@io_bazel_rules_go//go:deps",
    ],
)

bzl_library(
    name = "workspace",
    srcs = ["workspace.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "@bazel_skylib//:workspace",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
    ],
)
