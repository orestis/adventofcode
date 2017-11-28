(ns aoc.year2015-day12
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.walk :as walk])
  (:require [clojure.string :as str])
  (:require [clojure.data.json :as json]))


(defonce input
  (-> "2015/day12.txt" io/resource slurp json/read-str))


;; --- Day 12: JSAbacusFramework.io ---

;; Santa's Accounting-Elves need help balancing the books after a recent order.
;; Unfortunately, their accounting software uses a peculiar storage format. That's
;; where you come in.

;; They have a JSON document which contains a variety of things: arrays ([1,2,3]),
;; objects ({"a":1, "b":2}), numbers, and strings. Your first job is to simply find
;; all of the numbers throughout the document and add them together.

;; For example:

;; [1,2,3] and {"a":2,"b":4} both have a sum of 6.
;; [[[3]]] and {"a":{"b":4},"c":-1} both have a sum of 3.
;; {"a":[-1,1]} and [-1,{"a":1}] both have a sum of 0.
;; [] and {} both have a sum of 0.

;; You will not encounter any strings containing numbers.

;; What is the sum of all numbers in the document?

(with-test
  (defn numbers [d]
    (let [result (atom [])]
      (walk/prewalk (fn [x]
                      (if (number? x)
                        (do (swap! result conj x) nil)
                        x)) d)
      @result))
  (testing "Numbers"
    (doseq [[i n]
            [
             [[1,2,3], [1,2,3]]
             [[1,{"c" "red", "b" 2},3], [1,2,3]]
             [[[[3]]], [3]]
             [{"a" [-1,1]}, [-1,1]]
             ]]
      (testing (str i)
        (is (= n (numbers i)))))))

#_(->> input
     (re-seq #"-?\d+")
     (map #(Integer/parseInt %))
     (reduce +))

(reduce + (numbers input))

;; Your puzzle answer was 191164.

;; --- Part Two ---

;; Uh oh - the Accounting-Elves have realized that they double-counted everything
;; red.

;; Ignore any object (and all of its children) which has any property with the
;; value "red". Do this only for objects ({...}), not arrays ([...]).

(defn red-skipper [x]
  (if (and (map? x) (some #{"red"} (vals x) ))
    nil
    x))

(walk/prewalk red-skipper [1,2,3])
(walk/prewalk red-skipper [1,{"c" "red" "b" 2},3])

(reduce + (numbers (walk/prewalk red-skipper input)))



;; [1,2,3] still has a sum of 6.
;; [1,{"c":"red","b":2},3] now has a sum of 4, because the middle object is ignored.
;; {"d":"red","e":[1,2,3,4],"f":5} now has a sum of 0, because the entire structure is ignored.
;; [1,"red",5] has a sum of 6, because "red" in an array has no effect.

;; Your puzzle answer was 87842.

(run-all-tests #"aoc\.year2015-day12")
