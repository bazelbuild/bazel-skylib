workspace(name = "bazel_skylib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

maybe(
    name = "io_bazel_rules_go",
    repo_rule = http_archive,
    sha256 = "2b1641428dff9018f9e85c0384f03ec6c10660d935b750e3fa1492a281a53b0f",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
        "https://github.com/bazelbuild/rules_go/releases/download/v0.29.0/rules_go-v0.29.0.zip",
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.1")

# Below this line is for documentation generation only,
# and should thus not be included by dependencies on
# bazel-skylib.

load("//:internal_deps.bzl", "bazel_skylib_internal_deps")

bazel_skylib_internal_deps()

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()

load("//:internal_setup.bzl", "bazel_skylib_internal_setup")

bazel_skylib_internal_setup()

load("//lib:unittest.bzl", "register_unittest_toolchains")

register_unittest_toolchains()

# Provide a repository hint for Gazelle to inform it that the go package
# github.com/bazelbuild/rules_go is available from io_bazel_rules_go and it
# doesn't need to duplicatively fetch it.
# gazelle:repository go_repository name=io_bazel_rules_go importpath=github.com/bazelbuild/rules_go
http_archive(
    name = "bazel_gazelle",
    sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
    ],
)
# Another Gazelle repository hint.
# gazelle:repository go_repository name=bazel_gazelle importpath=github.com/bazelbuild/bazel-gazelle/testtools

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()
