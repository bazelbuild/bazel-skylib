<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing a library rule for aggregating rules files.

<a id="bzl_library"></a>

## bzl_library

<pre>
bzl_library(<a href="#bzl_library-name">name</a>, <a href="#bzl_library-deps">deps</a>, <a href="#bzl_library-srcs">srcs</a>)
</pre>

Creates a logical collection of Starlark .bzl and .scl files.

Example:
  Suppose your project has the following structure:

  ```
  [workspace]/
      WORKSPACE
      BUILD
      checkstyle/
          BUILD
          checkstyle.bzl
      lua/
          BUILD
          lua.bzl
          luarocks.bzl
  ```

  In this case, you can have `bzl_library` targets in `checkstyle/BUILD` and
  `lua/BUILD`:

  `checkstyle/BUILD`:

  ```python
  load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

  bzl_library(
      name = "checkstyle-rules",
      srcs = ["checkstyle.bzl"],
  )
  ```

  `lua/BUILD`:

  ```python
  load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

  bzl_library(
      name = "lua-rules",
      srcs = [
          "lua.bzl",
          "luarocks.bzl",
      ],
  )
  ```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bzl_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bzl_library-deps"></a>deps |  List of other <code>bzl_library</code> targets that are required by the Starlark files listed in <code>srcs</code>.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="bzl_library-srcs"></a>srcs |  List of <code>.bzl</code> and <code>.scl</code> files that are processed to create this target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |


<a id="StarlarkLibraryInfo"></a>

## StarlarkLibraryInfo

<pre>
StarlarkLibraryInfo(<a href="#StarlarkLibraryInfo-srcs">srcs</a>, <a href="#StarlarkLibraryInfo-transitive_srcs">transitive_srcs</a>)
</pre>

Information on contained Starlark rules.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="StarlarkLibraryInfo-srcs"></a>srcs |  Top level rules files.    |
| <a id="StarlarkLibraryInfo-transitive_srcs"></a>transitive_srcs |  Transitive closure of rules files required for interpretation of the srcs    |


