<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#copy_file"></a>

## copy_file

<pre>
copy_file(<a href="#copy_file-name">name</a>, <a href="#copy_file-src">src</a>, <a href="#copy_file-out">out</a>, <a href="#copy_file-is_executable">is_executable</a>, <a href="#copy_file-allow_symlink">allow_symlink</a>, <a href="#copy_file-kwargs">kwargs</a>)
</pre>

Copies a file to another location.

`native.genrule()` is sometimes used to copy files (often wishing to rename them). The 'copy_file' rule does this with a simpler interface than genrule.

This rule uses a Bash command on Linux/macOS/non-Windows, and a cmd.exe command on Windows (no Bash is required).


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="copy_file-name">
      <td><code>name</code></td>
      <td>
        required.
        <p>
          Name of the rule.
        </p>
      </td>
    </tr>
    <tr id="copy_file-src">
      <td><code>src</code></td>
      <td>
        required.
        <p>
          A Label. The file to make a copy of. (Can also be the label of a rule
    that generates a file.)
        </p>
      </td>
    </tr>
    <tr id="copy_file-out">
      <td><code>out</code></td>
      <td>
        required.
        <p>
          Path of the output file, relative to this package.
        </p>
      </td>
    </tr>
    <tr id="copy_file-is_executable">
      <td><code>is_executable</code></td>
      <td>
        optional. default is <code>False</code>
        <p>
          A boolean. Whether to make the output file executable. When
    True, the rule's output can be executed using `bazel run` and can be
    in the srcs of binary and test rules that require executable sources.
    WARNING: If `allow_symlink` is True, `src` must also be executable.
        </p>
      </td>
    </tr>
    <tr id="copy_file-allow_symlink">
      <td><code>allow_symlink</code></td>
      <td>
        optional. default is <code>False</code>
        <p>
          A boolean. Whether to allow symlinking instead of copying.
    When False, the output is always a hard copy. When True, the output
    *can* be a symlink, but there is no guarantee that a symlink is
    created (i.e., at the time of writing, we don't create symlinks on
    Windows). Set this to True if you need fast copying and your tools can
    handle symlinks (which most UNIX tools can).
        </p>
      </td>
    </tr>
    <tr id="copy_file-kwargs">
      <td><code>kwargs</code></td>
      <td>
        optional.
        <p>
          further keyword arguments, e.g. `visibility`
        </p>
      </td>
    </tr>
  </tbody>
</table>


