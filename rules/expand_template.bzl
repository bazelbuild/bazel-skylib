# Copyright 2022 The Bazel Authors. All rights reserved.
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

"""A rule that performes template expansion.
"""

def _expand_template_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.out,
        substitutions = ctx.attr.substitutions,
    )

_expand_template = rule(
    implementation = _expand_template_impl,
    attrs = {
        "template": attr.label(mandatory = True, allow_single_file = True),
        "substitutions": attr.string_dict(mandatory = True),
        "out": attr.output(mandatory = True),
    },
    output_to_genfiles = True,
)

def expand_template(name, template, substitutions, out):
    """Template expansion

    This performs a simple search over the template file for the keys in substitutions,
    and replaces them with the corresponding values.

    There is no special syntax for the keys.
    To avoid conflicts, you would need to explicitly add delimiters to the key strings, for example "{KEY}" or "@KEY@".

    Args:
      name: The name of the rule.
      template: The template file to expand
      out: The destination of the expanded file
      substitutions: A dictionary mapping strings to their substitutions
    """
    _expand_template(
        name = name,
        template = template,
        substitutions = substitutions,
        out = out,
    )
