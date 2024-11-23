(import ../janet-bencode/bencode :as ben)

(def [host port] ["127.0.0.1" "63251"])

(comment

  (let [message :hello
        server (net/server host port
                           |(defer (:close $)
                              (ben/write-stream $ message)))]
    (var result nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set result (ben/read-stream (net/connect host port))))
        ([e]
          (eprint "Problem reading stream: " e)
          (set result nil))))
    result)
  # =>
  "hello"

  )

(comment

  (defn round-trip-check
    [message]
    (def server (net/server host port
                            |(defer (:close $)
                               (ben/write-stream $ message))))
    (var result nil)
    (defer (:close server)
      (try
        (ev/with-deadline 1
          (set result (ben/read-stream (net/connect host port))))
        ([e]
          (eprint "Problem reading stream: " e)
          (set result nil))))
    #
    (when result
      (deep= message result)))

  (round-trip-check "breathe")
  # =>
  true

  (round-trip-check "")
  # =>
  true

  (round-trip-check 32767)
  # =>
  true

  (round-trip-check -2)
  # =>
  true

  (round-trip-check ["alice" "carol" "bob"])
  # =>
  true

  (round-trip-check [])
  # =>
  true

  (round-trip-check {:length 5.0
                     :width 12.0
                     :height 13.0})
  # =>
  true

  (round-trip-check {})
  # =>
  true

  (round-trip-check {:id "1" :op "clone"})
  # =>
  true

  (round-trip-check {:id "1"
                     :new-session "4ca0256c-606f-47ec-9534-06eeaa3227f0"
                     :session "fabb7627-45d3-46a8-8804-7a8cd3fc6f94"
                     :status ["done"]})
  # =>
  true

  )

