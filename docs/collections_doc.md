<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing functions that operate on collections.

<a id="#collections.after_each"></a>

## collections.after_each

<pre>
collections.after_each(<a href="#collections.after_each-separator">separator</a>, <a href="#collections.after_each-iterable">iterable</a>)
</pre>

Inserts `separator` after each item in `iterable`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="collections.after_each-separator"></a>separator |  The value to insert after each item in <code>iterable</code>.   |  none |
| <a id="collections.after_each-iterable"></a>iterable |  The list into which to intersperse the separator.   |  none |

**RETURNS**

A new list with `separator` after each item in `iterable`.


<a id="#collections.before_each"></a>

## collections.before_each

<pre>
collections.before_each(<a href="#collections.before_each-separator">separator</a>, <a href="#collections.before_each-iterable">iterable</a>)
</pre>

Inserts `separator` before each item in `iterable`.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="collections.before_each-separator"></a>separator |  The value to insert before each item in <code>iterable</code>.   |  none |
| <a id="collections.before_each-iterable"></a>iterable |  The list into which to intersperse the separator.   |  none |

**RETURNS**

A new list with `separator` before each item in `iterable`.


<a id="#collections.uniq"></a>

## collections.uniq

<pre>
collections.uniq(<a href="#collections.uniq-iterable">iterable</a>)
</pre>

Returns a list of unique elements in `iterable`.

Requires all the elements to be hashable.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="collections.uniq-iterable"></a>iterable |  An iterable to filter.   |  none |

**RETURNS**

A new list with all unique elements from `iterable`.


