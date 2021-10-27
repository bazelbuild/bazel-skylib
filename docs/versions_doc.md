<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing functions for checking Bazel versions.

<a id="#versions.get"></a>

## versions.get

<pre>
versions.get()
</pre>

Returns the current Bazel version



<a id="#versions.parse"></a>

## versions.parse

<pre>
versions.parse(<a href="#versions.parse-bazel_version">bazel_version</a>)
</pre>

Parses a version string into a 3-tuple of ints

int tuples can be compared directly using binary operators (<, >).


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="versions.parse-bazel_version"></a>bazel_version |  the Bazel version string   |  none |

**RETURNS**

An int 3-tuple of a (major, minor, patch) version.


<a id="#versions.check"></a>

## versions.check

<pre>
versions.check(<a href="#versions.check-minimum_bazel_version">minimum_bazel_version</a>, <a href="#versions.check-maximum_bazel_version">maximum_bazel_version</a>, <a href="#versions.check-bazel_version">bazel_version</a>)
</pre>

Check that the version of Bazel is valid within the specified range.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="versions.check-minimum_bazel_version"></a>minimum_bazel_version |  minimum version of Bazel expected   |  none |
| <a id="versions.check-maximum_bazel_version"></a>maximum_bazel_version |  maximum version of Bazel expected   |  <code>None</code> |
| <a id="versions.check-bazel_version"></a>bazel_version |  the version of Bazel to check. Used for testing, defaults to native.bazel_version   |  <code>None</code> |


<a id="#versions.is_at_most"></a>

## versions.is_at_most

<pre>
versions.is_at_most(<a href="#versions.is_at_most-threshold">threshold</a>, <a href="#versions.is_at_most-version">version</a>)
</pre>

Check that a version is lower or equals to a threshold.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="versions.is_at_most-threshold"></a>threshold |  the maximum version string   |  none |
| <a id="versions.is_at_most-version"></a>version |  the version string to be compared to the threshold   |  none |

**RETURNS**

True if version <= threshold.


<a id="#versions.is_at_least"></a>

## versions.is_at_least

<pre>
versions.is_at_least(<a href="#versions.is_at_least-threshold">threshold</a>, <a href="#versions.is_at_least-version">version</a>)
</pre>

Check that a version is higher or equals to a threshold.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="versions.is_at_least-threshold"></a>threshold |  the minimum version string   |  none |
| <a id="versions.is_at_least-version"></a>version |  the version string to be compared to the threshold   |  none |

**RETURNS**

True if version >= threshold.


