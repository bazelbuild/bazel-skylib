<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing functions that operate on structs.

<a id="structs.merge"></a>

## structs.merge

<pre>
load("@bazel_skylib//lib:structs.bzl", "structs")

structs.merge(<a href="#structs.merge-first">first</a>, <a href="#structs.merge-rest">*rest</a>)
</pre>

Merges multiple `struct` instances together. Later `struct` keys overwrite early `struct` keys.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="structs.merge-first"></a>first |  The initial `struct` to merge keys/values into.   |  none |
| <a id="structs.merge-rest"></a>rest |  Other `struct` instances to merge.   |  none |

**RETURNS**

A merged `struct`.


<a id="structs.to_dict"></a>

## structs.to_dict

<pre>
load("@bazel_skylib//lib:structs.bzl", "structs")

structs.to_dict(<a href="#structs.to_dict-s">s</a>)
</pre>

Converts a `struct` to a `dict`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="structs.to_dict-s"></a>s |  A `struct`.   |  none |

**RETURNS**

A `dict` whose keys and values are the same as the fields in `s`. The
transformation is only applied to the struct's fields and not to any
nested values.


