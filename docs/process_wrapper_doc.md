## process_wrapper

Process wrapper is a helper that allows you, in a platform independent way,
to not depend on run_shell to perform basic operations like capturing
the output or having $pwd used in command line arguments or environment
variables

It is meant to be used in rules implementations like such:

```python
  def _impl(ctx):
    stdout_output = ctx.actions.declare_file(ctx.label.name + ".stdout")
    args = ctx.actions.args()
    args.add("--stdout-file", stdout_output.path)
    args.add("--subst-pwd")
    args.add("--")
    args.add(ctx.executable._compiler.path)
    args.add(ctx.attr.test_config)
    args.add("--current-dir", "<pwd>")
    env = {"CURRENT_DIR": "<pwd>/test_path"}

    ctx.actions.run(
        executable = ctx.executable._process_wrapper,
        inputs = ctx.files.env_files + ctx.files.arg_files,
        outputs = [stdout_output],
        arguments = [args],
        env = env,
        tools = [ctx.executable._process_wrapper_tester],
    )

    return [DefaultInfo(files = depset([stdout_output]))]

  process_wrapper_tester = rule(
      implementation = _impl,
      attrs = {
          "_compiler": attr.label(
              default = "//compiler/label",
              executable = True,
              cfg = "exec",
          ),
          "_process_wrapper": attr.label(
              default = "@bazel_skylib//lib:process_wrapper",
              executable = True,
              allow_single_file = True,
              cfg = "exec",
          ),
      },
  )

```

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="process_wrapper---">
      <td><code>-- executable_path [args]</code></td>
      <td>
        required.
        <p>
          Everything after -- is used as command line arguments to the child process.
        </p>
        <p>
          executable_path: path to the executable that is going to be launched as a child process.
        </p>
        <p>
          [args]: Arguments to be passed on to the child process.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-subst-pwd">
      <td><code>--subst-pwd</code></td>
      <td>
        optional.
        <p>
          Replaces &lt;pwd&gt; in arguments and environment variables.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-env-file">
      <td><code>--env-file file_path</code></td>
      <td>
        optional.
        <p>
          Loads an environment variables file form "file_path".
          Can appear multiple times.
        </p>
        <p>
          The file consists of new line separated environment variables under the form of VAR=VALUE.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-arg-file">
      <td><code>--arg-file file_path</code></td>
      <td>
        optional.
        <p>
          Loads a command line arguments file form "file_path".
          Can appear multiple times.
        </p>
        <p>
          The file consists of  new line separated arguments.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-stdout-file">
      <td><code>--stdout-file file_path</code></td>
      <td>
        optional.
        <p>
          Writes the standard output of the child process to a file.
          Can appear once.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-touch-file">
      <td><code>--touch-file file_path</code></td>
      <td>
        optional.
        <p>
          Touches the file specified in file_path.
        </p>
      </td>
    </tr>
  </tbody>
</table>
