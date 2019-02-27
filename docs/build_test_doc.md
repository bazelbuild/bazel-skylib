## build_test

<pre>
build_test(<a href="#build_test-name">name</a>, <a href="#build_test-targets">targets</a>, <a href="#build_test-kwargs">kwargs</a>)
</pre>

Test rule checking that other targets build.

This works not by an instance of this test failing, but instead by
the targets it depends on failing to build, and hence failing
the attempt to run this test.

NOTE: At the moment, this won't work on Windows; but someone adding
support would be welcomed.

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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="build_test-name">
      <td><code>name</code></td>
      <td>
        required.
        <p>
          The name of the test rule.
        </p>
      </td>
    </tr>
    <tr id="build_test-targets">
      <td><code>targets</code></td>
      <td>
        required.
        <p>
          A list of targets to ensure build.
        </p>
      </td>
    </tr>
    <tr id="build_test-kwargs">
      <td><code>kwargs</code></td>
      <td>
        optional.
        <p>
          The <a href="https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes-tests">common attributes for tests</a>.
        </p>
      </td>
    </tr>
  </tbody>
</table>


