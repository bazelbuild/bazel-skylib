"""Dependency registration helpers for repositories which need to load bazel-skylib."""

load("@bazel_skylib//lib:unittest.bzl", "register_unittest_toolchains")

def bazel_skylib_workspace():
    """Registers toolchains and declares repository dependencies of the bazel_skylib repository."""
    register_unittest_toolchains()
