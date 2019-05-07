# This package aids testing the 'diff_test' rule.

load("//rules:diff_test.bzl", "diff_test")

licenses(["notice"])

package(default_testonly = 1)

sh_test(
    name = "diff_test_tests",
    srcs = ["diff_test_tests.sh"],
    data = [
        "//rules:diff_test",
        "//tests:unittest.bash",
    ],
    # Test marked local because it uses bazel.
    tags = ["local"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

diff_test(
    name = "same_src_src",
    file1 = "a.txt",
    file2 = "aa.txt",
)

diff_test(
    name = "same_src_gen",
    file1 = "a.txt",
    file2 = "a-gen.txt",
)

diff_test(
    name = "same_gen_gen",
    file1 = "a-gen.txt",
    file2 = "aa-gen.txt",
)

genrule(
    name = "gen",
    outs = [
        "a-gen.txt",
        "aa-gen.txt",
    ],
    cmd = "echo -n 'potato' > $(location a-gen.txt) && echo -n 'potato' > $(location aa-gen.txt)",
)
