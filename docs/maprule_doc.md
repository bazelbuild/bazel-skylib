<a name="#bash_maprule"></a>
## bash_maprule

<pre>
bash_maprule(<a href="#bash_maprule-name">name</a>, <a href="#bash_maprule-add_env">add_env</a>, <a href="#bash_maprule-cmd">cmd</a>, <a href="#bash_maprule-foreach_srcs">foreach_srcs</a>, <a href="#bash_maprule-message">message</a>, <a href="#bash_maprule-outs_templates">outs_templates</a>, <a href="#bash_maprule-srcs">srcs</a>, <a href="#bash_maprule-tools">tools</a>)
</pre>



Maprule that runs a Bash command.

This rule is the same as `cmd_maprule` except this one uses Bash to run the command, therefore the
`cmd` attribute must use Bash syntax. `bash_maprule` rules can only be built if Bash is installed on
the build machine.


Maprule runs a specific command for each of the "foreach" source files. This allows processing
source files in parallel, to produce some outputs for each of them.

The name "maprule" indicates that this rule can be used to map source files to output files, and is
also a reference to "genrule" that inspired this rule's design (though there are significant
differences).

Below you will find an Example, Tips and Tricks, and an FAQ.

### Example


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
        add_env = {
            "COMMAND": "$(location :command.bat)",
            "STATS_TOOL": "$(location :weather-stats-computer)",
            "TEMPERATURES": "$(location //data:temperatures.txt)",
        },
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
        outs_templates = {"STATS_OUT": "{src}-stats.txt"},
        srcs = ["//data:temperatures.txt"],
        tools = [":weather-stats"],
        add_env = {
            "STATS_TOOL": "$(location :weather-stats-computer)",
            "TEMPERATURES": "$(location //data:temperatures.txt)",
        },
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


### Attributes

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="bash_maprule-name">
      <td><code>name</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#name">Name</a>; required
        <p>
          A unique name for this target.
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-add_env">
      <td><code>add_env</code></td>
      <td>
        <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a>; optional
        <p>
          Extra environment variables to define for the actions. Every variable's name must be uppercase. Bazel will automatically prepend "MAPRULE_" to the name when exporting the variable for the action. The values may use "$(location)" expressions for labels declared in the `srcs` and `tools` attribute, and may reference the same placeholders as the values of the `outs_templates` attribute.
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-cmd">
      <td><code>cmd</code></td>
      <td>
        String; required
        <p>
          The command to execute. It must be in the syntax corresponding to this maprule type, e.g. for `bash_maprule` this must be a Bash command, and for `cmd_maprule` a Windows Command Prompt (cmd.exe) command. Several environment variables are available for this command, storing values like the paths of the input and output files of the action. See the "Environment Variables" section for the complete list of environment variables available to this command.
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-foreach_srcs">
      <td><code>foreach_srcs</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a>; required
        <p>
          The set of sources that will be processed one by one in parallel, to produce the templated outputs. Each of these source files will will be processed individually by its own action.
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-message">
      <td><code>message</code></td>
      <td>
        String; optional
        <p>
          A custom progress message to display as the actions are executed.
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-outs_templates">
      <td><code>outs_templates</code></td>
      <td>
        <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a>; required
        <p>
          <p>Templates for the output files. Each key defines a name for an output file and the value specifies a path template for that output. For each of the files in `foreach_srcs` this rule creates one action that produces all of these outputs. The paths of the particular output files for that input are computed from the template. The ensure the resolved templates yield unique paths, the following placeholders are supported in the path templates:</p><ul><li>"{src}": same as "{src_dir}/{src_name}"</li><li>"{src_dir}": package path of the source file, and a trailing "/"</li><li>"{src_name}": base name of the source file</li><li>"{src_name_noext}": same as "{src_name}" without the file extension</li></ul><p>You may also add extra path components to the templates, as long as the path template is relative and does not contain uplevel references (".."). Placeholders will be replaced by the values corresponding to the respective input file in `foreach_srcs`. Every output file is generated under &lt;bazel_bin&gt;/path/to/maprule/&lt;maprule_name&gt; + "_outs/".</p>
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-srcs">
      <td><code>srcs</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a>; optional
        <p>
          The set of source files common to all actions of this rule.
        </p>
      </td>
    </tr>
    <tr id="bash_maprule-tools">
      <td><code>tools</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a>; optional
        <p>
          Tools used by the command. The `cmd` attribute, and the values of the `add_env` attribute may reference these tools in "$(location)" expressions, similar to the genrule rule.
        </p>
      </td>
    </tr>
  </tbody>
</table>


<a name="#cmd_maprule"></a>
## cmd_maprule

<pre>
cmd_maprule(<a href="#cmd_maprule-name">name</a>, <a href="#cmd_maprule-add_env">add_env</a>, <a href="#cmd_maprule-cmd">cmd</a>, <a href="#cmd_maprule-foreach_srcs">foreach_srcs</a>, <a href="#cmd_maprule-message">message</a>, <a href="#cmd_maprule-outs_templates">outs_templates</a>, <a href="#cmd_maprule-srcs">srcs</a>, <a href="#cmd_maprule-tools">tools</a>)
</pre>



Maprule that runs a Windows Command Prompt (`cmd.exe`) command.

This rule is the same as `bash_maprule`, but uses `cmd.exe` instead of Bash, therefore the `cmd`
attribute must use Command Prompt syntax. `cmd_maprule` rules can only be built on Windows.


Maprule runs a specific command for each of the "foreach" source files. This allows processing
source files in parallel, to produce some outputs for each of them.

The name "maprule" indicates that this rule can be used to map source files to output files, and is
also a reference to "genrule" that inspired this rule's design (though there are significant
differences).

Below you will find an Example, Tips and Tricks, and an FAQ.

### Example


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
        add_env = {
            "COMMAND": "$(location :command.bat)",
            "STATS_TOOL": "$(location :weather-stats-computer)",
            "TEMPERATURES": "$(location //data:temperatures.txt)",
        },
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
        outs_templates = {"STATS_OUT": "{src}-stats.txt"},
        srcs = ["//data:temperatures.txt"],
        tools = [":weather-stats"],
        add_env = {
            "STATS_TOOL": "$(location :weather-stats-computer)",
            "TEMPERATURES": "$(location //data:temperatures.txt)",
        },
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


### Attributes

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="cmd_maprule-name">
      <td><code>name</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#name">Name</a>; required
        <p>
          A unique name for this target.
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-add_env">
      <td><code>add_env</code></td>
      <td>
        <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a>; optional
        <p>
          Extra environment variables to define for the actions. Every variable's name must be uppercase. Bazel will automatically prepend "MAPRULE_" to the name when exporting the variable for the action. The values may use "$(location)" expressions for labels declared in the `srcs` and `tools` attribute, and may reference the same placeholders as the values of the `outs_templates` attribute.
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-cmd">
      <td><code>cmd</code></td>
      <td>
        String; required
        <p>
          The command to execute. It must be in the syntax corresponding to this maprule type, e.g. for `bash_maprule` this must be a Bash command, and for `cmd_maprule` a Windows Command Prompt (cmd.exe) command. Several environment variables are available for this command, storing values like the paths of the input and output files of the action. See the "Environment Variables" section for the complete list of environment variables available to this command.
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-foreach_srcs">
      <td><code>foreach_srcs</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a>; required
        <p>
          The set of sources that will be processed one by one in parallel, to produce the templated outputs. Each of these source files will will be processed individually by its own action.
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-message">
      <td><code>message</code></td>
      <td>
        String; optional
        <p>
          A custom progress message to display as the actions are executed.
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-outs_templates">
      <td><code>outs_templates</code></td>
      <td>
        <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a>; required
        <p>
          <p>Templates for the output files. Each key defines a name for an output file and the value specifies a path template for that output. For each of the files in `foreach_srcs` this rule creates one action that produces all of these outputs. The paths of the particular output files for that input are computed from the template. The ensure the resolved templates yield unique paths, the following placeholders are supported in the path templates:</p><ul><li>"{src}": same as "{src_dir}/{src_name}"</li><li>"{src_dir}": package path of the source file, and a trailing "/"</li><li>"{src_name}": base name of the source file</li><li>"{src_name_noext}": same as "{src_name}" without the file extension</li></ul><p>You may also add extra path components to the templates, as long as the path template is relative and does not contain uplevel references (".."). Placeholders will be replaced by the values corresponding to the respective input file in `foreach_srcs`. Every output file is generated under &lt;bazel_bin&gt;/path/to/maprule/&lt;maprule_name&gt; + "_outs/".</p>
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-srcs">
      <td><code>srcs</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a>; optional
        <p>
          The set of source files common to all actions of this rule.
        </p>
      </td>
    </tr>
    <tr id="cmd_maprule-tools">
      <td><code>tools</code></td>
      <td>
        <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a>; optional
        <p>
          Tools used by the command. The `cmd` attribute, and the values of the `add_env` attribute may reference these tools in "$(location)" expressions, similar to the genrule rule.
        </p>
      </td>
    </tr>
  </tbody>
</table>


