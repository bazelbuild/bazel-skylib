# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""Unix shell commands toolchain support.

Defines a toolchain capturing common Unix shell commands, see `unix_toolchain`,
and `unix_configure` to scan the local environment for shell commands. The list
of known commands is available in `unix.commands`.

"""

load("@bazel_tools//tools/cpp:lib_cc_configure.bzl", "get_cpu_value")
load(":paths.bzl", "paths")

# List of Unix commands as specified by IEEE Std 1003.1-2008.
# Extracted from https://en.wikipedia.org/wiki/List_of_Unix_commands.
_commands = [
    "admin",
    "alias",
    "ar",
    "asa",
    "at",
    "awk",
    "basename",
    "batch",
    "bc",
    "bg",
    "cc",
    "c99",
    "cal",
    "cat",
    "cd",
    "cflow",
    "chgrp",
    "chmod",
    "chown",
    "cksum",
    "cmp",
    "comm",
    "command",
    "compress",
    "cp",
    "crontab",
    "csplit",
    "ctags",
    "cut",
    "cxref",
    "date",
    "dd",
    "delta",
    "df",
    "diff",
    "dirname",
    "du",
    "echo",
    "ed",
    "env",
    "ex",
    "expand",
    "expr",
    "false",
    "fc",
    "fg",
    "file",
    "find",
    "fold",
    "fort77",
    "fuser",
    "gencat",
    "get",
    "getconf",
    "getopts",
    "grep",
    "hash",
    "head",
    "iconv",
    "id",
    "ipcrm",
    "ipcs",
    "jobs",
    "join",
    "kill",
    "lex",
    "link",
    "ln",
    "locale",
    "localedef",
    "logger",
    "logname",
    "lp",
    "ls",
    "m4",
    "mailx",
    "make",
    "man",
    "mesg",
    "mkdir",
    "mkfifo",
    "more",
    "mv",
    "newgrp",
    "nice",
    "nl",
    "nm",
    "nohup",
    "od",
    "paste",
    "patch",
    "pathchk",
    "pax",
    "pr",
    "printf",
    "prs",
    "ps",
    "pwd",
    "qalter",
    "qdel",
    "qhold",
    "qmove",
    "qmsg",
    "qrerun",
    "qrls",
    "qselect",
    "qsig",
    "qstat",
    "qsub",
    "read",
    "renice",
    "rm",
    "rmdel",
    "rmdir",
    "sact",
    "sccs",
    "sed",
    "sh",
    "sleep",
    "sort",
    "split",
    "strings",
    "strip",
    "stty",
    "tabs",
    "tail",
    "talk",
    "tee",
    "test",
    "time",
    "touch",
    "tput",
    "tr",
    "true",
    "tsort",
    "tty",
    "type",
    "ulimit",
    "umask",
    "unalias",
    "uname",
    "uncompress",
    "unexpand",
    "unget",
    "uniq",
    "unlink",
    "uucp",
    "uudecode",
    "uuencode",
    "uustat",
    "uux",
    "val",
    "vi",
    "wait",
    "wc",
    "what",
    "who",
    "write",
    "xargs",
    "yacc",
    "zcat",
]

TOOLCHAIN_TYPE = "@bazel_skylib//toolchains/unix:toolchain_type"
MAKE_VARIABLES = "@bazel_skylib//toolchains/unix:make_variables"

def _unix_toolchain_impl(ctx):
    commands = {}
    for cmd in _commands:
        cmd_path = getattr(ctx.attr, cmd, None)
        if not cmd_path:
            cmd_path = None
        commands[cmd] = cmd_path
    cmd_paths = {
        paths.dirname(cmd_path): None
        for cmd_path in commands.values()
        if cmd_path
    }.keys()
    return [platform_common.ToolchainInfo(
        commands = commands,
        paths = cmd_paths,
    )]

unix_toolchain = rule(
    attrs = {
        cmd: attr.string(
            doc = "Absolute path to the {} command.".format(cmd),
            mandatory = False,
        )
        for cmd in _commands
    },
    doc = """
A toolchain capturing standard Unix shell commands.

Provides:
  commands: Dict of String, an item per command holding the path to the executable or None.
  paths: List of String, deduplicated bindir paths. Suitable for generating `$PATH`.

Use `unix_configure` to create an instance of this toolchain.
See `unix_make_variables` on how to use this toolchain in genrules.
""",
    implementation = _unix_toolchain_impl,
)

def _unix_make_variables_impl(ctx):
    toolchain = ctx.toolchains[TOOLCHAIN_TYPE]
    cmd_vars = {
        "UNIX_%s" % cmd.upper(): cmd_path
        for cmd in _commands
        for cmd_path in [toolchain.commands[cmd]]
        if cmd_path
    }
    return [platform_common.TemplateVariableInfo(cmd_vars)]

unix_make_variables = rule(
    doc = """
Provides Unix toolchain commands as custom make variables.

Make variables:
  Provides a make variable of the form `UNIX_<COMMAND>` for each available
  command, where `<COMMAND>` is the name of the command in upper case.

Use `unix.MAKE_VARIABLES` instead of instantiating this rule yourself.

Example:
  >>> genrule(
          name = "use-grep",
          srcs = [":some-file"],
          outs = ["grep-out"],
          cmd = "$(UNIX_GREP) search $(execpath :some-file) > $(OUTS)",
          toolchains = [unix.MAKE_VARIABLES],
      )
""",
    implementation = _unix_make_variables_impl,
    toolchains = [TOOLCHAIN_TYPE],
)

def _unix_config_impl(repository_ctx):
    cpu = get_cpu_value(repository_ctx)
    commands = {}
    for cmd in _commands:
        cmd_path = repository_ctx.which(cmd)
        if cmd_path == None and cpu == "x64_windows":
            cmd_path = repository_ctx.which(cmd + ".exe")
        commands[cmd] = cmd_path
    repository_ctx.file("BUILD.bazel", executable = False, content = """
load("@bazel_skylib//lib:unix.bzl", "unix_toolchain")
unix_toolchain(
    name = "local_unix",
    visibility = ["//visibility:public"],
    {commands}
)
toolchain(
    name = "local_unix_toolchain",
    toolchain = ":local_unix",
    toolchain_type = "{toolchain_type}",
    exec_compatible_with = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:{os}",
    ],
    target_compatible_with = [
        "@bazel_tools//platforms:x86_64",
        "@bazel_tools//platforms:{os}",
    ],
)
""".format(
        commands = ",\n    ".join([
            '{cmd} = "{path}"'.format(cmd = cmd, path = cmd_path)
            for (cmd, cmd_path) in commands.items()
            if cmd_path
        ]),
        os = {
            "darwin": "osx",
            "x64_windows": "windows",
        }.get(cpu, "linux"),
        toolchain_type = TOOLCHAIN_TYPE,
    ))

_unix_config = repository_rule(
    environ = ["PATH"],
    local = True,
    implementation = _unix_config_impl,
)

def unix_configure(name = "local_unix_config"):
    """Autodetect local Unix commands.

    Scans the environment (`$PATH`) for standard shell commands, generates a
    corresponding unix toolchain and registers the toolchain.
    """
    _unix_config(name = name)
    native.register_toolchains("@{}//:local_unix_toolchain".format(name))

unix = struct(
    commands = _commands,
    TOOLCHAIN_TYPE = TOOLCHAIN_TYPE,
    MAKE_VARIABLES = MAKE_VARIABLES,
)
