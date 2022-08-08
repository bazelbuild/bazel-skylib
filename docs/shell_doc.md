<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing shell utility functions.

<a id="#shell.array_literal"></a>

## shell.array_literal

<pre>
shell.array_literal(<a href="#shell.array_literal-iterable">iterable</a>)
</pre>

Creates a string from a sequence that can be used as a shell array.

For example, `shell.array_literal(["a", "b", "c"])` would return the string
`("a" "b" "c")`, which can be used in a shell script wherever an array
literal is needed.

Note that all elements in the array are quoted (using `shell.quote`) for
safety, even if they do not need to be.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="shell.array_literal-iterable"></a>iterable |  A sequence of elements. Elements that are not strings will be converted to strings first, by calling <code>str()</code>.   |  none |

**RETURNS**

A string that represents the sequence as a shell array; that is,
parentheses containing the quoted elements.


<a id="#shell.quote"></a>

## shell.quote

<pre>
shell.quote(<a href="#shell.quote-s">s</a>)
</pre>

Quotes the given string for use in a shell command.

This function quotes the given string (in case it contains spaces or other
shell metacharacters.)


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="shell.quote-s"></a>s |  The string to quote.   |  none |

**RETURNS**

A quoted version of the string that can be passed to a shell command.


