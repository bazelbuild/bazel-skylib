load("@bazel_federation//:repositories.bzl", "bazel", "bazel_stardoc")

def bazel_skylib_internal_deps():
    bazel()
    bazel_stardoc()

