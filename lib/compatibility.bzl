"""TODO(trybka): Write module docstring."""

load(":selects.bzl", "selects")

INCOMPATIBLE_TARGET="@platforms//:incompatible"
INCOMPATIBLE_SETTING="@platforms//:incompatible_setting"

def _none_of_without_no_match(settings):
    settings_name = "_or_".join([s.split(":")[1] for s in settings])
    name = settings_name.replace(":", "-").replace("//", "").replace("/", "_")
    compat_name = "incompatible_with_" + name
    if not native.existing_rule(compat_name):
        # We need to make (or re-use?) constraint values within a single instance to avoid a duplicate label.
        native.constraint_value(name = compat_name, constraint_setting = INCOMPATIBLE_SETTING)
    return selects.with_or({"//conditions:default": [], tuple(settings): [":" + compat_name]})

def _any_of_without_no_match(settings):
    settings_name = "_or_".join([s.split(":")[1] for s in settings])
    name = settings_name.replace(":", "-").replace("//", "").replace("/", "_")
    compat_name = "compatible_with_any_of_" + name
    if not native.existing_rule(compat_name):
        native.constraint_value(name = compat_name, constraint_setting = INCOMPATIBLE_SETTING)
    return selects.with_or({tuple(settings): [], "//conditions:default": [":" + compat_name]})

def _all_of_without_no_match(settings):
    settings_name = "_and_".join([s.split(":")[1] for s in settings])
    name = settings_name.replace(":", "-").replace("//", "").replace("/", "_")
    if not native.existing_rule(name):
        selects.config_setting_group(name = name, match_all = settings)
    compat_name = "compatible_with_all_of_" + name
    if not native.existing_rule(compat_name + name):
        native.constraint_value(name = compat_name, constraint_setting = INCOMPATIBLE_SETTING)
    return select({":" + name: [], "//conditions:default": [":" + compat_name]})

verbose_compatibility = struct(
    all_of = _all_of_without_no_match,
    any_of = _any_of_without_no_match,
    none_of = _none_of_without_no_match,
)

# Another alternative:
# def compatibility(any_of = [], none_of = [], all_of = None):


def _none_of(settings):
    return selects.with_or({"//conditions:default": [], tuple(settings): [INCOMPATIBLE_TARGET]})

def _any_of(settings):
    no_match_error = "Didn't match any conditions." # TODO(trybka): concat setting names?
    return selects.with_or({tuple(settings): [],}, no_match_error = no_match_error)

def _all_of(settings):
    settings_name = "_and_".join([s.split(":")[1] for s in settings])
    name = settings_name.replace(":", "-").replace("//", "").replace("/", "_")
    if not native.existing_rule(name):
        selects.config_setting_group(name = name, match_all = settings)
    no_match_error = "Didn't match all conditions." # TODO(trybka): concat setting names?
    return select({":" + name: []}, no_match_error=no_match_error)

compatibility = struct(
    all_of = _all_of,  # optional?--just require the user to make their own config_setting_group.
    any_of = _any_of,
    none_of = _none_of,
)
