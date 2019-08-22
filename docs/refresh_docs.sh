#!/bin/bash -e

bazel build //docs:* || (echo ERROR: Could not build //docs:* ; exit 1)
for generated in ../bazel-bin/docs/*_gen.md ; do
  dest_name=$(basename "$generated" | sed -e 's/_gen.md/.md/')
  if ! cmp -s "$generated" "$dest_name" ; then
    echo updating "$dest_name"
    cp "$generated" "$dest_name"
  fi
done
