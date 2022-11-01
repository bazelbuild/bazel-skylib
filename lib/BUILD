load("//:bzl_library.bzl", "bzl_library")
load("//rules:common_settings.bzl", "string_setting")

licenses(["notice"])

package(default_visibility = ["//visibility:public"])

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
)

# The files needed for distribution
filegroup(
    name = "distribution",
    srcs = glob(["*"]),
    visibility = [
        "//:__pkg__",
        "//distribution:__pkg__",
    ],
)

bzl_library(
    name = "old_sets",
    srcs = ["old_sets.bzl"],
)

# Define a hidden setting which no other modules can change.
# No references to this setting other than the two config_setting targets below
# should exist.
string_setting(
    name = "private_setting",
    build_setting_default = "constant",
    values = [
        "constant",
        "not_constant",
    ],
    visibility = ["//visibility:private"],
)

# Define a config setting that will always match, since nothing ever changes
# private_setting from its default value of "constant".
config_setting(
    name = "always_true",
    flag_values = {
        ":private_setting": "constant",
    },
)

# Define a config setting that will never match, since nothing ever changes
# private_setting from its default value of "constant".
config_setting(
    name = "always_false",
    flag_values = {
        ":private_setting": "not_constant",
    },
)
