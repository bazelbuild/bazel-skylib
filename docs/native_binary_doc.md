<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#native_binary"></a>

## native_binary

<pre>
native_binary(<a href="#native_binary-name">name</a>, <a href="#native_binary-src">src</a>, <a href="#native_binary-out">out</a>, <a href="#native_binary-data">data</a>, <a href="#native_binary-kwargs">kwargs</a>)
</pre>

Wraps a pre-built binary or script with a binary rule.

You can "bazel run" this rule like any other binary rule, and use it as a tool in genrule.tools for example. You can also augment the binary with runfiles.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the test rule.   |  none |
| src |  label; path of the pre-built executable   |  none |
| out |  output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)   |  none |
| data |  list of labels; data dependencies   |  <code>None</code> |
| kwargs |  The &lt;a href="https://docs.bazel.build/versions/main/be/common-definitions.html#common-attributes-binaries"&gt;common attributes for binaries&lt;/a&gt;.   |  none |


<a name="#native_test"></a>

## native_test

<pre>
native_test(<a href="#native_test-name">name</a>, <a href="#native_test-src">src</a>, <a href="#native_test-out">out</a>, <a href="#native_test-data">data</a>, <a href="#native_test-kwargs">kwargs</a>)
</pre>

Wraps a pre-built binary or script with a test rule.

You can "bazel test" this rule like any other test rule. You can also augment the binary with
runfiles.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the test rule.   |  none |
| src |  label; path of the pre-built executable   |  none |
| out |  output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)   |  none |
| data |  list of labels; data dependencies   |  <code>None</code> |
| kwargs |  The &lt;a href="https://docs.bazel.build/versions/main/be/common-definitions.html#common-attributes-tests"&gt;common attributes for tests&lt;/a&gt;.   |  none |


