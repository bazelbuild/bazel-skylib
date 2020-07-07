load("@rules_cc//cc:defs.bzl", "cc_binary")
load("//tests/process_wrapper:process_wrapper_tester.bzl", "process_wrapper_tester")
load("@bazel_skylib//rules:build_test.bzl", "build_test")

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
    name = "process_wrapper_tester_no_arg",
)

process_wrapper_tester(
    name = "process_wrapper_tester_stdout",
    capture_stdout = True,
)

process_wrapper_tester(
    name = "process_wrapper_tester_input_files",
    arg_files = [
        ":arg_files",
    ],
    env_files = [
        ":env_files",
    ],
)

process_wrapper_tester(
    name = "process_wrapper_tester_all_features",
    arg_files = [
        ":arg_files",
    ],
    capture_stdout = True,
    env_files = [
        ":env_files",
    ],
)

build_test(
      name = "my_build_test",
      targets = [
          ":process_wrapper_tester_no_arg",
      ],
  )