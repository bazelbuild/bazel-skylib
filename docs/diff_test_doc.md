## diff_test

<pre>
diff_test(<a href="#diff_test-name">name</a>, <a href="#diff_test-file1">file1</a>, <a href="#diff_test-file2">file2</a>, <a href="#diff_test-kwargs">kwargs</a>)
</pre>

A test that compares two files.

The test succeeds if the files' contents match.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="diff_test-name">
      <td><code>name</code></td>
      <td>
        required.
        <p>
          The name of the test rule.
        </p>
      </td>
    </tr>
    <tr id="diff_test-file1">
      <td><code>file1</code></td>
      <td>
        required.
        <p>
          Label of the file to compare to <code>file2</code>.
        </p>
      </td>
    </tr>
    <tr id="diff_test-file2">
      <td><code>file2</code></td>
      <td>
        required.
        <p>
          Label of the file to compare to <code>file1</code>.
        </p>
      </td>
    </tr>
    <tr id="diff_test-kwargs">
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


