## _after_each

<pre>
_after_each(<a href="#_after_each-separator">separator</a>, <a href="#_after_each-iterable">iterable</a>)
</pre>

Inserts `separator` after each item in `iterable`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_after_each-separator>
      <td><code>separator</code></td>
      <td>
        required.
        <p>
          The value to insert after each item in `iterable`.
        </p>
      </td>
    </tr>
    <tr id="_after_each-iterable>
      <td><code>iterable</code></td>
      <td>
        required.
        <p>
          The list into which to intersperse the separator.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _before_each

<pre>
_before_each(<a href="#_before_each-separator">separator</a>, <a href="#_before_each-iterable">iterable</a>)
</pre>

Inserts `separator` before each item in `iterable`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_before_each-separator>
      <td><code>separator</code></td>
      <td>
        required.
        <p>
          The value to insert before each item in `iterable`.
        </p>
      </td>
    </tr>
    <tr id="_before_each-iterable>
      <td><code>iterable</code></td>
      <td>
        required.
        <p>
          The list into which to intersperse the separator.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## _uniq

<pre>
_uniq(<a href="#_uniq-iterable">iterable</a>)
</pre>

Returns a list of unique elements in `iterable`.

Requires all the elements to be hashable.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="_uniq-iterable>
      <td><code>iterable</code></td>
      <td>
        required.
        <p>
          An iterable to filter.
        </p>
      </td>
    </tr>
  </tbody>
</table>


