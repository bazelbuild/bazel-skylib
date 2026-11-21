load("@bazel_skylib//:version.bzl", "version")
load("@rules_pkg//:mappings.bzl", "pkg_files", "strip_prefix")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("distribution.bzl", "remove_internal_only")

package(
    default_applicable_licenses = ["//:license"],
    default_visibility = ["//visibility:private"],
)

licenses(["notice"])

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

remove_internal_only(
    name = "distro_gazelle_module",
    src = "@bazel_skylib_gazelle_plugin//:MODULE.bazel",
    out = "gazelle/MODULE.bazel",
)

# @bazel_skylib_gazelle_plugin//:WORKSPACE refers to bazel-skylib in the parent
# directory. For distribution, use the minimal WORKSPACE.bzlmod instead.
pkg_files(
    name = "bazel-skylib-gazelle-plugin-workspace-files",
    srcs = [
        "gazelle/MODULE.bazel",
        "@bazel_skylib_gazelle_plugin//:WORKSPACE.bzlmod",
    ],
    renames = {
        "gazelle/MODULE.bazel": "MODULE.bazel",
        "@bazel_skylib_gazelle_plugin//:WORKSPACE.bzlmod": "WORKSPACE",
    },
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
        "bazel-skylib-gazelle-plugin-without-external-prefix",
        "bazel-skylib-gazelle-plugin-workspace-files",
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
