load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@bazel_skylib//rules/directory:directory.bzl", "directory")
load(":directory_test.bzl", "directory_test_suite")
load(":subdirectory_test.bzl", "subdirectory_test_suite")

directory(
    name = "root",
    srcs = glob(["testdata/**"]),
)

filegroup(
    name = "f1_filegroup",
    srcs = ["testdata/f1"],
)

filegroup(
    name = "f2_filegroup",
    srcs = ["testdata/subdir/f2"],
)

copy_file(
    name = "generated_file",
    src = "testdata/f1",
    out = "dir/generated",
)

directory_test_suite(
    name = "directory_tests",
)

subdirectory_test_suite(
    name = "subdirectory_tests",
)
