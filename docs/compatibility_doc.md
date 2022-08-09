<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module of convenience functions for `target_compatible_with`.

<a id="#compatibility.all_of"></a>

## compatibility.all_of

<pre>
compatibility.all_of(<a href="#compatibility.all_of-settings">settings</a>)
</pre>

Create a `select()` which matches all of the given config_settings.

All of the settings must be true to get an empty list. Failure to match will result
in an incompatible constraint_value for the purpose of target skipping.

See also: `selects.config_setting_group(match_all)`


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compatibility.all_of-settings"></a>settings |  A list of <code>config_settings</code>.   |  none |

**RETURNS**

A native `select()` which is "incompatible" unless all `config_settings` are true.


<a id="#compatibility.any_of"></a>

## compatibility.any_of

<pre>
compatibility.any_of(<a href="#compatibility.any_of-settings">settings</a>)
</pre>

Create a `select()` which matches any of the given config_settings.

Any of the settings will resolve to an empty list, while the default condition will map to
an incompatible constraint_value for the purpose of target skipping.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compatibility.any_of-settings"></a>settings |  A list of <code>config_settings</code>.   |  none |

**RETURNS**

A native `select()` which maps any of the settings an empty list.


<a id="#compatibility.none_of"></a>

## compatibility.none_of

<pre>
compatibility.none_of(<a href="#compatibility.none_of-settings">settings</a>)
</pre>

Create a `select()` which matches none of the given config_settings.

Any of the settings will resolve to an incompatible constraint_value for the
purpose of target skipping.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compatibility.none_of-settings"></a>settings |  A list of <code>config_settings</code>.   |  none |

**RETURNS**

A native `select()` which maps any of the settings to the incompatible target.


