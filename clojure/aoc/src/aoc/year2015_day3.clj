(ns aoc.year2015-day3
  (:require [clojure.java.io :as io]))

(def input
  (-> "2015/day3.txt" io/resource slurp))

;; Santa is delivering presents to an infinite two-dimensional grid of houses.

;; He begins by delivering a present to the house at his starting location, and
;; then an elf at the North Pole calls him via radio and tells him where to move
;; next. Moves are always exactly one house to the north (^), south (v), east
;; (>), or west (<). After each move, he delivers another present to the house
;; at his new location.

(def start [0 0])

(defn move [ins]
  (cond
    (= ins \^) [0 1]
    (= ins \v) [0 -1]
    (= ins \>) [1 0]
    (= ins \<) [-1 0]
    :else [0 0]))

(move \^)

(def moves (map move input))

(take 10 moves)

(defn next-house
  [current-house m]
  (vec (map + current-house m)))

(next-house [1 1] [0 0])
(next-house [1 1] [0 -1])

(first moves)
(last moves)

;; could use reductions instead
(defn calc-locations
  [moves]
  (reduce #(conj %1 (next-house (last %1) %2)) [[0 0]] moves))

(defn calc-locations
  [moves]
  (reductions next-house [0 0] moves))

(calc-locations (map move "^>v<"))
(calc-locations (map move ">"))


;; However, the elf back at the north pole has had a little too much eggnog, and
;; so his directions are a little off, and Santa ends up visiting some houses
;; more than once. How many houses receive at least one present?

;; For example:

;; > delivers presents to 2 houses: one at the starting location, and one to the
;; east. ^>v< delivers presents to 4 houses in a square, including twice to the
;; house at his starting/ending location. ^v^v^v^v^v delivers a bunch of
;; presents to some very lucky children at only 2 houses.
(count (distinct (calc-locations (map move ">"))))
(count (distinct (calc-locations (map move "^>v<"))))
(count (distinct (calc-locations (map move "^v^v^v^v^v^v"))))

;; Your puzzle answer was 2081.
(count (distinct (calc-locations moves)))


;; --- Part Two ---

;; The next year, to speed up the process, Santa creates a robot version of
;; himself, Robo-Santa, to deliver presents with him.

;; Santa and Robo-Santa start at the same location (delivering two presents to
;; the same starting house), then take turns moving based on instructions from
;; the elf, who is eggnoggedly reading from the same script as the previous
;; year.

(partition 2 2 (range 20))
(take-nth 2 (range 20))
(take-nth 2 (rest (range 20)))

(defn calc-locations-robo
  [moves]
  (let [santa (take-nth 2 moves)
        robo (take-nth 2 (rest moves))]
    (concat (calc-locations santa) (calc-locations robo))))

;; This year, how many houses receive at least one present?

;; For example:

;; ^v delivers presents to 3 houses, because Santa goes north, and then
;; Robo-Santa goes south. ^>v< now delivers presents to 3 houses, and Santa and
;; Robo-Santa end up back where they started. ^v^v^v^v^v now delivers presents
;; to 11 houses, with Santa going one direction and Robo-Santa going the other.

(count (distinct (calc-locations-robo (map move "^v"))))
(count (distinct (calc-locations-robo (map move "^>v<"))))
(count (distinct (calc-locations-robo (map move "^v^v^v^v^v"))))

;; Your puzzle answer was 2341.
(count (distinct (calc-locations-robo moves)))
