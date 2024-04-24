load(":bzl_library_consumer.bzl", "bzl_library_consumer")
load("//:bzl_library.bzl", "bzl_library")
load("//rules:build_test.bzl", "build_test")

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

bzl_library_consumer(
    name = "consumer",
    target = ":c",
)

build_test(
    name = "test_bzl_library",
    targets = [":consumer"],
)
