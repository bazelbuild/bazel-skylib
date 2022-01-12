<!-- Generated with Stardoc: http://skydoc.bazel.build -->

native_binary() and native_test() rule implementations.

These rules let you wrap a pre-built binary or script in a conventional binary
and test rule respectively. They fulfill the same goal as sh_binary and sh_test
do, but they run the wrapped binary directly, instead of through Bash, so they
don't depend on Bash and work with --shell_exectuable="".


<a id="#native_binary"></a>

## native_binary

<pre>
native_binary(<a href="#native_binary-name">name</a>, <a href="#native_binary-src">src</a>, <a href="#native_binary-out">out</a>, <a href="#native_binary-data">data</a>, <a href="#native_binary-kwargs">kwargs</a>)
</pre>

Wraps a pre-built binary or script with a binary rule.

You can "bazel run" this rule like any other binary rule, and use it as a tool in genrule.tools for example. You can also augment the binary with runfiles.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="native_binary-name"></a>name |  The name of the rule.   |  none |
| <a id="native_binary-src"></a>src |  label; path of the pre-built executable   |  none |
| <a id="native_binary-out"></a>out |  output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)   |  none |
| <a id="native_binary-data"></a>data |  list of labels; data dependencies   |  <code>None</code> |
| <a id="native_binary-kwargs"></a>kwargs |  The &lt;a href="https://docs.bazel.build/versions/main/be/common-definitions.html#common-attributes-binaries"&gt;common attributes for binaries&lt;/a&gt;.   |  none |


<a id="#native_test"></a>

## native_test

<pre>
native_test(<a href="#native_test-name">name</a>, <a href="#native_test-src">src</a>, <a href="#native_test-out">out</a>, <a href="#native_test-data">data</a>, <a href="#native_test-kwargs">kwargs</a>)
</pre>

Wraps a pre-built binary or script with a test rule.

You can "bazel test" this rule like any other test rule. You can also augment the binary with
runfiles.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="native_test-name"></a>name |  The name of the test rule.   |  none |
| <a id="native_test-src"></a>src |  label; path of the pre-built executable   |  none |
| <a id="native_test-out"></a>out |  output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)   |  none |
| <a id="native_test-data"></a>data |  list of labels; data dependencies   |  <code>None</code> |
| <a id="native_test-kwargs"></a>kwargs |  The &lt;a href="https://docs.bazel.build/versions/main/be/common-definitions.html#common-attributes-tests"&gt;common attributes for tests&lt;/a&gt;.   |  none |


