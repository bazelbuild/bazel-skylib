#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Argument provided by reusable workflow caller, see
# https://github.com/bazel-contrib/.github/blob/d197a6427c5435ac22e56e33340dff912bc9334e/.github/workflows/release_ruleset.yaml#L72
VERSION=$1

bazel build //distribution:bazel-skylib
ARCHIVE="$(bazel cquery --output=files //distribution:bazel-skylib)"
SHA256SUM=$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')

bazel build //distribution:bazel-skylib-gazelle-plugin
ARCHIVE_GAZELLE_PLUGIN="$(bazel cquery --output=files //distribution:bazel-skylib-gazelle-plugin)"
SHA256SUM_GAZELLE_PLUGIN=$(shasum -a 256 "$ARCHIVE_GAZELLE_PLUGIN" | awk '{print $1}')

# Move the archives to the root so that they are discoverable for upload
mv "$ARCHIVE" .
mv "$ARCHIVE_GAZELLE_PLUGIN" .

cat << EOF
**MODULE.bazel setup**

\`\`\`starlark
bazel_dep(name = "bazel_skylib", version = "$VERSION")
\`\`\`

And for the Gazelle plugin:

\`\`\`starlark
bazel_dep(name = "bazel_skylib_gazelle_plugin", version = "$VERSION", dev_dependency = True)
\`\`\`

**WORKSPACE setup**

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "$SHA256SUM",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-$VERSION.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-$VERSION.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
\`\`\`

***Additional WORKSPACE setup for the Gazelle plugin***

\`\`\`starlark
http_archive(
    name = "bazel_skylib_gazelle_plugin",
    sha256 = "$SHA256SUM_GAZELLE_PLUGIN",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-gazelle-plugin-$VERSION.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/$VERSION/bazel-skylib-gazelle-plugin-$VERSION.tar.gz",
    ],
)

load("@bazel_skylib_gazelle_plugin//:workspace.bzl", "bazel_skylib_gazelle_plugin_workspace")

bazel_skylib_gazelle_plugin_workspace()

load("@bazel_skylib_gazelle_plugin//:setup.bzl", "bazel_skylib_gazelle_plugin_setup")

bazel_skylib_gazelle_plugin_setup()
\`\`\`
EOF
