## sets.make

<pre>
sets.make(<a href="#sets.make-elements">elements</a>)
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
    <tr id="sets.make-elements">
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


## sets.copy

<pre>
sets.copy(<a href="#sets.copy-s">s</a>)
</pre>

Creates a new set from another set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.copy-s">
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


## sets.to_list

<pre>
sets.to_list(<a href="#sets.to_list-s">s</a>)
</pre>

Creates a list from the values in the set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.to_list-s">
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


## sets.insert

<pre>
sets.insert(<a href="#sets.insert-s">s</a>, <a href="#sets.insert-e">e</a>)
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
    <tr id="sets.insert-s">
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.insert-e">
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


## sets.contains

<pre>
sets.contains(<a href="#sets.contains-a">a</a>, <a href="#sets.contains-e">e</a>)
</pre>

Checks for the existence of an element in a set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.contains-a">
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.contains-e">
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


## sets.is_equal

<pre>
sets.is_equal(<a href="#sets.is_equal-a">a</a>, <a href="#sets.is_equal-b">b</a>)
</pre>

Returns whether two sets are equal.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.is_equal-a">
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.is_equal-b">
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


## sets.is_subset

<pre>
sets.is_subset(<a href="#sets.is_subset-a">a</a>, <a href="#sets.is_subset-b">b</a>)
</pre>

Returns whether `a` is a subset of `b`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.is_subset-a">
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.is_subset-b">
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


## sets.disjoint

<pre>
sets.disjoint(<a href="#sets.disjoint-a">a</a>, <a href="#sets.disjoint-b">b</a>)
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
    <tr id="sets.disjoint-a">
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.disjoint-b">
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


## sets.intersection

<pre>
sets.intersection(<a href="#sets.intersection-a">a</a>, <a href="#sets.intersection-b">b</a>)
</pre>

Returns the intersection of two sets.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.intersection-a">
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.intersection-b">
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


## sets.union

<pre>
sets.union(<a href="#sets.union-args">args</a>)
</pre>

Returns the union of several sets.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.union-args">
      <td><code>args</code></td>
      <td>
        optional.
        <p>
          An arbitrary number of sets or lists.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## sets.difference

<pre>
sets.difference(<a href="#sets.difference-a">a</a>, <a href="#sets.difference-b">b</a>)
</pre>

Returns the elements in `a` that are not in `b`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.difference-a">
      <td><code>a</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.difference-b">
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


## sets.length

<pre>
sets.length(<a href="#sets.length-s">s</a>)
</pre>

Returns the number of elements in a set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.length-s">
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


## sets.remove

<pre>
sets.remove(<a href="#sets.remove-s">s</a>, <a href="#sets.remove-e">e</a>)
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
    <tr id="sets.remove-s">
      <td><code>s</code></td>
      <td>
        required.
        <p>
          A set, as returned by `sets.make()`.
        </p>
      </td>
    </tr>
    <tr id="sets.remove-e">
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


## sets.repr

<pre>
sets.repr(<a href="#sets.repr-s">s</a>)
</pre>

Returns a string value representing the set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.repr-s">
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


## sets.str

<pre>
sets.str(<a href="#sets.str-s">s</a>)
</pre>

Returns a string value representing the set.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="sets.str-s">
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


