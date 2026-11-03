"""Test file."""

load(":bar.bzl", "bar")

def foo():
    bar()
