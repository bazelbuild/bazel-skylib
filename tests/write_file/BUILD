load("//rules:write_file.bzl", "write_file", "write_xfile")

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
# executable, asserting that write_xfile makes the output executable.
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

write_xfile(
    name = "write_empty_bin",
    out = "out/empty.sh",
)

write_xfile(
    name = "write_nonempty_bin",
    out = "out/nonempty.sh",
    content = [
        "#!/bin/bash",
        "echo potato",
    ],
)
