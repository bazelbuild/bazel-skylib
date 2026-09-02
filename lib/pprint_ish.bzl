"""
A very limited version of Python's pprint module.

Note:
    This formats lists, dicts, etc. on multiple lines with simple indentation,
    not visual indentation.
"""

def pprint_ish(obj):
    """A limited version of pprint for debugging Starlark."""

    # Prefix newline to move content after the "DEBUG" line.
    print("\n" + pformat_ish(obj))

def pformat_ish(obj, prefix = "    "):
    """A limited version of pformat."""

    # Note: Can't recurse in Starlark at present?
    obj = _pformat_preprocess(obj)
    if type(obj) in ["list", "tuple"]:
        return _pformat_list(obj, prefix)
    elif type(obj) == "dict":
        return _pformat_dict(obj, prefix)
    elif type(obj) == "struct":
        return _pformat_struct(obj, prefix)
    else:
        return repr(obj)

def _pformat_preprocess(x):
    if type(x) == "depset":
        x = sorted(x.to_list())
    if type(x) == "Label":
        x = str(x)
    return x

def _pformat_list(obj, prefix):
    lines = ["["]
    for x in obj:
        x = _pformat_preprocess(x)
        lines.append(prefix + repr(x) + ",")
    lines += ["]"]
    return "\n".join(lines)

def _pformat_lvl_1(obj, prefix):
    obj = _pformat_preprocess(obj)

    # Partial recursion :/
    if type(obj) in ["list", "tuple"]:
        return _pformat_list(obj, prefix)
    else:
        return repr(obj)

def _pformat_dict(obj, prefix):
    lines = ["{"]
    for k, v in obj.items():
        k = _pformat_lvl_1(k, prefix)
        v = _pformat_lvl_1(v, prefix)
        s = k + ": " + v
        lines.append(_indent(s, prefix) + ",")
    lines.append("}")
    return "\n".join(lines)

def _pformat_struct(obj, prefix):
    lines = ["struct("]
    for k in dir(obj):
        v = getattr(obj, k)
        s = _pformat_lvl_1(v, prefix)
        lines.append(_indent(s, prefix) + ",")
    lines += [")"]
    return "\n".join(lines)

def _indent(s, prefix):
    return "\n".join([prefix + line for line in s.splitlines()])
