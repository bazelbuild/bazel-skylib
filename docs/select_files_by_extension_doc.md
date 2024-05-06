<!-- Generated with Stardoc: http://skydoc.bazel.build -->

select_files_by_extension() build rule implementation.

Selects a set of files from the outputs of a target by file extension.

<a id="select_files_by_extension"></a>

## select_files_by_extension

<pre>
select_files_by_extension(<a href="#select_files_by_extension-name">name</a>, <a href="#select_files_by_extension-srcs">srcs</a>, <a href="#select_files_by_extension-extensions">extensions</a>)
</pre>

Selects a single file from the outputs of a target by given relative path

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="select_files_by_extension-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="select_files_by_extension-srcs"></a>srcs |  The target producing the file among other outputs   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="select_files_by_extension-extensions"></a>extensions |  Extensions to select by   | List of strings | required |  |


