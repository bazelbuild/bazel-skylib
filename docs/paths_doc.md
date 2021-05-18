<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#paths.basename"></a>

## paths.basename

<pre>
paths.basename(<a href="#paths.basename-p">p</a>)
</pre>

Returns the basename (i.e., the file portion) of a path.

Note that if `p` ends with a slash, this function returns an empty string.
This matches the behavior of Python's `os.path.basename`, but differs from
the Unix `basename` command (which would return the path segment preceding
the final slash).


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| p |  The path whose basename should be returned.   |  none |


<a name="#paths.dirname"></a>

## paths.dirname

<pre>
paths.dirname(<a href="#paths.dirname-p">p</a>)
</pre>

Returns the dirname of a path.

The dirname is the portion of `p` up to but not including the file portion
(i.e., the basename). Any slashes immediately preceding the basename are not
included, unless omitting them would make the dirname empty.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| p |  The path whose dirname should be returned.   |  none |


<a name="#paths.is_absolute"></a>

## paths.is_absolute

<pre>
paths.is_absolute(<a href="#paths.is_absolute-path">path</a>)
</pre>

Returns `True` if `path` is an absolute path.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| path |  A path (which is a string).   |  none |


<a name="#paths.join"></a>

## paths.join

<pre>
paths.join(<a href="#paths.join-path">path</a>, <a href="#paths.join-others">others</a>)
</pre>

Joins one or more path components intelligently.

This function mimics the behavior of Python's `os.path.join` function on POSIX
platform. It returns the concatenation of `path` and any members of `others`,
inserting directory separators before each component except the first. The
separator is not inserted if the path up until that point is either empty or
already ends in a separator.

If any component is an absolute path, all previous components are discarded.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| path |  A path segment.   |  none |
| others |  Additional path segments.   |  none |


<a name="#paths.normalize"></a>

## paths.normalize

<pre>
paths.normalize(<a href="#paths.normalize-path">path</a>)
</pre>

Normalizes a path, eliminating double slashes and other redundant segments.

This function mimics the behavior of Python's `os.path.normpath` function on
POSIX platforms; specifically:

- If the entire path is empty, "." is returned.
- All "." segments are removed, unless the path consists solely of a single
  "." segment.
- Trailing slashes are removed, unless the path consists solely of slashes.
- ".." segments are removed as long as there are corresponding segments
  earlier in the path to remove; otherwise, they are retained as leading ".."
  segments.
- Single and double leading slashes are preserved, but three or more leading
  slashes are collapsed into a single leading slash.
- Multiple adjacent internal slashes are collapsed into a single slash.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| path |  A path.   |  none |


<a name="#paths.relativize"></a>

## paths.relativize

<pre>
paths.relativize(<a href="#paths.relativize-path">path</a>, <a href="#paths.relativize-start">start</a>)
</pre>

Returns the portion of `path` that is relative to `start`.

Because we do not have access to the underlying file system, this
implementation differs slightly from Python's `os.path.relpath` in that it
will fail if `path` is not beneath `start` (rather than use parent segments to
walk up to the common file system root).

Relativizing paths that start with parent directory references only works if
the path both start with the same initial parent references.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| path |  The path to relativize.   |  none |
| start |  The ancestor path against which to relativize.   |  none |


<a name="#paths.replace_extension"></a>

## paths.replace_extension

<pre>
paths.replace_extension(<a href="#paths.replace_extension-p">p</a>, <a href="#paths.replace_extension-new_extension">new_extension</a>)
</pre>

Replaces the extension of the file at the end of a path.

If the path has no extension, the new extension is added to it.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| p |  The path whose extension should be replaced.   |  none |
| new_extension |  The new extension for the file. The new extension should     begin with a dot if you want the new filename to have one.   |  none |


<a name="#paths.split_extension"></a>

## paths.split_extension

<pre>
paths.split_extension(<a href="#paths.split_extension-p">p</a>)
</pre>

Splits the path `p` into a tuple containing the root and extension.

Leading periods on the basename are ignored, so
`path.split_extension(".bashrc")` returns `(".bashrc", "")`.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| p |  The path whose root and extension should be split.   |  none |


