## _contains

<pre>
_contains(<a href="#_contains-a">a</a>, <a href="#_contains-e">e</a>)
</pre>

Checks for the existence of an element in a set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_contains-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_contains-e>
      <td><code>e</code></td>
      <td>
        required.
        <p>
          The element to look for.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _copy

<pre>
_copy(<a href="#_copy-s">s</a>)
</pre>

Creates a new set from another set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_copy-s>
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _difference

<pre>
_difference(<a href="#_difference-a">a</a>, <a href="#_difference-b">b</a>)
</pre>

Returns the elements in `a` that are not in `b`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_difference-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_difference-b>
      <td><code>b</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _disjoint

<pre>
_disjoint(<a href="#_disjoint-a">a</a>, <a href="#_disjoint-b">b</a>)
</pre>

Returns whether two sets are disjoint.

Two sets are disjoint if they have no elements in common.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_disjoint-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_disjoint-b>
      <td><code>b</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _get_shorter_and_longer

<pre>
_get_shorter_and_longer(<a href="#_get_shorter_and_longer-a">a</a>, <a href="#_get_shorter_and_longer-b">b</a>)
</pre>

Returns two sets in the order of shortest and longest.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_get_shorter_and_longer-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_get_shorter_and_longer-b>
      <td><code>b</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _insert

<pre>
_insert(<a href="#_insert-s">s</a>, <a href="#_insert-e">e</a>)
</pre>

Inserts an element into the set.

Element must be hashable.  This mutates the orginal set.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_insert-s>
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_insert-e>
      <td><code>e</code></td>
      <td>
        required.
        <p>
          The element to be inserted.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _intersection

<pre>
_intersection(<a href="#_intersection-a">a</a>, <a href="#_intersection-b">b</a>)
</pre>

Returns the intersection of two sets.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_intersection-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_intersection-b>
      <td><code>b</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _is_equal

<pre>
_is_equal(<a href="#_is_equal-a">a</a>, <a href="#_is_equal-b">b</a>)
</pre>

Returns whether two sets are equal.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_is_equal-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_is_equal-b>
      <td><code>b</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _is_subset

<pre>
_is_subset(<a href="#_is_subset-a">a</a>, <a href="#_is_subset-b">b</a>)
</pre>

Returns whether `a` is a subset of `b`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_is_subset-a>
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_is_subset-b>
      <td><code>b</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _length

<pre>
_length(<a href="#_length-s">s</a>)
</pre>

Returns the number of elements in a set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_length-s>
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _make

<pre>
_make(<a href="#_make-elements">elements</a>)
</pre>

Creates a new set.

All elements must be hashable.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_make-elements>
      <td><code>elements</code></td>
      <td>
        optional. default is <code>None</code>
        <p>
          Optional sequence to construct the set out of.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _remove

<pre>
_remove(<a href="#_remove-s">s</a>, <a href="#_remove-e">e</a>)
</pre>

Removes an element from the set.

Element must be hashable.  This mutates the orginal set.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_remove-s>
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="_remove-e>
      <td><code>e</code></td>
      <td>
        required.
        <p>
          The element to be removed.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _repr

<pre>
_repr(<a href="#_repr-s">s</a>)
</pre>

Returns a string value representing the set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_repr-s>
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _to_list

<pre>
_to_list(<a href="#_to_list-s">s</a>)
</pre>

Creates a list from the values in the set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_to_list-s>
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _union

<pre>
_union(<a href="#_union-args">args</a>)
</pre>

Returns the union of several sets.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_union-args>
      <td><code>args</code></td>
      <td>
        required.
      </td>
    </tr>
  </tbody>
</table>


