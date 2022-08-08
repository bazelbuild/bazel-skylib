<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing convenience interfaces for select().

<a id="#selects.with_or"></a>

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


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="selects.with_or-input_dict"></a>input_dict |  The same dictionary <code>select()</code> takes, except keys may take either the usual form <code>"//foo:config1"</code> or <code>("//foo:config1", "//foo:config2", ...)</code> to signify <code>//foo:config1</code> OR <code>//foo:config2</code> OR <code>...</code>.   |  none |
| <a id="selects.with_or-no_match_error"></a>no_match_error |  Optional custom error to report if no condition matches.   |  <code>""</code> |

**RETURNS**

A native `select()` that expands

`("//configs:two", "//configs:three"): [":dep2or3"]`

to

```build
"//configs:two": [":dep2or3"],
"//configs:three": [":dep2or3"],
```


<a id="#selects.with_or_dict"></a>

## selects.with_or_dict

<pre>
selects.with_or_dict(<a href="#selects.with_or_dict-input_dict">input_dict</a>)
</pre>

Variation of `with_or` that returns the dict of the `select()`.

Unlike `select()`, the contents of the dict can be inspected by Starlark
macros.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="selects.with_or_dict-input_dict"></a>input_dict |  Same as <code>with_or</code>.   |  none |

**RETURNS**

A dictionary usable by a native `select()`.


<a id="#selects.config_setting_group"></a>

## selects.config_setting_group

<pre>
selects.config_setting_group(<a href="#selects.config_setting_group-name">name</a>, <a href="#selects.config_setting_group-match_any">match_any</a>, <a href="#selects.config_setting_group-match_all">match_all</a>, <a href="#selects.config_setting_group-visibility">visibility</a>)
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


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="selects.config_setting_group-name"></a>name |  The group's name. This is how <code>select()</code>s reference it.   |  none |
| <a id="selects.config_setting_group-match_any"></a>match_any |  A list of <code>config_settings</code>. This group matches if *any* member in the list matches. If this is set, <code>match_all</code> must not be set.   |  <code>[]</code> |
| <a id="selects.config_setting_group-match_all"></a>match_all |  A list of <code>config_settings</code>. This group matches if *every* member in the list matches. If this is set, <code>match_any</code> must be not set.   |  <code>[]</code> |
| <a id="selects.config_setting_group-visibility"></a>visibility |  Visibility of the config_setting_group.   |  <code>None</code> |


