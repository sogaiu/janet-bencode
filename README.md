# janet-bencode

A janet bencode library based on [cmiles74's bencode
library](https://github.com/cmiles74/bencode).

## Why

When looking for a bencode library for use with Janet, cmiles74's
bencode library seemed close to what I was looking for but there were
a variety of things which I wanted to do differently in terms of
naming, constructs used, reduction of features, testing, etc.

I started by adding more tests to the functions in the original
bencode library and followed some of [fogus'
advice](https://blog.fogus.me/2018/11/27/starboy/) to help develop my
understanding.  `janet-bencode` is the result of these efforts.

## Usage

See the files in the [usages directory](usages).  ATM, the functions
meant as a public interface include:

* reading
  * `reader`
  * `stream-reader`
  * `read`
  * `read-buffer`
  * `read-stream`

* writing
  * `write`
  * `write-buffer`
  * `write-stream`

These are very similar to the originals but some of the features have
been removed (e.g. ignoring newlines) and names are not all the same.

## Generated Docs

The
[documentarian](https://github.com/pyrmont/documentarian)-generated
[api.md file](api.md) exists for convenience of reference.  Although
there is documentation for all functions, not all of them are meant to
be publically used.  See the Usage section above for those bits.

For each function listed on api.md, following the corresponding source
link should land one at the first line of the source code for the
function's definition.  Usually, there should be some example usages
for the function below its definition.

For example, the following sort of thing can be found for `read`:

```janet
(comment

  (read (reader (string "d"
                        "2:" "id"
                        "1:" "1"
                        "2:" "op"
                        "5:" "clone"
                        "e")))
  # =>
  {:id "1" :op "clone"}

  (read (reader ""))
  # =>
  nil

  (read (reader (string "d2:id1:12:op5:clonee"))
        true)
  # =>
  @{:id "1" :op "clone"}

  )
```

## Credits

* cmiles74 - bencode
* greenfork - bencode contributions
* felixr - bencode contributions
* pyrmont - discussion, documentarian, and
  [bencodobi](https://github.com/pyrmont/bencodobi)

