workspace(name = "bazel_skylib")

load(":workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Below this line is for documentation generation only,
# and should thus not be included by dependencies on
# bazel-skylib.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

maybe(
    http_archive,
    name = "io_bazel_skydoc",
    url = "https://github.com/bazelbuild/skydoc/archive/0.3.0.tar.gz",
    sha256 = "c2d66a0cc7e25d857e480409a8004fdf09072a1bd564d6824441ab2f96448eea",
    strip_prefix = "skydoc-0.3.0",
)

load("@io_bazel_skydoc//skylark:skylark.bzl", "skydoc_repositories")

skydoc_repositories()


# Dependencies for packaging and redistribution.

maybe(
    http_archive,
    name = "rules_pkg",
    url = "https://github.com/bazelbuild/rules_pkg/releases/download/0.2.0/rules_pkg-0.2.0.tar.gz",
    sha256 = "5bdc04987af79bd27bc5b00fe30f59a858f77ffa0bd2d8143d5b31ad8b1bd71c",
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()
