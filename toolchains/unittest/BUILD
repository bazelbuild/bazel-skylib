load("//lib:unittest.bzl", "TOOLCHAIN_TYPE", "unittest_toolchain")

toolchain_type(
    name = "toolchain_type",
)

unittest_toolchain(
    name = "exec_batch",
    failure_templ = "\n".join([
        "@echo off",
        "echo %s",
        "exit /b 1",
    ]),
    file_ext = ".bat",
    join_on = "\necho",
    success_templ = "@exit /b 0",
    visibility = ["//visibility:public"],
)

unittest_toolchain(
    name = "exec_bash",
    failure_templ = "\n".join([
        "#!/bin/sh",
        "cat <<'EOF'",
        "%s",
        "EOF",
        "exit 1",
    ]),
    file_ext = ".sh",
    join_on = "\n",
    success_templ = "\n".join([
        "#!/bin/sh",
        "exit 0",
    ]),
    visibility = ["//visibility:public"],
)

toolchain(
    name = "starlark_batch_toolchain",
    exec_compatible_with = [
        "@bazel_tools//platforms:windows",
    ],
    toolchain = ":exec_batch",
    toolchain_type = TOOLCHAIN_TYPE,
)

toolchain(
    name = "starlark_bash_toolchain",
    toolchain = ":exec_bash",
    toolchain_type = TOOLCHAIN_TYPE,
)
