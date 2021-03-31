<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#sets.make"></a>

## sets.make

<pre>
sets.make(<a href="#sets.make-elements">elements</a>)
</pre>

Creates a new set.

All elements must be hashable.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| elements |  Optional sequence to construct the set out of.   |  <code>None</code> |


<a name="#sets.copy"></a>

## sets.copy

<pre>
sets.copy(<a href="#sets.copy-s">s</a>)
</pre>

Creates a new set from another set.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.to_list"></a>

## sets.to_list

<pre>
sets.to_list(<a href="#sets.to_list-s">s</a>)
</pre>

Creates a list from the values in the set.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.insert"></a>

## sets.insert

<pre>
sets.insert(<a href="#sets.insert-s">s</a>, <a href="#sets.insert-e">e</a>)
</pre>

Inserts an element into the set.

Element must be hashable.  This mutates the original set.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |
| e |  The element to be inserted.   |  none |


<a name="#sets.contains"></a>

## sets.contains

<pre>
sets.contains(<a href="#sets.contains-a">a</a>, <a href="#sets.contains-e">e</a>)
</pre>

Checks for the existence of an element in a set.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| a |  A set, as returned by <code>sets.make()</code>.   |  none |
| e |  The element to look for.   |  none |


<a name="#sets.is_equal"></a>

## sets.is_equal

<pre>
sets.is_equal(<a href="#sets.is_equal-a">a</a>, <a href="#sets.is_equal-b">b</a>)
</pre>

Returns whether two sets are equal.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| a |  A set, as returned by <code>sets.make()</code>.   |  none |
| b |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.is_subset"></a>

## sets.is_subset

<pre>
sets.is_subset(<a href="#sets.is_subset-a">a</a>, <a href="#sets.is_subset-b">b</a>)
</pre>

Returns whether `a` is a subset of `b`.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| a |  A set, as returned by <code>sets.make()</code>.   |  none |
| b |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.disjoint"></a>

## sets.disjoint

<pre>
sets.disjoint(<a href="#sets.disjoint-a">a</a>, <a href="#sets.disjoint-b">b</a>)
</pre>

Returns whether two sets are disjoint.

Two sets are disjoint if they have no elements in common.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| a |  A set, as returned by <code>sets.make()</code>.   |  none |
| b |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.intersection"></a>

## sets.intersection

<pre>
sets.intersection(<a href="#sets.intersection-a">a</a>, <a href="#sets.intersection-b">b</a>)
</pre>

Returns the intersection of two sets.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| a |  A set, as returned by <code>sets.make()</code>.   |  none |
| b |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.union"></a>

## sets.union

<pre>
sets.union(<a href="#sets.union-args">args</a>)
</pre>

Returns the union of several sets.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| args |  An arbitrary number of sets.   |  none |


<a name="#sets.difference"></a>

## sets.difference

<pre>
sets.difference(<a href="#sets.difference-a">a</a>, <a href="#sets.difference-b">b</a>)
</pre>

Returns the elements in `a` that are not in `b`.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| a |  A set, as returned by <code>sets.make()</code>.   |  none |
| b |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.length"></a>

## sets.length

<pre>
sets.length(<a href="#sets.length-s">s</a>)
</pre>

Returns the number of elements in a set.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.remove"></a>

## sets.remove

<pre>
sets.remove(<a href="#sets.remove-s">s</a>, <a href="#sets.remove-e">e</a>)
</pre>

Removes an element from the set.

Element must be hashable.  This mutates the original set.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |
| e |  The element to be removed.   |  none |


<a name="#sets.repr"></a>

## sets.repr

<pre>
sets.repr(<a href="#sets.repr-s">s</a>)
</pre>

Returns a string value representing the set.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |


<a name="#sets.str"></a>

## sets.str

<pre>
sets.str(<a href="#sets.str-s">s</a>)
</pre>

Returns a string value representing the set.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  A set, as returned by <code>sets.make()</code>.   |  none |


