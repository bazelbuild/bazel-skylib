"""c.bzl, standin' on the shoulder of giants"""

load(":a.bzl", "A")
load(":b.bzl", "B")

C = A + B
