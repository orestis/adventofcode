(ns aoc.2017-day1
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(def input
  (-> "2017/day1.txt" io/resource slurp str/trim-newline))

;; --- Day 1: Inverse Captcha ---

;; You're standing in a room with "digitization quarantine" written in LEDs along
;; one wall. The only door is locked, but it includes a small
;; interface. "Restricted Area - Strictly No Digitized Users Allowed."

;; It goes on to explain that you may only leave by solving a captcha to prove
;; you're not a human. Apparently, you only get one millisecond to solve the
;; captcha: too fast for a normal human, but it feels like hours to you.

;; The captcha requires you to review a sequence of digits (your puzzle input) and
;; find the sum of all digits that match the next digit in the list. The list is
;; circular, so the digit after the last digit is the first digit in the list.


(defn str->intl [s]
  (map #(Character/getNumericValue %) s))

(defn wrapped [coll]
  (let [v (vec coll)
        f (first v)]
    (conj v f)))

(defn captcha-by [x partition-f]
  (->> x
       str->intl
       partition-f
       (filter #(= (first %) (second %)))
       (map first)
       (reduce +)))


(with-test
  (defn captcha [x]
    (captcha-by x #(partition 2 1 (wrapped %))))
  ;; For example:
  (testing "examples"
    ;;     1122 produces a sum of 3 (1 + 2) because the first digit (1) matches the
    ;;     second digit and the third digit (2) matches the fourth digit.
    (is (= 3 (captcha "1122")))
    ;;     1111 produces 4 because each digit (all 1) matches the next.
    (is (= 4 (captcha "1111")))
    ;;     1234 produces 0 because no digit matches the next.
    (is (= 0 (captcha "1234")))
    ;;     91212129 produces 9 because the only digit that matches the next one is
    ;;     the last digit, 9.
    (is (= 9 (captcha "91212129")))))


(captcha input)
;; => 1343

;; --- Part Two ---

;; You notice a progress bar that jumps to 50% completion. Apparently, the door
;; isn't yet satisfied, but it did emit a star as encouragement. The
;; instructions change:

;; Now, instead of considering the next digit, it wants you to consider the
;; digit halfway around the circular list. That is, if your list contains 10
;; items, only include a digit in your sum if the digit 10/2 = 5 steps forward
;; matches it. Fortunately, your list has an even number of elements.


(defn partition-wrap [coll]
  (let [c (count coll)
        w (/ c 2)
        v (vec coll)]
    (map-indexed (fn [idx d] [d (v (rem (+ w idx) c))]) v)))

(with-test
  (defn captcha-2 [x]
    (captcha-by x partition-wrap))
  ;; For example:
  (testing "examples 2"
    ;; 1212 produces 6: the list contains 4 items, and all four digits match the digit 2 items ahead.
    (is (= 6 (captcha-2 "1212")))
    ;; 1221 produces 0, because every comparison is between a 1 and a 2.
    (is (= 0 (captcha-2 "1221")))
    ;; 123425 produces 4, because both 2s match each other, but no other digit has a match.
    (is (= 4 (captcha-2 "123425")))
    ;; 123123 produces 12.
    (is (= 12 (captcha-2 "123123")))
    ;; 12131415 produces 4.
    (is (= 4 (captcha-2 "12131415")))))


;; What is the solution to your new captcha?

(captcha-2 input)
;; => 1274


(run-all-tests #"aoc\.year2017-day1")
