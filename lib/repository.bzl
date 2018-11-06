# Copyright 2018 The Bazel Authors. All rights reserved.
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
