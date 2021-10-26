#!/usr/bin/env bash

# Copyright 2019 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# A script to manually regenerate the documentation contained in the docs/ directory.
# Should be run from the WORKSPACE root.

set -euo pipefail

bazel build docs:all

for filename in bazel-bin/docs/*_gen.md; do
    target_filename="$(echo $filename | sed -En "s/bazel-bin\/(.*)_gen.md/\1/p").md"
    cp $filename $target_filename
done
