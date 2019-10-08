workspace(name = "bazel_skylib")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

maybe(
    repo_rule = http_archive,
    name = "bazel_federation",
    url = "https://github.com/bazelbuild/bazel-federation/releases/download/0.0.1/bazel_federation-0.0.1.tar.gz",
    sha256 = "506dfbfd74ade486ac077113f48d16835fdf6e343e1d4741552b450cfc2efb53",
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

maybe(
    repo_rule = http_archive,
    name = "rules_cc",
    sha256 = "b4b2a2078bdb7b8328d843e8de07d7c13c80e6c89e86a09d6c4b424cfd1aaa19",
    strip_prefix = "rules_cc-cb2dfba6746bfa3c3705185981f3109f0ae1b893",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
        "https://github.com/bazelbuild/rules_cc/archive/cb2dfba6746bfa3c3705185981f3109f0ae1b893.zip",
    ],
)
