(ns aoc.year2015-day15
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(defonce input
  (-> "2015/day15.txt" io/resource slurp str/split-lines))


(defn pInt [x] (Integer/parseInt x))
;; --- Day 15: Science for Hungry People ---

;; Today, you set out on the task of perfecting your milk-dunking cookie recipe.
;; All you have to do is find the right balance of ingredients.

;; Your recipe leaves room for exactly 100 teaspoons of ingredients. You make a
;; list of the remaining ingredients you could use to finish the recipe (your
;; puzzle input) and their properties per teaspoon:

;;     capacity (how well it helps the cookie absorb milk)
;;     durability (how well it keeps the cookie intact when full of milk)
;;     flavor (how tasty it makes the cookie)
;;     texture (how it improves the feel of the cookie)
;;     calories (how many calories it adds to the cookie)

;; You can only measure ingredients in whole-teaspoon amounts accurately, and you
;; have to be accurate so you can reproduce your results in the future. The total
;; score of a cookie can be found by adding up each of the properties (negative
;; totals become 0) and then multiplying together everything except calories.

;; For instance, suppose you have these two ingredients:

(def sample-input [
 "Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8"
 "Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3"])

(defn parse [line]
  (let [[_ ing cap dur fla tex cal]
        (re-find #"(\w+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)" line)]
    (mapv pInt [cal cap dur fla tex])))

(def sample-ingredients
  (mapv parse sample-input))

(def input-ingredients
  (mapv parse input))

;; Then, choosing to use 44 teaspoons of butterscotch and 56 teaspoons of
;; cinnamon (because the amounts of each ingredient must add up to 100) would
;; result in a cookie with the following properties:

;;     A capacity of 44*-1 + 56*2 = 68
;;     A durability of 44*-2 + 56*3 = 80
;;     A flavor of 44*6 + 56*-2 = 152
;;     A texture of 44*3 + 56*-1 = 76

(mapv #(* % 2) [1 2 3])

(defn mulprops [props x]
  (mapv #(* % x) props))

(mulprops [1 2 3] 2)

(mapv + [1 2 3] [4 5 6])

(defn cookie-props [ingr tsp]
  (let [mul (map rest ingr)
        subtotal (mapv mulprops mul tsp)]
    (apply mapv + subtotal)))

(cookie-props sample-ingredients [44 56])

(defn score [cp]
  (let [zeroed (mapv #(if (< % 0) 0 %) cp)]
    (reduce * zeroed)))

(score [68 80 152 76])
(score [68 -1 152 76])

;; Multiplying these together (68 * 80 * 152 * 76, ignoring calories for now)
;; results in a total score of 62842880, which happens to be the best score
;; possible given these ingredients. If any properties had produced a negative
;; total, it would have instead become zero, causing the whole score to multiply to
;; zero.

;; Given the ingredients in your kitchen and their properties, what is the total
;; score of the highest-scoring cookie you can make?


;; Your puzzle answer was 13882464.

(run-all-tests #"aoc\.year2015-day15")
