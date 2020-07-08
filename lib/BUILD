load("//:bzl_library.bzl", "bzl_library")
load("@rules_cc//cc:defs.bzl", "cc_binary")

package(
    default_applicable_licenses = ["//:license"],
    default_visibility = ["//visibility:public"],
)

licenses(["notice"])

# export bzl files for the documentation
exports_files(
    glob(["*.bzl"]),
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "collections",
    srcs = ["collections.bzl"],
)

bzl_library(
    name = "dicts",
    srcs = ["dicts.bzl"],
)

bzl_library(
    name = "modules",
    srcs = ["modules.bzl"],
)

bzl_library(
    name = "partial",
    srcs = ["partial.bzl"],
)

bzl_library(
    name = "paths",
    srcs = ["paths.bzl"],
)

bzl_library(
    name = "selects",
    srcs = ["selects.bzl"],
)

bzl_library(
    name = "sets",
    srcs = ["sets.bzl"],
    deps = [
        ":new_sets",
    ],
)

bzl_library(
    name = "new_sets",
    srcs = ["new_sets.bzl"],
    deps = [
        ":dicts",
    ],
)

bzl_library(
    name = "shell",
    srcs = ["shell.bzl"],
)

bzl_library(
    name = "structs",
    srcs = ["structs.bzl"],
)

bzl_library(
    name = "subpackages",
    srcs = ["subpackages.bzl"],
)

bzl_library(
    name = "types",
    srcs = ["types.bzl"],
)

bzl_library(
    name = "unittest",
    srcs = ["unittest.bzl"],
    deps = [
        ":new_sets",
        ":partial",
        ":sets",
        ":types",
    ],
)

bzl_library(
    name = "versions",
    srcs = ["versions.bzl"],
)

filegroup(
    name = "test_deps",
    testonly = True,
    srcs = ["BUILD"] + glob(["*.bzl"]),
    visibility = ["//:__subpackages__"],  # Needs skylib's root BUILD file for default_applicable_licenses
)

# The files needed for distribution
filegroup(
    name = "distribution",
    srcs = glob(["**"]),
    visibility = [
        "//:__pkg__",
        "//distribution:__pkg__",
    ],
)

bzl_library(
    name = "old_sets",
    srcs = ["old_sets.bzl"],
)

cc_binary(
    name = "process_wrapper",
    srcs = [
        "process_wrapper/process_wrapper.cc",
        "process_wrapper/system.h",
        "process_wrapper/utils.h",
        "process_wrapper/utils.cc",
    ] + select({
        "@bazel_tools//src/conditions:host_windows": [
            "process_wrapper/system_windows.cc",
        ],
        "//conditions:default": [
            "process_wrapper/system_posix.cc",
        ],
    }),
    defines = [] + select({
        "@bazel_tools//src/conditions:host_windows": [
            "UNICODE",
            "_UNICODE",
        ],
        "//conditions:default": [],
    }),
    visibility = ["//visibility:public"],
)
