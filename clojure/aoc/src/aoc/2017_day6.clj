(ns aoc.2017-day6
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str])
  (:use clojure.test))

(def input [4	10	4	1	8	4	9	14	5	1	14	15	0	15	3	5])

;; --- Day 6: Memory Reallocation ---

;; A debugger program here is having an issue: it is trying to repair a memory
;; reallocation routine, but it keeps getting stuck in an infinite loop.

;; In this area, there are sixteen memory banks; each memory bank can hold any
;; number of blocks. The goal of the reallocation routine is to balance the
;; blocks between the memory banks.

;; The reallocation routine operates in cycles. In each cycle, it finds the
;; memory bank with the most blocks (ties won by the lowest-numbered memory
;; bank) and redistributes those blocks among the banks. To do this, it removes
;; all of the blocks from the selected bank, then moves to the next (by index)
;; memory bank and inserts one of the blocks. It continues doing this until it
;; runs out of blocks; if it reaches the last memory bank, it wraps around to
;; the first one.

;; The debugger would like to know how many redistributions can be done before a
;; blocks-in-banks configuration is produced that has been seen before.

(defn first-max-index [coll]
  (let [m (apply max coll)]
    (first (keep-indexed #(when (= %2 m) %1) coll))))

(defn next-bank [i n]
  (mod (inc i) n))

(defn increase-bank [board from c]
  (if (= c 0) board
      (recur (update board from inc) (next-bank from (count board)) (dec c))))



(with-test
  (defn next-cycle [board]
    (let [n (first-max-index board)
          v (nth board n)
          board' (assoc board n 0)
          i (next-bank n (count board))]
      (increase-bank board' i v)))

(run-tests)
;; For example, imagine a scenario with only four memory banks:

;;     The banks start with 0, 2, 7, and 0 blocks. The third bank has the most
;;     blocks, so it is chosen for redistribution.

;;     Starting with the next bank (the fourth bank) and then continuing to the
;;     first bank, the second bank, and so on, the 7 blocks are spread out over
;;     the memory banks. The fourth, first, and second banks get two blocks
;;     each, and the third bank gets one back. The final result looks like this:
;;     2 4 1 2.
  (is (= [2 4 1 2] (next-cycle [0 2 7 0])))

;;     Next, the second bank is chosen because it contains the most
;;     blocks (four). Because there are four memory banks, each gets one block.
;;     The result is: 3 1 2 3.
  (is (= [3 1 2 3] (next-cycle [2 4 1 2])))

;;     Now, there is a tie between the first and fourth memory banks, both of
;;     which have three blocks. The first bank wins the tie, and its three
;;     blocks are distributed evenly over the other three banks, leaving it with
;;     none: 0 2 3 4.
  (is (= [0 2 3 4] (next-cycle [3 1 2 3])))
j
;;     The fourth bank is chosen, and its four blocks are distributed such that
;;     each of the four banks receives one: 1 3 4 1.
  (is (= [1 3 4 1] (next-cycle [0 2 3 4])))

;;     The third bank is chosen, and the same thing happens: 2 4 1 2.
  (is (= [2 4 1 2] (next-cycle [1 3 4 1]))))

;; At this point, we've reached a state we've seen before: 2 4 1 2 was already
;; seen. The infinite loop is detected after the fifth block redistribution
;; cycle, and so the answer in this example is 5.

(defn detect-loop [board]
  (let [seen (transient #{board})]
    (loop [b (next-cycle board) c 1]
      (if (seen b) c
          (do
            (conj! seen b)
            (recur (next-cycle b) (inc c)))))))

(detect-loop [0 2 7 0])
;; => 5

;; Given the initial block counts in your puzzle input, how many redistribution
;; cycles must be completed before a configuration is produced that has been
;; seen before?

(detect-loop input)
;; => 12841


;; --- Part Two ---

;; Out of curiosity, the debugger would also like to know the size of the loop:
;; starting from a state that has already been seen, how many block
;; redistribution cycles must be performed before that same state is seen again?

(nth (iterate next-cycle [0 2 7 0]) 5)
;; => [2 4 1 2]
(take 2 (keep-indexed #(when (= [2 4 1 2] %2) %1) (iterate next-cycle [0 2 7 0])))

(nth (iterate next-cycle input) 12841)
;; => [1 0 14 14 12 11 10 9 9 7 5 5 4 3 7 1]
(take 2 (keep-indexed #(when (= [1 0 14 14 12 11 10 9 9 7 5 5 4 3 7 1] %2) %1) (iterate next-cycle input)))
;; => (4803 12841)
(- 12841 4803)
;; => 8038

;; In the example above, 2 4 1 2 is seen again after four cycles, and so the
;; answer in that example would be 4.

;; How many cycles are in the infinite loop that arises from the configuration
;; in your puzzle input?


(run-tests)
