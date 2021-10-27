<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Common build setting rules

These rules return a BuildSettingInfo with the value of the build setting.
For label-typed settings, use the native label_flag and label_setting rules.

More documentation on how to use build settings at
https://docs.bazel.build/versions/main/skylark/config.html#user-defined-build-settings


<a id="#bool_flag"></a>

## bool_flag

<pre>
bool_flag(<a href="#bool_flag-name">name</a>)
</pre>

A bool-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bool_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a id="#bool_setting"></a>

## bool_setting

<pre>
bool_setting(<a href="#bool_setting-name">name</a>)
</pre>

A bool-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bool_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a id="#int_flag"></a>

## int_flag

<pre>
int_flag(<a href="#int_flag-name">name</a>)
</pre>

An int-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="int_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a id="#int_setting"></a>

## int_setting

<pre>
int_setting(<a href="#int_setting-name">name</a>)
</pre>

An int-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="int_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a id="#string_flag"></a>

## string_flag

<pre>
string_flag(<a href="#string_flag-name">name</a>, <a href="#string_flag-values">values</a>)
</pre>

A string-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="string_flag-values"></a>values |  The list of allowed values for this setting. An error is raised if any other value is given.   | List of strings | optional | [] |


<a id="#string_list_flag"></a>

## string_list_flag

<pre>
string_list_flag(<a href="#string_list_flag-name">name</a>)
</pre>

A string list-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_list_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a id="#string_list_setting"></a>

## string_list_setting

<pre>
string_list_setting(<a href="#string_list_setting-name">name</a>)
</pre>

A string list-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_list_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a id="#string_setting"></a>

## string_setting

<pre>
string_setting(<a href="#string_setting-name">name</a>, <a href="#string_setting-values">values</a>)
</pre>

A string-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="string_setting-values"></a>values |  The list of allowed values for this setting. An error is raised if any other value is given.   | List of strings | optional | [] |


<a id="#BuildSettingInfo"></a>

## BuildSettingInfo

<pre>
BuildSettingInfo(<a href="#BuildSettingInfo-value">value</a>)
</pre>

A singleton provider that contains the raw value of a build setting

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="BuildSettingInfo-value"></a>value |  The value of the build setting in the current configuration. This value may come from the command line or an upstream transition, or else it will be the build setting's default.    |


