# This package aids testing the 'maprule' rule.
#
# ATTENTION: As of 2019-03-20, maprule is not ready for public use.
# @laszlocsomor is planning incompatible changes to the rule.

load("//rules/private:maprule.bzl", "bash_maprule")

licenses(["notice"])

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
    add_env = {
        "TOOL": "$(location :mr_bash_tool)",
    },
    # TODO(laszlocsomor): add quotes around $MAPRULE_TOOL after
    # https://github.com/bazelbuild/bazel/issues/7454 is fixed.
    cmd = "$MAPRULE_TOOL",
    foreach_srcs = [
        "foo.txt",
        "b/bar.txt",
    ],
    outs_templates = {
        "OUT1": "{src}.out1",
        "OUT2": "out2/{src_name_noext}",
    },
    tools = [":mr_bash_tool"],
)

sh_binary(
    name = "mr_bash_tool",
    srcs = ["mr_bash_tool.sh"],
)
