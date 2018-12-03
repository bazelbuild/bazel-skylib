def bazel_skylib_workspace():
    native.register_toolchains(
        "@bazel_skylib//toolchains:bazel_skylib_windows_toolchain",
        "@bazel_skylib//toolchains:bazel_skylib_default_toolchain",
    )
