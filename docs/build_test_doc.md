<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test verifying other targets build as part of a `bazel test`

<a id="#build_test"></a>

## build_test

<pre>
build_test(<a href="#build_test-name">name</a>, <a href="#build_test-targets">targets</a>, <a href="#build_test-kwargs">kwargs</a>)
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
| <a id="build_test-kwargs"></a>kwargs |  The &lt;a href="https://docs.bazel.build/versions/main/be/common-definitions.html#common-attributes-tests"&gt;common attributes for tests&lt;/a&gt;.   |  none |


