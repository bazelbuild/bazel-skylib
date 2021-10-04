<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#unittest_toolchain"></a>

## unittest_toolchain

<pre>
unittest_toolchain(<a href="#unittest_toolchain-name">name</a>, <a href="#unittest_toolchain-escape_chars_with">escape_chars_with</a>, <a href="#unittest_toolchain-escape_other_chars_with">escape_other_chars_with</a>, <a href="#unittest_toolchain-failure_templ">failure_templ</a>, <a href="#unittest_toolchain-file_ext">file_ext</a>,
                   <a href="#unittest_toolchain-join_on">join_on</a>, <a href="#unittest_toolchain-success_templ">success_templ</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| escape_chars_with |  Dictionary of characters that need escaping in test failure message to prefix appended to escape those characters. For example, <code>{"%": "%", "&gt;": "^"}</code> would replace <code>%</code> with <code>%%</code> and <code>&gt;</code> with <code>^&gt;</code> in the failure message before that is included in <code>success_templ</code>.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |
| escape_other_chars_with |  String to prefix every character in test failure message which is not a key in <code>escape_chars_with</code> before including that in <code>success_templ</code>. For example, <code>""</code> would prefix every character in the failure message (except those in the keys of <code>escape_chars_with</code>) with <code>\</code>.   | String | optional | "" |
| failure_templ |  Test script template with a single <code>%s</code>. That placeholder is replaced with the lines in the failure message joined with the string specified in <code>join_with</code>. The resulting script should print the failure message and exit with non-zero status.   | String | required |  |
| file_ext |  File extension for test script, including leading dot.   | String | required |  |
| join_on |  String used to join the lines in the failure message before including the resulting string in the script specified in <code>failure_templ</code>.   | String | required |  |
| success_templ |  Test script generated when the test passes. Should exit with status 0.   | String | required |  |


<a name="#analysistest.make"></a>

## analysistest.make

<pre>
analysistest.make(<a href="#analysistest.make-impl">impl</a>, <a href="#analysistest.make-expect_failure">expect_failure</a>, <a href="#analysistest.make-attrs">attrs</a>, <a href="#analysistest.make-fragments">fragments</a>, <a href="#analysistest.make-config_settings">config_settings</a>,
                  <a href="#analysistest.make-extra_target_under_test_aspects">extra_target_under_test_aspects</a>)
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
| :-------------: | :-------------: | :-------------: |
| impl |  The implementation function of the unit test.   |  none |
| expect_failure |  If true, the analysis test will expect the target_under_test     to fail. Assertions can be made on the underlying failure using asserts.expect_failure   |  <code>False</code> |
| attrs |  An optional dictionary to supplement the attrs passed to the     unit test's <code>rule()</code> constructor.   |  <code>{}</code> |
| fragments |  An optional list of fragment names that can be used to give rules access to     language-specific parts of configuration.   |  <code>[]</code> |
| config_settings |  A dictionary of configuration settings to change for the target under     test and its dependencies. This may be used to essentially change 'build flags' for     the target under test, and may thus be utilized to test multiple targets with different     flags in a single build   |  <code>{}</code> |
| extra_target_under_test_aspects |  An optional list of aspects to apply to the target_under_test     in addition to those set up by default for the test harness itself.   |  <code>[]</code> |


<a name="#analysistest.begin"></a>

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
| :-------------: | :-------------: | :-------------: |
| ctx |  The Starlark context. Pass the implementation function's <code>ctx</code> argument     in verbatim.   |  none |


<a name="#analysistest.end"></a>

## analysistest.end

<pre>
analysistest.end(<a href="#analysistest.end-env">env</a>)
</pre>

Ends an analysis test and logs the results.

This must be called and returned at the end of an analysis test implementation function so
that the results are reported.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>analysistest.begin</code>.   |  none |


<a name="#analysistest.fail"></a>

## analysistest.fail

<pre>
analysistest.fail(<a href="#analysistest.fail-env">env</a>, <a href="#analysistest.fail-msg">msg</a>)
</pre>

Unconditionally causes the current test to fail.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| msg |  The message to log describing the failure.   |  none |


<a name="#analysistest.target_actions"></a>

## analysistest.target_actions

<pre>
analysistest.target_actions(<a href="#analysistest.target_actions-env">env</a>)
</pre>

Returns a list of actions registered by the target under test.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>analysistest.begin</code>.   |  none |


<a name="#analysistest.target_bin_dir_path"></a>

## analysistest.target_bin_dir_path

<pre>
analysistest.target_bin_dir_path(<a href="#analysistest.target_bin_dir_path-env">env</a>)
</pre>

Returns ctx.bin_dir.path for the target under test.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>analysistest.begin</code>.   |  none |


<a name="#analysistest.target_under_test"></a>

## analysistest.target_under_test

<pre>
analysistest.target_under_test(<a href="#analysistest.target_under_test-env">env</a>)
</pre>

Returns the target under test.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>analysistest.begin</code>.   |  none |


<a name="#asserts.expect_failure"></a>

## asserts.expect_failure

<pre>
asserts.expect_failure(<a href="#asserts.expect_failure-env">env</a>, <a href="#asserts.expect_failure-expected_failure_msg">expected_failure_msg</a>)
</pre>

Asserts that the target under test has failed with a given error message.

This requires that the analysis test is created with `analysistest.make()` and
`expect_failures = True` is specified.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>analysistest.begin</code>.   |  none |
| expected_failure_msg |  The error message to expect as a result of analysis failures.   |  <code>""</code> |


<a name="#asserts.equals"></a>

## asserts.equals

<pre>
asserts.equals(<a href="#asserts.equals-env">env</a>, <a href="#asserts.equals-expected">expected</a>, <a href="#asserts.equals-actual">actual</a>, <a href="#asserts.equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` values are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| expected |  The expected value of some computation.   |  none |
| actual |  The actual value returned by some computation.   |  none |
| msg |  An optional message that will be printed that describes the failure.     If omitted, a default will be used.   |  <code>None</code> |


<a name="#asserts.false"></a>

## asserts.false

<pre>
asserts.false(<a href="#asserts.false-env">env</a>, <a href="#asserts.false-condition">condition</a>, <a href="#asserts.false-msg">msg</a>)
</pre>

Asserts that the given `condition` is false.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| condition |  A value that will be evaluated in a Boolean context.   |  none |
| msg |  An optional message that will be printed that describes the failure.     If omitted, a default will be used.   |  <code>"Expected condition to be false, but was true."</code> |


<a name="#asserts.set_equals"></a>

## asserts.set_equals

<pre>
asserts.set_equals(<a href="#asserts.set_equals-env">env</a>, <a href="#asserts.set_equals-expected">expected</a>, <a href="#asserts.set_equals-actual">actual</a>, <a href="#asserts.set_equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` sets are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| expected |  The expected set resulting from some computation.   |  none |
| actual |  The actual set returned by some computation.   |  none |
| msg |  An optional message that will be printed that describes the failure.     If omitted, a default will be used.   |  <code>None</code> |


<a name="#asserts.new_set_equals"></a>

## asserts.new_set_equals

<pre>
asserts.new_set_equals(<a href="#asserts.new_set_equals-env">env</a>, <a href="#asserts.new_set_equals-expected">expected</a>, <a href="#asserts.new_set_equals-actual">actual</a>, <a href="#asserts.new_set_equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` sets are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| expected |  The expected set resulting from some computation.   |  none |
| actual |  The actual set returned by some computation.   |  none |
| msg |  An optional message that will be printed that describes the failure.     If omitted, a default will be used.   |  <code>None</code> |


<a name="#asserts.true"></a>

## asserts.true

<pre>
asserts.true(<a href="#asserts.true-env">env</a>, <a href="#asserts.true-condition">condition</a>, <a href="#asserts.true-msg">msg</a>)
</pre>

Asserts that the given `condition` is true.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| condition |  A value that will be evaluated in a Boolean context.   |  none |
| msg |  An optional message that will be printed that describes the failure.     If omitted, a default will be used.   |  <code>"Expected condition to be true, but was false."</code> |


<a name="#register_unittest_toolchains"></a>

## register_unittest_toolchains

<pre>
register_unittest_toolchains()
</pre>

Registers the toolchains for unittest users.

**PARAMETERS**



<a name="#unittest.make"></a>

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
| :-------------: | :-------------: | :-------------: |
| impl |  The implementation function of the unit test.   |  none |
| attrs |  An optional dictionary to supplement the attrs passed to the     unit test's <code>rule()</code> constructor.   |  <code>{}</code> |


<a name="#unittest.suite"></a>

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
| :-------------: | :-------------: | :-------------: |
| name |  The name of the <code>test_suite</code> target, and the prefix of all the test     target names.   |  none |
| test_rules |  A list of test rules defines by <code>unittest.test</code>.   |  none |


<a name="#unittest.begin"></a>

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
| :-------------: | :-------------: | :-------------: |
| ctx |  The Starlark context. Pass the implementation function's <code>ctx</code> argument     in verbatim.   |  none |


<a name="#unittest.end"></a>

## unittest.end

<pre>
unittest.end(<a href="#unittest.end-env">env</a>)
</pre>

Ends a unit test and logs the results.

This must be called and returned at the end of a unit test implementation function so
that the results are reported.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |


<a name="#unittest.fail"></a>

## unittest.fail

<pre>
unittest.fail(<a href="#unittest.fail-env">env</a>, <a href="#unittest.fail-msg">msg</a>)
</pre>

Unconditionally causes the current test to fail.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| env |  The test environment returned by <code>unittest.begin</code>.   |  none |
| msg |  The message to log describing the failure.   |  none |


