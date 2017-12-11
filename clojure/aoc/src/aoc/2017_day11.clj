(ns aoc.2017-day11
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

;; FULL DISCLOSURE
;; hex grids logic and cube coordinates taken from:
;; http://keekerdc.com/2011/03/hexagon-grids-coordinate-systems-and-distance-calculations/

(def input
  (-> "2017/day11.txt" io/resource slurp str/trim-newline (str/split #",")))

;; --- Day 11: Hex Ed ---

;; Crossing the bridge, you've barely reached the other side of the stream when
;; a program comes up to you, clearly in distress. "It's my child process," she
;; says, "he's gotten lost in an infinite grid!"

;; Fortunately for her, you have plenty of experience with infinite grids.

;; Unfortunately for you, it's a hex grid.

(defn tile [x y z] {:x x :y y :z z})

;; The hexagons ("hexes") in this grid are aligned such that adjacent hexes can
;; be found to the north, northeast, southeast, south, southwest, and northwest:

;;   \ n  /
;; nw +--+ ne
;;   /    \
;; -+      +-
;;   \    /
;; sw +--+ se
;;   / s  \

(with-test
  (defn move [{:keys [x y z]} direction]
    (let [offset
            (case direction
              "n"  [ 0  1 -1]
              "ne" [ 1  0 -1]
              "se" [ 1 -1  0]
              "s"  [ 0 -1  1]
              "sw" [-1  0  1]
              "nw" [-1  1  0])]
      (apply tile (map + [x y z] offset))))
  (is (= (tile 1 2 -3) (move (tile 1 1 -2)  "n")))
  (is (= (tile 2 1 -3) (move (tile 1 1 -2) "ne")))
  (is (= (tile 2 0 -2) (move (tile 1 1 -2) "se")))
  (is (= (tile 1 0 -1) (move (tile 1 1 -2)  "s")))
  (is (= (tile 0 1 -1) (move (tile 1 1 -2) "sw")))
  (is (= (tile 0 2 -2) (move (tile 1 1 -2) "nw"))))

(defn abs [x]
  (if (neg? x) (- x) x))

(defn distance [{x1 :x y1 :y z1 :z} {x2 :x y2 :y z2 :z}]
  (apply max (map abs [(- x2 x1) (- y2 y1) (- z2 z1)])))


;; You have the path the child process took. Starting where he started, you need
;; to determine the fewest number of steps required to reach him. (A "step"
;; means to move from the hex you are in to any adjacent hex.)

(with-test
  (defn steps-away [start steps]
    (let [end-tile (reduce move start steps) ]
          (distance end-tile start)))
  ;; For example:
  ;; ne,ne,ne is 3 steps away.
  (is (= 3 (steps-away (tile 0 0 0) ["ne" "ne" "ne"])))
  ;; ne,ne,sw,sw is 0 steps away (back where you started).
  (is (= 0 (steps-away (tile 0 0 0) ["ne" "ne" "sw" "sw"])))
  ;; ne,ne,s,s is 2 steps away (se,se).
  (is (= 2 (steps-away (tile 0 0 0) ["ne" "ne" "s" "s"])))
  ;; se,sw,se,sw,sw is 3 steps away (s,s,sw).
  (is (= 3 (steps-away (tile 0 0 0) ["se" "sw" "se" "sw" "sw"]))))

(steps-away (tile 0 0 0) input)
;; => 715

;; --- Part Two ---

;; How many steps away is the furthest he ever got from his starting position?
(let [start (tile 0 0 0)
      reds (reductions move start input)
      dists (map #(distance start %) reds)]
  (apply max dists))
;; => 1512


(run-tests)
