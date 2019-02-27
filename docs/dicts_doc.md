## dicts.add

<pre>
dicts.add(<a href="#dicts.add-dictionaries">dictionaries</a>)
</pre>

Returns a new `dict` that has all the entries of the given dictionaries.

If the same key is present in more than one of the input dictionaries, the
last of them in the argument list overrides any earlier ones.

This function is designed to take zero or one arguments as well as multiple
dictionaries, so that it follows arithmetic identities and callers can avoid
special cases for their inputs: the sum of zero dictionaries is the empty
dictionary, and the sum of a single dictionary is a copy of itself.


### Parameters

<table class="params-table">
  <colgroup>
    <col class="col-param" />
    <col class="col-description" />
  </colgroup>
  <tbody>
    <tr id="dicts.add-dictionaries">
      <td><code>dictionaries</code></td>
      <td>
        optional.
        <p>
          Zero or more dictionaries to be added.
        </p>
      </td>
    </tr>
  </tbody>
</table>


