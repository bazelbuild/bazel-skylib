load("//rules:diff_test.bzl", "diff_test")
load("//rules:select_files_by_extension.bzl", "select_files_by_extension")

package(
    default_applicable_licenses = ["//:license"],
    default_testonly = 1,
)

licenses(["notice"])

filegroup(
    name = "fg",
    srcs = [
        ":Foo.cpp",
        ":Foo.h",
    ],
)

select_files_by_extension(
    name = "select_cpp",
    srcs = ":fg",
    extensions = [".cpp"],
)

select_files_by_extension(
    name = "select_header",
    srcs = ":fg",
    extensions = [".h"],
)

diff_test(
    name = "selected_cpp",
    file1 = ":select_cpp",
    file2 = ":Foo.cpp",
)

diff_test(
    name = "selected_header",
    file1 = ":select_header",
    file2 = ":Foo.h",
)
