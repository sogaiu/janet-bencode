(import ../janet-bencode/bencode :as ben)

(comment

  (ben/read-buffer (string "d"
                           "2:" "id"
                           "1:" "1"
                           "2:" "op"
                           "5:" "clone"
                           "e"))
  # =>
  {:id "1" :op "clone"}

  (ben/read-buffer (string "d"
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

  )
