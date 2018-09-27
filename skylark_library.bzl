print(
    "WARNING: skylark_library.bzl is deprecated and will go away in the future, please" +
    " use bzl_library.bzl instead.",
)

load("//:bzl_library.bzl", "StarlarkLibraryInfo", "bzl_library")

# These are temporary forwarding macros to facilitate migration to
# the new names for these objects.
SkylarkLibraryInfo = StarlarkLibraryInfo

skylark_library = bzl_library
