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

# This is a replacement for native.genrule in macros, taking an argument
# vector instead of a command; in this vector, labels are replaced by their
# paths. Note that calling this macro is quite expensive and a proper rule
# would be the preferrable option, but it allows an easy transition for
# existing macros that hit the limit of stringified labels.

def _outer_name(name):
  """Convenience function to obtain a label in the name space of the outermost
     caller, even if provided as a non-absolute name."""
  if type(name) == type(Label("//:x")):
      return name
  return Label("//" + native.package_name(),
               relative_to_caller_repository=True).relative(name)

# In the implementation of generic_action we have to split the flexible
# argv that we allow, as rules accept only homogeneous lists of arguments.
# We are provideded with
# - tools: the list of tools required (a list of labels to be evaluated in
#   the configuration of the execution platform), and
# - outs: the list of names for the outputs.
# We then split the provided argv as follows, where we consider any labels
# found there that are not declared as tools or outs as additional sources.
# - argvstrings: a list of strings of the same length as the final argv. All
#   the string arguments are in their respective positions; positions with
#   labels are replaced with placeholder strings (for efficiency the empty
#   string).
# - argvtaketool: a list of ints, the same length as the final argv, where
#   non-negative entries indicate an index into the list of tools to be taken.
# - argvtakeoutput: a list of ints, the same length as the final argv, where
#   non-negative entries indicate an index into the list of outputs to be taken.
# - argvlabels: a lsit of additional labels referred to in the command line
# - argvtakelabel: the indices in argv where the argvlabels have to be put into
#   the final argv.

def _generic_action_rule_impl(ctx):
  """Implementation of the rule behind the generic_action macro"""
  newargv = []
  for i in range(len(ctx.attr.argvstrings)):
      if ctx.attr.argvtakeoutput[i] >= 0:
          newargv.append(ctx.outputs.outs[ctx.attr.argvtakeoutput[i]].path)
      elif ctx.attr.argvtaketool[i] >= 0:
          newargv.append(ctx.files.tools[ctx.attr.argvtaketool[i]].path)
      elif i in ctx.attr.argvtakelabel:
          newargv.append(
              ctx.files.argvlabels[ctx.attr.argvtakelabel.index(i)].path)
      else:
          newargv.append(ctx.attr.argvstrings[i])
  ctx.actions.run(
      executable = newargv[0],
      arguments = newargv[1:],
      inputs = ctx.files.tools + ctx.files.srcs + ctx.files.argvlabels,
      outputs = ctx.outputs.outs,
      use_default_shell_env = True,
   )

_generic_action_rule = rule(
    implementation = _generic_action_rule_impl,
    attrs = {
        "tools" : attr.label_list(cfg = "host", allow_files=True),
        "srcs" : attr.label_list(allow_files=True),
        "outs" : attr.output_list(),
        "argvstrings" : attr.string_list(),
        "argvtakeoutput" : attr.int_list(),
        "argvtaketool" : attr.int_list(),
        "argvlabels" : attr.label_list(allow_files=True, allow_empty=True),
        "argvtakelabel" : attr.int_list(),
    })


def _generic_action(name="", argv=[], tools=[], srcs=[], outs=[]):
    """A macro that generates a generic action, that can be used in other
macros. As opposed to a genrule, the command is given as an argv vector.
In this vector, labels are interpreted as path to the corresponding file,
whereas strings are taken literally. In this way, command lines can be
constructed that refer to paths in different repositories, typically a
tool or data file the repository the macro is defined in, and source
and output files in the calling repository.

So, a typical use would be as follows.
  ```python
  load("@bazel_tools//tools/build_rules:generic_action.bzl",
       "generic_action", "outer_name")
  def my_macro(name="", src=""):
    tool = Label("//package/in/local/repo:tool")
    data = Label("//pacakge/in/local/repo:config")
    input = outer_name(src)
    output = outer_name(name + ".out")
    generic_action(
      name = name,
      tools = [tool],
      srcs = [input, data],
      outs = [output],
      argv = [tool, "-c", data, "-o", output, input],
    )
  ```

Note, however, that rules generally are the better and more efficient solution
and also provide more flexibility.
"""
    newouts = []
    for out in outs:
        if type(out) == type(Label("//:x")):
            # As we cannot pass a label to an output list, we have to stringify
            # it here. However, we know that it will always be a label in the
            # repository of the outermost call, which is also the repository
            # where the call to the rule will be interpreted in. So a label
            # string "relative to the current repository", will always be
            # interpreted correctly.
            newouts.append("//" + out.package + ":" + out.name)
        else:
            newouts.append(out)
    argvstrings = []
    argvtakeoutput = []
    argvtaketool = []
    argvtakelabel = []
    argvlabels = []
    for i in range(len(argv)):
        arg = argv[i]
        if type(arg) == type(Label("//:x")):
            argvstrings.append("")
            if arg in outs:
                argvtakeoutput.append(outs.index(arg))
                argvtaketool.append(-1)
            elif arg in tools:
                argvtaketool.append(tools.index(arg))
                argvtakeoutput.append(-1)
            else:
                argvtakeoutput.append(-1)
                argvtaketool.append(-1)
                argvtakelabel.append(i)
                argvlabels.append(arg)
        else:
            argvtakeoutput.append(-1)
            argvtaketool.append(-1)
            argvstrings.append(arg)
    _generic_action_rule(
        name = name,
        tools = tools,
        srcs = srcs,
        outs = newouts,
        argvstrings = argvstrings,
        argvtakeoutput = argvtakeoutput,
        argvtaketool = argvtaketool,
        argvtakelabel = argvtakelabel,
        argvlabels = argvlabels,
    )

actions = struct(
  outer_name = _outer_name,
  generic_action = _generic_action,
)
