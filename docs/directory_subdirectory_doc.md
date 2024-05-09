<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing rules to create metadata about subdirectories.

<a id="subdirectory"></a>

## subdirectory

<pre>
subdirectory(<a href="#subdirectory-name">name</a>, <a href="#subdirectory-parent">parent</a>, <a href="#subdirectory-path">path</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="subdirectory-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="subdirectory-parent"></a>parent |  A label corresponding to the parent directory (or subdirectory).   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="subdirectory-path"></a>path |  A path within the parent directory (eg. "path/to/subdir")   | String | required |  |


