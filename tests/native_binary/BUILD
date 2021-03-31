load("//rules:copy_file.bzl", "copy_file")
load("//rules:native_binary.bzl", "native_binary", "native_test")
load("@rules_cc//cc:defs.bzl", "cc_binary")

package(
    default_testonly = 1,
    default_visibility = ["//visibility:private"],
)

cc_binary(
    name = "assertarg",
    srcs = ["assertarg.cc"],
)

cc_binary(
    name = "assertdata",
    srcs = ["assertdata.cc"],
    deps = ["@bazel_tools//tools/cpp/runfiles"],
    # Depends on the runfiles library but doesn't have data-dependencies, on
    # purpose. We supplement the runfiles in the native_binary / native_test
    # rule.
)

# A rule that copies "assertarg"'s output as an opaque executable, simulating a
# binary that's not built from source and needs to be wrapped in native_binary.
copy_file(
    name = "copy_assertarg_exe",
    src = ":assertarg",
    # On Windows we need the ".exe" extension.
    # On other platforms the extension doesn't matter.
    # Therefore we can use ".exe" on every platform.
    out = "assertarg_copy.exe",
    is_executable = True,
)

# A rule that copies "assertdata"'s output as an opaque executable, simulating a
# binary that's not built from source and needs to be wrapped in native_binary.
copy_file(
    name = "copy_assertdata_exe",
    src = ":assertdata",
    # On Windows we need the ".exe" extension.
    # On other platforms the extension doesn't matter.
    # Therefore we can use ".exe" on every platform.
    out = "assertdata_copy.exe",
    is_executable = True,
)

_ARGS = [
    "'a b'",
    "c\\ d",
    "$(location testdata.txt) $$(location testdata.txt) $(location testdata.txt)",
    "'$(location testdata.txt) $$(location testdata.txt) $(location testdata.txt)'",
    "$$TEST_SRCDIR",

    # TODO(laszlocsomor): uncomment this (and its counterpart in assertarg.cc)
    # after https://github.com/bazelbuild/bazel/issues/6622 is resolved and the
    # Bash-less test wrapper is the default on Windows.
    # "$${TEST_SRCDIR}",
]

native_binary(
    name = "args_bin",
    src = ":copy_assertarg_exe",
    # On Windows we need the ".exe" extension.
    # On other platforms the extension doesn't matter.
    # Therefore we can use ".exe" on every platform.
    out = "args_bin.exe",
    args = _ARGS,
    # We only need the data-dependency for $(location) expansion.
    data = ["testdata.txt"],
)

native_test(
    name = "args_test",
    src = ":copy_assertarg_exe",
    # On Windows we need the ".exe" extension.
    # On other platforms the extension doesn't matter.
    # Therefore we can use ".exe" on every platform.
    out = "args_test.exe",
    args = _ARGS,
    # We only need the data-dependency for $(location) expansion.
    data = ["testdata.txt"],
)

native_binary(
    name = "data_bin",
    src = ":copy_assertdata_exe",
    # On Windows we need the ".exe" extension.
    # On other platforms the extension doesn't matter.
    # Therefore we can use ".exe" on every platform.
    out = "data_bin.exe",
    data = ["testdata.txt"],
)

native_test(
    name = "data_test",
    src = ":copy_assertdata_exe",
    # On Windows we need the ".exe" extension.
    # On other platforms the extension doesn't matter.
    # Therefore we can use ".exe" on every platform.
    out = "data_test.exe",
    data = ["testdata.txt"],
)
