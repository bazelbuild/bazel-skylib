<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#versions.get"></a>

## versions.get

<pre>
versions.get()
</pre>

Returns the current Bazel version

**PARAMETERS**



<a name="#versions.parse"></a>

## versions.parse

<pre>
versions.parse(<a href="#versions.parse-bazel_version">bazel_version</a>)
</pre>

Parses a version string into a 3-tuple of ints

int tuples can be compared directly using binary operators (<, >).


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| bazel_version |  the Bazel version string   |  none |


<a name="#versions.check"></a>

## versions.check

<pre>
versions.check(<a href="#versions.check-minimum_bazel_version">minimum_bazel_version</a>, <a href="#versions.check-maximum_bazel_version">maximum_bazel_version</a>, <a href="#versions.check-bazel_version">bazel_version</a>)
</pre>

Check that the version of Bazel is valid within the specified range.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| minimum_bazel_version |  minimum version of Bazel expected   |  none |
| maximum_bazel_version |  maximum version of Bazel expected   |  <code>None</code> |
| bazel_version |  the version of Bazel to check. Used for testing, defaults to native.bazel_version   |  <code>None</code> |


<a name="#versions.is_at_most"></a>

## versions.is_at_most

<pre>
versions.is_at_most(<a href="#versions.is_at_most-threshold">threshold</a>, <a href="#versions.is_at_most-version">version</a>)
</pre>

Check that a version is lower or equals to a threshold.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| threshold |  the maximum version string   |  none |
| version |  the version string to be compared to the threshold   |  none |


<a name="#versions.is_at_least"></a>

## versions.is_at_least

<pre>
versions.is_at_least(<a href="#versions.is_at_least-threshold">threshold</a>, <a href="#versions.is_at_least-version">version</a>)
</pre>

Check that a version is higher or equals to a threshold.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| threshold |  the minimum version string   |  none |
| version |  the version string to be compared to the threshold   |  none |


