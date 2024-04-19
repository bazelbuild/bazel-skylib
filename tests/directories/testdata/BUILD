load("@rules_testing//lib:util.bzl", "util")
load("//rules:copy_file.bzl", "copy_file")
load("//rules/directories:directory.bzl", "directory")

package(default_visibility = ["//tests/directories:__pkg__"])

copy_file(
    name = "f3",
    src = "dir/subdir/f2",
    out = "newdir/f3",
)

directory(
    name = "root",
    srcs = glob(
        ["**"],
        exclude = ["BUILD"],
    ) + [":f3"],
)

util.helper_target(
    directory,
    name = "outside_testdata",
    srcs = glob(
        ["**"],
        exclude = ["BUILD"],
    ) + ["//tests/directories:outside_testdata"],
)

filegroup(
    name = "f1_filegroup",
    srcs = ["f1"],
)

filegroup(
    name = "f2_filegroup",
    srcs = ["dir/subdir/f2"],
)
