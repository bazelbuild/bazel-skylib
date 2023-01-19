load("@bazel_skylib//:version.bzl", "version")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_pkg//:mappings.bzl", "pkg_files", "strip_prefix")

package(
    default_visibility = ["//visibility:private"],
)

genrule(
    name = "distro_module_bazel",
    srcs = ["//:MODULE.bazel"],
    outs = ["MODULE.bazel"],
    cmd = "sed -e '/### INTERNAL ONLY/,$$d' $(location //:MODULE.bazel) >$@",
)

# Build the artifacts to put on the github release page.
pkg_tar(
    name = "bazel-skylib",
    srcs = [
        "distro_module_bazel",
        "//:distribution",
    ],
    out = "bazel-skylib-%s.tar.gz" % version,
    extension = "tar.gz",
    mode = "0644",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
    strip_prefix = strip_prefix.from_root(),
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
        ":bazel-skylib-gazelle-plugin-without-external-prefix",
        "//:LICENSE",
    ],
    out = "bazel-skylib-gazelle-plugin-%s.tar.gz" % version,
    extension = "tar.gz",
    mode = "0644",
    # Make it owned by root so it does not have the uid of the CI robot.
    owner = "0.0",
)

filegroup(
    name = "distribution",
    srcs = [
        "bazel-skylib",
        "bazel-skylib-gazelle-plugin",
    ],
)
