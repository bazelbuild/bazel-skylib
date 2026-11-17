<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A transition that applies the flags of the target platform again.

Bazel applies the [flags of a platform](https://bazel.build/reference/be/platforms-and-toolchains#platform_flags)
when a transition changes the target platform to it. Newer Bazel versions don't apply them again after a
transition that leaves the target platform unchanged, so such a transition can override flags set by the
platform. To apply the flags of the target platform after such a transition, compose it with
`reapply_platform_flags`:

```starlark
load("@bazel_skylib//rules:reapply_platform_flags.bzl", "reapply_platform_flags")

my_rule = rule(
    ...
    cfg = my_transition.and_then(reapply_platform_flags),
)
```

`reapply_platform_flags` changes the target platform to a platform without flags and back. It does nothing
with Bazel versions that don't support `transition.and_then`, which apply the flags of the target platform
after every transition.

