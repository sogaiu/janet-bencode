# janet-bencode API

## janet-bencode/bencode

[compact-reader](#compact-reader), [digit?](#digit), [end?](#end), [parse-error](#parse-error), [peek](#peek), [pushback](#pushback), [read](#read), [read-buffer](#read-buffer), [read-byte](#read-byte), [read-byte-buffer](#read-byte-buffer), [read-byte-stream](#read-byte-stream), [read-dictionary](#read-dictionary), [read-integer](#read-integer), [read-integer-bytes](#read-integer-bytes), [read-list](#read-list), [read-stream](#read-stream), [read-string](#read-string), [read-value](#read-value), [reader](#reader), [stream-reader](#stream-reader), [stream-reader?](#stream-reader-1), [write](#write), [write-buffer](#write-buffer), [write-dictionary](#write-dictionary), [write-integer](#write-integer), [write-list](#write-list), [write-stream](#write-stream), [write-string](#write-string)

## compact-reader

**function**  | [source][1]

```janet
(compact-reader a-reader)
```

If `a-reader` is backed by a stream, clears the buffer and resets the
index.

[1]: janet-bencode/bencode.janet#L716

## digit?

**function**  | [source][2]

```janet
(digit? byte)
```

Returns true if `byte` represents a digit.

[2]: janet-bencode/bencode.janet#L324

## end?

**function**  | [source][3]

```janet
(end? a-reader)
```

Returns true if `a-reader`'s index points to the end of the buffer.

[3]: janet-bencode/bencode.janet#L158

## parse-error

**function**  | [source][4]

```janet
(parse-error message &opt a-reader)
```

Throws an error with `message`.

If optional parameter `a-reader` is given, the error will include the
index for `a-reader`.

[4]: janet-bencode/bencode.janet#L94

## peek

**function**  | [source][5]

```janet
(peek a-reader)
```

Returns the byte at `a-reader`'s current index.

[5]: janet-bencode/bencode.janet#L126

## pushback

**function**  | [source][6]

```janet
(pushback a-reader)
```

Decrements the current index of `a-reader` if data has been read
at least once before.

Otheriwse, throws an error.

[6]: janet-bencode/bencode.janet#L405

## read

**function**  | [source][7]

```janet
(read a-reader &opt mut)
```

Reads the next bencoded value from `a-reader`, but returns nil if
there is no data left to read.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[7]: janet-bencode/bencode.janet#L757

## read-buffer

**function**  | [source][8]

```janet
(read-buffer a-buffer &opt mut)
```

Reads the first bencoded value from `a-buffer`, but returns nil if
there is no data to read.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[8]: janet-bencode/bencode.janet#L794

## read-byte

**function**  | [source][9]

```janet
(read-byte a-reader)
```

Reads the next byte from `a-reader`.  If the reader wraps a network
stream, this function may block until data is available on the
network stream.

[9]: janet-bencode/bencode.janet#L287

## read-byte-buffer

**function**  | [source][10]

```janet
(read-byte-buffer a-reader)
```

Return a byte from `a-reader`.  The reader's index is incremented as
well.

[10]: janet-bencode/bencode.janet#L199

## read-byte-stream

**function**  | [source][11]

```janet
(read-byte-stream a-reader)
```

Return a byte from the stream reader `a-reader`, possibly fetching
it from the network first.  The reader's index is incremented as
well.

The returned byte is ultimately read from the reader's buffer,
but as it is possible that the desired byte is not yet in the
reader's buffer, an attempt may be made to fetch it from the
network via the reader's stream into the buffer.

Since the reader's stream may not have any data available around
the time of a call to this function, this can result in the call
to this function blocking.

[11]: janet-bencode/bencode.janet#L229

## read-dictionary

**function**  | [source][12]

```janet
(read-dictionary a-reader &opt mut)
```

Reads a dictionary from `a-reader`.

Assumes the dictionary's leading delimiter "d" is at the reader's
current index.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[12]: janet-bencode/bencode.janet#L572

## read-integer

**function**  | [source][13]

```janet
(read-integer a-reader)
```

Reads a bencoded integer from `a-reader`.

Assumes the integer's leading delimiter "i" is at the reader's current
index.

[13]: janet-bencode/bencode.janet#L441

## read-integer-bytes

**function**  | [source][14]

```janet
(read-integer-bytes a-reader)
```

Reads the next integer from `a-reader`'s buffer.

Note that the integer may have a leading minus sign.

Bytes continue to be read as long as each byte represents a digit.

[14]: janet-bencode/bencode.janet#L357

## read-list

**function**  | [source][15]

```janet
(read-list a-reader &opt mut)
```

Reads a list from `a-reader`.

Assumes the list's leading delimiter "l" is at the reader's current
index.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[15]: janet-bencode/bencode.janet#L519

## read-stream

**function**  | [source][16]

```janet
(read-stream stream &opt mut)
```

Reads the first bencoded value from `stream`.

If there is no data in `stream` to be read, this function will block
until data is available.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[16]: janet-bencode/bencode.janet#L834

## read-string

**function**  | [source][17]

```janet
(read-string a-reader &opt mut)
```

Reads a bencoded binary string from `a-reader`.

Assumes the string's length prefix starts at the current index.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[17]: janet-bencode/bencode.janet#L477

## read-value

**function**  | [source][18]

```janet
(read-value a-reader &opt mut)
```

Reads the next bencoded value from `a-reader`, but returns nil if
there is no data left to read.

If the optional parameter `mut` is truthy, then the result uses
mutable data structures (the default is nil).

[18]: janet-bencode/bencode.janet#L635

## reader

**function**  | [source][19]

```janet
(reader a-buffer)
```

Returns a "reader" for `a-buffer`.

A reader is a table with the following keys:

* :buffer - the buffer being read
* :index - index of the current byte in the buffer

When :index is associated with -1, it means that there is no current
byte.

[19]: janet-bencode/bencode.janet#L1

## stream-reader

**function**  | [source][20]

```janet
(stream-reader stream)
```

Returns a "reader" for `stream`.

A stream reader is a table with the following keys:

* :buffer - the data read from the stream
* :index - index of the current byte in the buffer
* :stream - the stream being read from

When :index is associated with -1, it means that there is no current
byte.

[20]: janet-bencode/bencode.janet#L51

## stream-reader?

**function**  | [source][21]

```janet
(stream-reader? a-reader)
```

Truthy if `a-reader` is a stream reader.

[21]: janet-bencode/bencode.janet#L27

## write

**function**  | [source][22]

```janet
(write data)
```

Returns a buffer with the bencoded representation of `data`.

Keywords will be turned into strings (i.e. :key becomes "key").

[22]: janet-bencode/bencode.janet#L957

## write-buffer

**function**  | [source][23]

```janet
(write-buffer a-buffer data)
```

Write the bencoded representation of `data` to `a-buffer`.

Keywords will be turned into strings (i.e. :key becomes "key").

[23]: janet-bencode/bencode.janet#L928

## write-dictionary

**function**  | [source][24]

```janet
(write-dictionary a-buffer a-dict)
```

Writes the bencoded representation of `a-dict to `a-buffer`.

Keywords are transformed into strings (i.e. :key becomes "key").

[24]: janet-bencode/bencode.janet#L902

## write-integer

**function**  | [source][25]

```janet
(write-integer a-buffer an-int)
```

Writes the bencoded representation of `an-int` to `a-buffer`.

[25]: janet-bencode/bencode.janet#L871

## write-list

**function**  | [source][26]

```janet
(write-list a-buffer a-list)
```

Writes the bencoded representation of `a-list` to `a-buffer`.

[26]: janet-bencode/bencode.janet#L892

## write-stream

**function**  | [source][27]

```janet
(write-stream stream data)
```

Writes the bencoded representation of `data` to `stream`.

Keywords will be turned into strings (i.e. :key becomes "key").

[27]: janet-bencode/bencode.janet#L944

## write-string

**function**  | [source][28]

```janet
(write-string a-buffer a-string)
```

Writes the bencoded representation of `a-string` to `a-buffer`.

[28]: janet-bencode/bencode.janet#L880

