def _impl(ctx):
    args = ctx.actions.args()
    outputs = []
    combined = ctx.attr.test_config == "combined"
    
    if combined or ctx.attr.test_config == "stdout":
        stdout_output = ctx.actions.declare_file(ctx.label.name + ".stdout")
        outputs.append(stdout_output)
        args.add("--stdout-file", stdout_output.path)

    if combined or ctx.attr.test_config != "stdout":
        touch_output = ctx.actions.declare_file(ctx.label.name + ".touch")
        outputs.append(touch_output)
        args.add("--touch-file", touch_output.path)

    if combined or ctx.attr.test_config == "env-files":
        args.add_all(ctx.files.env_files, before_each = "--env-file")

    if combined or ctx.attr.test_config == "arg-files":
        args.add_all(ctx.files.arg_files, before_each = "--arg-file")

    if combined or ctx.attr.test_config == "subst-pwd":
        args.add("--subst-pwd")

    args.add("--")

    args.add(ctx.executable._process_wrapper_tester.path)
    args.add(ctx.attr.test_config)
    args.add("--current-dir", "<pwd>")
    env = {"CURRENT_DIR": "<pwd>/test_path"}

    ctx.actions.run(
        executable = ctx.executable._process_wrapper,
        inputs = ctx.files.env_files + ctx.files.arg_files,
        outputs = outputs,
        arguments = [args],
        env = env,
        tools = [ctx.executable._process_wrapper_tester],
    )

    return [DefaultInfo(files = depset(outputs))]

process_wrapper_tester = rule(
    implementation = _impl,
    attrs = {
        "test_config": attr.string(mandatory = True),
        "arg_files": attr.label_list(),
        "env_files": attr.label_list(),
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
