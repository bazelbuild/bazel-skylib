<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Skylib module containing common functions for working with native.subpackages()


<a id="subpackages.all"></a>

## subpackages.all

<pre>
subpackages.all(<a href="#subpackages.all-exclude">exclude</a>, <a href="#subpackages.all-allow_empty">allow_empty</a>, <a href="#subpackages.all-fully_qualified">fully_qualified</a>)
</pre>

List all direct subpackages of the current package regardless of directory depth.

The returned list contains all subpackages, but not subpackages of subpackages.

Example:
Assuming the following BUILD files exist:

    BUILD
    foo/BUILD
    foo/sub/BUILD
    bar/BUILD
    baz/deep/dir/BUILD

If the current package is '//' all() will return ['//foo', '//bar',
'//baz/deep/dir'].  //foo/sub is not included because it is a direct
subpackage of '//foo' not '//'

NOTE: fail()s if native.subpackages() is not supported.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="subpackages.all-exclude"></a>exclude |  see native.subpackages(exclude)   |  <code>[]</code> |
| <a id="subpackages.all-allow_empty"></a>allow_empty |  see native.subpackages(allow_empty)   |  <code>False</code> |
| <a id="subpackages.all-fully_qualified"></a>fully_qualified |  It true return fully qualified Labels for subpackages, otherwise returns subpackage path relative to current package.   |  <code>True</code> |

**RETURNS**

A mutable sorted list containing all sub-packages of the current Bazel
package.


<a id="subpackages.exists"></a>

## subpackages.exists

<pre>
subpackages.exists(<a href="#subpackages.exists-relative_path">relative_path</a>)
</pre>

Checks to see if relative_path is a direct subpackage of the current package.

Example:

    BUILD
    foo/BUILD
    foo/sub/BUILD

If the current package is '//' (the top-level BUILD file):
    subpackages.exists("foo") == True
    subpackages.exists("foo/sub") == False
    subpackages.exists("bar") == False

NOTE: fail()s if native.subpackages() is not supported in the current Bazel version.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="subpackages.exists-relative_path"></a>relative_path |  a path to a subpackage to test, must not be an absolute Label.   |  none |

**RETURNS**

True if 'relative_path' is a subpackage of the current package.


<a id="subpackages.supported"></a>

## subpackages.supported

<pre>
subpackages.supported()
</pre>





