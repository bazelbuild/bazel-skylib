load("@bazel_skylib//:workspace.bzl", "globals_repo")

def _globals_extension_impl(module_ctx):
    globals_repo()

globals_extension = module_extension(_globals_extension_impl)
