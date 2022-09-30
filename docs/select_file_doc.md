<!-- Generated with Stardoc: http://skydoc.bazel.build -->


select_file() build rule implementation.

Selects a single file from the outputs of a target by given relative path.


<a id="select_file"></a>

## select_file

<pre>
select_file(<a href="#select_file-name">name</a>, <a href="#select_file-srcs">srcs</a>, <a href="#select_file-subpath">subpath</a>)
</pre>

Selects a single file from the outputs of a target by given relative path

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="select_file-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="select_file-srcs"></a>srcs |  The target producing the file among other outputs   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="select_file-subpath"></a>subpath |  Relative path to the file   | String | required |  |


