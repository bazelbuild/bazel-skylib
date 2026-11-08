<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test verifying other targets build as part of a `bazel test`

<a id="build_test"></a>

## build_test

<pre>
load("@bazel_skylib//rules:build_test.bzl", "build_test")

build_test(<a href="#build_test-name">name</a>, <a href="#build_test-targets">targets</a>, <a href="#build_test-marker_tool">marker_tool</a>, <a href="#build_test-test_runner">test_runner</a>, <a href="#build_test-size">size</a>, <a href="#build_test-kwargs">**kwargs</a>)
</pre>

Test rule checking that other targets build.

This works not by an instance of this test failing, but instead by
the targets it depends on failing to build, and hence failing
the attempt to run this test.

Typical usage:

```
  load("@bazel_skylib//rules:build_test.bzl", "build_test")
  build_test(
      name = "my_build_test",
      targets = [
          "//some/package:rule",
      ],
  )
```


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="build_test-name"></a>name |  The name of the test rule.   |  none |
| <a id="build_test-targets"></a>targets |  A list of targets to ensure build.   |  none |
| <a id="build_test-marker_tool"></a>marker_tool |  Optional execution-platform tool that creates an empty file at the path passed as its only argument.   |  `None` |
| <a id="build_test-test_runner"></a>test_runner |  Optional target-platform executable to run with the test arguments once the checked targets build. Set the native_test `out` attribute if the executable needs a specific name.   |  `None` |
| <a id="build_test-size"></a>size |  The size of the test target.   |  `"small"` |
| <a id="build_test-kwargs"></a>kwargs |  The [common attributes for tests](https://bazel.build/reference/be/common-definitions#common-attributes-tests).   |  none |


