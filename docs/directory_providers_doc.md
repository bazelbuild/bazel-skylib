<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing providers for directories.

<a id="DirectoryInfo"></a>

## DirectoryInfo

<pre>
DirectoryInfo(<a href="#DirectoryInfo-entries">entries</a>, <a href="#DirectoryInfo-transitive_files">transitive_files</a>, <a href="#DirectoryInfo-path">path</a>, <a href="#DirectoryInfo-human_readable">human_readable</a>, <a href="#DirectoryInfo-get_path">get_path</a>, <a href="#DirectoryInfo-get_file">get_file</a>, <a href="#DirectoryInfo-get_subdirectory">get_subdirectory</a>,
              <a href="#DirectoryInfo-glob">glob</a>)
</pre>

Information about a directory

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="DirectoryInfo-entries"></a>entries |  (Dict[str, Either[File, DirectoryInfo]]) The entries contained directly within. Ordered by filename    |
| <a id="DirectoryInfo-transitive_files"></a>transitive_files |  (depset[File]) All files transitively contained within this directory.    |
| <a id="DirectoryInfo-path"></a>path |  (string) Path to all files contained within this directory.    |
| <a id="DirectoryInfo-human_readable"></a>human_readable |  (string) A human readable identifier for a directory. Useful for providing error messages to a user.    |
| <a id="DirectoryInfo-get_path"></a>get_path |  (Function(str) -> DirectoryInfo\|File) A function to return the entry corresponding to the joined path.    |
| <a id="DirectoryInfo-get_file"></a>get_file |  (Function(str) -> File) A function to return the entry corresponding to the joined path.    |
| <a id="DirectoryInfo-get_subdirectory"></a>get_subdirectory |  (Function(str) -> DirectoryInfo) A function to return the entry corresponding to the joined path.    |
| <a id="DirectoryInfo-glob"></a>glob |  (Function(include, exclude, allow_empty=False)) A function that works the same as native.glob.    |


<a id="create_directory_info"></a>

## create_directory_info

<pre>
create_directory_info(<a href="#create_directory_info-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="create_directory_info-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


