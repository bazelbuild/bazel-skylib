Release 1.5.0

## What's Changed
* Expose int- and string-valued build settings as Make variables by @fmeum in https://github.com/bazelbuild/bazel-skylib/pull/440
* Modify actions in order not to need `toolchain` param  by @kotlaja in https://github.com/bazelbuild/bazel-skylib/pull/455
* versions: Don't fail on Bazel dev builds by @fmeum in https://github.com/bazelbuild/bazel-skylib/pull/463
* Add error for empty `bzl_library` by @keith in https://github.com/bazelbuild/bazel-skylib/pull/457
* Add `doc` param to `unittest.make` by @UebelAndre in https://github.com/bazelbuild/bazel-skylib/pull/464

## New Contributors
* @kotlaja made their first contribution in https://github.com/bazelbuild/bazel-skylib/pull/455
* @keith made their first contribution in https://github.com/bazelbuild/bazel-skylib/pull/457

**Full Changelog**: https://github.com/bazelbuild/bazel-skylib/compare/1.4.2...1.5.0


Release 1.4.2

Bugfix release: fixes `build_test` to respect `target_compatible_with` (#448)

**New Features**
-   `bzl_library` allows `.scl` files (new Starlark dialect loadable by Bazel at
    HEAD with `--experimental_enable_scl_dialect`)

**Contributors**
Alexandre Rostovtsev, UebelAndre, Vertexwahn, Xavier Bonaventura


Release 1.4.1

Bugfix release: fixes gazelle plugin failure with
`--incompatible_disallow_empty_glob` (#431) and (for released versions) with
`--incompatible_disable_starlark_host_transitions` (#433).

**Contributors**
Alexandre Rostovtsev, Chuck Grindel


Release 1.4.0

**New Features**
-   The Gazelle plugin is marked stable for general use (#400, #424)

**Other Notable Changes**
-   copy_file/copy_directory again allow sandboxing (#392)

**Contributors**
Alexandre Rostovtsev, Nick Gooding, Simon Stewart, Xùdōng Yáng


Release 1.3.0

**New Features**
-   Added `dicts.omit` and `dicts.pick` (#304)
-   Added `expand_template` rule (#330)
-   Added `subpackages` module (#348)
-   Added `copy_directory` rule (#366)
-   Added `bzlmod` support (#385)

**Incompatible Changes**
-   `native_binary` and `native_test` now use symlinks instead of copying, if
    the OS supports it (#340)
-   `native_binary` and `native_test` now build in target configuration instead
    of host configuration (#341)
-   `copy_file` no longer adds non-executables to `default_runfiles` (#326)

**Contributors**

Alex Eagle, Alexandre Rostovtsev, Barry McNamara, Derek Cormier, Fabian
Meumertzheim, Geoffrey Martin-Noble, hchsiao, Kevin Kres, nickgooding,
Vertexwahn, Vinh Tran


Release 1.2.1

Bugfix release: fixes build failure with --incompatible_disallow_empty_glob
(#359)

**Contributors**

Alexandre Rostovtsev, Ivo List


Release 1.2.0

**New Features**

-   The unittest toolchain has better support for special characters in failure
    messages (#320)
-   Use portable Bash shebangs for BSD compatibility (#329)
-   Add loadingtest - tests which evaluate during the loading phase (#347)
-   Add doc parameter to analysistest.make, allowing analysis tests to be
    documented in a Stardoc-friendly way (#343, #352)

**Contributors**

Alexandre Rostovtsev, Geoffrey Martin-Noble, Kevin Kress, Samuel Freilich,
UebelAndre, Yesudeep Mangalapilly


Release 1.1.1 (initially tagged as 1.1.0)

**New Features**

-   Gazelle: support relative imports (#271) and imports from `@bazel_tools`
    (#273)
-   Add partial.is_instance() (#276)
-   Allow unittest.suite() to accept partial calls of test rules (#276)
-   Allow specifying additional aspects to target under test in
    analysistest.make() (#299)
-   Add Windows support for build_test (#302)

**Incompatible Changes**

-   structs.to_dict() ignores deprecated to_json()/to_proto() methods (#295)

**Contributors**

aiuto, alandonovan, Alex Eagle, Alexandre Rostovtsev, Andrew Z Allen, c-parsons,
Christopher Sauer, Daniel Wagner-Hall, David Sanderson, dmaclach, Laurent Le
Brun, Mansur, Olek Wojnar, Philipp Wollermann, River, Samuel Giddins, Thaler
Benedek


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
    https://github.com/bazelbuild/proposals/blob/HEAD/designs/2018-11-09-config-setting-chaining.md.
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
