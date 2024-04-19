load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load(
    ":directory_test.bzl",
    "directory_test",
    "outside_testdata_test",
)

analysis_test(
    name = "directory_test",
    impl = directory_test,
    targets = {
        "root": "//tests/directories/testdata:root",
        "f1": "//tests/directories/testdata:f1_filegroup",
        "f2": "//tests/directories/testdata:f2_filegroup",
        "f3": "//tests/directories/testdata:f3",
    },
)

filegroup(
    name = "outside_testdata",
    srcs = ["BUILD"],
    visibility = ["//tests/directories/testdata:__pkg__"],
)

analysis_test(
    name = "outside_testdata_test",
    expect_failure = True,
    impl = outside_testdata_test,
    target = "//tests/directories/testdata:outside_testdata",
)
