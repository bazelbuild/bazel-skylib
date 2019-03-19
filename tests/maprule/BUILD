# This package aids testing the 'maprule' rule.

load("//rules:maprule.bzl", "bash_maprule", "cmd_maprule")

package(default_testonly = 1)

sh_test(
    name = "maprule_tests",
    srcs = ["maprule_tests.sh"],
    data = [
        # Use DefaultInfo.files from 'mr_bash' (via 'file_deps').
        ":file_deps",
        "//tests:unittest.bash",
    ],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

filegroup(
    name = "file_deps",
    # Use DefaultInfo.files from 'mr_bash'.
    srcs = [":mr_bash"],
)

bash_maprule(
    name = "mr_bash",
    srcs = ["common.txt"],
    foreach_srcs = [
        "foo.txt",
        "b/bar.txt",
    ],
    outs_templates = {
        "OUT1": "{src}.out1",
        "OUT2": "out2/{src_name_noext}",
    },
    add_env = {
        "TOOL": "$(location :mr_bash_tool)",
    },
    tools = [":mr_bash_tool"],
    cmd = '"$MAPRULE_TOOL"',
)

sh_binary(
    name = "mr_bash_tool",
    srcs = ["mr_bash_tool.sh"],
)
