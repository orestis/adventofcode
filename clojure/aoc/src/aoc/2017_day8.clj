(ns aoc.2017-day8
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(def input (-> "2017/day8.txt" io/resource slurp str/split-lines))

;; --- Day 8: I Heard You Like Registers ---

;; You receive a signal directly from the CPU. Because of your recent assistance
;; with jump instructions, it would like you to compute the result of a series
;; of unusual register instructions.

;; Each instruction consists of several parts: the register to modify, whether
;; to increase or decrease that register's value, the amount by which to
;; increase or decrease it, and a condition. If the condition fails, skip the
;; instruction without modifying the register. The registers all start at 0. The
;; instructions look like this:

(def sample-input [
"b inc 5 if a > 1"
"a inc 1 if b < 5"
"c dec -10 if a >= 1"
"c inc -20 if c == 10"])

(def != not=)

(defn parse [line]
  (let [[_ r op am c_r c_op c_v] (re-find #"(\w+) (inc|dec) (-?\d+) if (\w+) (>=|<=|==|>|<|!=) (-?\d+)" line)]
    {:target (keyword r) :op (case op "inc" + "dec" -) :am (Integer/parseInt am) :f #((resolve (symbol c_op)) % (Integer/parseInt c_v)) :arg (keyword c_r) }
    )
  )



(map parse sample-input)


;; These instructions would be processed as follows:

(with-test
  (defn aoc-eval [context instr]
    (let [{:keys [f arg target op am]} instr]
      (if (f (arg context 0))
        (update context target #(op (or % 0) am))
        context)))
  ;;     Because a starts at 0, it is not greater than 1, and so b is not modified.
  (testing "example"
  (is (= 0 (:b (aoc-eval {:a 0 :b 0 :c 0} {:target :b :op + :am 5 :f #(> % 1) :arg :a} ))))
  ;;     a is increased by 1 (to 1) because b is less than 5 (it is 0).
  (is (= 1 (:a (aoc-eval  {:a 0 :b 0 :c 0} {:target :a :op + :am 1 :f #(< % 5) :arg :b}))))
  ;;     c is decreased by -10 (to 10) because a is now greater than or equal to 1 (it is 1).
  (is (= 10 (:c (aoc-eval  {:a 1 :b 0 :c 0} {:target :c :op - :am -10 :f #(>= % 1) :arg :a}))))
  ;;     c is increased by -20 (to -10) because c is equal to 10.
  (is (= -10 (:c (aoc-eval  {:a 1 :b 0 :c 10} {:target :c :op + :am -20 :f #(== % 10) :arg :c}))))
  ))

;; After this process, the largest value in any register is 1.

(defn process [instructions]
  (reduce aoc-eval {} instructions))
)

(apply max (vals (reduce aoc-eval {} (map parse sample-input))))
;; => 1

;; You might also encounter <= (less than or equal to) or != (not equal to).
;; However, the CPU doesn't have the bandwidth to tell you what all the
;; registers are named, and leaves that to you to determine.

;; What is the largest value in any register after completing the instructions
;; in your puzzle input?
(apply max (vals (reduce aoc-eval {} (map parse input))))
;; => 5102

;; --- Part Two ---

;; To be safe, the CPU also needs to know the highest value held in any register
;; during this process so that it can decide how much memory to allocate to these
;; operations. For example, in the above instructions, the highest value ever held
;; was 10 (in register c after the third instruction was evaluated).

(apply max (mapcat vals (reductions aoc-eval {} (map parse sample-input))))
;; => 10
(apply max (mapcat vals (reductions aoc-eval {} (map parse input))))
;; => 6056


(run-tests)
