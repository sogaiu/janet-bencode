(import ../janet-bencode/bencode :as ben)

(comment

  (ben/write {:id "1" :op "clone"})
  # =>
  (buffer "d"
          "2:id"
          "1:1"
          "2:op"
          "5:clone"
          "e")

  (ben/write {:id "1"
              :new-session "4ca0256c-606f-47ec-9534-06eeaa3227f0"
              :session "fabb7627-45d3-46a8-8804-7a8cd3fc6f94"
              :status ["done"]})
  # =>
  (buffer "d"
          "2:id" "1:1"
          "11:new-session" "36:4ca0256c-606f-47ec-9534-06eeaa3227f0"
          "7:session" "36:fabb7627-45d3-46a8-8804-7a8cd3fc6f94"
          "6:status" "l" "4:done" "e"
          "e")

  (ben/write {"integer" 5
              :string "pluck"
              'list [:a-keyword 'a-symbol @"a buffer"]
              @"map" @{"state" "confused"
                       "favorite" 11}})
  # =>
  (buffer "d"
          "7:integer" "i5e"
          "4:list" "l" "9:a-keyword" "8:a-symbol" "8:a buffer" "e"
          "3:map"
          "d" "8:favorite" "i11e" "5:state" "8:confused" "e"
          "6:string" "5:pluck"
          "e")

  )

