load(":collections_tests.bzl", "collections_test_suite")
load(":dicts_tests.bzl", "dicts_test_suite")
load(":maprule_tests.bzl", "maprule_test_suite")
load(":new_sets_tests.bzl", "new_sets_test_suite")
load(":partial_tests.bzl", "partial_test_suite")
load(":paths_tests.bzl", "paths_test_suite")
load(":selects_tests.bzl", "selects_test_suite")
load(":sets_tests.bzl", "sets_test_suite")
load(":shell_tests.bzl", "shell_test_suite")
load(":structs_tests.bzl", "structs_test_suite")
load(":types_tests.bzl", "types_test_suite")
load(":versions_tests.bzl", "versions_test_suite")
load("//:bzl_library.bzl", "bzl_library")

licenses(["notice"])

collections_test_suite()

dicts_test_suite()

maprule_test_suite()

partial_test_suite()

paths_test_suite()

selects_test_suite()

sets_test_suite()

new_sets_test_suite()

shell_test_suite()

structs_test_suite()

types_test_suite()

versions_test_suite()

bzl_library(
    name = "unittest_tests",
    srcs = [ "unittest_tests.bzl" ],
    deps = [ "//lib:unittest" ],
)

sh_test(
    name = "unittest_e2e_test",
    srcs = ["unittest_test.sh"],
    data = [
        ":unittest.bash",
        ":unittest_tests",
        "//toolchains/unittest:test_deps",
        "@bazel_tools//tools/bash/runfiles",
    ],
)
