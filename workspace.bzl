def bazel_skylib_workspace():
    native.register_toolchains(
        "//toolchains:bazel_skylib_windows_toolchain",
        "//toolchains:bazel_skylib_default_toolchain",
    )
