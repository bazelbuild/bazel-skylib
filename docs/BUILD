load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

licenses(["notice"])

# Note that due to a bug in Bazel 0.22.0, these targets cannot be built without
# the --incompatible_remap_main_repo flag.
stardoc(
    name = "build_test_docs",
    out = "build_test_doc_gen.md",
    input = "//rules:build_test.bzl",
    deps = ["//rules:build_test"],
)

stardoc(
    name = "analysis_test_docs",
    out = "analysis_test_doc_gen.md",
    input = "//rules:analysis_test.bzl",
)

stardoc(
    name = "collections_docs",
    out = "collections_doc_gen.md",
    input = "//lib:collections.bzl",
    deps = ["//lib:collections"],
)

stardoc(
    name = "dicts_docs",
    out = "dicts_doc_gen.md",
    input = "//lib:dicts.bzl",
    deps = ["//lib:dicts"],
)

stardoc(
    name = "partial_docs",
    out = "partial_doc_gen.md",
    input = "//lib:partial.bzl",
    deps = ["//lib:partial"],
)

stardoc(
    name = "paths_docs",
    out = "paths_doc_gen.md",
    input = "//lib:paths.bzl",
    deps = ["//lib:paths"],
)

stardoc(
    name = "selects_docs",
    out = "selects_doc_gen.md",
    input = "//lib:selects.bzl",
    deps = ["//lib:selects"],
)

stardoc(
    name = "new_sets_docs",
    out = "new_sets_doc_gen.md",
    input = "//lib:new_sets.bzl",
    deps = ["//lib:new_sets"],
)

stardoc(
    name = "shell_docs",
    out = "shell_doc_gen.md",
    input = "//lib:shell.bzl",
    deps = ["//lib:shell"],
)

stardoc(
    name = "structs_docs",
    out = "structs_doc_gen.md",
    input = "//lib:structs.bzl",
    deps = ["//lib:structs"],
)

stardoc(
    name = "types_docs",
    out = "types_doc_gen.md",
    input = "//lib:types.bzl",
    deps = ["//lib:types"],
)

stardoc(
    name = "unittest_docs",
    out = "unittest_doc_gen.md",
    input = "//lib:unittest.bzl",
    deps = ["//lib:unittest"],
)

stardoc(
    name = "versions_docs",
    out = "versions_doc_gen.md",
    input = "//lib:versions.bzl",
    deps = ["//lib:versions"],
)

stardoc(
    name = "copy_file_docs",
    out = "copy_file_doc_gen.md",
    input = "//rules:copy_file.bzl",
    deps = ["//rules:copy_file"],
)

stardoc(
    name = "write_file_docs",
    out = "write_file_doc_gen.md",
    input = "//rules:write_file.bzl",
    deps = ["//rules:write_file"],
)

stardoc(
    name = "diff_test_docs",
    out = "diff_test_doc_gen.md",
    input = "//rules:diff_test.bzl",
    deps = ["//rules:diff_test"],
)

stardoc(
    name = "native_binary_docs",
    out = "native_binary_doc_gen.md",
    input = "//rules:native_binary.bzl",
    deps = ["//rules:native_binary"],
)

stardoc(
    name = "run_binary_docs",
    out = "run_binary_doc_gen.md",
    input = "//rules:run_binary.bzl",
    deps = ["//rules:run_binary"],
)

stardoc(
    name = "common_settings_docs",
    out = "common_settings_doc_gen.md",
    input = "//rules:common_settings.bzl",
    deps = ["//rules:common_settings"],
)
