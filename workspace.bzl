def bazel_skylib_workspace(name = None):
    repo_name = ("@" + name) if name else ""
    native.register_toolchains(
        repo_name + "//toolchains:bazel_skylib_windows_toolchain",
        repo_name + "//toolchains:bazel_skylib_default_toolchain",
    )
