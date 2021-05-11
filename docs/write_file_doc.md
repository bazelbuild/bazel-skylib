<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#write_file"></a>

## write_file

<pre>
write_file(<a href="#write_file-name">name</a>, <a href="#write_file-out">out</a>, <a href="#write_file-content">content</a>, <a href="#write_file-is_executable">is_executable</a>, <a href="#write_file-newline">newline</a>, <a href="#write_file-kwargs">kwargs</a>)
</pre>

Creates a UTF-8 encoded text file.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  Name of the rule.   |  none |
| out |  Path of the output file, relative to this package.   |  none |
| content |  A list of strings. Lines of text, the contents of the file.     Newlines are added automatically after every line except the last one.   |  <code>[]</code> |
| is_executable |  A boolean. Whether to make the output file executable.     When True, the rule's output can be executed using <code>bazel run</code> and can     be in the srcs of binary and test rules that require executable     sources.   |  <code>False</code> |
| newline |  one of ["auto", "unix", "windows"]: line endings to use. "auto"     for platform-determined, "unix" for LF, and "windows" for CRLF.   |  <code>"auto"</code> |
| kwargs |  further keyword arguments, e.g. &lt;code&gt;visibility&lt;/code&gt;   |  none |


