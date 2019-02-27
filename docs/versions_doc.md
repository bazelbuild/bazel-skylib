## versions.get

<pre>
versions.get()
</pre>

Returns the current Bazel version



## versions.parse

<pre>
versions.parse(<a href="#versions.parse-bazel_version">bazel_version</a>)
</pre>

Parses a version string into a 3-tuple of ints

int tuples can be compared directly using binary operators (<, >).


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="versions.parse-bazel_version">
      <td><code>bazel_version</code></td>
      <td>
        required.
        <p>
          the Bazel version string
        </p>
      </td>
    </tr>
  </tbody>
</table>


## versions.check

<pre>
versions.check(<a href="#versions.check-minimum_bazel_version">minimum_bazel_version</a>, <a href="#versions.check-maximum_bazel_version">maximum_bazel_version</a>, <a href="#versions.check-bazel_version">bazel_version</a>)
</pre>

Check that the version of Bazel is valid within the specified range.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="versions.check-minimum_bazel_version">
      <td><code>minimum_bazel_version</code></td>
      <td>
        required.
        <p>
          minimum version of Bazel expected
        </p>
      </td>
    </tr>
    <tr id="versions.check-maximum_bazel_version">
      <td><code>maximum_bazel_version</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          maximum version of Bazel expected
        </p>
      </td>
    </tr>
    <tr id="versions.check-bazel_version">
      <td><code>bazel_version</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          the version of Bazel to check. Used for testing, defaults to native.bazel_version
        </p>
      </td>
    </tr>
  </tbody>
</table>


## versions.is_at_most

<pre>
versions.is_at_most(<a href="#versions.is_at_most-threshold">threshold</a>, <a href="#versions.is_at_most-version">version</a>)
</pre>

Check that a version is lower or equals to a threshold.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="versions.is_at_most-threshold">
      <td><code>threshold</code></td>
      <td>
        required.
        <p>
          the maximum version string
        </p>
      </td>
    </tr>
    <tr id="versions.is_at_most-version">
      <td><code>version</code></td>
      <td>
        required.
        <p>
          the version string to be compared to the threshold
        </p>
      </td>
    </tr>
  </tbody>
</table>


## versions.is_at_least

<pre>
versions.is_at_least(<a href="#versions.is_at_least-threshold">threshold</a>, <a href="#versions.is_at_least-version">version</a>)
</pre>

Check that a version is higher or equals to a threshold.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="versions.is_at_least-threshold">
      <td><code>threshold</code></td>
      <td>
        required.
        <p>
          the minimum version string
        </p>
      </td>
    </tr>
    <tr id="versions.is_at_least-version">
      <td><code>version</code></td>
      <td>
        required.
        <p>
          the version string to be compared to the threshold
        </p>
      </td>
    </tr>
  </tbody>
</table>


