"""
Doc string
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def wrapped_http_archive(**kwargs):
    http_archive(
        **kwargs
    )
