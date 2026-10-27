# Copyright 2026 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Convenience macro for declaring a constraint setting and its values."""

def constraint(name, values, default = None, **kwargs):
    """Declares a constraint setting and one or more constraint values.

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

    Args:
        name: Name of the generated `constraint_setting` target.
        values: Nonempty list of names for the generated `constraint_value`
            targets.
        default: Name of a value in `values` to use when a platform omits this
            setting. If `None`, the setting has no default.
        **kwargs: Common attributes passed to both the setting and its values,
            such as `visibility`, `tags`, or `testonly`.
    """
    if not values:
        fail("values must contain at least one constraint value name")
    if default != None and default not in values:
        fail("default must be one of the declared values: {}".format(default))

    native.constraint_setting(
        name = name,
        default_constraint_value = ":" + default if default != None else None,
        **kwargs
    )
    for value in values:
        native.constraint_value(
            name = value,
            constraint_setting = ":" + name,
            **kwargs
        )
