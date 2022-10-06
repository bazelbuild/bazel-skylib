load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

def bazel_skylib_gazelle_plugin_setup():
    go_rules_dependencies()
    go_register_toolchains(version = "1.17.1")

    gazelle_dependencies()
