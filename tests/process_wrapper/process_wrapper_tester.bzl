def _impl(ctx):
    env_output = ctx.actions.declare_file(ctx.label.name + ".envs")
    arg_output = ctx.actions.declare_file(ctx.label.name + ".args")
    outputs = [arg_output, env_output]
    args = ctx.actions.args()
    if ctx.attr.capture_stdout:
        stdout_output = ctx.actions.declare_file("hello/" + ctx.label.name + ".stdout")
        outputs.append(stdout_output)
        args.add("--stdout-file", stdout_output.path)

    args.add_all(ctx.files.env_files, before_each = "--env-file")
    args.add_all(ctx.files.arg_files, before_each = "--arg-file")
    args.add("--subst-pwd")

    args.add("--")
    
    args.add(ctx.executable._process_wrapper_tester.path)
    args.add(env_output.path)
    args.add(arg_output.path)
    args.add("--current-dir", "$pwd")

    env = {"CURRENT_DIR": "$pwd/test_path"}

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
        "arg_files": attr.label_list(),
        "env_files": attr.label_list(),
        "capture_stdout": attr.bool(default = False),
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
