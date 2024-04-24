"""Unit tests for bzl_library"""

load("//:bzl_library.bzl", "StarlarkLibraryInfo")
load("//lib:sets.bzl", "sets")
load("//lib:unittest.bzl", "analysistest", "asserts")

def _assert_same_files(env, expected_file_targets, actual_files):
    """Assertion that a list of expected file targets and an actual list or depset of files contain the same files"""
    expected_files = []
    for target in expected_file_targets:
        target_files = target[DefaultInfo].files.to_list()
        asserts.true(env, len(target_files) == 1, "expected_file_targets must contain only file targets")
        expected_files.append(target_files[0])
    if type(actual_files) == "depset":
        actual_files = actual_files.to_list()
    asserts.set_equals(env = env, expected = sets.make(expected_files), actual = sets.make(actual_files))

def _bzl_library_test_impl(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    _assert_same_files(env, ctx.attr.expected_srcs, target_under_test[StarlarkLibraryInfo].srcs)
    _assert_same_files(env, ctx.attr.expected_transitive_srcs, target_under_test[StarlarkLibraryInfo].transitive_srcs)
    _assert_same_files(env, ctx.attr.expected_transitive_srcs, target_under_test[DefaultInfo].files)
    return analysistest.end(env)

bzl_library_test = analysistest.make(
    impl = _bzl_library_test_impl,
    attrs = {
        "expected_srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "Expected direct srcs in target_under_test's providers",
        ),
        "expected_transitive_srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "Expected transitive srcs in target_under_test's providers",
        ),
    },
)
