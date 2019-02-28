## paths.basename

<pre>
paths.basename(<a href="#paths.basename-p">p</a>)
</pre>

Returns the basename (i.e., the file portion) of a path.

Note that if `p` ends with a slash, this function returns an empty string.
This matches the behavior of Python's `os.path.basename`, but differs from
the Unix `basename` command (which would return the path segment preceding
the final slash).


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.basename-p">
      <td><code>p</code></td>
      <td>
        required.
        <p>
          The path whose basename should be returned.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## paths.dirname

<pre>
paths.dirname(<a href="#paths.dirname-p">p</a>)
</pre>

Returns the dirname of a path.

The dirname is the portion of `p` up to but not including the file portion
(i.e., the basename). Any slashes immediately preceding the basename are not
included, unless omitting them would make the dirname empty.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.dirname-p">
      <td><code>p</code></td>
      <td>
        required.
        <p>
          The path whose dirname should be returned.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## paths.is_absolute

<pre>
paths.is_absolute(<a href="#paths.is_absolute-path">path</a>)
</pre>

Returns `True` if `path` is an absolute path.

### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.is_absolute-path">
      <td><code>path</code></td>
      <td>
        required.
        <p>
          A path (which is a string).
        </p>
      </td>
    </tr>
  </tbody>
</table>


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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.join-path">
      <td><code>path</code></td>
      <td>
        required.
        <p>
          A path segment.
        </p>
      </td>
    </tr>
    <tr id="paths.join-others">
      <td><code>others</code></td>
      <td>
        optional.
        <p>
          Additional path segments.
        </p>
      </td>
    </tr>
  </tbody>
</table>


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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.normalize-path">
      <td><code>path</code></td>
      <td>
        required.
        <p>
          A path.
        </p>
      </td>
    </tr>
  </tbody>
</table>


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


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.relativize-path">
      <td><code>path</code></td>
      <td>
        required.
        <p>
          The path to relativize.
        </p>
      </td>
    </tr>
    <tr id="paths.relativize-start">
      <td><code>start</code></td>
      <td>
        required.
        <p>
          The ancestor path against which to relativize.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## paths.replace_extension

<pre>
paths.replace_extension(<a href="#paths.replace_extension-p">p</a>, <a href="#paths.replace_extension-new_extension">new_extension</a>)
</pre>

Replaces the extension of the file at the end of a path.

If the path has no extension, the new extension is added to it.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.replace_extension-p">
      <td><code>p</code></td>
      <td>
        required.
        <p>
          The path whose extension should be replaced.
        </p>
      </td>
    </tr>
    <tr id="paths.replace_extension-new_extension">
      <td><code>new_extension</code></td>
      <td>
        required.
        <p>
          The new extension for the file. The new extension should
    begin with a dot if you want the new filename to have one.
        </p>
      </td>
    </tr>
  </tbody>
</table>


## paths.split_extension

<pre>
paths.split_extension(<a href="#paths.split_extension-p">p</a>)
</pre>

Splits the path `p` into a tuple containing the root and extension.

Leading periods on the basename are ignored, so
`path.split_extension(".bashrc")` returns `(".bashrc", "")`.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="paths.split_extension-p">
      <td><code>p</code></td>
      <td>
        required.
        <p>
          The path whose root and extension should be split.
        </p>
      </td>
    </tr>
  </tbody>
</table>


