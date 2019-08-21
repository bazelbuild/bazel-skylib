workspace(name = "bazel_skylib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

http_archive(
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/archive/130c84ec6d60f31b711400e8445a8d0d4a2b5de8.zip",
    sha256 = "9d4fdf7cc533af0b50f7dd8e58bea85df3b4454b7ae00056d7090eb98e3515cc",
    strip_prefix = "bazel-federation-130c84ec6d60f31b711400e8445a8d0d4a2b5de8",
    type = "zip",
)

load("@bazel_federation//:repositories.bzl", "bazel_skylib_deps")

bazel_skylib_deps()

load("@bazel_federation//setup:bazel_skylib.bzl", "bazel_skylib_setup")

bazel_skylib_setup()

# Below this line is for documentation generation only,
# and should thus not be included by dependencies on
# bazel-skylib.

maybe(
    http_archive,
    name = "io_bazel_skydoc",
    url = "https://github.com/bazelbuild/skydoc/archive/0.3.0.tar.gz",
    sha256 = "c2d66a0cc7e25d857e480409a8004fdf09072a1bd564d6824441ab2f96448eea",
    strip_prefix = "skydoc-0.3.0",
)
load("//:internal_deps.bzl", "bazel_skylib_internal_deps")
bazel_skylib_internal_deps()

load("//:internal_setup.bzl", "bazel_skylib_internal_setup")
bazel_skylib_internal_setup()

# Dependencies for packaging and redistribution.

maybe(
    http_archive,
    name = "rules_pkg",
    url = "https://github.com/bazelbuild/rules_pkg/releases/download/0.2.0/rules_pkg-0.2.0.tar.gz",
    sha256 = "5bdc04987af79bd27bc5b00fe30f59a858f77ffa0bd2d8143d5b31ad8b1bd71c",
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()
