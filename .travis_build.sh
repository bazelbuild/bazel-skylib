#!/bin/bash

set -eu

# -------------------------------------------------------------------------------------------------
# Asked to do a bazel build.
if [[ -n "${BAZEL:-}" ]]; then
  bazel --bazelrc=/dev/null test --show_progress_rate_limit=30.0 //...
fi

# -------------------------------------------------------------------------------------------------
# Asked to do a buildifier run.
if [[ -n "${BUILDIFER:-}" ]]; then
  # bazelbuild/buildtools/issues/220 - diff doesn't include the file that needs updating
  # bazelbuild/buildtools/issues/221 - the exist status is always zero.
  if [[ -n "$(find . -name BUILD -print | xargs buildifier -v -d)" ]]; then
    echo "ERROR: BUILD file formatting issue(s)"
    find . -name BUILD -print -exec buildifier -v -d {} \;
    exit 1
  fi
fi
