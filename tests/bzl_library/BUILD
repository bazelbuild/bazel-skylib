load("//:bzl_library.bzl", "bzl_library")
load(":bzl_library_test.bzl", "bzl_library_test")

filegroup(
    name = "a",
    srcs = ["a.bzl"],
)

bzl_library(
    name = "b",
    srcs = ["b.bzl"],
)

bzl_library(
    name = "c",
    srcs = ["c.bzl"],
    deps = [
        ":a",
        ":b",
    ],
)

bzl_library_test(
    name = "bzl_library_test",
    expected_srcs = ["c.bzl"],
    expected_transitive_srcs = [
        "a.bzl",
        "b.bzl",
        "c.bzl",
    ],
    target_under_test = ":c",
)
