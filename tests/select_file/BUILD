load("//rules:select_file.bzl", "select_file")

filegroup(
    name = "fg",
    srcs = [
        "subdir/inner.txt",
        ":select_me.txt",
    ],
)

select_file(
    name = "select_me",
    srcs = ":fg",
    subpath = "select_me.txt",
)

select_file(
    name = "select_inner",
    srcs = ":fg",
    subpath = "subdir/inner.txt",
)
