## collections.after_each

<pre>
collections.after_each(<a href="#collections.after_each-separator">separator</a>, <a href="#collections.after_each-iterable">iterable</a>)
</pre>

Inserts `separator` after each item in `iterable`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="collections.after_each-separator">
      <td><code>separator</code></td>
      <td>
        required.
        <p>
          The value to insert after each item in `iterable`.
        </p>
      </td>
    </tr>
    <tr id="collections.after_each-iterable">
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


## collections.before_each

<pre>
collections.before_each(<a href="#collections.before_each-separator">separator</a>, <a href="#collections.before_each-iterable">iterable</a>)
</pre>

Inserts `separator` before each item in `iterable`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="collections.before_each-separator">
      <td><code>separator</code></td>
      <td>
        required.
        <p>
          The value to insert before each item in `iterable`.
        </p>
      </td>
    </tr>
    <tr id="collections.before_each-iterable">
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


## collections.uniq

<pre>
collections.uniq(<a href="#collections.uniq-iterable">iterable</a>)
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
    <tr id="collections.uniq-iterable">
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


