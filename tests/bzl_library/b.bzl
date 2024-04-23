"""b.bzl, which loads from a.bzl"""

load(":a.bzl", "A")
B = A + 70
