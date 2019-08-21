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
        "@bazel_skylib//:standard_package",
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

"""
py_test(
    name = "packaging_test",
    size = "large",
    srcs = [
        "packaging_test.py",
    ],
    data = [
        ":rules_pkg-%s.tar.gz" % version,
        "testdata/BUILD.tmpl",
    ],
    local = True,
    python_version = "PY3",
    tags = [
        "no_windows",
        "noci",
    ],
    deps = [
        ":util",
        "@bazel_tools//tools/python/runfiles",
    ],
)
"""
