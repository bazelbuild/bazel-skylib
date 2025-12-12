<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test verifying other targets fail to be analyzed as part of a `bazel test`

<a id="analysis_failure_test"></a>

## analysis_failure_test

<pre>
load("@bazel_skylib//rules:analysis_failure_test.bzl", "analysis_failure_test")

analysis_failure_test(<a href="#analysis_failure_test-name">name</a>, <a href="#analysis_failure_test-error_message">error_message</a>, <a href="#analysis_failure_test-target_under_test">target_under_test</a>)
</pre>

A test that verifies another target fails during **analysis**.

If the target under test does **not** fail analysis, the test **fails**.
If `error_message` is not found in the error output, the test **fails**.
Otherwise, the test **passes**.

NOTE: Add the `manual` tag to the target under test to avoid failing `bazel test //...`.

Typical usage:

```
load("@bazel_skylib//rules:analysis_failure_test.bzl", "analysis_failure_test")

rule_with_analysis_failure(
    name = "unit",
    tags = ["manual"],
)


analysis_failure_test(
    name = "analysis_fails_with_error",
    target_under_test = ":unit",
    error_message = _EXPECTED_ERROR_MESSAGE,
)
```

Args:
  target_under_test: Label of the target expected to fail during analysis (provided by `analysistest.make`).
  error_message: Substring that must appear in the error message.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="analysis_failure_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="analysis_failure_test-error_message"></a>error_message |  The test asserts that the given string is contained in the error message of the target under test.   | String | required |  |
| <a id="analysis_failure_test-target_under_test"></a>target_under_test |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


