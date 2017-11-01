(ns aoc.year2015-day2
  (:require [clojure.java.io :as io]))

(def input
  (-> "2015/day2.txt" io/resource slurp))

(defn dimensions [l w h]
  (let [a (* 2 l w)
        b (* 2 w h)
        c (* 2 h l)
        m (min a b c)]
    (+ a b c (/ m 2))))

#_(dimensions 2 3 4)
#_(dimensions 1 1 10)

(def lines (clojure.string/split-lines input))

(defn parse [line]
  (map #(Integer. %) (clojure.string/split line #"x")))

#_(parse "1x2x3")

(def solutionA
  (apply + (map #(apply dimensions (parse %)) lines)))

(defn perimeters [l w h]
  [(+ l l w w)
   (+ l l h h)
   (+ h h w w)])

#_(perimeters 2 3 4)
#_(perimeters 1 1 10)

(defn volume [l w h]
  (* l w h))

#_(volume 2 3 4)
#_(volume 1 1 10)

(defn ribbon [l w h]
  (+ (apply min (perimeters l w h)) (volume l w h)))

(ribbon 2 3 4)
(ribbon 1 1 10)

(def solutionB
  (apply + (map #(apply ribbon (parse %)) lines)))

