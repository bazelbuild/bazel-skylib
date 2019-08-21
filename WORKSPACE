workspace(name = "bazel_skylib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# register toolchains
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

# Below this line is for skylib development. It defines dependencies for
# packaging and redistribution and should thus not be included by
# repos that depend on bazel-skylib.

http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/130c84ec6d60f31b711400e8445a8d0d4a2b5de8.zip",
    sha256 = "9d4fdf7cc533af0b50f7dd8e58bea85df3b4454b7ae00056d7090eb98e3515cc",
    strip_prefix = "bazel-federation-130c84ec6d60f31b711400e8445a8d0d4a2b5de8",
    type = "zip",
)

load("//:internal_deps.bzl", "bazel_skylib_internal_deps")
bazel_skylib_internal_deps()

load("//:internal_setup.bzl", "bazel_skylib_internal_setup")
bazel_skylib_internal_setup()
