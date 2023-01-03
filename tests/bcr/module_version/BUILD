load("@test_version//:version.bzl", "VERSION")

# buildifier: disable=no-effect
VERSION == "1.2.3.4-alpha+meta" or fail("Unexpected version: %s" % VERSION)
