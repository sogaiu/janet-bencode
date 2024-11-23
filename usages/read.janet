(import ../janet-bencode/bencode :as ben)

(comment

  (def rdr
    (ben/reader (string "d"
                        "2:" "id"
                        "1:" "1"
                        "2:" "op"
                        "5:" "clone"
                        "e")))

  rdr
  # =>
  @{:buffer "d2:id1:12:op5:clonee" :index -1}

  (ben/read rdr)
  # =>
  {:id "1" :op "clone"}

  rdr
  # =>
  @{:buffer "d2:id1:12:op5:clonee" :index 19}

  (ben/read rdr)
  # =>
  nil

  rdr
  # =>
  @{:buffer "d2:id1:12:op5:clonee" :index 20}

  (def [ok? val] (protect (ben/read rdr)))

  [ok? val]
  # =>
  [false "Read past the end of the buffer"]

  )

(comment

  (def rdr (ben/reader (string "2:id" "1:1")))

  rdr
  # =>
  @{:buffer "2:id1:1" :index -1}

  (ben/read rdr)
  # =>
  "id"

  rdr
  # =>
  @{:buffer "2:id1:1" :index 3}

  (ben/read rdr)
  # =>
  "1"

  rdr
  # =>
  @{:buffer "2:id1:1" :index 6}

  (ben/read rdr)
  # =>
  nil

  rdr
  # =>
  @{:buffer "2:id1:1" :index 7}

  (def [ok? val] (protect (ben/read rdr)))

  [ok? val]
  # =>
  [false "Read past the end of the buffer"]

  )

