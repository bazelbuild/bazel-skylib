<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test rule that compares two binary files.

The rule uses a Bash command (diff) on Linux/macOS/non-Windows, and a cmd.exe
command (fc.exe) on Windows (no Bash is required).


<a id="diff_test"></a>

## diff_test

<pre>
diff_test(<a href="#diff_test-name">name</a>, <a href="#diff_test-file1">file1</a>, <a href="#diff_test-file2">file2</a>, <a href="#diff_test-failure_message">failure_message</a>, <a href="#diff_test-kwargs">kwargs</a>)
</pre>

A test that compares two files.

The test succeeds if the files' contents match.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="diff_test-name"></a>name |  The name of the test rule.   |  none |
| <a id="diff_test-file1"></a>file1 |  Label of the file to compare to <code>file2</code>.   |  none |
| <a id="diff_test-file2"></a>file2 |  Label of the file to compare to <code>file1</code>.   |  none |
| <a id="diff_test-failure_message"></a>failure_message |  Additional message to log if the files' contents do not match.   |  <code>None</code> |
| <a id="diff_test-kwargs"></a>kwargs |  The [common attributes for tests](https://bazel.build/reference/be/common-definitions#common-attributes-tests).   |  none |


