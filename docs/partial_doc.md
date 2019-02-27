## partial.make

<pre>
partial.make(<a href="#partial.make-func">func</a>, <a href="#partial.make-args">args</a>, <a href="#partial.make-kwargs">kwargs</a>)
</pre>

Creates a partial that can be called using `call`.

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

The positional args passed to the function are the args passed into make
followed by any additional positional args given to call. The below example
illustrates a function with two positional arguments where one is supplied by
make and the other by call:

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

prints:

  "Hello, Jennifer!"
  "Hello, Dave!"
  "Goodbye, Jennifer!"
  "Goodbye, Dave!"

The keyword args given to the function are the kwargs passed into make
unioned with the keyword args given to call. In case of a conflict, the
keyword args given to call take precedence. This allows you to set a default
value for keyword arguments and override it at the call site.

Example with a make site arg, a call site arg, a make site kwarg and a
call site kwarg:

  def _foo(make_arg1, call_arg1, make_location, call_location):
    print(make_arg1 + " is from " + make_location + " and " +
          call_arg1 + " is from " + call_location + "!")

  func = partial.make(_foo, "Ben", make_location="Hollywood")
  partial.call(func, "Jennifer", call_location="Denver")

Prints "Ben is from Hollywood and Jennifer is from Denver!".

  partial.call(func, "Jennifer", make_location="LA", call_location="Denver")

Prints "Ben is from LA and Jennifer is from Denver!".

Note that keyword args may not overlap with positional args, regardless of
whether they are given during the make or call step. For instance, you can't
do:

def foo(x):
  pass

func = partial.make(foo, 1)
partial.call(func, x=2)


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="partial.make-func">
      <td><code>func</code></td>
      <td>
        required.
        <p>
          The function to be called.
        </p>
      </td>
    </tr>
    <tr id="partial.make-args">
      <td><code>args</code></td>
      <td>
        optional.
        <p>
          Positional arguments to be passed to function.
        </p>
      </td>
    </tr>
    <tr id="partial.make-kwargs">
      <td><code>kwargs</code></td>
      <td>
        optional.
        <p>
          Keyword arguments to be passed to function. Note that these can
          be overridden at the call sites.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## partial.call

<pre>
partial.call(<a href="#partial.call-partial">partial</a>, <a href="#partial.call-args">args</a>, <a href="#partial.call-kwargs">kwargs</a>)
</pre>

Calls a partial created using `make`.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="partial.call-partial">
      <td><code>partial</code></td>
      <td>
        required.
        <p>
          The partial to be called.
        </p>
      </td>
    </tr>
    <tr id="partial.call-args">
      <td><code>args</code></td>
      <td>
        optional.
        <p>
          Additional positional arguments to be appended to the ones given to
       make.
        </p>
      </td>
    </tr>
    <tr id="partial.call-kwargs">
      <td><code>kwargs</code></td>
      <td>
        optional.
        <p>
          Additional keyword arguments to augment and override the ones
          given to make.
        </p>
      </td>
    </tr>
  </tbody>
</table>


