load("@bazel_skylib//:version.bzl", "version")
load("@rules_pkg//:mappings.bzl", "pkg_files", "strip_prefix")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("distribution.bzl", "remove_internal_only")

package(
    default_visibility = ["//visibility:private"],
)

remove_internal_only(
    name = "distro_workspace",
    src = "//:WORKSPACE",
    out = "WORKSPACE",
)

remove_internal_only(
    name = "distro_module_bazel",
    src = "//:MODULE.bazel",
    out = "MODULE.bazel",
)

# remove "distribution/" path prefix
pkg_files(
    name = "distro-files-without-prefix",
    srcs = [
        "distro_module_bazel",
        "distro_workspace",
    ],
    strip_prefix = strip_prefix.from_pkg(),
)

pkg_tar(
    name = "bazel-skylib",
    srcs = [
        "distro-files-without-prefix",
        "//:distribution",
    ],
    out = "bazel-skylib-%s.tar.gz" % version,
    extension = "tar.gz",
    mode = "0644",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    strip_prefix = strip_prefix.from_root(),
)

# @bazel_skylib_gazelle_plugin//:WORKSPACE refers to bazel-skylib in the parent
# directory. For distribution, use the minimal WORSKPACE.bzlmod instead.
pkg_files(
    name = "bazel-skylib-gazelle-plugin-distro_workspace",
    srcs = ["@bazel_skylib_gazelle_plugin//:WORKSPACE.bzlmod"],
    renames = {"@bazel_skylib_gazelle_plugin//:WORKSPACE.bzlmod": "WORKSPACE"},
)

pkg_files(
    name = "bazel-skylib-gazelle-plugin-without-external-prefix",
    srcs = [
        "@bazel_skylib_gazelle_plugin//:distribution",
        "@bazel_skylib_gazelle_plugin//bzl:distribution",
    ],
    strip_prefix = strip_prefix.from_root(),
)

pkg_tar(
    name = "bazel-skylib-gazelle-plugin",
    srcs = [
        "bazel-skylib-gazelle-plugin-distro_workspace",
        "bazel-skylib-gazelle-plugin-without-external-prefix",
        "//:LICENSE",
    ],
    out = "bazel-skylib-gazelle-plugin-%s.tar.gz" % version,
    extension = "tar.gz",
    mode = "0644",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
)

# Build the artifacts to put on the github release page.
filegroup(
    name = "distribution",
    srcs = [
        "bazel-skylib",
        "bazel-skylib-gazelle-plugin",
    ],
)
