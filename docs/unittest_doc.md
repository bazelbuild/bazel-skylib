<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Unit testing support.

Unlike most Skylib files, this exports two modules: `unittest` which contains
functions to declare and define unit tests, and `asserts` which contains the
assertions used to within tests.


<a id="#unittest_toolchain"></a>

## unittest_toolchain

<pre>
unittest_toolchain(<a href="#unittest_toolchain-name">name</a>, <a href="#unittest_toolchain-escape_chars_with">escape_chars_with</a>, <a href="#unittest_toolchain-escape_other_chars_with">escape_other_chars_with</a>, <a href="#unittest_toolchain-failure_templ">failure_templ</a>, <a href="#unittest_toolchain-file_ext">file_ext</a>,
                   <a href="#unittest_toolchain-join_on">join_on</a>, <a href="#unittest_toolchain-success_templ">success_templ</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="unittest_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="unittest_toolchain-escape_chars_with"></a>escape_chars_with |  Dictionary of characters that need escaping in test failure message to prefix appended to escape those characters. For example, <code>{"%": "%", "&gt;": "^"}</code> would replace <code>%</code> with <code>%%</code> and <code>&gt;</code> with <code>^&gt;</code> in the failure message before that is included in <code>success_templ</code>.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |
| <a id="unittest_toolchain-escape_other_chars_with"></a>escape_other_chars_with |  String to prefix every character in test failure message which is not a key in <code>escape_chars_with</code> before including that in <code>success_templ</code>. For example, <code>""</code> would prefix every character in the failure message (except those in the keys of <code>escape_chars_with</code>) with <code>\</code>.   | String | optional | "" |
| <a id="unittest_toolchain-failure_templ"></a>failure_templ |  Test script template with a single <code>%s</code>. That placeholder is replaced with the lines in the failure message joined with the string specified in <code>join_with</code>. The resulting script should print the failure message and exit with non-zero status.   | String | required |  |
| <a id="unittest_toolchain-file_ext"></a>file_ext |  File extension for test script, including leading dot.   | String | required |  |
| <a id="unittest_toolchain-join_on"></a>join_on |  String used to join the lines in the failure message before including the resulting string in the script specified in <code>failure_templ</code>.   | String | required |  |
| <a id="unittest_toolchain-success_templ"></a>success_templ |  Test script generated when the test passes. Should exit with status 0.   | String | required |  |


<a id="#analysistest.make"></a>

## analysistest.make

<pre>
analysistest.make(<a href="#analysistest.make-impl">impl</a>, <a href="#analysistest.make-expect_failure">expect_failure</a>, <a href="#analysistest.make-attrs">attrs</a>, <a href="#analysistest.make-fragments">fragments</a>, <a href="#analysistest.make-config_settings">config_settings</a>,
                  <a href="#analysistest.make-extra_target_under_test_aspects">extra_target_under_test_aspects</a>, <a href="#analysistest.make-doc">doc</a>)
</pre>

Creates an analysis test rule from its implementation function.

An analysis test verifies the behavior of a "real" rule target by examining
and asserting on the providers given by the real target.

Each analysis test is defined in an implementation function that must then be
associated with a rule so that a target can be built. This function handles
the boilerplate to create and return a test rule and captures the
implementation function's name so that it can be printed in test feedback.

An example of an analysis test:

```
def _your_test(ctx):
  env = analysistest.begin(ctx)

  # Assert statements go here

  return analysistest.end(env)

your_test = analysistest.make(_your_test)
```

Recall that names of test rules must end in `_test`.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.make-impl"></a>impl |  The implementation function of the unit test.   |  none |
| <a id="analysistest.make-expect_failure"></a>expect_failure |  If true, the analysis test will expect the target_under_test to fail. Assertions can be made on the underlying failure using asserts.expect_failure   |  <code>False</code> |
| <a id="analysistest.make-attrs"></a>attrs |  An optional dictionary to supplement the attrs passed to the unit test's <code>rule()</code> constructor.   |  <code>{}</code> |
| <a id="analysistest.make-fragments"></a>fragments |  An optional list of fragment names that can be used to give rules access to language-specific parts of configuration.   |  <code>[]</code> |
| <a id="analysistest.make-config_settings"></a>config_settings |  A dictionary of configuration settings to change for the target under test and its dependencies. This may be used to essentially change 'build flags' for the target under test, and may thus be utilized to test multiple targets with different flags in a single build   |  <code>{}</code> |
| <a id="analysistest.make-extra_target_under_test_aspects"></a>extra_target_under_test_aspects |  An optional list of aspects to apply to the target_under_test in addition to those set up by default for the test harness itself.   |  <code>[]</code> |
| <a id="analysistest.make-doc"></a>doc |  A description of the rule that can be extracted by documentation generating tools.   |  <code>""</code> |

**RETURNS**

A rule definition that should be stored in a global whose name ends in
`_test`.


<a id="#analysistest.begin"></a>

## analysistest.begin

<pre>
analysistest.begin(<a href="#analysistest.begin-ctx">ctx</a>)
</pre>

Begins a unit test.

This should be the first function called in a unit test implementation
function. It initializes a "test environment" that is used to collect
assertion failures so that they can be reported and logged at the end of the
test.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.begin-ctx"></a>ctx |  The Starlark context. Pass the implementation function's <code>ctx</code> argument in verbatim.   |  none |

**RETURNS**

A test environment struct that must be passed to assertions and finally to
`unittest.end`. Do not rely on internal details about the fields in this
struct as it may change.


<a id="#analysistest.end"></a>

## analysistest.end

<pre>
analysistest.end(<a href="#analysistest.end-env">env</a>)
</pre>

Ends an analysis test and logs the results.

This must be called and returned at the end of an analysis test implementation function so
that the results are reported.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.end-env"></a>env |  The test environment returned by <code>analysistest.begin</code>.   |  none |

**RETURNS**

A list of providers needed to automatically register the analysis test result.


<a id="#analysistest.fail"></a>

## analysistest.fail

<pre>
analysistest.fail(<a href="#analysistest.fail-env">env</a>, <a href="#analysistest.fail-msg">msg</a>)
</pre>

Unconditionally causes the current test to fail.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.fail-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="analysistest.fail-msg"></a>msg |  The message to log describing the failure.   |  none |


<a id="#analysistest.target_actions"></a>

## analysistest.target_actions

<pre>
analysistest.target_actions(<a href="#analysistest.target_actions-env">env</a>)
</pre>

Returns a list of actions registered by the target under test.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.target_actions-env"></a>env |  The test environment returned by <code>analysistest.begin</code>.   |  none |

**RETURNS**

A list of actions registered by the target under test


<a id="#analysistest.target_bin_dir_path"></a>

## analysistest.target_bin_dir_path

<pre>
analysistest.target_bin_dir_path(<a href="#analysistest.target_bin_dir_path-env">env</a>)
</pre>

Returns ctx.bin_dir.path for the target under test.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.target_bin_dir_path-env"></a>env |  The test environment returned by <code>analysistest.begin</code>.   |  none |

**RETURNS**

Output bin dir path string.


<a id="#analysistest.target_under_test"></a>

## analysistest.target_under_test

<pre>
analysistest.target_under_test(<a href="#analysistest.target_under_test-env">env</a>)
</pre>

Returns the target under test.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="analysistest.target_under_test-env"></a>env |  The test environment returned by <code>analysistest.begin</code>.   |  none |

**RETURNS**

The target under test.


<a id="#asserts.expect_failure"></a>

## asserts.expect_failure

<pre>
asserts.expect_failure(<a href="#asserts.expect_failure-env">env</a>, <a href="#asserts.expect_failure-expected_failure_msg">expected_failure_msg</a>)
</pre>

Asserts that the target under test has failed with a given error message.

This requires that the analysis test is created with `analysistest.make()` and
`expect_failures = True` is specified.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="asserts.expect_failure-env"></a>env |  The test environment returned by <code>analysistest.begin</code>.   |  none |
| <a id="asserts.expect_failure-expected_failure_msg"></a>expected_failure_msg |  The error message to expect as a result of analysis failures.   |  <code>""</code> |


<a id="#asserts.equals"></a>

## asserts.equals

<pre>
asserts.equals(<a href="#asserts.equals-env">env</a>, <a href="#asserts.equals-expected">expected</a>, <a href="#asserts.equals-actual">actual</a>, <a href="#asserts.equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` values are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="asserts.equals-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="asserts.equals-expected"></a>expected |  The expected value of some computation.   |  none |
| <a id="asserts.equals-actual"></a>actual |  The actual value returned by some computation.   |  none |
| <a id="asserts.equals-msg"></a>msg |  An optional message that will be printed that describes the failure. If omitted, a default will be used.   |  <code>None</code> |


<a id="#asserts.false"></a>

## asserts.false

<pre>
asserts.false(<a href="#asserts.false-env">env</a>, <a href="#asserts.false-condition">condition</a>, <a href="#asserts.false-msg">msg</a>)
</pre>

Asserts that the given `condition` is false.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="asserts.false-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="asserts.false-condition"></a>condition |  A value that will be evaluated in a Boolean context.   |  none |
| <a id="asserts.false-msg"></a>msg |  An optional message that will be printed that describes the failure. If omitted, a default will be used.   |  <code>"Expected condition to be false, but was true."</code> |


<a id="#asserts.set_equals"></a>

## asserts.set_equals

<pre>
asserts.set_equals(<a href="#asserts.set_equals-env">env</a>, <a href="#asserts.set_equals-expected">expected</a>, <a href="#asserts.set_equals-actual">actual</a>, <a href="#asserts.set_equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` sets are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="asserts.set_equals-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="asserts.set_equals-expected"></a>expected |  The expected set resulting from some computation.   |  none |
| <a id="asserts.set_equals-actual"></a>actual |  The actual set returned by some computation.   |  none |
| <a id="asserts.set_equals-msg"></a>msg |  An optional message that will be printed that describes the failure. If omitted, a default will be used.   |  <code>None</code> |


<a id="#asserts.new_set_equals"></a>

## asserts.new_set_equals

<pre>
asserts.new_set_equals(<a href="#asserts.new_set_equals-env">env</a>, <a href="#asserts.new_set_equals-expected">expected</a>, <a href="#asserts.new_set_equals-actual">actual</a>, <a href="#asserts.new_set_equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` sets are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="asserts.new_set_equals-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="asserts.new_set_equals-expected"></a>expected |  The expected set resulting from some computation.   |  none |
| <a id="asserts.new_set_equals-actual"></a>actual |  The actual set returned by some computation.   |  none |
| <a id="asserts.new_set_equals-msg"></a>msg |  An optional message that will be printed that describes the failure. If omitted, a default will be used.   |  <code>None</code> |


<a id="#asserts.true"></a>

## asserts.true

<pre>
asserts.true(<a href="#asserts.true-env">env</a>, <a href="#asserts.true-condition">condition</a>, <a href="#asserts.true-msg">msg</a>)
</pre>

Asserts that the given `condition` is true.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="asserts.true-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="asserts.true-condition"></a>condition |  A value that will be evaluated in a Boolean context.   |  none |
| <a id="asserts.true-msg"></a>msg |  An optional message that will be printed that describes the failure. If omitted, a default will be used.   |  <code>"Expected condition to be true, but was false."</code> |


<a id="#loadingtest.make"></a>

## loadingtest.make

<pre>
loadingtest.make(<a href="#loadingtest.make-name">name</a>)
</pre>

Creates a loading phase test environment and test_suite.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="loadingtest.make-name"></a>name |  name of the suite of tests to create   |  none |

**RETURNS**

loading phase environment passed to other loadingtest functions


<a id="#loadingtest.equals"></a>

## loadingtest.equals

<pre>
loadingtest.equals(<a href="#loadingtest.equals-env">env</a>, <a href="#loadingtest.equals-test_case">test_case</a>, <a href="#loadingtest.equals-expected">expected</a>, <a href="#loadingtest.equals-actual">actual</a>)
</pre>

Creates a test case for asserting state at LOADING phase.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="loadingtest.equals-env"></a>env |  Loading test env created from loadingtest.make   |  none |
| <a id="loadingtest.equals-test_case"></a>test_case |  Name of the test case   |  none |
| <a id="loadingtest.equals-expected"></a>expected |  Expected value to test   |  none |
| <a id="loadingtest.equals-actual"></a>actual |  Actual value received.   |  none |

**RETURNS**

None, creates test case


<a id="#register_unittest_toolchains"></a>

## register_unittest_toolchains

<pre>
register_unittest_toolchains()
</pre>

Registers the toolchains for unittest users.



<a id="#unittest.make"></a>

## unittest.make

<pre>
unittest.make(<a href="#unittest.make-impl">impl</a>, <a href="#unittest.make-attrs">attrs</a>)
</pre>

Creates a unit test rule from its implementation function.

Each unit test is defined in an implementation function that must then be
associated with a rule so that a target can be built. This function handles
the boilerplate to create and return a test rule and captures the
implementation function's name so that it can be printed in test feedback.

The optional `attrs` argument can be used to define dependencies for this
test, in order to form unit tests of rules.

An example of a unit test:

```
def _your_test(ctx):
  env = unittest.begin(ctx)

  # Assert statements go here

  return unittest.end(env)

your_test = unittest.make(_your_test)
```

Recall that names of test rules must end in `_test`.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="unittest.make-impl"></a>impl |  The implementation function of the unit test.   |  none |
| <a id="unittest.make-attrs"></a>attrs |  An optional dictionary to supplement the attrs passed to the unit test's <code>rule()</code> constructor.   |  <code>{}</code> |

**RETURNS**

A rule definition that should be stored in a global whose name ends in
`_test`.


<a id="#unittest.suite"></a>

## unittest.suite

<pre>
unittest.suite(<a href="#unittest.suite-name">name</a>, <a href="#unittest.suite-test_rules">test_rules</a>)
</pre>

Defines a `test_suite` target that contains multiple tests.

After defining your test rules in a `.bzl` file, you need to create targets
from those rules so that `blaze test` can execute them. Doing this manually
in a BUILD file would consist of listing each test in your `load` statement
and then creating each target one by one. To reduce duplication, we recommend
writing a macro in your `.bzl` file to instantiate all targets, and calling
that macro from your BUILD file so you only have to load one symbol.

You can use this function to create the targets and wrap them in a single
test_suite target. If a test rule requires no arguments, you can simply list
it as an argument. If you wish to supply attributes explicitly, you can do so
using `partial.make()`. For instance, in your `.bzl` file, you could write:

```
def your_test_suite():
  unittest.suite(
      "your_test_suite",
      your_test,
      your_other_test,
      partial.make(yet_another_test, timeout = "short"),
  )
```

Then, in your `BUILD` file, simply load the macro and invoke it to have all
of the targets created:

```
load("//path/to/your/package:tests.bzl", "your_test_suite")
your_test_suite()
```

If you pass _N_ unit test rules to `unittest.suite`, _N_ + 1 targets will be
created: a `test_suite` target named `${name}` (where `${name}` is the name
argument passed in here) and targets named `${name}_test_${i}`, where `${i}`
is the index of the test in the `test_rules` list, which is used to uniquely
name each target.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="unittest.suite-name"></a>name |  The name of the <code>test_suite</code> target, and the prefix of all the test target names.   |  none |
| <a id="unittest.suite-test_rules"></a>test_rules |  A list of test rules defines by <code>unittest.test</code>.   |  none |


<a id="#unittest.begin"></a>

## unittest.begin

<pre>
unittest.begin(<a href="#unittest.begin-ctx">ctx</a>)
</pre>

Begins a unit test.

This should be the first function called in a unit test implementation
function. It initializes a "test environment" that is used to collect
assertion failures so that they can be reported and logged at the end of the
test.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="unittest.begin-ctx"></a>ctx |  The Starlark context. Pass the implementation function's <code>ctx</code> argument in verbatim.   |  none |

**RETURNS**

A test environment struct that must be passed to assertions and finally to
`unittest.end`. Do not rely on internal details about the fields in this
struct as it may change.


<a id="#unittest.end"></a>

## unittest.end

<pre>
unittest.end(<a href="#unittest.end-env">env</a>)
</pre>

Ends a unit test and logs the results.

This must be called and returned at the end of a unit test implementation function so
that the results are reported.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="unittest.end-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |

**RETURNS**

A list of providers needed to automatically register the test result.


<a id="#unittest.fail"></a>

## unittest.fail

<pre>
unittest.fail(<a href="#unittest.fail-env">env</a>, <a href="#unittest.fail-msg">msg</a>)
</pre>

Unconditionally causes the current test to fail.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="unittest.fail-env"></a>env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| <a id="unittest.fail-msg"></a>msg |  The message to log describing the failure.   |  none |


