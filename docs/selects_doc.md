<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#selects.with_or"></a>

## selects.with_or

<pre>
selects.with_or(<a href="#selects.with_or-input_dict">input_dict</a>, <a href="#selects.with_or-no_match_error">no_match_error</a>)
</pre>

Drop-in replacement for `select()` that supports ORed keys.

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
        </p>
      </td>
    </tr>
  </tbody>
</table>


<a name="#selects.with_or_dict"></a>

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


<a name="#selects.config_setting_group"></a>

## selects.config_setting_group

<pre>
selects.config_setting_group(<a href="#selects.config_setting_group-name">name</a>, <a href="#selects.config_setting_group-match_any">match_any</a>, <a href="#selects.config_setting_group-match_all">match_all</a>)
</pre>

Matches if all or any of its member `config_setting`s match.

Example:

  ```build
  config_setting(name = "one", define_values = {"foo": "true"})
  config_setting(name = "two", define_values = {"bar": "false"})
  config_setting(name = "three", define_values = {"baz": "more_false"})

  config_setting_group(
      name = "one_two_three",
      match_all = [":one", ":two", ":three"]
  )

  cc_binary(
      name = "myapp",
      srcs = ["myapp.cc"],
      deps = select({
          ":one_two_three": [":special_deps"],
          "//conditions:default": [":default_deps"]
      })
  ```


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="selects.config_setting_group-name">
      <td><code>name</code></td>
      <td>
        required.
        <p>
          The group's name. This is how `select()`s reference it.
        </p>
      </td>
    </tr>
    <tr id="selects.config_setting_group-match_any">
      <td><code>match_any</code></td>
      <td>
        optional. default is <code>[]</code>
        <p>
          A list of `config_settings`. This group matches if *any* member
    in the list matches. If this is set, `match_all` must not be set.
        </p>
      </td>
    </tr>
    <tr id="selects.config_setting_group-match_all">
      <td><code>match_all</code></td>
      <td>
        optional. default is <code>[]</code>
        <p>
          A list of `config_settings`. This group matches if *every*
    member in the list matches. If this is set, `match_any` must be not
    set.
        </p>
      </td>
    </tr>
  </tbody>
</table>


