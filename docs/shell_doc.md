<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#shell.array_literal"></a>

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
| :-------------: | :-------------: | :-------------: |
| iterable |  A sequence of elements. Elements that are not strings will be     converted to strings first, by calling <code>str()</code>.   |  none |


<a name="#shell.quote"></a>

## shell.quote

<pre>
shell.quote(<a href="#shell.quote-s">s</a>)
</pre>

Quotes the given string for use in a shell command.

This function quotes the given string (in case it contains spaces or other
shell metacharacters.)


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| s |  The string to quote.   |  none |


