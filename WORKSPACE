workspace(name = "bazel_skylib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

http_archive(
    name = "rules_pkg",
    urls = [
        "https://github.com/bazelbuild/rules_pkg/releases/download/0.2.5/rules_pkg-0.2.5.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.2.5/rules_pkg-0.2.5.tar.gz",
    ],
    sha256 = "352c090cc3d3f9a6b4e676cf42a6047c16824959b438895a76c2989c6d7c246a",
)
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")
rules_pkg_dependencies()

maybe(
    name = "bazel_federation",
    repo_rule = http_archive,
    sha256 = "b10529fcf8a464591e845588348533981e948315b706183481e0d076afe2fa3c",
    url = "https://github.com/bazelbuild/bazel-federation/releases/download/0.0.2/bazel_federation-0.0.2.tar.gz",
)

load("@bazel_federation//:repositories.bzl", "bazel_skylib_deps", "rules_go")

bazel_skylib_deps()

rules_go()

load("@bazel_federation//setup:bazel_skylib.bzl", "bazel_skylib_setup")

bazel_skylib_setup()

load("@bazel_federation//setup:rules_go.bzl", "rules_go_setup")

rules_go_setup()

# Below this line is for documentation generation only,
# and should thus not be included by dependencies on
# bazel-skylib.

load("//:internal_deps.bzl", "bazel_skylib_internal_deps")

bazel_skylib_internal_deps()

load("//:internal_setup.bzl", "bazel_skylib_internal_setup")

bazel_skylib_internal_setup()

maybe(
    name = "rules_cc",
    repo_rule = http_archive,
    sha256 = "b4b2a2078bdb7b8328d843e8de07d7c13c80e6c89e86a09d6c4b424cfd1aaa19",
    strip_prefix = "rules_cc-cb2dfba6746bfa3c3705185981f3109f0ae1b893",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
        "https://github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
    ],
)

# Provide a repository hint for Gazelle to inform it that the go package
# github.com/bazelbuild/rules_go is available from io_bazel_rules_go and it
# doesn't need to duplicatively fetch it.
# gazelle:repository go_repository name=io_bazel_rules_go importpath=github.com/bazelbuild/rules_go
http_archive(
    name = "bazel_gazelle",
    sha256 = "bfd86b3cbe855d6c16c6fce60d76bd51f5c8dbc9cfcaef7a2bb5c1aafd0710e8",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.21.0/bazel-gazelle-v0.21.0.tar.gz",
        "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.21.0/bazel-gazelle-v0.21.0.tar.gz",
    ],
)
# Another Gazelle repository hint.
# gazelle:repository go_repository name=bazel_gazelle importpath=github.com/bazelbuild/bazel-gazelle/testtools

load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

gazelle_dependencies()
