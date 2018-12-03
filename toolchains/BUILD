load(":bazel_skylib_toolchain.bzl", "bazel_skylib_toolchain")

toolchain_type(
    name = "toolchain_type",
)

bazel_skylib_toolchain(
    name = "exec_windows",
    is_exec_windows = True,
    visibility = ["//visibility:public"],
)

bazel_skylib_toolchain(
    name = "exec_default",
    is_exec_windows = False,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "bazel_skylib_windows_toolchain",
    exec_compatible_with = [
        "@bazel_tools//platforms:windows",
    ],
    toolchain = "@bazel_skylib//toolchains:exec_windows",
    toolchain_type = "@bazel_skylib//toolchains:toolchain_type",
)

toolchain(
    name = "bazel_skylib_default_toolchain",
    toolchain = "@bazel_skylib//toolchains:exec_default",
    toolchain_type = "@bazel_skylib//toolchains:toolchain_type",
)
