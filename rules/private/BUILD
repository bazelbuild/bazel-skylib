load("//:bzl_library.bzl", "bzl_library")
load("//rules:common_settings.bzl", "string_list_setting")
load(":copy_common.bzl", "is_windows")

package(default_applicable_licenses = ["//:license"])

licenses(["notice"])

is_windows(
    name = "is_windows",
    applicable_licenses = [],  # no output artifacts
    visibility = ["//visibility:public"],
)

# The target platforms that //rules:reapply_platform_flags.bzl changes back to.
string_list_setting(
    name = "reapply_platform_flags_original_platforms",
    build_setting_default = [],
)

platform(name = "reapply_platform_flags_platform_without_flags")

bzl_library(
    name = "bzl_library",
    srcs = ["bzl_library.bzl"],
    visibility = [
        "//:__pkg__",
        "//docs:__pkg__",
    ],
)

exports_files(
    ["bzl_library.bzl"],
    visibility = ["//docs:__pkg__"],
)

bzl_library(
    name = "copy_common",
    srcs = ["copy_common.bzl"],
    visibility = ["//rules:__pkg__"],
)

bzl_library(
    name = "copy_directory_private",
    srcs = ["copy_directory_private.bzl"],
    visibility = ["//rules:__pkg__"],
    deps = [":copy_common"],
)

bzl_library(
    name = "copy_file_private",
    srcs = ["copy_file_private.bzl"],
    visibility = ["//rules:__pkg__"],
    deps = [":copy_common"],
)

bzl_library(
    name = "write_file_private",
    srcs = ["write_file_private.bzl"],
    visibility = ["//rules:__pkg__"],
)

bzl_library(
    name = "maprule_util",
    srcs = ["maprule_util.bzl"],
)

filegroup(
    name = "test_deps",
    testonly = True,
    srcs = [
        "BUILD",
    ] + glob(["*.bzl"]),
    visibility = [
        "//rules:__pkg__",
    ],
)

# The files needed for distribution
filegroup(
    name = "distribution",
    srcs = glob(["*"]),
    visibility = [
        "//:__subpackages__",
    ],
)
