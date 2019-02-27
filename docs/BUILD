load("@io_bazel_skydoc//stardoc:stardoc.bzl", "stardoc")

# Note that due to a bug in Bazel 0.22.0, these targets cannot be built without
# the --experimental_remap_main_repo flag.
stardoc(
    name = "build_test_docs",
    input = "//rules:build_test.bzl",
    out = "build_test_doc_gen.md",
    deps = ["//rules:build_test"],
)

stardoc(
    name = "analysis_test_docs",
    input = "//rules:analysis_test.bzl",
    out = "analysis_test_doc_gen.md",
)

stardoc(
    name = "collections_docs",
    input = "//lib:collections.bzl",
    out = "collections_doc_gen.md",
    deps = ["//lib:collections"],
)

stardoc(
    name = "dicts_docs",
    input = "//lib:dicts.bzl",
    out = "dicts_doc_gen.md",
    deps = ["//lib:dicts"],
)

stardoc(
    name = "partial_docs",
    input = "//lib:partial.bzl",
    out = "partial_doc_gen.md",
    deps = ["//lib:partial"],
)

stardoc(
    name = "paths_docs",
    input = "//lib:paths.bzl",
    out = "paths_doc_gen.md",
    deps = ["//lib:paths"],
)

stardoc(
    name = "selects_docs",
    input = "//lib:selects.bzl",
    out = "selects_doc_gen.md",
    deps = ["//lib:selects"],
)

stardoc(
    name = "new_sets_docs",
    input = "//lib:new_sets.bzl",
    out = "new_sets_doc_gen.md",
    deps = ["//lib:new_sets"],
)

stardoc(
    name = "shell_docs",
    input = "//lib:shell.bzl",
    out = "shell_doc_gen.md",
    deps = ["//lib:shell"],
)

stardoc(
    name = "structs_docs",
    input = "//lib:structs.bzl",
    out = "structs_doc_gen.md",
    deps = ["//lib:structs"],
)

stardoc(
    name = "types_docs",
    input = "//lib:types.bzl",
    out = "types_doc_gen.md",
    deps = ["//lib:types"],
)

stardoc(
    name = "unittest_docs",
    input = "//lib:unittest.bzl",
    out = "unittest_doc_gen.md",
    deps = ["//lib:unittest"],
)

stardoc(
    name = "versions_docs",
    input = "//lib:versions.bzl",
    out = "versions_doc_gen.md",
    deps = ["//lib:versions"],
)

stardoc(
    name = "maprule_docs",
    input = "//rules:maprule.bzl",
    out = "maprule_doc_gen.md",
    deps = ["//rules:maprule"],
)

