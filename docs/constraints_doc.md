<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Convenience macro for declaring a constraint setting and its values.

<a id="constraint"></a>

## constraint

<pre>
load("@bazel_skylib//rules:constraints.bzl", "constraint")

constraint(<a href="#constraint-name">name</a>, <a href="#constraint-values">values</a>, <a href="#constraint-default">default</a>, <a href="#constraint-kwargs">**kwargs</a>)
</pre>

Declares a constraint setting and one or more constraint values.

The setting is named `name`. Each entry in `values` is the name of a
separate `constraint_value` target in the same package. Value names must
be distinct from each other and from the setting name.

For example:

```starlark
load("@bazel_skylib//rules:constraints.bzl", "constraint")

constraint(
    name = "runtime",
    values = ["minimal", "full"],
    default = "minimal",
)
```

This declares the setting `:runtime` and the values `:minimal` and `:full`.
A platform can select at most one value for the setting. A platform that
omits the setting uses `:minimal` in this example.

To declare an opt-in capability, omit `default`:

```starlark
constraint(name = "network_support", values = ["network"])
```

A platform must then explicitly include `:network` to satisfy that
constraint; omitting it does not imply support.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="constraint-name"></a>name |  Name of the generated `constraint_setting` target.   |  none |
| <a id="constraint-values"></a>values |  Nonempty list of names for the generated `constraint_value` targets.   |  none |
| <a id="constraint-default"></a>default |  Name of a value in `values` to use when a platform omits this setting. If `None`, the setting has no default.   |  `None` |
| <a id="constraint-kwargs"></a>kwargs |  Common attributes passed to both the setting and its values, such as `visibility`, `tags`, or `testonly`.   |  none |


