# This package aids testing the 'write_file' rule.
#
# The package contains 4 write_file rules:
# - 'write_empty_text' and 'write_empty_bin' write an empty text and an empty
#   executable file respectively
# - 'write_nonempty_text' and 'write_nonempty_bin' write a non-empty text and
#   a non-empty executable file (a shell script) respectively
#
# The 'bin_empty' and 'bin_nonempty' rules are sh_binary rules. They use
# the 'write_empty_bin' and 'write_nonempty_bin' rules respectively. The
# sh_binary rule requires its source to be executable, so building these two
# rules successfully means that 'write_file' managed to make its output
# executable.
#
# The 'run_executables' genrule runs the 'bin_empty' and 'bin_nonempty'
# binaries, partly to ensure they can be run, and partly so we can observe their
# output and assert the contents in the 'write_file_tests' test.
#
# The 'file_deps' filegroup depends on 'write_empty_text'. The filegroup rule
# uses the DefaultInfo.files field from its dependencies. When we data-depend on
# the filegroup from 'write_file_tests', we transitively data-depend on the
# DefaultInfo.files of the 'write_empty_text' rule.
#
# The 'write_file_tests' test is the actual integration test. It data-depends
# on:
# - the 'run_executables' rule, to get the outputs of 'bin_empty' and
#   'bin_nonempty'
# - the 'file_deps' rule, and by nature of using a filegroup, we get the files
#   from the DefaultInfo.files of the 'write_file' rule, and thereby assert that
#   that field contains the output file of the rule
# - the 'write_nonempty_text' rule, and thereby on the DefaultInfo.runfiles
#   field of it, so we assert that that field contains the output file of the
#   rule

load("//rules:diff_test.bzl", "diff_test")
load("//rules:write_file.bzl", "write_file")

licenses(["notice"])

package(default_testonly = 1)

sh_test(
    name = "write_file_tests",
    srcs = ["write_file_tests.sh"],
    data = [
        ":run_executables",
        # Use DefaultInfo.files from 'write_empty_text' (via 'file_deps').
        ":file_deps",
        # Use DefaultInfo.runfiles from 'write_nonempty_text'.
        ":write_nonempty_text",
        "//tests:unittest.bash",
    ],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

filegroup(
    name = "file_deps",
    # Use DefaultInfo.files from 'write_empty_text'.
    srcs = [":write_empty_text"],
)

# If 'run_executables' is built, then 'bin_nonempty' and 'bin_empty' are
# executable, asserting that write_file makes the output executable.
genrule(
    name = "run_executables",
    outs = [
        "empty-bin-out.txt",
        "nonempty-bin-out.txt",
    ],
    cmd = ("$(location :bin_empty) > $(location empty-bin-out.txt) && " +
           "$(location :bin_nonempty) > $(location nonempty-bin-out.txt)"),
    output_to_bindir = 1,
    tools = [
        ":bin_empty",
        ":bin_nonempty",
    ],
)

# If 'bin_empty' is built, then 'write_empty_bin' made its output executable.
sh_binary(
    name = "bin_empty",
    srcs = [":write_empty_bin"],
)

# If 'bin_nonempty' is built, then 'write_nonempty_bin' made its output
# executable.
sh_binary(
    name = "bin_nonempty",
    srcs = [":write_nonempty_bin"],
)

write_file(
    name = "write_empty_text",
    out = "out/empty.txt",
)

write_file(
    name = "write_nonempty_text",
    out = "out/nonempty.txt",
    content = [
        "aaa",
        "bbb",
    ],
)

write_file(
    name = "write_empty_bin",
    out = "out/empty.sh",
    is_executable = True,
)

write_file(
    name = "write_nonempty_bin",
    out = "out/nonempty.sh",
    content = [
        "#!/usr/bin/env bash",
        "echo potato",
    ],
    is_executable = True,
)

write_file(
    name = "newline_unix_actual",
    out = "out/newline_unix_actual.txt",
    content = [
        "ab",
        "cd",
        "ef",
    ],
    newline = "unix",
)

write_file(
    name = "newline_unix_exp",
    out = "out/newline_unix_exp.txt",
    content = ["ab\ncd\nef"],
)

diff_test(
    name = "unix_line_ending_test",
    file1 = ":newline_unix_actual",
    file2 = ":newline_unix_exp",
)

write_file(
    name = "newline_win_actual",
    out = "out/newline_win_actual.txt",
    content = [
        "ab",
        "cd",
        "ef",
    ],
    newline = "windows",
)

write_file(
    name = "newline_win_exp",
    out = "out/newline_win_exp.txt",
    content = ["ab\r\ncd\r\nef"],
)

diff_test(
    name = "win_line_ending_test",
    file1 = ":newline_win_actual",
    file2 = ":newline_win_exp",
)
