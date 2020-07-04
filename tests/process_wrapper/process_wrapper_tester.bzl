def _impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".o")

    args = ctx.actions.args()

    #args.add("--expand_args", args_file)
    #args.add("--env_vars", env_file)
    args.add("--")
    args.add(ctx.executable._process_wrapper_tester.path)

    ctx.actions.run(
        executable = ctx.executable._process_wrapper,
        inputs = ctx.files.arg_files + ctx.files.env_files,
        outputs = [output],
        arguments = [args],
        tools = [ctx.executable._process_wrapper_tester],
    )
    return [DefaultInfo(files = depset([output]))]

process_wrapper_tester = rule(
    implementation = _impl,
    attrs = {
        "arg_files": attr.label_list(),
        "env_files": attr.label_list(),
        "output_to_stdout": attr.bool(default = False),
        "_process_wrapper_tester": attr.label(
            default = "//tests/process_wrapper:process_wrapper_tester",
            executable = True,
            cfg = "exec",
        ),
        "_process_wrapper": attr.label(
            default = "@bazel_skylib//lib/process_wrapper:process_wrapper",
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),
    },
)
