(ns aoc.year2015-day10
  (:use clojure.test)
  (:require [clojure.string :as str]))

(def input "1113122113")

;; --- Day 10: Elves Look, Elves Say ---

;; Today, the Elves are playing a game called look-and-say. They take turns making
;; sequences by reading aloud the previous sequence and using that reading as the
;; next sequence. For example, 211 is read as "one two, two ones", which becomes
;; 1221 (1 2, 2 1s).

;; Look-and-say sequences are generated iteratively, using the previous value as
;; input for the next step. For each step, take the previous value, and replace
;; each run of digits (like 111) with the number of digits (3) followed by the
;; digit itself (1).

;; For example:

;; 1 becomes 11 (1 copy of digit 1).
;; 11 becomes 21 (2 copies of digit 1).
;; 21 becomes 1211 (one 2 followed by one 1).
;; 1211 becomes 111221 (one 1, one 2, and two 1s).
;; 111221 becomes 312211 (three 1s, two 2s, and one 1).

(seq "11")
(partition-by identity "111221")
(->> "111221"
     (partition-by identity)
     (map count))

(apply str (interleave [3 2 1] [\1 \2 \1]))

(with-test
  (defn look-and-say [s]
    (let [partitions (partition-by identity s)
          counts (map count partitions)
          digits (map first partitions)]
      (apply str (interleave counts digits))))
  (testing "look and say"
  (doseq [[in out] [
                    ["1" "11"]
                    ["11" "21"]
                    ["21" "1211"]
                    ["1211" "111221"]
                    ["111221" "312211"]
                    ]]
    (testing in
      (is (= out (look-and-say in))))
    )))

;; Starting with the digits in your puzzle input, apply this process 40 times. What
;; is the length of the result?

(take 6 (iterate look-and-say "1"))

(count (last (take 41 (iterate look-and-say input))))

;; Your puzzle answer was 360154.

;; --- Part Two ---

;; Neat, right? You might also enjoy hearing John Conway talking about this
;; sequence (that's Conway of Conway's Game of Life fame).

;; Now, starting again with the digits in your puzzle input, apply this process 50
;; times. What is the length of the new result?

(count (last (take 51 (iterate look-and-say input))))
;; Your puzzle answer was 5103798.

(run-all-tests #"aoc\.year2015-day10")
