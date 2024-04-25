load("//:bzl_library.bzl", "bzl_library")
load(":bzl_library_test.bzl", "bzl_library_test")

package(
    default_applicable_licenses = ["//:license"],
    default_testonly = 1,
)

licenses(["notice"])

filegroup(
    name = "a",
    srcs = ["testdata/a.bzl"],
)

bzl_library(
    name = "b",
    srcs = ["testdata/b.bzl"],
)

bzl_library(
    name = "c",
    srcs = ["testdata/c.bzl"],
    deps = [
        ":a",
        ":b",
    ],
)

bzl_library_test(
    name = "bzl_library_test",
    expected_srcs = ["testdata/c.bzl"],
    expected_transitive_srcs = [
        "testdata/a.bzl",
        "testdata/b.bzl",
        "testdata/c.bzl",
    ],
    target_under_test = ":c",
)
