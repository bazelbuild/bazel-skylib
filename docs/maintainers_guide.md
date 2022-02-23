# Skylib Maintainer's Guide

## The Parts of Skylib

*   `bzl_library.bzl` - used by almost all rule sets, and thus requiring
    especial attention to maintaining backwards compatibility. Ideally, it ought
    to be moved out of Skylib and and into Bazel's bundled `@bazel_tools` repo
    (see https://github.com/bazelbuild/bazel-skylib/issues/127).
*   Test libraries - `rules/analysis_test.bzl`, `rules/build_test.bzl`,
    `lib/unittest.bzl`; these are under more active development than the rest of
    Skylib, because we want to provide rule authors with a good testing story.
    Ideally, these ought to be moved out of Skylib and evolved at a faster pace.
*   A kitchen sink of utility modules (everything else). Formerly, these
    features were piled on in a rather haphazard manner. For any new additions,
    we want to be more conservative: add a feature only if it is widely needed
    (or was already independently implemented in multiple rule sets), if the
    interface is unimpeachable, if level of abstraction is not shallow, and the
    implementation is efficient.

## PR Review Standards

Because Skylib is so widely used, breaking backwards compatibility can cause
widespread pain, and shouldn't be done lightly. Therefore:

1.  In the first place, avoid adding insufficiently thought out, insufficiently
    tested features which will later need to be replaced in a
    backwards-incompatible manner. See the criteria in README.md.
2.  Given a choice between breaking backwards compatibilty and keeping it, try
    to keep backwards compatibility. For example, if adding a new argument to a
    function, add it to the end of the argument list, so that existing callers'
    positional arguments continue to work.
3.  Keep Skylib out-of-the-box compatible with the current stable Bazel release
    (ideally - with two most recent stable releases).
    *   For example, when adding a new function which calls the new
        `native.foobar()` method which was introduced in the latest Bazel
        pre-release or is gated behind an `--incompatible` flag, use an `if
        hasattr(native, "foobar")` check to keep the rest of your module (which
        doesn't need `native.foobar()`) working even when `native.foobar()` is
        not available.

In addition, make sure that new code is documented and tested.

If a PR adds or changes any docstrings, check that Markdown docs in `docs`
directory are updated; if not, ask the PR author to run
`./docs/regenerate_docs.sh`. (See
https://github.com/bazelbuild/bazel-skylib/pull/321 for the proposal to automate
this.)

## Making a New Release

1.  Update CHANGELOG.md at the top. You may want to use the following template:

--------------------------------------------------------------------------------

Release $VERSION

**New Features**

-   Feature
-   Feature

**Incompatible Changes**

-   Change
-   Change

**Contributors**

Name 1, Name 2, Name 3 (alphabetically from `git log`)

--------------------------------------------------------------------------------

2.  Bump `version` in version.bzl to the new version.
3.  Ensure that the commits for steps 1 and 2 have been merged. All further
    steps must be performed on a single, known-good git commit.
4.  `bazel build //distribution:bazel-skylib-$VERSION.tar.gz`
5.  Copy the `bazel-skylib-$VERSION.tar.gz` tarball to the mirror (you'll need
    Bazel developer gcloud credentials; assuming you are a Bazel developer, you
    can obtain them via `gcloud init`):

```
gsutil cp bazel-bin/distro/bazel-skylib-$VERSION.tar.gz gs://bazel-mirror/github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-$VERSION.tar.gz
gsutil setmeta -h "Cache-Control: public, max-age=31536000" "gs://bazel-mirror/github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-$VERSION.tar.gz"
```

6.  Run `sha256sum bazel-bin/distro/bazel-skylib-$VERSION.tar.gz`; you'll need
    the checksum for the release notes.
7.  Draft a new release with a new tag named $VERSION in github. Attach
    `bazel-skylib-$VERSION.tar.gz` to the release. For the release notes, use
    the CHANGELOG.md entry plus the following template:

--------------------------------------------------------------------------------

**WORKSPACE setup**

```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "bazel_skylib",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-$VERSION.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-$VERSION.tar.gz",
    ],
    sha256 = "$SHA256SUM",
)
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()
```

**Using the rules**

See [the source](https://github.com/bazelbuild/bazel-skylib/tree/$VERSION).

--------------------------------------------------------------------------------