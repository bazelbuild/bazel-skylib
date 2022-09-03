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

def current_qualified_package():
    """
    Gets the current package as "qualified package".
    """
    label_str = "//" + native.package_name()
    repository = native.repository_name()
    if repository == "@":
        return "//" + native.package_name()
    else:
        return repository + "//" + native.package_name()

def to_label(label_str):
    """
    Converts any label string to a Label instance.
    Normally, Label() requires absolute paths, so this wraps the constructor to
    allow automatic scoping.
    This can be used to parse / canonicalize labels.
    """
    if label_str.startswith(":"):
        label_str = current_qualified_package() + label_str
    return Label(label_str)

def in_workspace(label, workspace):
    """True if given Label is in the specified workspace / repository."""
    if workspace.startswith("@"):
        fail("Please supply name without @")
    return label.workspace_name == workspace

def in_root_workspace(label):
    """True if given Label is in source workspace."""
    return in_workspace(label, "")

def workspace_name():
    """Repository name, but without leading @."""
    return strip_prefix("@", native.repository_name())

def in_current_package(label):
    """True if given label is in the current package."""
    return (
        label.workspace_name == workspace_name() and
        label.package == native.package_name()
    )

labels = struct(
    strip_prefix = strip_prefix,
    qualify_package = qualify_package,
    current_qualified_package = current_qualified_package,
    to_label = to_label,
    in_workspace = in_workspace,
    in_root_workspace = in_root_workspace,
    workspace_name = workspace_name,
    in_current_package = in_current_package,
)
