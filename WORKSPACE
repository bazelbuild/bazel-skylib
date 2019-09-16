workspace(name = "bazel_skylib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
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

load("//:internal_deps.bzl", "bazel_skylib_internal_deps")

bazel_skylib_internal_deps()

load("//:internal_setup.bzl", "bazel_skylib_internal_setup")

bazel_skylib_internal_setup()

http_archive(
    name = "rules_cc",
    sha256 = "b4b2a2078bdb7b8328d843e8de07d7c13c80e6c89e86a09d6c4b424cfd1aaa19",
    strip_prefix = "rules_cc-cb2dfba6746bfa3c3705185981f3109f0ae1b893",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
        "https://github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
    ],
)

