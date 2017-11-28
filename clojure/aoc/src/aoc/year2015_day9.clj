(ns aoc.year2015-day9
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(defonce input
  (-> "2015/day9.txt" io/resource slurp str/split-lines))

(re-seq #"(\w+) to (\w+) = (\d+)" "Snowdin to Faeruon = 12")

(defn parse [line]
  (let [[[_ from to d]] (re-seq #"(\w+) to (\w+) = (\d+)" line)
        d' (Integer/parseInt d)]
    [[(keyword from) (keyword to)] d']))

(parse "Snowdin to Faeruon = 12")

;; --- Day 9: All in a Single Night ---

;; Every year, Santa manages to deliver all of his presents in a single night.

;; This year, however, he has some new locations to visit; his elves have provided
;; him the distances between every pair of locations. He can start and end at any
;; two (different) locations he wants, but he must visit each location exactly
;; once. What is the shortest distance he can travel to achieve this?

;; For example, given the following distances:

;; London to Dublin = 464
;; London to Belfast = 518
;; Dublin to Belfast = 141

(def sample-dists {[:london :dublin] 464
                   [:london :belfast] 518
                   [:dublin :belfast] 141})

(defn locations [m]
  (-> m keys flatten distinct))

(defn with-reverse [m]
  (merge m (into {} (map (fn [[[a b] d]] [[b a] d]) m))))

(defn gen-routes [m]
    (combo/permutations (locations m)) )

(gen-routes sample-dists)


(defn rank-route [route dists]
  (let [steps (partition 2 1 route)]
    (reduce + (map #(dists %) steps))))

;; The possible routes are therefore:

;; Dublin -> London -> Belfast = 982
;; London -> Dublin -> Belfast = 605
;; London -> Belfast -> Dublin = 659
;; Dublin -> Belfast -> London = 659
;; Belfast -> Dublin -> London = 605
;; Belfast -> London -> Dublin = 982

;; The shortest of these is London -> Dublin -> Belfast = 605, and so the answer is
;; 605 in this example.

(defn shortest-route [m]
  (let [routes (gen-routes m)
        m' (with-reverse m)
        ranked (map #(rank-route % m') routes)
        shortest (apply min ranked)]
    shortest))

(shortest-route sample-dists)

;; What is the distance of the shortest route?

(def input-routes (into {} (map parse input)))

(shortest-route input-routes)

;; Your puzzle answer was 141.
