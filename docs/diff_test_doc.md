<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#diff_test"></a>

## diff_test

<pre>
diff_test(<a href="#diff_test-name">name</a>, <a href="#diff_test-file1">file1</a>, <a href="#diff_test-file2">file2</a>, <a href="#diff_test-kwargs">kwargs</a>)
</pre>

A test that compares two files.

The test succeeds if the files' contents match.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the test rule.   |  none |
| file1 |  Label of the file to compare to &lt;code&gt;file2&lt;/code&gt;.   |  none |
| file2 |  Label of the file to compare to &lt;code&gt;file1&lt;/code&gt;.   |  none |
| kwargs |  The &lt;a href="https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes-tests"&gt;common attributes for tests&lt;/a&gt;.   |  none |


