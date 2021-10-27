<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing functions checking types.

<a id="#types.is_list"></a>

## types.is_list

<pre>
types.is_list(<a href="#types.is_list-v">v</a>)
</pre>

Returns True if v is an instance of a list.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_list-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a list, False otherwise.


<a id="#types.is_string"></a>

## types.is_string

<pre>
types.is_string(<a href="#types.is_string-v">v</a>)
</pre>

Returns True if v is an instance of a string.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_string-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a string, False otherwise.


<a id="#types.is_bool"></a>

## types.is_bool

<pre>
types.is_bool(<a href="#types.is_bool-v">v</a>)
</pre>

Returns True if v is an instance of a bool.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_bool-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a bool, False otherwise.


<a id="#types.is_none"></a>

## types.is_none

<pre>
types.is_none(<a href="#types.is_none-v">v</a>)
</pre>

Returns True if v has the type of None.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_none-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is None, False otherwise.


<a id="#types.is_int"></a>

## types.is_int

<pre>
types.is_int(<a href="#types.is_int-v">v</a>)
</pre>

Returns True if v is an instance of a signed integer.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_int-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a signed integer, False otherwise.


<a id="#types.is_tuple"></a>

## types.is_tuple

<pre>
types.is_tuple(<a href="#types.is_tuple-v">v</a>)
</pre>

Returns True if v is an instance of a tuple.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_tuple-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a tuple, False otherwise.


<a id="#types.is_dict"></a>

## types.is_dict

<pre>
types.is_dict(<a href="#types.is_dict-v">v</a>)
</pre>

Returns True if v is an instance of a dict.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_dict-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a dict, False otherwise.


<a id="#types.is_function"></a>

## types.is_function

<pre>
types.is_function(<a href="#types.is_function-v">v</a>)
</pre>

Returns True if v is an instance of a function.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_function-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a function, False otherwise.


<a id="#types.is_depset"></a>

## types.is_depset

<pre>
types.is_depset(<a href="#types.is_depset-v">v</a>)
</pre>

Returns True if v is an instance of a `depset`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_depset-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v is an instance of a `depset`, False otherwise.


<a id="#types.is_set"></a>

## types.is_set

<pre>
types.is_set(<a href="#types.is_set-v">v</a>)
</pre>

Returns True if v is a set created by sets.make().

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="types.is_set-v"></a>v |  The value whose type should be checked.   |  none |

**RETURNS**

True if v was created by sets.make(), False otherwise.


