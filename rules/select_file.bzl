def _impl(ctx):
    if ctx.attr.subpath and len(ctx.attr.subpath) == 0:
        fail("Subpath can not be empty.")

    out = None
    canonical = ctx.attr.subpath.replace("\\", "/")
    for file_ in ctx.attr.srcs.files.to_list():
        if file_.path.replace("\\", "/").endswith(canonical):
            out = file_
            break
    if not out:
        fail("Can not find specified file in '%s'" % str(ctx.attr.srcs))
    print("Selected: " + str(out))
    return [DefaultInfo(files = depset([out]))]

select_file = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label(allow_files = True),
        "subpath": attr.string(),
    },
)
