# Copyright 2018 The Bazel Authors. All rights reserved.
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

"""Maprule implementation in Starlark.

This module exports:

- The cmd_maprule() and bash_maprule() build rules.
  They are the same except for the interpreter they use (cmd.exe and Bash respectively) and for the
  expected language of their `cmd` attribute. We will refer to them collectively as `maprule`.

- The maprule_testing struct. This should only be used by maprule's own unittests.
"""

load("//lib:dicts.bzl", "dicts")
load("//lib:paths.bzl", "paths")
load(
    ":maprule_util.bzl",
    "BASH_STRATEGY",
    "CMD_STRATEGY",
    "fail_if_errors",
    "resolve_locations",
)

_cmd_maprule_intro = """
Maprule that runs a Windows Command Prompt (`cmd.exe`) command.

This rule is the same as `bash_maprule`, but uses `cmd.exe` instead of Bash, therefore the `cmd`
attribute must use Command Prompt syntax. `cmd_maprule` rules can only be built on Windows.
"""

_bash_maprule_intro = """
Maprule that runs a Bash command.

This rule is the same as `cmd_maprule` except this one uses Bash to run the command, therefore the
`cmd` attribute must use Bash syntax. `bash_maprule` rules can only be built if Bash is installed on
the build machine.
"""

_cmd_maprule_example = """
    # This file is //projects/game:BUILD

    load("@bazel_skylib//rules:maprule.bzl", "cmd_maprule")

    cmd_maprule(
        name = "process_assets",
        foreach_srcs = [
            "rust.png",
            "teapot.3ds",
            "//assets:wood.jpg",
            "//assets:models",
        ],
        outs_templates = {
            "TAGS": "{src}.tags",
            "DIGEST": "digests/{src_name_noext}.md5",
        },
        tools = [
            "//bin:asset-tagger",
            "//util:md5sum",
        ],
        add_env = {
            "ASSET_TAGGER": "$(location //bin:asset-tagger)",
            "MD5SUM": "$(location //util:md5sum)",
        },

        # Note: this command should live in a script file, we only inline it in the `cmd` attribute
        # for the sake of demonstration. See Tips and Tricks section.
        cmd = "%MAPRULE_ASSET_TAGGER% --input=%MAPRULE_SRC% --output=%MAPRULE_TAGS% & " +
              'IF /I "%ERRORLEVEL%" EQU "0" ( %MAPRULE_MD5SUM% %MAPRULE_SRC% &gt; %MAPRULE_DIGEST% )',
    )
"""

_bash_maprule_example = """
    # This file is //projects/game:BUILD

    load("@bazel_skylib//rules:maprule.bzl", "bash_maprule")

    bash_maprule(
        name = "process_assets",
        foreach_srcs = [
            "rust.png",
            "teapot.3ds",
            "//assets:wood.jpg",
            "//assets:models",
        ],
        outs_templates = {
            "TAGS": "{src}.tags",
            "DIGEST": "digests/{src_name_noext}.md5",
        },
        tools = [
            "//bin:asset-tagger",
            "//util:md5sum",
        ],
        add_env = {
            "ASSET_TAGGER": "$(location //bin:asset-tagger)",
            "MD5SUM": "$(location //util:md5sum)",
        },

        # Note: this command should live in a script file, we only inline it in the `cmd` attribute
        # for the sake of demonstration. See Tips and Tricks section.
        cmd = '"$MAPRULE_ASSET_TAGGER" --input="$MAPRULE_SRC" --output="$MAPRULE_TAGS" && ' +
              '"$MAPRULE_MD5SUM" "$MAPRULE_SRC" &gt; "$MAPRULE_DIGEST"',
    )
"""

_rule_doc_template = """
{intro}

Maprule runs a specific command for each of the "foreach" source files. This allows processing
source files in parallel, to produce some outputs for each of them.

The name "maprule" indicates that this rule can be used to map source files to output files, and is
also a reference to "genrule" that inspired this rule's design (though there are significant
differences).

Below you will find an Example, Tips and Tricks, and an FAQ.

### Example

{example}

The "process_assets" rule above will execute the command in the `cmd` to process "rust.png",
"teapot.3ds", "//assets:wood.jpg", and every file in the "//assets:models" rule, producing the
corresponding .tags and .md5 files for each of them, under the following paths:

    bazel-bin/projects/game/process_assets_out/projects/game/rust.png.tags
    bazel-bin/projects/game/process_assets_out/digests/rust.md5
    bazel-bin/projects/game/process_assets_out/projects/game/teapot.3ds.tags
    bazel-bin/projects/game/process_assets_out/digests/teapot.md5
    bazel-bin/projects/game/process_assets_out/assets/wood.jpg.tags
    bazel-bin/projects/game/process_assets_out/digests/wood.md5
    ...

You can create downstream rules, for example a filegroup or genrule (or another maprule) that put
this rule in their `srcs` attribute and get all the .tags and .md5 files.

## Tips and Tricks

*(The Tips and Tricks section is the same for `cmd_maprule` and `bash_maprule`.)*

### Use script files instead of inlining commands in the `cmd` attribute.

Unless the command is trivial, don't try to write it in `cmd`.

Properly quoting parts of the command is challenging enough, add to that escaping for the BUILD
file's syntax and the `cmd` attribute quickly gets unmaintainably complex.

It's a lot easier and maintainable to create a script file such as "foo.sh" in `bash_maprule` or
"foo.bat" in `cmd_maprule` for the commands. To do that:

1. move the commands to a script file
2. add the script file to the `tools` attribute
3. add an entry to the `add_env` attribute, e.g. "`TOOL:&nbsp;"$(location :tool.sh)"`"
4. replace the `cmd` with just "$MAPRULE_FOO" (in `bash_maprule`) or "%MAPRULE_FOO%" (in
   `cmd_maprule`).

Doing this also avoids hitting command line length limits.

Example:

    cmd_maprule(
        ...
        srcs = ["//data:temperatures.txt"],
        tools = [
            "command.bat",
            ":weather-stats",
        ],
        add_env = {{
            "COMMAND": "$(location :command.bat)",
            "STATS_TOOL": "$(location :weather-stats-computer)",
            "TEMPERATURES": "$(location //data:temperatures.txt)",
        }},
        cmd = "%MAPRULE_COMMAND%",
    )

### Use the `add_env` attribute to pass tool locations to the command.

Entries in the `add_env` attribute may use "$(location)" references and may also use the same
placeholders as the `outs_templates` attribute. For example you can use this mechanism to pass extra
"$(location)" references of `tools` or `srcs` to the actions.

Example:

    cmd_maprule(
        ...
        foreach_srcs = [...],
        outs_templates = {{"STATS_OUT": "{{src}}-stats.txt"}},
        srcs = ["//data:temperatures.txt"],
        tools = [":weather-stats"],
        add_env = {{
            "STATS_TOOL": "$(location :weather-stats-computer)",
            "TEMPERATURES": "$(location //data:temperatures.txt)",
        }},
        cmd = "%MAPRULE_STATS_TOOL% --src=%MAPRULE_SRC% --data=%MAPRULE_TEMPERATURES% > %MAPRULE_STATS_OUT%",
    )

    cc_binary(
        name = "weather-stats",
        ...
    )

## Environment Variables

*(The Environment Variables section is the same for `cmd_maprule` and `bash_maprule`.)*

The rule defines several environment variables available to the command may reference. All of these
envvars names start with "MAPRULE_". You can add your own envvars with the `add_env` attribute.

The command can use some envvars, all named "MAPRULE_*&lt;something&gt;*".

The complete list of environment variables is:

-   "MAPRULE_SRC": the path of the current file from `foreach_srcs`
-   "MAPRULE_SRCS": the space-separated paths of all files in the `srcs` attribute
-   "MAPRULE_*&lt;OUT&gt;*": for each key name *&lt;OUT&gt;* in the `outs_templates` attribute, this
    is the path of the respective output file for the current source
-   "MAPRULE_*&lt;ENV&gt;*": for each key name *&lt;ENV&gt;* in the `add_env` attribute

## FAQ

*(The FAQ section is the same for `cmd_maprule` and `bash_maprule`.)*

### What's the motivation for maprule? What's wrong with genrule?

genrule creates a single action for all of its inputs. It requires specifying all output files.
Finally, it can only create Bash commands.

Maprule supports parallel processing of its inputs and doesn't require specifying all outputs, just
templates for the outputs. And not only Bash is supported (via `bash_maprule`) but so are
cmd.exe-style commands via `cmd_maprule`.

### `genrule.cmd` supports "$(location)" expressions, how come `*_maprule.cmd` doesn't?

Maprule deliberately omits support for this feature to avoid pitfalls with quoting and escaping, and
potential issues with paths containing spaces. Instead, maprule exports environment variables for
the input and outputs of the action, and allows the user to define extra envvars. These extra
envvars do support "$(location)" expressions, so you can pass paths of labels in `srcs` and `tools`.

### Why are all envvars exported with the "MAPRULE_" prefix?

To avoid conflicts with other envvars, whose names could also be attractive outs_templates names.

### Why do `outs_templates` and `add_env` keys have to be uppercase?

Because they are exported as all-uppercase envvars, so requiring that they be declared as uppercase
gives a visual cue of that. It also avoids clashes resulting from mixed lower-upper-case names like
"foo" and "Foo".

### Why don't `outs_templates` and `add_env` keys have to start with "MAPRULE_" even though they are exported as such?

For convenience. It seems to bring no benefit to have the user always type "MAPRULE_" in front of
the name when the rule itself could as well add it.

### Why are all outputs relative to "*&lt;maprule_pkg&gt;*/*&lt;maprule_name&gt;*_out/" ?

To ensure that maprules in the same package and with the same outs_templates produce distinct output
files.

### Why aren't `outs_templates` keys available as placeholders in the values of `add_env`?

Because `add_env` is meant to be used for passing extra "$(location)" information to the action, and
the output paths are already available as envvars for the action.
"""

def _is_relative_path(p):
    """Returns True if `p` is a relative path (considering Unix and Windows semantics)."""
    return p and p[0] != "/" and p[0] != "\\" and (
        len(p) < 2 or not p[0].isalpha() or p[1] != ":"
    )

def _validate_attributes(ctx_attr_outs_templates, ctx_attr_add_env):
    """Validates rule attributes and returns a list of error messages if there were errors."""
    errors = []

    envvars = {
        "MAPRULE_SRC": "the source file",
        "MAPRULE_SRCS": "the space-joined paths of the common sources",
    }

    if not ctx_attr_outs_templates:
        errors.append("ERROR: \"outs_templates\" must not be empty")

    names_to_paths = {}
    paths_to_names = {}

    # Check entries in "outs_templates".
    for name, path in ctx_attr_outs_templates.items():
        # Check the entry's name.
        envvar_for_name = "MAPRULE_" + name.upper()
        error_prefix = "ERROR: In \"outs_templates\" entry {\"%s\": \"%s\"}: " % (name, path)
        if not name:
            errors.append("ERROR: Bad entry in the \"outs_templates\" attribute: the name " +
                          "should not be empty.")
        elif name.upper() != name:
            errors.append(error_prefix + "the name should be all upper-case.")
        elif envvar_for_name in envvars:
            errors.append((error_prefix +
                           "please rename it, otherwise this output path would be exported " +
                           "as the environment variable \"%s\", conflicting with the " +
                           "environment variable of %s.") % (
                envvar_for_name,
                envvars[envvar_for_name],
            ))
        elif not path:
            errors.append(error_prefix + "output path should not be empty.")
        elif not _is_relative_path(path):
            errors.append(error_prefix + "output path should be relative.")
        elif ".." in path:
            errors.append(error_prefix + "output path should not contain uplevel references.")
        elif path in paths_to_names:
            errors.append(error_prefix +
                          "output path is already used for \"%s\"." % paths_to_names[path])
        envvars[envvar_for_name] = "the \"%s\" output file declared in the \"outs_templates\" attribute" % name
        names_to_paths[name] = path
        paths_to_names[path] = name

    # Check envvar names in "add_env".
    for name, value in ctx_attr_add_env.items():
        envvar_for_name = "MAPRULE_" + name.upper()
        error_prefix = "ERROR: In \"add_env\" entry {\"%s\": \"%s\"}: " % (name, value)
        if not name:
            errors.append("ERROR: Bad entry in the \"add_env\" attribute: the name should not be " +
                          "empty.")
        elif name.upper() != name:
            errors.append(error_prefix + "the name should be all upper-case.")
        elif envvar_for_name in envvars:
            errors.append((error_prefix +
                           "please rename it, otherwise it would be exported as \"%s\", " +
                           "conflicting with the environment variable of %s.") % (
                envvar_for_name,
                envvars[envvar_for_name],
            ))
        elif "$(location" in value:
            tokens = value.split("$(location")
            if len(tokens) != 2:
                errors.append(error_prefix + "use only one $(location) or $(locations) function.")
            elif ")" not in tokens[1]:
                errors.append(error_prefix +
                              "incomplete $(location) or $(locations) function, missing closing " +
                              "parenthesis")
        envvars[name] = "an additional environment declared in \"add_env\" as \"%s\"" % name

    return errors

def _src_placeholders(src, strategy):
    return {
        "src": strategy.as_path(src.short_path),
        "src_dir": strategy.as_path(paths.dirname(src.short_path) + "/"),
        "src_name": src.basename,
        "src_name_noext": (src.basename[:-len(src.extension) - 1] if len(src.extension) else src.basename),
    }

def _create_outputs(ctx, ctx_label_name, ctx_attr_outs_templates, strategy, foreach_srcs):
    errors = []
    outs_dicts = {}
    output_generated_by = {}
    all_output_files = []
    src_placeholders_dicts = {}
    output_path_prefix = ctx_label_name + "_out/"
    for src in foreach_srcs:
        src_placeholders_dicts[src] = _src_placeholders(src, strategy)

        outputs_for_src = {}
        for template_name, path in ctx_attr_outs_templates.items():
            output_path = path.format(**src_placeholders_dicts[src])
            if output_path in output_generated_by:
                existing_generator = output_generated_by[output_path]
                errors.append("\n".join([
                    "ERROR: output file generated multiple times:",
                    "  output file: " + output_path,
                    "  foreach_srcs file 1: " + existing_generator[0].short_path,
                    "  outs_templates entry 1: " + existing_generator[1],
                    "  foreach_srcs file 2: " + src.short_path,
                    "  outs_templates entry 2: " + template_name,
                ]))
            output_generated_by[output_path] = (src, template_name)
            output = ctx.actions.declare_file(output_path_prefix + output_path)
            outputs_for_src[template_name] = output
            all_output_files.append(output)
        outs_dicts[src] = outputs_for_src

    if errors:
        # For sake of Starlark unittest we return all_output_files, so the test can create dummy
        # generating actions for the files even in case of errors.
        return None, all_output_files, None, errors
    else:
        return outs_dicts, all_output_files, src_placeholders_dicts, None

def _custom_envmap(ctx, strategy, src_placeholders, outs_dict, resolved_add_env):
    return dicts.add(
        {
            "MAPRULE_" + k.upper(): strategy.as_path(v)
            for k, v in src_placeholders.items()
        },
        {
            "MAPRULE_" + k.upper(): strategy.as_path(v.path)
            for k, v in outs_dict.items()
        },
        {
            "MAPRULE_" + k.upper(): v
            for k, v in resolved_add_env.items()
        },
    )

def _maprule_main(ctx, strategy):
    errors = _validate_attributes(ctx.attr.outs_templates, ctx.attr.add_env)
    fail_if_errors(errors)

    # From "srcs": merge the depsets in the DefaultInfo.files of the targets.
    common_srcs = depset(transitive = [t[DefaultInfo].files for t in ctx.attr.srcs])
    common_srcs_list = common_srcs.to_list()

    # From "foreach_srcs": by accessing the attribute's value through ctx.files (a list, not a
    # depset), we flatten the depsets of DefaultInfo.files of the targets and merge them to a single
    # list.  This is fine, we would have to do this anyway, because we iterate over them later.
    foreach_srcs = ctx.files.foreach_srcs

    # Create the outputs for each file in "foreach_srcs".
    foreach_src_outs_dicts, all_outputs, src_placeholders_dicts, errors = _create_outputs(
        ctx,
        ctx.label.name,
        ctx.attr.outs_templates,
        strategy,
        foreach_srcs,
    )
    fail_if_errors(errors)

    progress_message = (ctx.attr.message or "Executing maprule") + " for %s" % ctx.label

    # Create the part of the environment variables map that all actions will share.
    common_envmap = dicts.add(
        ctx.configuration.default_shell_env,
        {"MAPRULE_SRCS": " ".join([strategy.as_path(p.path) for p in common_srcs_list])},
    )

    # Resolve "tools" runfiles and $(location) references in "add_env".
    inputs_from_tools, manifests_from_tools = ctx.resolve_tools(tools = ctx.attr.tools)
    add_env = resolve_locations(ctx, strategy, ctx.attr.add_env)

    # Create actions for each of the "foreach" sources.
    for src in foreach_srcs:
        strategy.create_action(
            ctx,
            inputs = depset(direct = [src], transitive = [common_srcs, inputs_from_tools]),
            outputs = foreach_src_outs_dicts[src].values(),
            # The custom envmap contains envvars specific to the current "src", such as MAPRULE_SRC.
            env = dicts.add(
                common_envmap,
                _custom_envmap(
                    ctx,
                    strategy,
                    src_placeholders_dicts[src],
                    foreach_src_outs_dicts[src],
                    add_env,
                ),
            ),
            command = ctx.attr.cmd,
            progress_message = progress_message,
            mnemonic = "Maprule",
            manifests_from_tools = manifests_from_tools,
        )

    return [DefaultInfo(files = depset(all_outputs))]

def _cmd_maprule_impl(ctx):
    return _maprule_main(ctx, CMD_STRATEGY)

def _bash_maprule_impl(ctx):
    return _maprule_main(ctx, BASH_STRATEGY)

_ATTRS = {
    "srcs": attr.label_list(
        allow_files = True,
        doc = "The set of source files common to all actions of this rule.",
    ),
    "add_env": attr.string_dict(
        doc = "Extra environment variables to define for the actions. Every variable's name " +
              "must be uppercase. Bazel will automatically prepend \"MAPRULE_\" to the name " +
              "when exporting the variable for the action. The values may use \"$(location)\" " +
              "expressions for labels declared in the `srcs` and `tools` attribute, and " +
              "may reference the same placeholders as the values of the `outs_templates` " +
              "attribute.",
    ),
    "cmd": attr.string(
        mandatory = True,
        doc = "The command to execute. It must be in the syntax corresponding to this maprule " +
              "type, e.g. for `bash_maprule` this must be a Bash command, and for `cmd_maprule` " +
              "a Windows Command Prompt (cmd.exe) command. Several environment variables are " +
              "available for this command, storing values like the paths of the input and output " +
              "files of the action. See the \"Environment Variables\" section for the complete " +
              "list of environment variables available to this command.",
    ),
    "foreach_srcs": attr.label_list(
        allow_files = True,
        mandatory = True,
        doc = "The set of sources that will be processed one by one in parallel, to produce " +
              "the templated outputs. Each of these source files will will be processed " +
              "individually by its own action.",
    ),
    "message": attr.string(
        doc = "A custom progress message to display as the actions are executed.",
    ),
    "outs_templates": attr.string_dict(
        allow_empty = False,
        mandatory = True,
        doc = "<p>Templates for the output files. Each key defines a name for an output file " +
              "and the value specifies a path template for that output. For each of the " +
              "files in `foreach_srcs` this rule creates one action that produces all of " +
              "these outputs. The paths of the particular output files for that input are " +
              "computed from the template. The ensure the resolved templates yield unique " +
              "paths, the following placeholders are supported in the path " +
              "templates:</p>" +
              "<ul>" +
              "<li>\"{src}\": same as \"{src_dir}/{src_name}\"</li>" +
              "<li>\"{src_dir}\": package path of the source file, and a trailing \"/\"</li>" +
              "<li>\"{src_name}\": base name of the source file</li>" +
              "<li>\"{src_name_noext}\": same as \"{src_name}\" without the file extension</li>" +
              "</ul>" +
              "<p>You may also add extra path components to the templates, as long as the path " +
              "template is relative and does not contain uplevel references (\"..\"). " +
              "Placeholders will be replaced by the values corresponding to the respective " +
              "input file in `foreach_srcs`. Every output file is generated under " +
              "&lt;bazel_bin&gt;/path/to/maprule/&lt;maprule_name&gt; + \"_outs/\".</p>",
    ),
    "tools": attr.label_list(
        cfg = "host",
        allow_files = True,
        doc = "Tools used by the command. The `cmd` attribute, and the values of the " +
              "`add_env` attribute may reference these tools in \"$(location)\" expressions, " +
              "similar to the genrule rule.",
    ),
}

# Maprule that uses Windows cmd.exe as the interpreter.
cmd_maprule = rule(
    implementation = _cmd_maprule_impl,
    doc = _rule_doc_template.format(
        intro = _cmd_maprule_intro,
        example = _cmd_maprule_example,
    ),
    attrs = _ATTRS,
)

# Maprule that uses Bash as the interpreter.
bash_maprule = rule(
    implementation = _bash_maprule_impl,
    doc = _rule_doc_template.format(
        intro = _bash_maprule_intro,
        example = _bash_maprule_example,
    ),
    attrs = _ATTRS,
)

# Only used in unittesting maprule.
maprule_testing = struct(
    cmd_strategy = CMD_STRATEGY,
    bash_strategy = BASH_STRATEGY,
    src_placeholders = _src_placeholders,
    validate_attributes = _validate_attributes,
    is_relative_path = _is_relative_path,
    custom_envmap = _custom_envmap,
    create_outputs = _create_outputs,
)
