## shell.array_literal

<pre>
shell.array_literal(<a href="#shell.array_literal-iterable">iterable</a>)
</pre>

Creates a string from a sequence that can be used as a shell array.

For example, `shell.array_literal(["a", "b", "c"])` would return the string
`("a" "b" "c")`, which can be used in a shell script wherever an array
literal is needed.

Note that all elements in the array are quoted (using `shell.quote`) for
safety, even if they do not need to be.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="shell.array_literal-iterable">
      <td><code>iterable</code></td>
      <td>
        required.
        <p>
          A sequence of elements. Elements that are not strings will be
    converted to strings first, by calling `str()`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## shell.quote

<pre>
shell.quote(<a href="#shell.quote-s">s</a>)
</pre>

Quotes the given string for use in a shell command.

This function quotes the given string (in case it contains spaces or other
shell metacharacters.)


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="shell.quote-s">
      <td><code>s</code></td>
      <td>
        required.
        <p>
          The string to quote.
        </p>
      </td>
    </tr>
  </tbody>
</table>


