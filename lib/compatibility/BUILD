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

# We create custom incompatible constraints here instead of using the more
# general @platforms//:incompatible constraint. We do this because we cannot
# compose multiple select() statements that point at the same constraint. Bazel
# complains about duplicated labels in the "target_compatible_with" attribute.
#
# For example, the following select() statements may cause bazel to error out.
#
#   foo_binary(
#       name = "bin",
#       target_compatible_with = select({
#           "//some:config1": ["@platforms//:incompatible"],
#           "//conditions:default": [],
#       }) + select({
#           "//some:config2": [],
#           "//conditions:default": ["@platforms//:incompatible"],
#       }),
#   )
#
# The above can be read as "If //some:config1 is true or //some:config2 is
# false, then "bin" is incompatible". If both select() statements evaluate to
# @platforms//:incompatible, however, then bazel will error out and complain
# about duplicated labels.

constraint_value(
    name = "incompatible_in_none_of",
    constraint_setting = "@platforms//:incompatible_setting",
)

constraint_value(
    name = "incompatible_in_any_of",
    constraint_setting = "@platforms//:incompatible_setting",
)

[constraint_value(
    name = "incompatible_in_all_of_" + str(i),
    constraint_setting = "@platforms//:incompatible_setting",
) for i in range(MAX_NUM_ALL_OF_SETTINGS)]
