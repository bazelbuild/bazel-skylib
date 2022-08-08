<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A rule that copies a file to another place.

native.genrule() is sometimes used to copy files (often wishing to rename them).
The 'copy_file' rule does this with a simpler interface than genrule.

The rule uses a Bash command on Linux/macOS/non-Windows, and a cmd.exe command
on Windows (no Bash is required).


<a id="#copy_file"></a>

## copy_file

<pre>
copy_file(<a href="#copy_file-name">name</a>, <a href="#copy_file-src">src</a>, <a href="#copy_file-out">out</a>, <a href="#copy_file-is_executable">is_executable</a>, <a href="#copy_file-allow_symlink">allow_symlink</a>, <a href="#copy_file-kwargs">kwargs</a>)
</pre>

Copies a file to another location.

`native.genrule()` is sometimes used to copy files (often wishing to rename them). The 'copy_file' rule does this with a simpler interface than genrule.

This rule uses a Bash command on Linux/macOS/non-Windows, and a cmd.exe command on Windows (no Bash is required).


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="copy_file-name"></a>name |  Name of the rule.   |  none |
| <a id="copy_file-src"></a>src |  A Label. The file to make a copy of. (Can also be the label of a rule that generates a file.)   |  none |
| <a id="copy_file-out"></a>out |  Path of the output file, relative to this package.   |  none |
| <a id="copy_file-is_executable"></a>is_executable |  A boolean. Whether to make the output file executable. When True, the rule's output can be executed using <code>bazel run</code> and can be in the srcs of binary and test rules that require executable sources. WARNING: If <code>allow_symlink</code> is True, <code>src</code> must also be executable.   |  <code>False</code> |
| <a id="copy_file-allow_symlink"></a>allow_symlink |  A boolean. Whether to allow symlinking instead of copying. When False, the output is always a hard copy. When True, the output *can* be a symlink, but there is no guarantee that a symlink is created (i.e., at the time of writing, we don't create symlinks on Windows). Set this to True if you need fast copying and your tools can handle symlinks (which most UNIX tools can).   |  <code>False</code> |
| <a id="copy_file-kwargs"></a>kwargs |  further keyword arguments, e.g. <code>visibility</code>   |  none |


