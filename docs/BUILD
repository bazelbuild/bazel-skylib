load("//docs/private:stardoc_with_diff_test.bzl", "stardoc_with_diff_test", "update_docs")

licenses(["notice"])

stardoc_with_diff_test(
    bzl_library_target = "//rules:analysis_test",
    out_label = "//docs:analysis_test_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:build_test",
    out_label = "//docs:build_test_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:collections",
    out_label = "//docs:collections_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:common_settings",
    out_label = "//docs:common_settings_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:copy_file",
    out_label = "//docs:copy_file_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:dicts",
    out_label = "//docs:dicts_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:diff_test",
    out_label = "//docs:diff_test_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:expand_template",
    out_label = "//docs:expand_template_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:native_binary",
    out_label = "//docs:native_binary_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:new_sets",
    out_label = "//docs:new_sets_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:partial",
    out_label = "//docs:partial_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:paths",
    out_label = "//docs:paths_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:run_binary",
    out_label = "//docs:run_binary_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:selects",
    out_label = "//docs:selects_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:shell",
    out_label = "//docs:shell_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:structs",
    out_label = "//docs:structs_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:types",
    out_label = "//docs:types_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:unittest",
    out_label = "//docs:unittest_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//lib:versions",
    out_label = "//docs:versions_doc.md",
)

stardoc_with_diff_test(
    bzl_library_target = "//rules:write_file",
    out_label = "//docs:write_file_doc.md",
)

# update_docs must be at the bottom of the BUILD file
update_docs(
    name = "update",
    docs_folder = "docs",
)
