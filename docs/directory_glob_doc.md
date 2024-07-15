<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Rules to filter files from a directory.

<a id="directory_glob"></a>

## directory_glob

<pre>
directory_glob(<a href="#directory_glob-name">name</a>, <a href="#directory_glob-srcs">srcs</a>, <a href="#directory_glob-data">data</a>, <a href="#directory_glob-allow_empty">allow_empty</a>, <a href="#directory_glob-directory">directory</a>, <a href="#directory_glob-exclude">exclude</a>)
</pre>

globs files from a directory by relative path.

Usage:

```
directory_glob(
    name = "foo",
    directory = ":directory",
    srcs = ["foo/bar"],
    data = ["foo/**"],
    exclude = ["foo/**/*.h"]
)
```

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="directory_glob-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="directory_glob-srcs"></a>srcs |  A list of globs to files within the directory to put in the files.<br><br>For example, `srcs = ["foo/**"]` would collect the file at `<directory>/foo` into the files.   | List of strings | optional |  `[]`  |
| <a id="directory_glob-data"></a>data |  A list of globs to files within the directory to put in the runfiles.<br><br>For example, `data = ["foo/**"]` would collect all files contained within `<directory>/foo` into the runfiles.   | List of strings | optional |  `[]`  |
| <a id="directory_glob-allow_empty"></a>allow_empty |  If true, allows globs to not match anything.   | Boolean | optional |  `False`  |
| <a id="directory_glob-directory"></a>directory |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="directory_glob-exclude"></a>exclude |  A list of globs to files within the directory to exclude from the files and runfiles.   | List of strings | optional |  `[]`  |


