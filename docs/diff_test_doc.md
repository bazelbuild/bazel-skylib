<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test rule that compares two binary files.

The rule uses a Bash command (diff) on Linux/macOS/non-Windows, and a cmd.exe
command (fc.exe) on Windows (no Bash is required).

<a id="diff_test"></a>

## diff_test

<pre>
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

diff_test(<a href="#diff_test-name">name</a>, <a href="#diff_test-failure_message">failure_message</a>, <a href="#diff_test-file1">file1</a>, <a href="#diff_test-file2">file2</a>)
</pre>

A test that compares two files.

The test succeeds if the files' contents match.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="diff_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="diff_test-failure_message"></a>failure_message |  Additional message to log if the files' contents do not match.   | String | optional |  `""`  |
| <a id="diff_test-file1"></a>file1 |  Label of the file to compare to `file2`.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="diff_test-file2"></a>file2 |  Label of the file to compare to `file1`.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


