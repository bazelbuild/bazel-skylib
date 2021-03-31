Release 1.0.3

**Significant Changes**

-   Move Gazelle extension to //gazelle/bzl and change package name
-   Stop depending on rules_pkg through the federation. (#259)
-   copy_file: Add parameter to allow symlinks (#252)
-   Create Gazelle language for Starlark (#251)
-   Create a helper rule (`select_file`) for selecting a file from outputs of another rule (#233)


**Incompatible Changes**
-   Remove links to maprules (#213)
-   Remove old_sets.bzl (#231)
    It has been deprecated for a while, the code is not really compatible with Bazel depset-related changes.

**Contributors**
Andrew Z Allen, Bocete, Bor Kae Hwang, irengrig, Jay Conrod, Jonathan B Coe, Marc Plano-Lesay, Robbert van Ginkel, Thomas Van Lenten, Yannic


Release 1.0.0

**Incompatible Changes**

-   @bazel_skylib//:lib.bzl is removed. You now must specify specific modules
    via @bazel_skylib//lib:<file>.bzl.
-   maprule.bzl is removed.

**New Features**

-   Added types.is_set() to test whether an arbitrary object is a set as defined by sets.bzl.


Release 0.9.0

**New Features**

-   common_settings.bzl: Standard data types for user defined build
    configuration. Common scalar build settings for rules to use so they don't
    recreate them locally. This fulfills part of the SBC design doc:
    https://docs.google.com/document/d/1vc8v-kXjvgZOdQdnxPTaV0rrLxtP2XwnD2tAZlYJOqw/edit#bookmark=id.iiumwic0jphr
-   selects.bzl: Add config_setting_group for config_setting AND/OR-chaining
    Implements
    https://github.com/bazelbuild/proposals/blob/master/designs/2018-11-09-config-setting-chaining.md.
-   Make sets.bzl point to new_sets.bzl instead of old_sets.bzl. new_sets.bzl
    and old_sets.bzl should be removed in the following skylib release.

-   run_binary: runs an executable as an action

    -   This rule is an alternative for genrule(): it can run a binary with the
        desired arguments, environment, inputs, and outputs, as a single build
        action, without shelling out to Bash.
    -   Fixes https://github.com/bazelbuild/bazel-skylib/issues/149

-   New `native_binary()` and `native_test()` rules let you wrap a pre-built
    binary in a binary and test rule respectively.

    -   native_binary() wraps a pre-built binary or script in a *_binary rule
        interface. Rules like genrule can tool-depend on it, and it can be
        executed with "bazel run". This rule can also augment the binary with
        runfiles.
    -   native_test() is similar, but creates a testable rule instead of a
        binary rule.
    -   Fixes https://github.com/bazelbuild/bazel-skylib/issues/148

-   diff_test: test rule compares two files and passes if the files match.

    On Linux/macOS/non-Windows, the test compares files using 'diff'.

    On Windows, the test compares files using 'fc.exe'. This utility is
    available on all Windows versions I tried (Windows 2008 Server, Windows 2016
    Datacenter Core).

    See https://github.com/bazelbuild/bazel/issues/5508,
    https://github.com/bazelbuild/bazel/issues/4319

-   maprule: move functionality to maprule_util.bzl. maprule_util.bzl will
    benefit planned new rules (namely a genrule alternative).

**This release is tested with Bazel 0.28**
