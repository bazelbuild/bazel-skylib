<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A rule that performs template expansion.


<a id="expand_template"></a>

## expand_template

<pre>
expand_template(<a href="#expand_template-name">name</a>, <a href="#expand_template-out">out</a>, <a href="#expand_template-substitutions">substitutions</a>, <a href="#expand_template-template">template</a>)
</pre>

Template expansion

This performs a simple search over the template file for the keys in
substitutions, and replaces them with the corresponding values.

There is no special syntax for the keys. To avoid conflicts, you would need to
explicitly add delimiters to the key strings, for example "{KEY}" or "@KEY@".

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="expand_template-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="expand_template-out"></a>out |  The destination of the expanded file.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="expand_template-substitutions"></a>substitutions |  A dictionary mapping strings to their substitutions.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="expand_template-template"></a>template |  The template file to expand.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


