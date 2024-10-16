"""Repo rule and module extension used to test modules.apparent_repo_name"""

load("//lib:modules.bzl", "modules")

def _apparent_repo_name_test_repo_impl(repository_ctx):
    repo_name = modules.apparent_repo_name(repository_ctx)
    test_file = "repo-name.bzl"
    repository_ctx.file("WORKSPACE")
    repository_ctx.file("BUILD", """exports_files(["%s"])""" % test_file)
    repository_ctx.file(test_file, "REPO_NAME = \"%s\"" % repo_name)

apparent_repo_name_test_repo = repository_rule(
    _apparent_repo_name_test_repo_impl,
)

def apparent_repo_name_test_macro(*args):
    apparent_repo_name_test_repo(name = "apparent-repo-name-test")

apparent_repo_name_test_ext = module_extension(
    lambda _: apparent_repo_name_test_macro(),
    doc = "Only used for testing modules.apparent_repo_name()",
)
