(defn reader
  ``
  Returns a "reader" for `a-buffer`.

  A reader is a table with the following keys:

  * :buffer - the buffer being read
  * :index - index of the current byte in the buffer

  When :index is associated with -1, it means that there is no current
  byte.
  ``
  [a-buffer]
  @{:buffer a-buffer
    :index -1})

(comment

  (reader @"hello")
  # =>
  @{:buffer @"hello" :index -1}

  )

########################################################################

(defn stream-reader?
  ``
  Truthy if `a-reader` is a stream reader.
  ``
  [a-reader]
  # XXX: not checking values atm
  (and (table? a-reader)
       (has-key? a-reader :buffer)
       #(buffer? (get a-reader :buffer))
       (has-key? a-reader :index)
       #(int? (get a-reader :index))
       #(<= -1 (get a-reader :index))
       (has-key? a-reader :stream)
       #(= :core/stream (type (get a-reader :stream)))
       ))

(comment

  (stream-reader? (reader @""))
  # =>
  false

  )

(defn stream-reader
  ``
  Returns a "reader" for `stream`.

  A stream reader is a table with the following keys:

  * :buffer - the data read from the stream
  * :index - index of the current byte in the buffer
  * :stream - the stream being read from

  When :index is associated with -1, it means that there is no current
  byte.
  ``
  [stream]
  @{:buffer @""
    :index -1
    :stream stream})

(comment

  (let [[host port] ["127.0.0.1" "63251"]
        data @"X"
        server (net/server host port
                           |(defer (:close $)
                              (net/write $ data)))]
    (var sreader nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set sreader
               # call being tested
               (stream-reader (net/connect host port))))
        ([e]
          (eprint "Problem reading stream: " e)))
      # also being tested
      (stream-reader? sreader)))
  # =>
  true

  )

########################################################################

(defn parse-error
  ``
  Throws an error with `message`.

  If optional parameter `a-reader` is given, the error will include the
  index for `a-reader`.
  ``
  [message &opt a-reader]
  (if a-reader
    (errorf "%s at index %d" message (get a-reader :index))
    (errorf "%s" message)))

(comment

  (def [ok? value] (protect (parse-error "Oops")))

  [ok? value]
  # =>
  [false "Oops"]

  (def [ok? value]
    (protect (parse-error "Oops" (-> (reader "fun")
                                     (put :index 2)))))

  [ok? value]
  # =>
  [false "Oops at index 2"]

  )

########################################################################

(defn peek
  ``
  Returns the byte at `a-reader`'s current index.
  ``
  [a-reader]
  (def index (get a-reader :index))
  (assert (>= index 0) "Data must be read before peek")

  (get (get a-reader :buffer) index))

(comment

  (def [ok? value] (protect (peek (reader @""))))

  [ok? value]
  # =>
  [false "Data must be read before peek"]

  (peek (-> (reader @"a")
            (put :index 0)))
  # =>
  (chr "a")

  (peek (-> (reader @"tomato")
            (put :index 2)))
  # =>
  (chr "m")

  )

########################################################################

(defn end?
  ``
  Returns true if `a-reader`'s index points to the end of the buffer.
  ``
  [a-reader]
  (when (< (get a-reader :index) 0)
    (break false))

  (nil? (peek a-reader)))

(comment

  (end? (-> (reader @"abc")
            (put :index 3)))
  # =>
  true

  (end? (-> (reader @"abc")
            (put :index 2)))
  # =>
  false

  (end? (-> (reader @"abc")
            (put :index 1)))
  # =>
  false

  (end? (-> (reader @"abc")
            (put :index 0)))
  # =>
  false

  (end? (-> (reader @"abc")
            (put :index -1)))
  # =>
  false

  )

########################################################################

(defn read-byte-buffer
  ``
  Return a byte from `a-reader`.  The reader's index is incremented as
  well.
  ``
  [a-reader]
  (assert (not (end? a-reader)) "Read past the end of the buffer")

  (def index (get a-reader :index))
  (put a-reader :index (inc index))

  (peek a-reader))

(comment

  (read-byte-buffer (-> (reader @"alpha")
                        (put :index 0)))
  # =>
  (chr "l")

  (def [ok? value]
    (protect (read-byte-buffer (-> (reader @"x")
                                   (put :index 1)))))

  [ok? value]
  # =>
  [false "Read past the end of the buffer"]

  )

(defn read-byte-stream
  ``
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
  ``
  [a-reader]
  (def index (get a-reader :index))
  # a network read should only occur if the requested byte (i.e.
  # what is at a particular index) is not already available in the
  # reader's buffer.
  #
  # if index is less than the last index position of the buffer,
  # the byte should already be in the buffer from an earlier
  # read.  only try to read from the network if this is not the
  # case.
  (when (not (< index
                (dec (length (get a-reader :buffer)))))
    # XXX: consider using the timeout parameter for net/read to
    #      prevent program from hanging indefinitely?
    (net/read (get a-reader :stream) 1 (get a-reader :buffer)))
  (put a-reader :index (inc index))

  (peek a-reader))

(comment

  (let [[host port] ["127.0.0.1" "63251"]
        data @"X"
        server (net/server host port
                           |(defer (:close $)
                              (net/write $ data)))]
    (var sreader nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set sreader (stream-reader (net/connect host port))))
        ([e]
          (eprint "Problem reading stream: " e)))
      (when sreader
        # the call being tested
        (read-byte-stream sreader))))
  # =>
  (chr "X")

  )

########################################################################

(defn read-byte
  ``
  Reads the next byte from `a-reader`.  If the reader wraps a network
  stream, this function may block until data is available on the
  network stream.
  ``
  [a-reader]
  (if (stream-reader? a-reader)
    (read-byte-stream a-reader)
    (read-byte-buffer a-reader)))

(comment

  (read-byte (reader @"beta"))
  # =>
  (chr "b")

  (let [[host port] ["127.0.0.1" "63251"]
        data @"Y"
        server (net/server host port
                           |(defer (:close $) (net/write $ data)))]
    (var sreader nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set sreader
               (stream-reader (net/connect host port))))
        ([e]
          (eprint "Problem reading stream: " e)))
      (when sreader
        # the call being tested
        (read-byte sreader))))
  # =>
  (chr "Y")

  )

(defn digit?
  ``
  Returns true if `byte` represents a digit.
  ``
  [byte]
  (<= (chr "0") byte (chr "9")))

(comment

  (digit? (dec (chr "0")))
  # =>
  false

  (digit? (chr "0"))
  # =>
  true

  (digit? (chr "8"))
  # =>
  true

  (digit? (chr "9"))
  # =>
  true

  (digit? (inc (chr "9")))
  # =>
  false

  )

########################################################################

(defn read-integer-bytes
  ``
  Reads the next integer from `a-reader`'s buffer.

  Note that the integer may have a leading minus sign.

  Bytes continue to be read as long as each byte represents a digit.
  ``
  [a-reader]
  (def buf @"")
  (def byte (read-byte a-reader))

  # accumulate byte if it is a sign or digit
  (when (not (or (= (chr "-") byte)
                 (digit? byte)))
    (parse-error "No sign or digit after integer delimiter" a-reader))

  (buffer/push-byte buf byte)

  # read all of the digits
  (while (digit? (read-byte a-reader))
    (buffer/push-byte buf (peek a-reader)))

  (when (not (< 0 (length buf)))
    (parse-error "Could not read integer" a-reader))

  (scan-number buf))

(comment

  (read-integer-bytes (reader @"3"))
  # =>
  3

  (read-integer-bytes (reader @"10"))
  # =>
  10

  (read-integer-bytes (reader @"-7"))
  # =>
  -7

  (read-integer-bytes (reader @"-329"))
  # =>
  -329

  )

(defn pushback
  ``
  Decrements the current index of `a-reader` if data has been read
  at least once before.

  Otheriwse, throws an error.
  ``
  [a-reader]
  (def index (get a-reader :index))
  (assert (>= index 0) "Data must be read before pushback")

  (put a-reader :index (dec index)))

(comment

  (pushback (-> (reader @"3:fun")
                (put :index 2)))
  # =>
  @{:buffer @"3:fun" :index 1}

  (pushback (-> (reader @"i12e")
                (put :index 0)))
  # =>
  @{:buffer @"i12e" :index -1}

  (def [ok? value]
    (protect (pushback (reader @"i12e"))))

  [ok? value]
  # =>
  [false "Data must be read before pushback"]

  )

########################################################################

(defn read-integer
  ``
  Reads a bencoded integer from `a-reader`.

  Assumes the integer's leading delimiter "i" is at the reader's current
  index.
  ``
  [a-reader]
  (when (not= (chr "i") (peek a-reader))
    (parse-error "No integer found" a-reader))

  (def int (try
             (read-integer-bytes a-reader)
             ([e] (parse-error (string "Couldn't read integer: " e)))))

  (when (not= (chr "e") (peek a-reader))
    (parse-error "Unterminated integer" a-reader))

  int)

(comment

  (let [rdr (reader @"i77e")]
    (read-byte rdr)
    (read-integer rdr))
  # =>
  77

  (let [rdr (reader @"i-8901e")]
    (read-byte rdr)
    (read-integer rdr))
  # =>
  -8901

  )

(defn read-string
  ``
  Reads a bencoded binary string from `a-reader`.

  Assumes the string's length prefix starts at the current index.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [a-reader &opt mut]
  (def len (read-integer-bytes a-reader))
  (def buf @"")

  (when (< len 0)
    (parse-error (string "Negative string length not allowed (" len ")")
                 a-reader))

  (when (not= (chr ":") (peek a-reader))
    (parse-error `No separator ":" after string length` a-reader))

  (for count 0 len
    (buffer/push-byte buf (read-byte a-reader)))

  (if mut
    buf
    (string buf)))

(comment

  (let [rdr (reader @"3:fun")]
    (read-byte rdr)
    # rewind so read-string can succeed
    (pushback rdr)
    (read-string rdr))
  # =>
  "fun"

  )

# forward declaration
(varfn read-value [a-reader] nil)

(defn read-list
  ``
  Reads a list from `a-reader`.

  Assumes the list's leading delimiter "l" is at the reader's current
  index.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [a-reader &opt mut]
  (when (not= (chr "l") (peek a-reader))
    (parse-error "No list found" a-reader))

  (def list @[])
  (while (not (or (= (chr "e") (read-byte a-reader))
                  (end? a-reader)))
    (pushback a-reader)
    (def token (read-value a-reader))
    (array/push list token))

  (when (not= (chr "e") (peek a-reader))
    (parse-error "Unterminated list" a-reader))

  (if mut
    list
    (tuple ;list)))

(comment

  # read-list depends on value of read-value
  (varfn read-value [a-reader] (read-string a-reader))

  (let [rdr (reader @"le")]
    (read-byte rdr)
    (read-list rdr))
  # =>
  []

  (let [rdr (reader @"l2:hie")]
    (read-byte rdr)
    (read-list rdr))
  # =>
  ["hi"]

  (let [rdr (reader @"l2:yo5:theree")]
    (read-byte rdr)
    (read-list rdr))
  # =>
  ["yo" "there"]

  )

(defn read-dictionary
  ``
  Reads a dictionary from `a-reader`.

  Assumes the dictionary's leading delimiter "d" is at the reader's
  current index.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [a-reader &opt mut]
  (when (not= (chr "d") (peek a-reader))
    (parse-error "No dictionary found" a-reader))

  (def dict @{})
  (while (not (or (= (chr "e") (read-byte a-reader))
                  (end? a-reader)))
    (pushback a-reader)
    (def key (try
               (keyword (read-string a-reader mut))
               ([e] (parse-error (string "Couldn't read key: " e)))))
    (def val (try
               (read-value a-reader)
               ([e] (parse-error (string "Couldn't read value: " e)))))
    (put dict key val))

  (when (not= (chr "e") (peek a-reader))
    (parse-error "Unterminated dictionary" a-reader))

  (if mut
    dict
    (table/to-struct dict)))

(comment

  # read-dictionary depends on value of read-value
  (varfn read-value [a-reader] (read-string a-reader))

  (let [rdr (reader @"de")]
    (read-byte rdr)
    (read-dictionary rdr))
  # =>
  {}

  (let [rdr (reader @"d1:a1:11:b1:2e")]
    (read-byte rdr)
    (read-dictionary rdr))
  # =>
  {:a "1" :b "2"}

  )

########################################################################

(varfn read-value
  ``
  Reads the next bencoded value from `a-reader`, but returns nil if
  there is no data left to read.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [a-reader &opt mut]
  (def byte (read-byte a-reader))
  (cond
    (end? a-reader)
    nil
    #
    (= (chr "i") byte)
    (read-integer a-reader)
    # strings begin with an integer indicating their length
    (digit? byte)
    (do
      # read-string calls read-integer-bytes which initially calls
      # read-byte, unlike read-integer, read-list, or read-dictionary
      # which all call peek first...to compensate, call pushback here
      (pushback a-reader)
      (read-string a-reader mut))
    #
    (= (chr "l") byte)
    (read-list a-reader mut)
    #
    (= (chr "d") byte)
    (read-dictionary a-reader mut)
    #
    (parse-error (string `Unknown token "` (peek a-reader) `"`)
                 a-reader)))

(comment

  (read-value (reader @"i1e"))
  # =>
  1

  (read-value (reader @"i-101e"))
  # =>
  -101

  (read-value (reader @"3:ant"))
  # =>
  "ant"

  (read-value (reader @"0:"))
  # =>
  ""

  (read-value (reader @"li8ee"))
  # =>
  [8]

  (read-value (reader @"li3ei1ee"))
  # =>
  [3 1]

  (read-value (reader @"l0:1:a2:bce"))
  # =>
  ["" "a" "bc"]

  (read-value (reader @"le"))
  # =>
  []

  (read-value (reader @"d1:a1:11:b1:2e"))
  # =>
  {:a "1" :b "2"}

  (read-value (reader @"de"))
  # =>
  {}

  (read-value (-> (reader @"d1:a1:11:b1:2e")
                  (put :index 0)))
  # =>
  "a"

  (read-value (-> (reader @"d1:a1:11:b1:2e")
                  (put :index 6)))
  # =>
  "b"

  )

########################################################################

(defn compact-reader
  ``
  If `a-reader` is backed by a stream, clears the buffer and resets the
  index.
  ``
  [a-reader]
  (when (stream-reader? a-reader)
    (buffer/clear (get a-reader :buffer))
    (put a-reader :index -1)))

(comment

  (compact-reader (-> (reader @"i237e")
                      (put :index 0)))
  # =>
  nil

  (let [[host port] ["127.0.0.1" "63251"]
        data @"Y"
        server (net/server host port
                           |(defer (:close $) (net/write $ data)))]
    (var sreader nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set sreader
               (stream-reader (net/connect host port))))
        ([e]
          (eprint "Problem reading stream: " e)))
      (when sreader
        # the call being tested
        (compact-reader sreader)
        [(get sreader :buffer)
         (get sreader :index)])))
  # =>
  [@"" -1]

  )

########################################################################

(defn read
  ``
  Reads the next bencoded value from `a-reader`, but returns nil if
  there is no data left to read.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [a-reader &opt mut]
  (def out (read-value a-reader mut))
  (compact-reader a-reader)
  out)

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

########################################################################

(defn read-buffer
  ``
  Reads the first bencoded value from `a-buffer`, but returns nil if
  there is no data to read.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [a-buffer &opt mut]
  (def rdr (reader a-buffer))
  (read rdr mut))

(comment

  (read-buffer (string "d"
                       "2:id"
                       "1:1"
                       "11:new-session"
                       "36:4ca0256c-606f-47ec-9534-06eeaa3227f0"
                       "7:session"
                       "36:fabb7627-45d3-46a8-8804-7a8cd3fc6f94"
                       "6:status"
                       "l"
                       "4:done"
                       "e"
                       "e"))
  # =>
  {:id "1"
   :new-session "4ca0256c-606f-47ec-9534-06eeaa3227f0"
   :session "fabb7627-45d3-46a8-8804-7a8cd3fc6f94"
   :status ["done"]}

  (read-buffer "")
  # =>
  nil

  )

########################################################################

(defn read-stream
  ``
  Reads the first bencoded value from `stream`.

  If there is no data in `stream` to be read, this function will block
  until data is available.

  If the optional parameter `mut` is truthy, then the result uses
  mutable data structures (the default is nil).
  ``
  [stream &opt mut]
  (def rdr (stream-reader stream))
  (read rdr mut))

(comment

  (let [[host port] ["127.0.0.1" "63251"]
        server (net/server host port
                           |(defer (:close $)
                              (net/write $ "l3:hi!e")))]
    (var stream nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set stream (net/connect host port)))
        ([e]
          (eprint "Problem reading stream: " e)))
      (when stream
        # the call being tested
        (read-stream stream))))
  # =>
  ["hi!"]

  )

########################################################################

(defn write-integer
  ``
  Writes the bencoded representation of `an-int` to `a-buffer`.
  ``
  [a-buffer an-int]
  (buffer/push-byte a-buffer (chr "i"))
  (buffer/push-string a-buffer (string an-int))
  (buffer/push-byte a-buffer (chr "e")))

(defn write-string
  ``
  Writes the bencoded representation of `a-string` to `a-buffer`.
  ``
  [a-buffer a-string]
  (buffer/push-string a-buffer (string (length a-string)))
  (buffer/push-byte a-buffer (chr ":"))
  (buffer/push-string a-buffer a-string))

# forward declaration
(varfn write-buffer [a-buffer] nil)

(defn write-list
  ``
  Writes the bencoded representation of `a-list` to `a-buffer`.
  ``
  [a-buffer a-list]
  (buffer/push-byte a-buffer (chr "l"))
  (each item a-list
    (write-buffer a-buffer item))
  (buffer/push-byte a-buffer (chr "e")))

(defn write-dictionary
  ``
  Writes the bencoded representation of `a-dict to `a-buffer`.

  Keywords are transformed into strings (i.e. :key becomes "key").
  ``
  [a-buffer a-dict]
  (buffer/push-byte a-buffer (chr "d"))
  # sorting without converting to strings produces incorrect order.
  # atm, order seems to be: strings < symbols < keywords < buffers
  (def sorted-keys (sort-by string (keys a-dict)))
  (each key sorted-keys
    (write-string a-buffer (string key))
    (write-buffer a-buffer (get a-dict key)))
  (buffer/push-byte a-buffer (chr "e")))

########################################################################

(varfn write-buffer
  ``
  Write the bencoded representation of `data` to `a-buffer`.

  Keywords will be turned into strings (i.e. :key becomes "key").
  ``
  [a-buffer data]
  (cond
    (int? data)
    (write-integer a-buffer data)
    #
    (bytes? data)
    (write-string a-buffer data)
    #
    (indexed? data)
    (write-list a-buffer data)
    #
    (dictionary? data)
    (write-dictionary a-buffer data)
    #
    (errorf "Unknown type when writing data of type %n" (type data))))

########################################################################

(defn write-stream
  ``
  Writes the bencoded representation of `data` to `stream`.

  Keywords will be turned into strings (i.e. :key becomes "key").
  ``
  [stream data]
  (def buf @"")
  (write-buffer buf data)
  (net/write stream buf))

########################################################################

(defn write
  ``
  Returns a buffer with the bencoded representation of `data`.

  Keywords will be turned into strings (i.e. :key becomes "key").
  ``
  [data]
  (def buf @"")
  (write-buffer buf data))

