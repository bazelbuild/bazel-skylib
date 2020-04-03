load("//:bzl_library.bzl", "bzl_library")
load(":build_test_tests.bzl", "build_test_test_suite")
load(":collections_tests.bzl", "collections_test_suite")
load(":dicts_tests.bzl", "dicts_test_suite")
load(":new_sets_tests.bzl", "new_sets_test_suite")
load(":partial_tests.bzl", "partial_test_suite")
load(":paths_tests.bzl", "paths_test_suite")
load(":selects_tests.bzl", "selects_test_suite")
load(":shell_tests.bzl", "shell_args_test_gen", "shell_test_suite")
load(":structs_tests.bzl", "structs_test_suite")
load(":types_tests.bzl", "types_test_suite")
load(":unittest_tests.bzl", "unittest_passing_tests_suite")
load(":versions_tests.bzl", "versions_test_suite")

licenses(["notice"])

exports_files(
    ["unittest.bash"],
    visibility = ["//tests:__subpackages__"],
)

build_test_test_suite()

collections_test_suite()

dicts_test_suite()

new_sets_test_suite()

partial_test_suite()

paths_test_suite()

selects_test_suite()

shell_test_suite()

structs_test_suite()

types_test_suite()

unittest_passing_tests_suite()

versions_test_suite()

bzl_library(
    name = "unittest_tests_bzl",
    srcs = ["unittest_tests.bzl"],
    visibility = ["//visibility:private"],
    deps = ["//lib:unittest"],
)

sh_test(
    name = "unittest_e2e_test",
    srcs = ["unittest_test.sh"],
    data = [
        ":unittest.bash",
        ":unittest_tests_bzl",
        "//lib:dicts",
        "//lib:new_sets",
        "//lib:sets",
        "//lib:types",
        "//lib:unittest",
        "//toolchains/unittest:test_deps",
        "@bazel_tools//tools/bash/runfiles",
    ],
    tags = ["local"],
)

sh_test(
    name = "analysis_test_e2e_test",
    srcs = ["analysis_test_test.sh"],
    data = [
        ":unittest.bash",
        "//rules:analysis_test.bzl",
        "@bazel_tools//tools/bash/runfiles",
    ],
    tags = ["local"],
)

sh_test(
    name = "common_settings_e2e_test",
    srcs = ["common_settings_test.sh"],
    data = [
        ":unittest.bash",
        "//rules:common_settings.bzl",
        "@bazel_tools//tools/bash/runfiles",
    ],
    tags = ["local"],
)

shell_args_test_gen(
    name = "shell_spawn_e2e_test_src",
)

sh_test(
    name = "shell_spawn_e2e_test",
    srcs = [":shell_spawn_e2e_test_src"],
)
