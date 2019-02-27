## selects.with_or

<pre>
selects.with_or(<a href="#selects.with_or-input_dict">input_dict</a>, <a href="#selects.with_or-no_match_error">no_match_error</a>)
</pre>

Drop-in replacement for `select()` that supports ORed keys.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="selects.with_or-input_dict">
      <td><code>input_dict</code></td>
      <td>
        required.
        <p>
          The same dictionary `select()` takes, except keys may take
    either the usual form `"//foo:config1"` or
    `("//foo:config1", "//foo:config2", ...)` to signify
    `//foo:config1` OR `//foo:config2` OR `...`.
        </p>
      </td>
    </tr>
    <tr id="selects.with_or-no_match_error">
      <td><code>no_match_error</code></td>
      <td>
        optional. default is <code>""</code>
        <p>
          Optional custom error to report if no condition matches.

    Example:

    ```build
    deps = selects.with_or({
        "//configs:one": [":dep1"],
        ("//configs:two", "//configs:three"): [":dep2or3"],
        "//configs:four": [":dep4"],
        "//conditions:default": [":default"]
    })
    ```

    Key labels may appear at most once anywhere in the input.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## selects.with_or_dict

<pre>
selects.with_or_dict(<a href="#selects.with_or_dict-input_dict">input_dict</a>)
</pre>

Variation of `with_or` that returns the dict of the `select()`.

Unlike `select()`, the contents of the dict can be inspected by Starlark
macros.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="selects.with_or_dict-input_dict">
      <td><code>input_dict</code></td>
      <td>
        required.
        <p>
          Same as `with_or`.
        </p>
      </td>
    </tr>
  </tbody>
</table>


