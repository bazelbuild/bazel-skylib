load("@bazel_skylib//:version.bzl", "version")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_pkg//releasing:defs.bzl", "print_rel_notes")

package(
    default_visibility = ["//visibility:private"],
)

pkg_tar(
    name = "srcs",
    srcs = ["//:distribution"],
    mode = "0444",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    package_dir = "",
    strip_prefix = ".",
)

pkg_tar(
    name = "bins",
    srcs = ["//:bins"],
    mode = "0555",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    package_dir = "",
    strip_prefix = ".",
)

# Build the artifact to put on the github release page.
pkg_tar(
    name = "bazel-skylib-%s" % version,
    extension = "tar.gz",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    strip_prefix = ".",
    deps = [
        ":bins.tar",
        ":srcs.tar",
    ],
)

print_rel_notes(
    name = "relnotes",
    outs = ["relnotes.txt"],
    deps_method = "bazel_skylib_workspace",
    repo = "bazel-skylib",
    setup_file = ":workspace.bzl",
    version = version,
)
