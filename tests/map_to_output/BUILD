load("//rules:map_to_output.bzl", "map_to_output")

licenses(["notice"])

package(default_testonly = 1)

sh_test(
    name = "map_to_output_tests",
    srcs = ["map_to_output_tests.sh"],
    data = [
        ":a",
        "//tests:unittest.bash",
    ],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

map_to_output(
    name = "a",
    src = "foo/bar/a.txt",
)
