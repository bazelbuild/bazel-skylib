load("@bazel_gazelle//:def.bzl", "gazelle", "gazelle_binary")
load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_test")

# gazelle:exclude testdata

go_library(
    name = "bzl",
    srcs = ["gazelle.go"],
    importpath = "github.com/bazelbuild/bazel-skylib/gazelle",
    visibility = ["//visibility:public"],
    deps = [
        "@bazel_gazelle//config:go_default_library",
        "@bazel_gazelle//label:go_default_library",
        "@bazel_gazelle//language:go_default_library",
        "@bazel_gazelle//pathtools:go_default_library",
        "@bazel_gazelle//repo:go_default_library",
        "@bazel_gazelle//resolve:go_default_library",
        "@bazel_gazelle//rule:go_default_library",
        "@com_github_bazelbuild_buildtools//build:go_default_library",
    ],
)

go_test(
    name = "bzl_test",
    srcs = ["gazelle_test.go"],
    data = [
        ":gazelle-skylib",
    ] + glob(
        [
            "testdata/**",
        ],
        allow_empty = True,
    ),
    embed = [":bzl"],
    deps = [
        "@bazel_gazelle//testtools:go_default_library",
        "@io_bazel_rules_go//go/tools/bazel:go_default_library",
    ],
)

# This gazelle binary is used exclusively for testing the gazelle language
# extension and thus only has the skylib language installed.
gazelle_binary(
    name = "gazelle-skylib",
    languages = [":bzl"],
    visibility = [
        # Also make the binary available in the root of the repo for use, but
        # not externally.
        "//:__pkg__",
    ],
)

gazelle(
    name = "gazelle",
    gazelle = ":gazelle-skylib",
)

# TODO(arostovtsev): exclude everything below from distro tarball

# The files needed for distribution
# A fake testdata directory is created so that
# the build file has nothing missing, but we
# do not bloat the distribution tarball
filegroup(
    name = "distribution",
    srcs = glob(["*.go"]) + [
        "BUILD",
        ":fake-testdata",
    ],
    visibility = ["//visibility:public"],
)

genrule(
    name = "fake-testdata",
    outs = ["testdata"],
    cmd = "touch $@",
)
