"""Rules for generating skylark documentation"""

load(":skylark_library.bzl", "SkylarkLibraryInfo")

def _skydoc_impl(ctx):
    """Implementation of the skydoc rule."""
    out_file = ctx.outputs.out
    input_files = depset(order = "postorder", direct = [ctx.files.target_file[0]], transitive = [
        dep[SkylarkLibraryInfo].transitive_srcs
        for dep in ctx.attr.deps
    ])
    args = [
        str(ctx.files.target_file[0].owner),
        ctx.outputs.out.path,
    ] + ctx.attr.rule_names
    skydoc = ctx.executable.skydoc

    ctx.actions.run(
        outputs = [out_file],
        inputs = input_files,
        executable = skydoc,
        arguments = args,
        mnemonic = "Skydoc",
        progress_message = ("Generating Skylark doc for %s" %
                            (ctx.label.name)),
    )

skydoc = rule(
    _skydoc_impl,
    doc = """
Generates documentation for exported skylark rule definitions in a target skylark file.
""",
    attrs = {
        "target_file": attr.label(
            doc = "The skylark file to generate documentation for.",
            allow_files = [".bzl"],
        ),
        "deps": attr.label_list(
            doc = "A list of skylark_library dependencies which target_file depends on.",
            providers = [SkylarkLibraryInfo],
            allow_files = False,
        ),
        "out": attr.output(
            doc = "The file to which documentation will be output.",
            mandatory = True,
        ),
        "rule_names": attr.string_list(
            doc = """
A list of rule names to generate documentation for. These should correspond to
the names of exported symbols for rule definitions in the target file. If this list
is empty, then documentation for all exported rule definitions will be generated.
""",
            default = [],
        ),
        "skydoc": attr.label(
            doc = "The location of the skydoc tool.",
            allow_files = True,
            default = Label("@io_bazel//src/main/java/com/google/devtools/build/skydoc"),
            cfg = "host",
            executable = True,
        ),
    },
)

