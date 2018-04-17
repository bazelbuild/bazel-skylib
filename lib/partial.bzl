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

"""Skylib module for working with partials.

https://docs.python.org/3/library/functools.html#functools.partial
"""

def _call(partial, *args, **kwargs):
  """Calls a partial created using `make`.

  Args:
    partial: The partial to be called.
    *args: Arguments to be passed to the partial.
    **kwargs: Keywords to be passed to the partial.

  Returns:
    Whatever the function in the partial returns.
  """
  function_args = partial.args + args
  function_kwargs = dict(partial.kwargs)
  function_kwargs.update(kwargs)
  return partial.function(*function_args, **function_kwargs)

def _make(func, *args, **kwargs):
  """Creates a partial that is can be called using `call`.

  A partial can have args assigned to it at the make site, and can have args
  passed to it at the call sites.

  A partial 'function' can be defined with positional args and kwargs:

    # function with no args
    def function1():
      ...

    # function with 2 args
    def function2(arg1, arg2):
      ...

    # function with 2 args and keyword args
    def function3(arg1, arg2, x, y):
      ...

  The positional args `args` are the positional `args` passed in at make with
  any call site `args` appended on the end. So if a partial is created with
  one make argument, and is called with one call argument the function needs
  to be defined as:

  # function demonstrating 1 arg at make site, and 1 arg at call site
  def _foo(make_arg1, func_arg1):
    print(make_arg1 + " " + func_arg1 + "!")

  For example:

  hi_func = partial.make(_foo, "Hello")
  bye_func = partial.make(_foo, "Goodbye")
  partial.call(hi_func, "Jennifer")
  partial.call(hi_func, "Dave")
  partial.call(bye_func, "Jennifer")
  partial.call(bye_func, "Dave")

  should print:
  "Hello, Jennifer!"
  "Hello, Dave!"
  "Goodbye, Jennifer!"
  "Goodbye, Dave!"

  `kwargs` is the union of the kwargs passsed in at make and any call site
  `kwargs`. This means that call site kwargs CAN override make kwargs. One
  potential use for this is if you want optional arguments with defaults.

  Example with a make site arg, a call site arg, a make site kwarg and a
  call site kwarg:
    def _foo(make_arg1, call_arg1, make_location, call_location):
      print(make_arg1 + " is from " + make_location + " and " +
            call_arg1 + " is from " + call_location + "!")

    func = partial.make(_foo, "Ben", make_location="Hollywood")
    partial.call(func, "Jennifer", call_location="Denver")

  Should print "Ben is from Hollywood and Jennifer is from Denver!".

    partial.call(func, "Jennifer", make_location="LA", call_location="Denver")

  Should print "Ben is from LA and Jennifer is from Denver!".

  Args:
    func: The function to be called.
    *args: Initial positional arguments to be passed to func.
    **kwargs: Initial kwargs to be passed to func.

  Returns:
    A new `partial` that can be called using `call`
  """
  return struct(function=func, args=args, kwargs=kwargs)

partial = struct(
    make=_make,
    call=_call,
)
