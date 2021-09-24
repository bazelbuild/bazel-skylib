<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#bool_flag"></a>

## bool_flag

<pre>
bool_flag(<a href="#bool_flag-name">name</a>)
</pre>

A bool-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a name="#bool_setting"></a>

## bool_setting

<pre>
bool_setting(<a href="#bool_setting-name">name</a>)
</pre>

A bool-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a name="#int_flag"></a>

## int_flag

<pre>
int_flag(<a href="#int_flag-name">name</a>)
</pre>

An int-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a name="#int_setting"></a>

## int_setting

<pre>
int_setting(<a href="#int_setting-name">name</a>)
</pre>

An int-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a name="#string_flag"></a>

## string_flag

<pre>
string_flag(<a href="#string_flag-name">name</a>, <a href="#string_flag-values">values</a>)
</pre>

A string-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| values |  The list of allowed values for this setting. An error is raised if any other value is given.   | List of strings | optional | [] |


<a name="#string_list_flag"></a>

## string_list_flag

<pre>
string_list_flag(<a href="#string_list_flag-name">name</a>)
</pre>

A string list-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a name="#string_list_setting"></a>

## string_list_setting

<pre>
string_list_setting(<a href="#string_list_setting-name">name</a>)
</pre>

A string list-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |


<a name="#string_setting"></a>

## string_setting

<pre>
string_setting(<a href="#string_setting-name">name</a>, <a href="#string_setting-values">values</a>)
</pre>

A string-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| values |  The list of allowed values for this setting. An error is raised if any other value is given.   | List of strings | optional | [] |


<a name="#BuildSettingInfo"></a>

## BuildSettingInfo

<pre>
BuildSettingInfo(<a href="#BuildSettingInfo-value">value</a>)
</pre>

A singleton provider that contains the raw value of a build setting

**FIELDS**


| Name  | Description |
| :-------------: | :-------------: |
| value |  The value of the build setting in the current configuration. This value may come from the command line or an upstream transition, or else it will be the build setting's default.    |


