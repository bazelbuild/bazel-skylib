"""A rule that consumes a bzl_library target and asserts its providers are as expected."""

load("//:bzl_library.bzl", "StarlarkLibraryInfo")

def _bzl_library_consumer_impl(ctx):
    files = sorted([t.basename for t in ctx.attr.target.files.to_list()])
    if files != ["a.bzl", "b.bzl", "c.bzl"]:
        fail("unexpected filenames from DefaultInfo: ", files)
    files = sorted([t.basename for t in ctx.attr.target[StarlarkLibraryInfo].transitive_srcs.to_list()])
    if files != ["a.bzl", "b.bzl", "c.bzl"]:
        fail("unexpected filenames from StarlarkLibraryInfo: ", files)

bzl_library_consumer = rule(
    implementation = _bzl_library_consumer_impl,
    attrs = {
        "target": attr.label(
            providers = [[StarlarkLibraryInfo]],
        ),
    },
)
