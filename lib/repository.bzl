"""Helpers for creating repository rules.
"""

def _maybe(repo_rule, name, existing_rules = None, **kwargs):
    """Conditionally define a repository if it does not already exist.
    
    Args:
      repo_rule: The function to invoke. e.g. http_archive, git_archive, etc.
      name: The name to conditionally register.
      existing_rules: the set of preexisting rules to compare. Used for testing. Defaults to native.existing_rules()
    """
    if not existing_rules:
        existing_rules = native.existing_rules()
    if name not in existing_rules:
        repo_rule(name = name, **kwargs)


repository = struct(
    maybe = _maybe,
)
