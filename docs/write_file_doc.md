## write_file

<pre>
write_file(<a href="#write_file-name">name</a>, <a href="#write_file-out">out</a>, <a href="#write_file-content">content</a>, <a href="#write_file-is_executable">is_executable</a>, <a href="#write_file-newline">newline</a>, <a href="#write_file-kwargs">kwargs</a>)
</pre>

Creates a UTF-8 encoded text file.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="write_file-name">
      <td><code>name</code></td>
      <td>
        required.
        <p>
          Name of the rule.
        </p>
      </td>
    </tr>
    <tr id="write_file-out">
      <td><code>out</code></td>
      <td>
        required.
        <p>
          Path of the output file, relative to this package.
        </p>
      </td>
    </tr>
    <tr id="write_file-content">
      <td><code>content</code></td>
      <td>
        optional. default is <code>[]</code>
        <p>
          A list of strings. Lines of text, the contents of the file.
    Newlines are added automatically after every line except the last one.
        </p>
      </td>
    </tr>
    <tr id="write_file-is_executable">
      <td><code>is_executable</code></td>
      <td>
        optional. default is <code>False</code>
        <p>
          A boolean. Whether to make the output file executable.
    When True, the rule's output can be executed using `bazel run` and can
    be in the srcs of binary and test rules that require executable
    sources.
        </p>
      </td>
    </tr>
    <tr id="write_file-newline">
      <td><code>newline</code></td>
      <td>
        optional. default is <code>"auto"</code>
        <p>
          one of ["auto", "unix", "windows"]: line endings to use. "auto"
    for platform-determined, "unix" for LF, and "windows" for CRLF.
        </p>
      </td>
    </tr>
    <tr id="write_file-kwargs">
      <td><code>kwargs</code></td>
      <td>
        optional.
        <p>
          further keyword arguments, e.g. <code>visibility</code>
        </p>
      </td>
    </tr>
  </tbody>
</table>


