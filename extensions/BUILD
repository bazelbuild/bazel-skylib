load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

package(default_visibility = ["//visibility:public"])

bzl_library(
    name = "module_version",
    srcs = ["module_version.bzl"],
)

# The files needed for distribution
filegroup(
    name = "distribution",
    srcs = glob(["*"]),
    visibility = [
        "//:__pkg__",
    ],
)
