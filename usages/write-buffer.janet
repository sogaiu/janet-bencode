(import ../janet-bencode/bencode :as ben)

(comment

  (ben/write-buffer @"" 3)
  # =>
  @"i3e"

  (ben/write-buffer @"" -11)
  # =>
  @"i-11e"

  (ben/write-buffer @"" "hello")
  # =>
  @"5:hello"

  (ben/write-buffer @"" "")
  # =>
  @"0:"

  (ben/write-buffer @"" :a-keyword)
  # =>
  @"9:a-keyword"

  (ben/write-buffer @"" 'a-symbol)
  # =>
  @"8:a-symbol"

  (ben/write-buffer @"" @"a buffer")
  # =>
  @"8:a buffer"

  (ben/write-buffer @"" ["athena" "hermes"])
  # =>
  @"l6:athena6:hermese"

  (ben/write-buffer @"" ["a" "b" "c"])
  # =>
  @"l1:a1:b1:ce"

  (ben/write-buffer @"" ["c" "a" "b"])
  # =>
  @"l1:c1:a1:be"

  (ben/write-buffer @"" [:ant :bee])
  # =>
  @"l3:ant3:beee"

  (ben/write-buffer @"" @['a-sym @"a buffer"])
  # =>
  @"l5:a-sym8:a buffere"

  (ben/write-buffer @"" {"key" "value"})
  # =>
  @"d3:key5:valuee"

  (ben/write-buffer @"" @{@"gamma" "mysterious"
                          :alpha 'fun})
  # =>
  @"d5:alpha3:fun5:gamma10:mysteriouse"

  (def [ok? value] (protect (ben/write-buffer @"" 2.01)))

  [ok? value]
  # =>
  [false "Unknown type when writing data of type :number"]

  (ben/write-buffer @"" 2.000)
  # =>
  @"i2e"

  (def [ok? value] (protect (ben/write-buffer @"" nil)))

  [ok? value]
  # =>
  [false "Unknown type when writing data of type :nil"]

  (def [ok? value] (protect (ben/write-buffer @"" true)))

  [ok? value]
  # =>
  [false "Unknown type when writing data of type :boolean"]

  )

