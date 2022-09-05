"""
Skylib module containing additional sugar for resolving or analyzing labels
across workspaces / repositories and packages.
"""

# Possibly helpful pointers / complaints:
# https://github.com/bazelbuild/bazel/issues/16210

def strip_prefix(prefix, value):
    if not value.startswith(prefix):
        fail("bad")
    return value[len(prefix):]

def qualify_package(label):
    """
    Returns a "qualified package" name, that is "@repository//package".
    """
    if in_root_workspace(label):
        return "//" + label.package
    elif label.package == "":
        return "@" + label.workspace_name
    else:
        return "@" + label.workspace_name + "//" + label.package

def current_qualified_package(ctx = None):
    """
    Gets the current package as "qualified package".
    """
    label_str = "//" + package_name(ctx)
    repository = repository_name(ctx)
    if repository == "@":
        return "//" + package_name(ctx)
    else:
        return repository + "//" + package_name(ctx)

def to_label(label_str, ctx = None):
    """
    Converts any label string to a Label instance.

    Normally, Label() requires absolute paths, so this wraps the constructor to
    allow automatic scoping.

    This can be used to parse / canonicalize labels.
    """
    if type(label_str) == "Label":
        return label_str
    if label_str.startswith(":"):
        label_str = current_qualified_package(ctx) + label_str
    return Label(label_str)

def label_to_str(label, ctx = None):
    """
    Converts label to abbreviated string.

    For some reason, Bazel likes showing the more verbose label.
    """
    if in_current_package(label, ctx = ctx):
        return ":" + label.name
    else:
        if label.workspace_name == "" and repository_name(ctx) == "":
            repository_prefix = ""
        else:
            repository_prefix = "@" + label.workspace_name

        if label.package == "" and label.name == label.workspace_name:
            return repository_prefix
        elif (
            label.package == label.name or
            label.package.endswith("/" + label.name)
        ):
            return repository_prefix + "//" + label.package
        else:
            return str(label)

def labels_to_str_list(labels, ctx = None):
    return [label_to_str(label, ctx) for label in labels]

def in_workspace(label, workspace):
    """True if given Label is in the specified workspace / repository."""
    if workspace.startswith("@"):
        fail("Please supply name without @")
    return label.workspace_name == workspace

def in_root_workspace(label):
    """True if given Label is in source workspace."""
    return in_workspace(label, "")

def repository_name(ctx = None):
    if ctx == None:
        return native.repository_name()
    else:
        return ctx.attr.repository_name

def package_name(ctx = None):
    if ctx == None:
        return native.package_name()
    else:
        return ctx.attr.package_name

def workspace_name(ctx = None):
    """Repository name, but without leading @."""
    return strip_prefix("@", repository_name(ctx))

def in_current_package(label, ctx = None):
    """True if given label is in the current package."""
    return (
        label.workspace_name == workspace_name(ctx) and
        label.package == package_name(ctx)
    )

def in_same_package(a, b):
    return (
        a.workspace_name == b.workspace_name and
        a.package == b.package
    )

# Attributes for using these functions in analysis phase, where you cannot use
# native.repostiory_name() or native.package_name().
attrs = {
    "repository_name": attr.string(mandatory = True),
    "package_name": attr.string(mandatory = True),
}

"""Rolled-up access."""
labels = struct(
    strip_prefix = strip_prefix,
    qualify_package = qualify_package,
    current_qualified_package = current_qualified_package,
    to_label = to_label,
    label_to_str = label_to_str,
    labels_to_str_list = labels_to_str_list,
    in_workspace = in_workspace,
    in_root_workspace = in_root_workspace,
    package_name = package_name,
    repository_name = repository_name,
    workspace_name = workspace_name,
    in_current_package = in_current_package,
    in_same_package = in_same_package,
    attrs = attrs,
)
