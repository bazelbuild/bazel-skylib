load("@rules_cc//cc:defs.bzl", "cc_binary")
load("//tests/process_wrapper:process_wrapper_tester.bzl", "process_wrapper_tester")

cc_binary(
    name = "process_wrapper_tester",
    srcs = [
        "process_wrapper_tester.cc",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "arg_files",
    srcs = [
        "test_files/arg_file1",
        "test_files/arg_file2",
    ],
)

filegroup(
    name = "env_files",
    srcs = [
        "test_files/env_file1",
        "test_files/env_file2",
    ],
)

process_wrapper_tester(
    name = "process_wrapper_tester_1",
    arg_files = [
        ":arg_files",
    ],
    env_files = [
        ":env_files",
    ],
)
