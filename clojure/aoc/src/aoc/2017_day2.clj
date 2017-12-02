(ns aoc.2017-day2
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(defn parse [line]
  (let [s (str/split line #"\s+")]
  (mapv #(Integer/parseInt %) s)))

(def input
  (->> "2017/day2.txt" io/resource slurp str/split-lines (map parse)))

;; --- Day 2: Corruption Checksum ---

;; As you walk through the door, a glowing humanoid shape yells in your
;; direction. "You there! Your state appears to be idle. Come help us repair the
;; corruption in this spreadsheet - if we take another millisecond, we'll have
;; to display an hourglass cursor!"

;; The spreadsheet consists of rows of apparently-random numbers. To make sure
;; the recovery process is on the right track, they need you to calculate the
;; spreadsheet's checksum. For each row, determine the difference between the
;; largest value and the smallest value; the checksum is the sum of all of these
;; differences.

;; For example, given the following spreadsheet:

(def sample-input [
[5 1 9 5]
[7 5 3]
[2 4 6 8]
])


(with-test
  (defn row-diff [row]
    (let [l(apply max row)
          s(apply min row)]
      (- l s)))
  ;;     The first row's largest and smallest values are 9 and 1, and their difference is 8.
  (is (= 8 (row-diff (sample-input 0))))
  ;;     The second row's largest and smallest values are 7 and 3, and their difference is 4.
  (is (= 4 (row-diff (sample-input 1))))
  ;;     The third row's difference is 6.
  (is (= 6 (row-diff (sample-input 2)))))


(defn checksum [rows]
  (reduce + (map row-diff rows)))

;; In this example, the spreadsheet's checksum would be 8 + 4 + 6 = 18.
(checksum sample-input)
;; => 18


;; What is the checksum for the spreadsheet in your puzzle input?
(checksum input)
;; => 32020


;; --- Part Two ---

;; "Great work; looks like we're on the right track after all. Here's a star for
;; your effort." However, the program seems a little worried. Can programs be
;; worried?

;; "Based on what we're seeing, it looks like all the User wanted is some
;; information about the evenly divisible values in the spreadsheet.
;; Unfortunately, none of us are equipped for that kind of calculation - most of
;; us specialize in bitwise operations."

;; It sounds like the goal is to find the only two numbers in each row where one
;; evenly divides the other - that is, where the result of the division
;; operation is a whole number. They would like you to find those numbers on
;; each line, divide them, and add up each line's result.

;; For example, given the following spreadsheet:

(def sample-input-2 [
[5 9 2 8]
[9 4 7 3]
[3 8 6 5]
])


(with-test
  (defn even-div [n coll]
    (let [d (map #(/ n %) coll)]
      (first (filter integer? d))))
  (is (= nil (even-div 5 [9 2 8])))
  (is (= nil (even-div 9 [5 2 8])))
  (is (= nil (even-div 2 [5 9 8])))
  (is (= 4 (even-div 8 [5 9 2]))))

(for [n [5 9 2 8]]
  [n (remove #(= % n) [5 9 2 8])]
  )

(with-test
  (defn row-even-div [row]
    (first (filter integer?
      (for [n row :let [r (remove #(= % n) row)]]
        (even-div n r)))))
  ;;     In the first row, the only two numbers that evenly divide are 8 and 2; the result of this division is 4.
  (is (= 4 (row-even-div (sample-input-2 0))))
  ;;     In the second row, the two numbers are 9 and 3; the result is 3.
  (is (= 3 (row-even-div (sample-input-2 1))))
  ;;     In the third row, the result is 2.
  (is (= 2 (row-even-div (sample-input-2 2)))))

;; In this example, the sum of the results would be 4 + 3 + 2 = 9.

(reduce + (map row-even-div sample-input-2))
;; => 9

;; What is the sum of each row's result in your puzzle input?
(reduce + (map row-even-div input))
;; => 236

(run-tests)
