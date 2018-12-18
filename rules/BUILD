load("//:bzl_library.bzl", "bzl_library")
load("@io_bazel_skydoc//stardoc:stardoc.bzl", "stardoc")

licenses(["notice"])

exports_files(["maprule.bzl"])

bzl_library(
    name = "maprule_lib",
    srcs = ["maprule.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//lib:dicts",
        "//lib:paths",
    ],
)

stardoc(
    name = "maprule-docs",
    out = "maprule_doc.md",
    input = "maprule.bzl",
    symbol_names = ["cmd_maprule", "bash_maprule"],
)
