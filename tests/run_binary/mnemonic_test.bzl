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

"""Custom mnemonic tests for run_binary.bzl"""

load("//lib:unittest.bzl", "analysistest", "asserts")

def _run_binary_mnemonic_test_impl(ctx):
    env = analysistest.begin(ctx)

    expected_mmemonic = "FooBar"
    actual_mnemonic = analysistest.target_actions(env)[0].mnemonic

    asserts.equals(env, expected_mmemonic, actual_mnemonic)

    return analysistest.end(env)

run_binary_mnemonic_test = analysistest.make(_run_binary_mnemonic_test_impl)
