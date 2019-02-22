workspace(name = "bazel_skylib")

load(":workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Below this line is for documentation generation only,
# and should thus not be included by dependencies on
# bazel-skylib.

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
git_repository(
    name = "io_bazel_skydoc",
    remote = "https://github.com/bazelbuild/skydoc.git",
    tag = "0.2.0",
)
load("@io_bazel_skydoc//skylark:skylark.bzl", "skydoc_repositories")
skydoc_repositories()
