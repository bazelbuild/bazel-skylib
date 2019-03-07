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
    # Use DefaultInfo.files from 'write_empty_text'.
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
