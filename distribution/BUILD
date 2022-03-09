load("@bazel_skylib//:version.bzl", "version")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_pkg//releasing:defs.bzl", "print_rel_notes")

package(
    default_visibility = ["//visibility:private"],
)

# Build the artifact to put on the github release page.
pkg_tar(
    name = "bazel-skylib-%s" % version,
    srcs = ["//:distribution"],
    extension = "tar.gz",
    mode = "0644",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    strip_prefix = ".",
)

print_rel_notes(
    name = "relnotes",
    outs = ["relnotes.txt"],
    deps_method = "bazel_skylib_workspace",
    repo = "bazel-skylib",
    setup_file = ":workspace.bzl",
    version = version,
)
