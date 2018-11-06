"""Helpers for creating repository rules.
"""

def maybe(repo_rule, name, **kwargs):
    """Conditionally define a repository if it does not already exist."""
    if name not in native.existing_rules():
        repo_rule(name = name, **kwargs)
