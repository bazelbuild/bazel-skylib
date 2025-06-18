<!-- Generated with Stardoc: http://skydoc.bazel.build -->

A test verifying that another target fails to analyse as part of a `bazel test`

This analysistest is mostly aimed at rule authors that want to assert certain error conditions.
If the target under test does not fail the analysis phase, the test will evaluate to FAILED.
If the given error_message is not contained in the otherwise printed ERROR message, the test evaluates to FAILED.
If the given error_message is contained in the otherwise printed ERROR message, the test evaluates to PASSED.

NOTE:
Adding the `manual` tag  to the target-under-test is recommended.
It prevents analysis failure of that target if `bazel test //...` is used.

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
  target_under_test: The target that is expected to cause an anlysis failure
  error_message: The asserted error message in the (normally printed) ERROR.

<a id="analysis_failure_test"></a>

## analysis_failure_test

<pre>
analysis_failure_test(<a href="#analysis_failure_test-name">name</a>, <a href="#analysis_failure_test-error_message">error_message</a>, <a href="#analysis_failure_test-target_under_test">target_under_test</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="analysis_failure_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="analysis_failure_test-error_message"></a>error_message |  The test asserts that the given string is contained in the error message of the target under test.   | String | required |  |
| <a id="analysis_failure_test-target_under_test"></a>target_under_test |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


