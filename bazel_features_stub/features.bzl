"""
This is a stub for [bazel_features](https://github.com/bazel-contrib/bazel_features) used for
testing and updating docs.
"""

bazel_features = struct(
    globals = struct(
        RunEnvironmentInfo = RunEnvironmentInfo,
    ),
    external_deps = struct(
        extension_metadata_has_reproducible = False,
    ),
)
