<a name="#unittest_toolchain"></a>
## unittest_toolchain

<pre>
unittest_toolchain(<a href="#unittest_toolchain-name">name</a>, <a href="#unittest_toolchain-failure_templ">failure_templ</a>, <a href="#unittest_toolchain-file_ext">file_ext</a>, <a href="#unittest_toolchain-join_on">join_on</a>, <a href="#unittest_toolchain-success_templ">success_templ</a>)
</pre>



### Attributes

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="unittest_toolchain-name">
      <td><code>name</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#name">Name</a>; required
        <p>
          A unique name for this target.
        </p>
      </td>
    </tr>
    <tr id="unittest_toolchain-failure_templ">
      <td><code>failure_templ</code></td>
      <td>
        String; required
      </td>
    </tr>
    <tr id="unittest_toolchain-file_ext">
      <td><code>file_ext</code></td>
      <td>
        String; required
      </td>
    </tr>
    <tr id="unittest_toolchain-join_on">
      <td><code>join_on</code></td>
      <td>
        String; required
      </td>
    </tr>
    <tr id="unittest_toolchain-success_templ">
      <td><code>success_templ</code></td>
      <td>
        String; required
      </td>
    </tr>
  </tbody>
</table>


## analysistest.make

<pre>
analysistest.make(<a href="#analysistest.make-impl">impl</a>, <a href="#analysistest.make-expect_failure">expect_failure</a>, <a href="#analysistest.make-config_settings">config_settings</a>)
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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="analysistest.make-impl">
      <td><code>impl</code></td>
      <td>
        required.
        <p>
          The implementation function of the unit test.
        </p>
      </td>
    </tr>
    <tr id="analysistest.make-expect_failure">
      <td><code>expect_failure</code></td>
      <td>
        optional. default is <code>False</code>
        <p>
          If true, the analysis test will expect the target_under_test
    to fail. Assertions can be made on the underlying failure using asserts.expect_failure
        </p>
      </td>
    </tr>
    <tr id="analysistest.make-config_settings">
      <td><code>config_settings</code></td>
      <td>
        optional. default is <code>{}</code>
        <p>
          A dictionary of configuration settings to change for the target under
    test and its dependencies. This may be used to essentially change 'build flags' for
    the target under test, and may thus be utilized to test multiple targets with different
    flags in a single build
        </p>
      </td>
    </tr>
  </tbody>
</table>


## analysistest.begin

<pre>
analysistest.begin(<a href="#analysistest.begin-ctx">ctx</a>)
</pre>

Begins a unit test.

This should be the first function called in a unit test implementation
function. It initializes a "test environment" that is used to collect
assertion failures so that they can be reported and logged at the end of the
test.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="analysistest.begin-ctx">
      <td><code>ctx</code></td>
      <td>
        required.
        <p>
          The Skylark context. Pass the implementation function's `ctx` argument
    in verbatim.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## analysistest.end

<pre>
analysistest.end(<a href="#analysistest.end-env">env</a>)
</pre>

Ends an analysis test and logs the results.

This must be called and returned at the end of an analysis test implementation function so
that the results are reported.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="analysistest.end-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `analysistest.begin`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## analysistest.fail

<pre>
analysistest.fail(<a href="#analysistest.fail-env">env</a>, <a href="#analysistest.fail-msg">msg</a>)
</pre>

Unconditionally causes the current test to fail.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="analysistest.fail-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="analysistest.fail-msg">
      <td><code>msg</code></td>
      <td>
        required.
        <p>
          The message to log describing the failure.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## analysistest.target_actions

<pre>
analysistest.target_actions(<a href="#analysistest.target_actions-env">env</a>)
</pre>

Returns a list of actions registered by the target under test.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="analysistest.target_actions-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `analysistest.begin`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## analysistest.target_under_test

<pre>
analysistest.target_under_test(<a href="#analysistest.target_under_test-env">env</a>)
</pre>

Returns the target under test.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="analysistest.target_under_test-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `analysistest.begin`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## asserts.expect_failure

<pre>
asserts.expect_failure(<a href="#asserts.expect_failure-env">env</a>, <a href="#asserts.expect_failure-expected_failure_msg">expected_failure_msg</a>)
</pre>

Asserts that the target under test has failed with a given error message.

This requires that the analysis test is created with `analysistest.make()` and
`expect_failures = True` is specified.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="asserts.expect_failure-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `analysistest.begin`.
        </p>
      </td>
    </tr>
    <tr id="asserts.expect_failure-expected_failure_msg">
      <td><code>expected_failure_msg</code></td>
      <td>
        optional. default is <code>""</code>
        <p>
          The error message to expect as a result of analysis failures.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## asserts.equals

<pre>
asserts.equals(<a href="#asserts.equals-env">env</a>, <a href="#asserts.equals-expected">expected</a>, <a href="#asserts.equals-actual">actual</a>, <a href="#asserts.equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` values are equal.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="asserts.equals-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="asserts.equals-expected">
      <td><code>expected</code></td>
      <td>
        required.
        <p>
          The expected value of some computation.
        </p>
      </td>
    </tr>
    <tr id="asserts.equals-actual">
      <td><code>actual</code></td>
      <td>
        required.
        <p>
          The actual value returned by some computation.
        </p>
      </td>
    </tr>
    <tr id="asserts.equals-msg">
      <td><code>msg</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          An optional message that will be printed that describes the failure.
    If omitted, a default will be used.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## asserts.false

<pre>
asserts.false(<a href="#asserts.false-env">env</a>, <a href="#asserts.false-condition">condition</a>, <a href="#asserts.false-msg">msg</a>)
</pre>

Asserts that the given `condition` is false.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="asserts.false-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="asserts.false-condition">
      <td><code>condition</code></td>
      <td>
        required.
        <p>
          A value that will be evaluated in a Boolean context.
        </p>
      </td>
    </tr>
    <tr id="asserts.false-msg">
      <td><code>msg</code></td>
      <td>
        optional. default is <code>"Expected condition to be false, but was true."</code>
        <p>
          An optional message that will be printed that describes the failure.
    If omitted, a default will be used.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## asserts.set_equals

<pre>
asserts.set_equals(<a href="#asserts.set_equals-env">env</a>, <a href="#asserts.set_equals-expected">expected</a>, <a href="#asserts.set_equals-actual">actual</a>, <a href="#asserts.set_equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` sets are equal.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="asserts.set_equals-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="asserts.set_equals-expected">
      <td><code>expected</code></td>
      <td>
        required.
        <p>
          The expected set resulting from some computation.
        </p>
      </td>
    </tr>
    <tr id="asserts.set_equals-actual">
      <td><code>actual</code></td>
      <td>
        required.
        <p>
          The actual set returned by some computation.
        </p>
      </td>
    </tr>
    <tr id="asserts.set_equals-msg">
      <td><code>msg</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          An optional message that will be printed that describes the failure.
    If omitted, a default will be used.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## asserts.new_set_equals

<pre>
asserts.new_set_equals(<a href="#asserts.new_set_equals-env">env</a>, <a href="#asserts.new_set_equals-expected">expected</a>, <a href="#asserts.new_set_equals-actual">actual</a>, <a href="#asserts.new_set_equals-msg">msg</a>)
</pre>

Asserts that the given `expected` and `actual` sets are equal.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="asserts.new_set_equals-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="asserts.new_set_equals-expected">
      <td><code>expected</code></td>
      <td>
        required.
        <p>
          The expected set resulting from some computation.
        </p>
      </td>
    </tr>
    <tr id="asserts.new_set_equals-actual">
      <td><code>actual</code></td>
      <td>
        required.
        <p>
          The actual set returned by some computation.
        </p>
      </td>
    </tr>
    <tr id="asserts.new_set_equals-msg">
      <td><code>msg</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          An optional message that will be printed that describes the failure.
    If omitted, a default will be used.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## asserts.true

<pre>
asserts.true(<a href="#asserts.true-env">env</a>, <a href="#asserts.true-condition">condition</a>, <a href="#asserts.true-msg">msg</a>)
</pre>

Asserts that the given `condition` is true.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="asserts.true-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="asserts.true-condition">
      <td><code>condition</code></td>
      <td>
        required.
        <p>
          A value that will be evaluated in a Boolean context.
        </p>
      </td>
    </tr>
    <tr id="asserts.true-msg">
      <td><code>msg</code></td>
      <td>
        optional. default is <code>"Expected condition to be true, but was false."</code>
        <p>
          An optional message that will be printed that describes the failure.
    If omitted, a default will be used.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## register_unittest_toolchains

<pre>
register_unittest_toolchains()
</pre>

Registers the toolchains for unittest users.



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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="unittest.make-impl">
      <td><code>impl</code></td>
      <td>
        required.
        <p>
          The implementation function of the unit test.
        </p>
      </td>
    </tr>
    <tr id="unittest.make-attrs">
      <td><code>attrs</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          An optional dictionary to supplement the attrs passed to the
    unit test's `rule()` constructor.
        </p>
      </td>
    </tr>
  </tbody>
</table>


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

For the case where your unit tests do not take any (non-default) attributes --
i.e., if your unit tests do not test rules -- you can use this function to
create the targets and wrap them in a single test_suite target. In your
`.bzl` file, write:

```
def your_test_suite():
  unittest.suite(
      "your_test_suite",
      your_test,
      your_other_test,
      yet_another_test,
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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="unittest.suite-name">
      <td><code>name</code></td>
      <td>
        required.
        <p>
          The name of the `test_suite` target, and the prefix of all the test
    target names.
        </p>
      </td>
    </tr>
    <tr id="unittest.suite-test_rules">
      <td><code>test_rules</code></td>
      <td>
        optional.
        <p>
          A list of test rules defines by `unittest.test`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## unittest.begin

<pre>
unittest.begin(<a href="#unittest.begin-ctx">ctx</a>)
</pre>

Begins a unit test.

This should be the first function called in a unit test implementation
function. It initializes a "test environment" that is used to collect
assertion failures so that they can be reported and logged at the end of the
test.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="unittest.begin-ctx">
      <td><code>ctx</code></td>
      <td>
        required.
        <p>
          The Skylark context. Pass the implementation function's `ctx` argument
    in verbatim.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## unittest.end

<pre>
unittest.end(<a href="#unittest.end-env">env</a>)
</pre>

Ends a unit test and logs the results.

This must be called and returned at the end of a unit test implementation function so
that the results are reported.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="unittest.end-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## unittest.fail

<pre>
unittest.fail(<a href="#unittest.fail-env">env</a>, <a href="#unittest.fail-msg">msg</a>)
</pre>

Unconditionally causes the current test to fail.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="unittest.fail-env">
      <td><code>env</code></td>
      <td>
        required.
        <p>
          The test environment returned by `unittest.begin`.
        </p>
      </td>
    </tr>
    <tr id="unittest.fail-msg">
      <td><code>msg</code></td>
      <td>
        required.
        <p>
          The message to log describing the failure.
        </p>
      </td>
    </tr>
  </tbody>
</table>


