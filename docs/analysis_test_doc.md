<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test verifying other targets can be successfully analyzed as part of a `bazel test`

<a id="#analysis_test"></a>

## analysis_test

<pre>
analysis_test(<a href="#analysis_test-name">name</a>, <a href="#analysis_test-targets">targets</a>)
</pre>

Test rule checking that other targets can be successfully analyzed.

    This rule essentially verifies that all targets under `targets` would
    generate no errors when analyzed with `bazel build [targets] --nobuild`.
    Action success/failure for the targets and their transitive dependencies
    are not verified. An analysis test simply ensures that each target in the transitive
    dependencies propagate providers appropriately and register actions for their outputs
    appropriately.

    NOTE: If the targets fail to analyze, instead of the analysis_test failing, the analysis_test
    will fail to build. Ideally, it would instead result in a test failure. This is a current
    infrastructure limitation that may be fixed in the future.

    Typical usage:

      load("@bazel_skylib//rules:analysis_test.bzl", "analysis_test")
      analysis_test(
          name = "my_analysis_test",
          targets = [
              "//some/package:rule",
          ],
      )

    Args:
      name: The name of the test rule.
      targets: A list of targets to ensure build.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="analysis_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="analysis_test-targets"></a>targets |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


