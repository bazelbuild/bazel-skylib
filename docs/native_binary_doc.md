<!-- Generated with Stardoc: http://skydoc.bazel.build -->

native_binary() and native_test() rule implementations.

These rules let you wrap a pre-built binary or script in a conventional binary
and test rule respectively. They fulfill the same goal as sh_binary and sh_test
do, but they run the wrapped binary directly, instead of through Bash, so they
don't depend on Bash and work with --shell_executable="".


<a id="native_binary"></a>

## native_binary

<pre>
native_binary(<a href="#native_binary-name">name</a>, <a href="#native_binary-data">data</a>, <a href="#native_binary-out">out</a>, <a href="#native_binary-src">src</a>)
</pre>


Wraps a pre-built binary or script with a binary rule.

You can "bazel run" this rule like any other binary rule, and use it as a tool
in genrule.tools for example. You can also augment the binary with runfiles.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="native_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="native_binary-data"></a>data |  data dependencies. See https://bazel.build/reference/be/common-definitions#typical.data   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="native_binary-out"></a>out |  An output name for the copy of the binary   | String | required |  |
| <a id="native_binary-src"></a>src |  path of the pre-built executable   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="native_test"></a>

## native_test

<pre>
native_test(<a href="#native_test-name">name</a>, <a href="#native_test-data">data</a>, <a href="#native_test-out">out</a>, <a href="#native_test-src">src</a>)
</pre>


Wraps a pre-built binary or script with a test rule.

You can "bazel test" this rule like any other test rule. You can also augment
the binary with runfiles.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="native_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="native_test-data"></a>data |  data dependencies. See https://bazel.build/reference/be/common-definitions#typical.data   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="native_test-out"></a>out |  An output name for the copy of the binary   | String | required |  |
| <a id="native_test-src"></a>src |  path of the pre-built executable   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


