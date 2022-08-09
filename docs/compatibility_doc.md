<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module of convenience functions for `target_compatible_with`.

Load the macros as follows in your `BUILD` files:
```build
load("@bazel_skylib//lib:compatibility.bzl", "compatibility")
```

See the [Platform docs](https://bazel.build/docs/platforms#skipping-incompatible-targets) for
more information.


<a id="#compatibility.all_of"></a>

## compatibility.all_of

<pre>
compatibility.all_of(<a href="#compatibility.all_of-settings">settings</a>)
</pre>

Create a `select()` for `target_compatible_with` which matches all of the given settings.

All of the settings must be true to get an empty list. Failure to match will result
in an incompatible constraint_value for the purpose of target skipping.

In other words, use this function to make a target incompatible unless all of the settings are
true.

Example:

```build
config_setting(
    name = "dbg",
    values = {"compilation_mode": "dbg"},
)

cc_binary(
    name = "bin",
    srcs = ["bin.cc"],
    # This target can only be built for Linux in debug mode.
    target_compatible_with = compatibility.all_of([
        ":dbg",
        "@platforms//os:linux",
    ]),
)
```

See also: `selects.config_setting_group(match_all)`


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compatibility.all_of-settings"></a>settings |  A list of <code>config_setting</code> or <code>constraint_value</code> targets.   |  none |

**RETURNS**

A native `select()` which is "incompatible" unless all settings are true.


<a id="#compatibility.any_of"></a>

## compatibility.any_of

<pre>
compatibility.any_of(<a href="#compatibility.any_of-settings">settings</a>)
</pre>

Create a `select()` for `target_compatible_with` which matches any of the given settings.

Any of the settings will resolve to an empty list, while the default condition will map to
an incompatible constraint_value for the purpose of target skipping.

In other words, use this function to make target incompatible unless one or more of the
settings are true.

```build
cc_binary(
    name = "bin",
    srcs = ["bin.cc"],
    # This target can only be built for Linux or Mac.
    target_compatible_with = compatibility.any_of([
        "@platforms//os:linux",
        "@platforms//os:macos",
    ]),
)
```


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compatibility.any_of-settings"></a>settings |  A list of <code>config_settings</code> or <code>constraint_value</code> targets.   |  none |

**RETURNS**

A native `select()` which maps any of the settings an empty list.


<a id="#compatibility.none_of"></a>

## compatibility.none_of

<pre>
compatibility.none_of(<a href="#compatibility.none_of-settings">settings</a>)
</pre>

Create a `select()` for `target_compatible_with` which matches none of the given settings.

Any of the settings will resolve to an incompatible constraint_value for the
purpose of target skipping.

In other words, use this function to make target incompatible if any of the settings are true.

```build
cc_binary(
    name = "bin",
    srcs = ["bin.cc"],
    # This target cannot be built for Linux or Mac, but can be built for
    # everything else.
    target_compatible_with = compatibility.none_of([
        "@platforms//os:linux",
        "@platforms//os:macos",
    ]),
)
```


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="compatibility.none_of-settings"></a>settings |  A list of <code>config_setting</code> or <code>constraint_value</code> targets.   |  none |

**RETURNS**

A native `select()` which maps any of the settings to the incompatible target.


