<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing utility functions related to directories.

<a id="directory_glob"></a>

## directory_glob

<pre>
directory_glob(<a href="#directory_glob-directory">directory</a>, <a href="#directory_glob-include">include</a>, <a href="#directory_glob-allow_empty">allow_empty</a>)
</pre>

native.glob, but for DirectoryInfo.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="directory_glob-directory"></a>directory |  (DirectoryInfo) The directory to look relative from.   |  none |
| <a id="directory_glob-include"></a>include |  (List[string]) A list of globs to match.   |  none |
| <a id="directory_glob-allow_empty"></a>allow_empty |  (bool) Whether to allow a glob to not match any files.   |  `False` |

**RETURNS**

depset[File] A set of files that match.


<a id="directory_glob_chunk"></a>

## directory_glob_chunk

<pre>
directory_glob_chunk(<a href="#directory_glob_chunk-directory">directory</a>, <a href="#directory_glob_chunk-chunk">chunk</a>)
</pre>

Given a directory and a chunk of a glob, returns possible candidates.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="directory_glob_chunk-directory"></a>directory |  (DirectoryInfo) The directory to look relative from.   |  none |
| <a id="directory_glob_chunk-chunk"></a>chunk |  (string) A chunk of a glob to look at.   |  none |

**RETURNS**

List[Either[DirectoryInfo, File]]] The candidate next entries for the chunk.


<a id="directory_single_glob"></a>

## directory_single_glob

<pre>
directory_single_glob(<a href="#directory_single_glob-directory">directory</a>, <a href="#directory_single_glob-glob">glob</a>)
</pre>

Calculates all files that are matched by a glob on a directory.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="directory_single_glob-directory"></a>directory |  (DirectoryInfo) The directory to look relative from.   |  none |
| <a id="directory_single_glob-glob"></a>glob |  (string) A glob to match.   |  none |

**RETURNS**

List[File] A list of files that match.


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


<a id="transitive_entries"></a>

## transitive_entries

<pre>
transitive_entries(<a href="#transitive_entries-directory">directory</a>)
</pre>

Returns the files and directories contained within a directory transitively.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="transitive_entries-directory"></a>directory |  (DirectoryInfo) The directory to look at   |  none |

**RETURNS**

List[Either[DirectoryInfo, File]] The entries contained within.


