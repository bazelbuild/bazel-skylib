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

"""Custom mnemonic tests for copy_directory.bzl"""

load("//lib:unittest.bzl", "analysistest", "asserts")

def _copy_directory_mnemonic_test_impl(ctx):
    env = analysistest.begin(ctx)

    expected_mmemonic = "FooBar"

    mnemonics = [target_action.mnemonic for target_action in analysistest.target_actions(env)]
    contains_expected_mnemonic = expected_mmemonic in mnemonics

    asserts.true(env, contains_expected_mnemonic)

    return analysistest.end(env)

copy_directory_mnemonic_test = analysistest.make(_copy_directory_mnemonic_test_impl)
