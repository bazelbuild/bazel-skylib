load("//rules:select_file.bzl", "select_file")
load("//rules:diff_test.bzl", "diff_test")

licenses(["notice"])

filegroup(
    name = "fg",
    srcs = [
        "subdir/inner.txt",
        ":select_me.txt",
    ],
)

select_file(
    name = "select_me",
    srcs = ":fg",
    subpath = "select_me.txt",
)

select_file(
    name = "select_inner",
    srcs = ":fg",
    subpath = "subdir/inner.txt",
)

diff_test(
    name = "selected_me",
    file1 = ":select_me",
    file2 = ":select_me.txt",
)

diff_test(
    name = "selected_inner",
    file1 = ":select_inner",
    file2 = "subdir/inner.txt",
)
