<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#collections.after_each"></a>

## collections.after_each

<pre>
collections.after_each(<a href="#collections.after_each-separator">separator</a>, <a href="#collections.after_each-iterable">iterable</a>)
</pre>

Inserts `separator` after each item in `iterable`.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| separator |  The value to insert after each item in <code>iterable</code>.   |  none |
| iterable |  The list into which to intersperse the separator.   |  none |


<a name="#collections.before_each"></a>

## collections.before_each

<pre>
collections.before_each(<a href="#collections.before_each-separator">separator</a>, <a href="#collections.before_each-iterable">iterable</a>)
</pre>

Inserts `separator` before each item in `iterable`.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| separator |  The value to insert before each item in <code>iterable</code>.   |  none |
| iterable |  The list into which to intersperse the separator.   |  none |


<a name="#collections.uniq"></a>

## collections.uniq

<pre>
collections.uniq(<a href="#collections.uniq-iterable">iterable</a>)
</pre>

Returns a list of unique elements in `iterable`.

Requires all the elements to be hashable.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| iterable |  An iterable to filter.   |  none |


