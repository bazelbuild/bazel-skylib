## native_binary

<pre>
native_binary(<a href="#native_binary-name">name</a>, <a href="#native_binary-src">src</a>, <a href="#native_binary-out">out</a>, <a href="#native_binary-data">data</a>, <a href="#native_binary-kwargs">kwargs</a>)
</pre>

Wraps a pre-built binary or script with a binary rule.

You can "bazel run" this rule like any other binary rule, and use it as a tool in genrule.tools for example. You can also augment the binary with runfiles.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="native_binary-name">
      <td><code>name</code></td>
      <td>
        required.
      </td>
    </tr>
    <tr id="native_binary-src">
      <td><code>src</code></td>
      <td>
        required.
        <p>
          label; path of the pre-built executable
        </p>
      </td>
    </tr>
    <tr id="native_binary-out">
      <td><code>out</code></td>
      <td>
        required.
        <p>
          output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)
        </p>
      </td>
    </tr>
    <tr id="native_binary-data">
      <td><code>data</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          list of labels; data dependencies
        </p>
      </td>
    </tr>
    <tr id="native_binary-kwargs">
      <td><code>kwargs</code></td>
      <td>
        optional.
        <p>
          The <a href="https://docs.bazel.build/versions/master/be/common-definitions.html#common-attributes-binaries">common attributes for binaries</a>.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## native_test

<pre>
native_test(<a href="#native_test-name">name</a>, <a href="#native_test-src">src</a>, <a href="#native_test-out">out</a>, <a href="#native_test-data">data</a>, <a href="#native_test-kwargs">kwargs</a>)
</pre>

Wraps a pre-built binary or script with a test rule.

You can "bazel test" this rule like any other test rule. You can also augment the binary with
runfiles.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="native_test-name">
      <td><code>name</code></td>
      <td>
        required.
      </td>
    </tr>
    <tr id="native_test-src">
      <td><code>src</code></td>
      <td>
        required.
        <p>
          label; path of the pre-built executable
        </p>
      </td>
    </tr>
    <tr id="native_test-out">
      <td><code>out</code></td>
      <td>
        required.
        <p>
          output; an output name for the copy of the binary. (Bazel requires that this rule make a copy of 'src'.)
        </p>
      </td>
    </tr>
    <tr id="native_test-data">
      <td><code>data</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          list of labels; data dependencies
        </p>
      </td>
    </tr>
    <tr id="native_test-kwargs">
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


