load("//lib:unittest.bzl", "asserts", "unittest")

def _basic_passing_test(ctx):
    """Unit tests for a basic library verification test."""
    env = unittest.begin(ctx)

    asserts.equals(env, 1, 1)

    return unittest.end(env)

basic_passing_test = unittest.make(_basic_passing_test)


def _basic_failing_test(ctx):
    """Unit tests for a basic library verification test that fails."""
    env = unittest.begin(ctx)

    asserts.equals(env, 1, 2)

    return unittest.end(env)

basic_failing_test = unittest.make(_basic_failing_test)
