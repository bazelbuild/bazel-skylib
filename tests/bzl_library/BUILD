load("//:bzl_library.bzl", "bzl_library")
load("//rules:build_test.bzl", "build_test")

bzl_library(
    name = "a_bl",
    srcs = ["a.bzl"],
)

bzl_library(
    name = "b_bl",
    srcs = ["b.bzl"],
    deps = [":a_bl"],
)

filegroup(
    name = "a_fg",
    srcs = ["a.bzl"],
)

bzl_library(
    name = "b_fg",
    srcs = ["b.bzl"],
    deps = [":a_fg"],
)

build_test(
    name = "test_bzl_library",
    targets = [
        ":b_bl",
        ":b_fg",
    ],
)
