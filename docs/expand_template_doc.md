<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A rule that performes template expansion.


<a id="#expand_template"></a>

## expand_template

<pre>
expand_template(<a href="#expand_template-name">name</a>, <a href="#expand_template-template">template</a>, <a href="#expand_template-substitutions">substitutions</a>, <a href="#expand_template-out">out</a>)
</pre>

Template expansion

This performs a simple search over the template file for the keys in substitutions,
and replaces them with the corresponding values.

There is no special syntax for the keys.
To avoid conflicts, you would need to explicitly add delimiters to the key strings, for example "{KEY}" or "@KEY@".


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="expand_template-name"></a>name |  The name of the rule.   |  none |
| <a id="expand_template-template"></a>template |  The template file to expand   |  none |
| <a id="expand_template-substitutions"></a>substitutions |  A dictionary mapping strings to their substitutions   |  none |
| <a id="expand_template-out"></a>out |  The destination of the expanded file   |  none |


