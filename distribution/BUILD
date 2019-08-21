package(
    default_visibility = ["//visibility:private"],
)

load("@bazel_skylib//:version.bzl", "version")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_pkg//releasing:defs.bzl", "print_rel_notes")

# Build the artifact to put on the github release page.
pkg_tar(
    name = "bazel-skylib-%s" % version,
    srcs = [
        "@bazel_skylib//:distribution",
    ],
    extension = "tar.gz",
    # It is all source code, so make it read-only.
    mode = "0444",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    package_dir = ".",
)

print_rel_notes(
    name = "relnotes",
    repo = "bazel-skylib",
    version = version,
    outs = ["relnotes.txt"],
)
