load(":defs.bzl", "MAX_NUM_ALL_OF_SETTINGS")
load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

package(default_visibility = ["//visibility:public"])

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
)

filegroup(
    name = "build_file",
    testonly = True,
    srcs = ["BUILD"],
)

constraint_value(
    name = "none_of",
    constraint_setting = "@platforms//:incompatible_setting",
)

constraint_value(
    name = "any_of",
    constraint_setting = "@platforms//:incompatible_setting",
)

[constraint_value(
    name = "all_of_" + str(i),
    constraint_setting = "@platforms//:incompatible_setting",
) for i in range(MAX_NUM_ALL_OF_SETTINGS)]
