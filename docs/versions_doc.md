## _check_bazel_version

<pre>
_check_bazel_version(<a href="#_check_bazel_version-minimum_bazel_version">minimum_bazel_version</a>, <a href="#_check_bazel_version-maximum_bazel_version">maximum_bazel_version</a>, <a href="#_check_bazel_version-bazel_version">bazel_version</a>)
</pre>

Check that the version of Bazel is valid within the specified range.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_check_bazel_version-minimum_bazel_version>
      <td><code>minimum_bazel_version</code></td>
      <td>
        required.
        <p>
          minimum version of Bazel expected
        </p>
      </td>
    </tr>
    <tr id="_check_bazel_version-maximum_bazel_version>
      <td><code>maximum_bazel_version</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          maximum version of Bazel expected
        </p>
      </td>
    </tr>
    <tr id="_check_bazel_version-bazel_version>
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


## _extract_version_number

<pre>
_extract_version_number(<a href="#_extract_version_number-bazel_version">bazel_version</a>)
</pre>

Extracts the semantic version number from a version string

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_extract_version_number-bazel_version>
      <td><code>bazel_version</code></td>
      <td>
        required.
        <p>
          the version string that begins with the semantic version
  e.g. "1.2.3rc1 abc1234" where "abc1234" is a commit hash.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _get_bazel_version

<pre>
_get_bazel_version()
</pre>

Returns the current Bazel version



## _is_at_least

<pre>
_is_at_least(<a href="#_is_at_least-threshold">threshold</a>, <a href="#_is_at_least-version">version</a>)
</pre>

Check that a version is higher or equals to a threshold.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_is_at_least-threshold>
      <td><code>threshold</code></td>
      <td>
        required.
        <p>
          the minimum version string
        </p>
      </td>
    </tr>
    <tr id="_is_at_least-version>
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


## _is_at_most

<pre>
_is_at_most(<a href="#_is_at_most-threshold">threshold</a>, <a href="#_is_at_most-version">version</a>)
</pre>

Check that a version is lower or equals to a threshold.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_is_at_most-threshold>
      <td><code>threshold</code></td>
      <td>
        required.
        <p>
          the maximum version string
        </p>
      </td>
    </tr>
    <tr id="_is_at_most-version>
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


## _parse_bazel_version

<pre>
_parse_bazel_version(<a href="#_parse_bazel_version-bazel_version">bazel_version</a>)
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
    <tr id="_parse_bazel_version-bazel_version>
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


