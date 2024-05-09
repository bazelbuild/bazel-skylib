<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing utility functions related to directories.

<a id="get_child"></a>

## get_child

<pre>
get_child(<a href="#get_child-directory">directory</a>, <a href="#get_child-name">name</a>, <a href="#get_child-require_dir">require_dir</a>, <a href="#get_child-require_file">require_file</a>)
</pre>

Gets the direct child of a directory.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="get_child-directory"></a>directory |  (DirectoryInfo) The directory to look within.   |  none |
| <a id="get_child-name"></a>name |  (string) The name of the directory/file to look for.   |  none |
| <a id="get_child-require_dir"></a>require_dir |  (bool) If true, throws an error if the value is not a directory.   |  `False` |
| <a id="get_child-require_file"></a>require_file |  (bool) If true, throws an error if the value is not a file.   |  `False` |

**RETURNS**

(File|DirectoryInfo) The content contained within.


<a id="get_relative"></a>

## get_relative

<pre>
get_relative(<a href="#get_relative-directory">directory</a>, <a href="#get_relative-path">path</a>, <a href="#get_relative-require_dir">require_dir</a>, <a href="#get_relative-require_file">require_file</a>)
</pre>

Gets a subdirectory contained within a tree of another directory.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="get_relative-directory"></a>directory |  (DirectoryInfo) The directory to look within.   |  none |
| <a id="get_relative-path"></a>path |  (string) The path of the directory to look for within it.   |  none |
| <a id="get_relative-require_dir"></a>require_dir |  (bool) If true, throws an error if the value is not a directory.   |  `False` |
| <a id="get_relative-require_file"></a>require_file |  (bool) If true, throws an error if the value is not a file.   |  `False` |

**RETURNS**

(File|DirectoryInfo) The directory contained within.


