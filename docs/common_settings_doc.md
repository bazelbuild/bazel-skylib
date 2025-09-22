<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Common build setting rules

These rules return a BuildSettingInfo with the value of the build setting.
For label-typed settings, use the native label_flag and label_setting rules.

More documentation on how to use build settings at
https://bazel.build/extending/config#user-defined-build-settings

<a id="bool_flag"></a>

## bool_flag

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")

bool_flag(<a href="#bool_flag-name">name</a>, <a href="#bool_flag-scope">scope</a>)
</pre>

A bool-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bool_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bool_flag-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="bool_setting"></a>

## bool_setting

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "bool_setting")

bool_setting(<a href="#bool_setting-name">name</a>, <a href="#bool_setting-scope">scope</a>)
</pre>

A bool-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="bool_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="bool_setting-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="int_flag"></a>

## int_flag

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "int_flag")

int_flag(<a href="#int_flag-name">name</a>, <a href="#int_flag-make_variable">make_variable</a>, <a href="#int_flag-scope">scope</a>)
</pre>

An int-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="int_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="int_flag-make_variable"></a>make_variable |  If set, the build setting's value will be available as a Make variable with this name in the attributes of rules that list this build setting in their 'toolchains' attribute.   | String | optional |  `""`  |
| <a id="int_flag-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="int_setting"></a>

## int_setting

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "int_setting")

int_setting(<a href="#int_setting-name">name</a>, <a href="#int_setting-make_variable">make_variable</a>, <a href="#int_setting-scope">scope</a>)
</pre>

An int-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="int_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="int_setting-make_variable"></a>make_variable |  If set, the build setting's value will be available as a Make variable with this name in the attributes of rules that list this build setting in their 'toolchains' attribute.   | String | optional |  `""`  |
| <a id="int_setting-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="repeatable_string_flag"></a>

## repeatable_string_flag

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "repeatable_string_flag")

repeatable_string_flag(<a href="#repeatable_string_flag-name">name</a>, <a href="#repeatable_string_flag-scope">scope</a>)
</pre>

A build setting that accepts one or more string-typed settings on the command line, with the values concatenated into a single string list; for example, `--//my/setting=foo` `--//my/setting=bar` will be parsed as `["foo", "bar"]`. Contrast with `string_list_flag`
**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="repeatable_string_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="repeatable_string_flag-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="string_flag"></a>

## string_flag

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

string_flag(<a href="#string_flag-name">name</a>, <a href="#string_flag-make_variable">make_variable</a>, <a href="#string_flag-scope">scope</a>, <a href="#string_flag-values">values</a>)
</pre>

A string-typed build setting that can be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="string_flag-make_variable"></a>make_variable |  If set, the build setting's value will be available as a Make variable with this name in the attributes of rules that list this build setting in their 'toolchains' attribute.   | String | optional |  `""`  |
| <a id="string_flag-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |
| <a id="string_flag-values"></a>values |  The list of allowed values for this setting. An error is raised if any other value is given.   | List of strings | optional |  `[]`  |


<a id="string_list_flag"></a>

## string_list_flag

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "string_list_flag")

string_list_flag(<a href="#string_list_flag-name">name</a>, <a href="#string_list_flag-scope">scope</a>)
</pre>

A string list-typed build setting which expects its value on the command line to be given in comma-separated format; for example, `--//my/setting=foo,bar` will be parsed as `["foo", "bar"]`. Contrast with `repeatable_string_flag`.
**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_list_flag-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="string_list_flag-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="string_list_setting"></a>

## string_list_setting

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "string_list_setting")

string_list_setting(<a href="#string_list_setting-name">name</a>, <a href="#string_list_setting-scope">scope</a>)
</pre>

A string list-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_list_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="string_list_setting-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |


<a id="string_setting"></a>

## string_setting

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "string_setting")

string_setting(<a href="#string_setting-name">name</a>, <a href="#string_setting-make_variable">make_variable</a>, <a href="#string_setting-scope">scope</a>, <a href="#string_setting-values">values</a>)
</pre>

A string-typed build setting that cannot be set on the command line

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="string_setting-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="string_setting-make_variable"></a>make_variable |  If set, the build setting's value will be available as a Make variable with this name in the attributes of rules that list this build setting in their 'toolchains' attribute.   | String | optional |  `""`  |
| <a id="string_setting-scope"></a>scope |  The scope indicates where a flag can propagate to   | String | optional |  `"universal"`  |
| <a id="string_setting-values"></a>values |  The list of allowed values for this setting. An error is raised if any other value is given.   | List of strings | optional |  `[]`  |


<a id="BuildSettingInfo"></a>

## BuildSettingInfo

<pre>
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

BuildSettingInfo(<a href="#BuildSettingInfo-value">value</a>)
</pre>

A singleton provider that contains the raw value of a build setting

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="BuildSettingInfo-value"></a>value |  The value of the build setting in the current configuration. This value may come from the command line or an upstream transition, or else it will be the build setting's default.    |


