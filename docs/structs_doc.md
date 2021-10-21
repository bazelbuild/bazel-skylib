<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing functions that operate on structs.

<a id="#structs.to_dict"></a>

## structs.to_dict

<pre>
structs.to_dict(<a href="#structs.to_dict-s">s</a>)
</pre>

Converts a `struct` to a `dict`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="structs.to_dict-s"></a>s |  A <code>struct</code>.   |  none |

**RETURNS**

A `dict` whose keys and values are the same as the fields in `s`. The
transformation is only applied to the struct's fields and not to any
nested values.


