# This package aids testing the 'copy_file' rule.
#
# The package contains 4 copy_file rules:
# - 'copy_src' and 'copy_gen' copy a source file and a generated file
#   respectively
# - 'copy_xsrc' and 'copy_xgen' copy a source file and a generated file
#   respectively (both are shell scripts), and mark their output as executable
#
# The generated file is the output of the 'gen' genrule.
#
# The 'bin_src' and 'bin_gen' rules are sh_binary rules. They use the
# 'copy_xsrc' and 'copy_xgen' rules respectively. The sh_binary rule requires
# its source to be executable, so building these two rules successfully means
# that 'copy_file' managed to make its output executable.
#
# The 'run_executables' genrule runs the 'bin_src' and 'bin_gen' binaries,
# partly to ensure they can be run, and partly so we can observe their output
# and assert the contents in the 'copy_file_tests' test.
#
# The 'file_deps' filegroup depends on 'copy_src'. The filegroup rule uses the
# DefaultInfo.files field from its dependencies. When we data-depend on the
# filegroup from 'copy_file_tests', we transitively data-depend on the
# DefaultInfo.files of the 'copy_src' rule.
#
# The 'copy_file_tests' test is the actual integration test. It data-depends
# on:
# - the 'run_executables' rule, to get the outputs of 'bin_src' and 'bin_gen'
# - the 'file_deps' rule, and by nature of using a filegroup, we get the files
#   from the DefaultInfo.files of the 'copy_file' rule, and thereby assert that
#   that field contains the output file of the rule
# - the 'copy_nonempty_text' rule, and thereby on the DefaultInfo.runfiles field
#   of it, so we assert that that field contains the output file of the rule

load("//rules:copy_file.bzl", "copy_file")

package(default_testonly = 1)

sh_test(
    name = "copy_file_tests",
    srcs = ["copy_file_tests.sh"],
    data = [
        ":run_executables",
        # Use DefaultInfo.files from 'copy_src' (via 'file_deps').
        ":file_deps",
        # Use DefaultInfo.runfiles from 'copy_gen'.
        ":copy_gen",
        "//tests:unittest.bash",
    ],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

filegroup(
    name = "file_deps",
    # Use DefaultInfo.files from 'copy_src'.
    srcs = [
        ":copy_src",
    ],
)

# If 'run_executables' is built, then 'bin_gen' and 'bin_src' are
# executable, asserting that copy_file makes the output executable.
genrule(
    name = "run_executables",
    outs = [
        "xsrc-out.txt",
        "xgen-out.txt",
    ],
    cmd = ("$(location :bin_src) > $(location xsrc-out.txt) && " +
           "$(location :bin_gen) > $(location xgen-out.txt)"),
    output_to_bindir = 1,
    tools = [
        ":bin_gen",
        ":bin_src",
    ],
)

# If 'bin_src' is built, then 'copy_xsrc' made its output executable.
sh_binary(
    name = "bin_src",
    srcs = [":copy_xsrc"],
)

# If 'bin_gen' is built, then 'copy_xgen' made its output executable.
sh_binary(
    name = "bin_gen",
    srcs = [":copy_xgen"],
)

copy_file(
    name = "copy_src",
    src = "a.txt",
    out = "out/a-out.txt",
)

copy_file(
    name = "copy_gen",
    src = ":gen",
    out = "out/gen-out.txt",
)

copy_file(
    name = "copy_xsrc",
    src = "a.txt",
    out = "xout/a-out.sh",
    is_executable = True,
)

copy_file(
    name = "copy_xgen",
    src = ":gen",
    out = "xout/gen-out.sh",
    is_executable = True,
)

genrule(
    name = "gen",
    outs = ["b.txt"],
    cmd = "echo -e '#!/bin/bash\necho potato' > $@",
)
