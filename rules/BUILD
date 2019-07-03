load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

package(default_visibility = ["//visibility:public"])

bzl_library(
    name = "build_test",
    srcs = ["build_test.bzl"],
    deps = ["//lib:new_sets"],
)

bzl_library(
    name = "copy_file",
    srcs = ["copy_file.bzl"],
    deps = ["//rules/private:copy_file_private"],
)

bzl_library(
    name = "write_file",
    srcs = ["write_file.bzl"],
    deps = ["//rules/private:write_file_private"],
)

bzl_library(
    name = "diff_test",
    srcs = ["diff_test.bzl"],
)

bzl_library(
    name = "native_binary",
    srcs = ["native_binary.bzl"],
    deps = ["//rules/private:copy_file_private"],
)

bzl_library(
    name = "run_binary",
    srcs = ["run_binary.bzl"],
    deps = ["//lib:dicts"],
)

bzl_library(
    name = "common_settings",
    srcs = ["common_settings.bzl"],
)

# Exported for build_test.bzl to make sure of, it is an implementation detail
# of the rule and should not be directly used by anything else.
exports_files(["empty_test.sh"])

filegroup(
    name = "test_deps",
    testonly = True,
    srcs = [
        "BUILD",
        "empty_test.sh",
    ] + glob(["*.bzl"]),
)
