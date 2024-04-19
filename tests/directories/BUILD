load("@rules_testing//lib:analysis_test.bzl", "analysis_test")
load(
    ":directory_test.bzl",
    "directory_test",
    "nonexistent_subdirectory_test",
    "outside_testdata_test",
    "subdirectory_test",
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

analysis_test(
    name = "subdirectory_test",
    impl = subdirectory_test,
    targets = {
        "root": "//tests/directories/testdata:root",
        "dir": "//tests/directories/testdata:dir",
        "subdir": "//tests/directories/testdata:subdir",
        "f2": "//tests/directories/testdata:f2_filegroup",
    },
)

analysis_test(
    name = "nonexistent_subdirectory_test",
    expect_failure = True,
    impl = nonexistent_subdirectory_test,
    target = "//tests/directories/testdata:nonexistent_subdirectory",
)
