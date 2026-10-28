"""Have deps on both"""

load("//:bar.bzl", "bar")
load("//:baz.bzl", "baz")

bar()
baz()
