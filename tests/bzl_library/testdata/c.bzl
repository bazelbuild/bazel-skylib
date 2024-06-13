"""c.bzl, standin' on the shoulder of giants"""

load(":testdata/a.bzl", "A")
load(":testdata/b.bzl", "B")

C = A + B
