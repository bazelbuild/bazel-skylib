## process_wrapper

Process wrapper is a helper that allows you, in a platform independent way,
to not depend on run_shell to perform basic operations like capturing
the output or having $pwd used in command line arguments or environment
variables

Note: This wrapper adds a dependency on a C++ toolchain

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
        tools = [ctx.executable._compiler],
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
      <td><code>--subst var=val</code></td>
      <td>
        optional.
        <p>
          Allows to substitute ${key} by value in all environment variables and arguments passed to the child process.
          If value is equal to ${pwd} the actual working directory of the process is substituted.
          ${key} doesn’t have a corresponding value it is left as is.
          If key matches a an existing key there is no escaping mechanism.
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
          \ at the end of of a line allows you to escape the new line splitting.
        </p>
        <p>
          file_path is subject to system limitations regarding maximum number of characters, which is 260 on windows.
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
          The file consists of new line separated arguments.
          \ at the end of of a line allows you to escape the new line splitting.
        </p>
        <p>
          file_path is subject to system limitations regarding maximum number of characters, which is 260 on windows.
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
        <p>
          file_path is subject to system limitations regarding maximum number of characters, which is 260 on windows.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-stderr-file">
      <td><code>--stderr-file file_path</code></td>
      <td>
        optional.
        <p>
          Writes the standard error output of the child process to a file.
          Can appear once.
        </p>
        <p>
          file_path is subject to system limitations regarding maximum number of characters, which is 260 on windows.
        </p>
      </td>
    </tr>
    <tr id="process_wrapper-touch-file">
      <td><code>--touch-file file_path</code></td>
      <td>
        optional.
        <p>
          Touches the file specified in file_path. The touch file only gets created if the child process exists successfully.
        </p>
        <p>
          file_path is subject to system limitations regarding maximum number of characters, which is 260 on windows.
        </p>
      </td>
    </tr>
  </tbody>
</table>
