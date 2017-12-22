(ns aoc.2017-day21
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(defn parse [line]
  (let [[input output] (str/split line #" => ")
        in-rows (str/split input #"/")
        out-rows (str/split output #"/")
        conv-fn (fn [c] (case c \. 0 \# 1))
        in-pixels (mapcat #(map conv-fn %) in-rows)
        out-pixels (mapcat #(map conv-fn %) out-rows)]
  [(vec in-pixels) (vec out-pixels)]
  ))

(def puzzle-input
  (->> "2017/day21.txt" io/resource slurp str/split-lines (map parse)))


;; --- Day 21: Fractal Art ---

;; You find a program trying to generate some art. It uses a strange process
;; that involves repeatedly enhancing the detail of an image through a set of
;; rules.

;; The image consists of a two-dimensional square grid of pixels that are either
;; on (#) or off (.). The program always begins with this pattern:

(def init-pattern {:d 3 :pixels [0 1 0, 0 0 1, 1 1 1]})
;; .#.
;; ..#
;; ###

;; Because the pattern is both 3 pixels wide and 3 pixels tall, it is said to
;; have a size of 3.

(defn pattern-size [{:keys [d]}]
  d)

;; Then, the program repeats the following process:

;;     If the size is evenly divisible by 2, break the pixels up into 2x2
;;     squares, and convert each 2x2 square into a 3x3 square by following the
;;     corresponding enhancement rule.

(defn square-split [d side sq-pat pixels]
  (let [
        sq-dim (/ d side)
        large-coords (for [y (range sq-dim) x (range sq-dim)] [(* x side) (* y side)])
        small-coords (for [offset large-coords] (mapv #(mapv + % offset) sq-pat))
        indices (map (fn [[x y]] (+ x (* y d))) (apply concat small-coords))
        values (map (fn [pixels] {:d side :pixels (vec pixels)}) (partition (* side side) (map pixels indices)))
        ]
    (mapv vec (partition sq-dim values))
    ))

(square-split 4 2 [[0 0] [1 0] [0 1] [1 1]] (vec (range 16)))
;; => [[{:d 2, :pixels [0 1 4 5]} {:d 2, :pixels [2 3 6 7]}] [{:d 2, :pixels [8 9 12 13]} {:d 2, :pixels [10 11 14 15]}]]

(square-split 6 2 [[0 0] [1 0] [0 1] [1 1]] (vec (range 36)))
;; => [[{:d 2, :pixels [0 1 6 7]} {:d 2, :pixels [2 3 8 9]} {:d 2, :pixels [4 5 10 11]}] [{:d 2, :pixels [12 13 18 19]} {:d 2, :pixels [14 15 20 21]} {:d 2, :pixels [16 17 22 23]}] [{:d 2, :pixels [24 25 30 31]} {:d 2, :pixels [26 27 32 33]} {:d 2, :pixels [28 29 34 35]}]]

(defn pixel-split [{:keys [d pixels]} size]
  (case size
    2 (square-split d 2 [[0 0] [1 0] [0 1] [1 1]] pixels)
    3 (square-split d 3 [[0 0] [1 0] [2 0] [0 1] [1 1] [2 1] [0 2] [1 2] [2 2]] pixels)))

(pixel-split {:d 3 :pixels (vec (range 9))} 3)

(pixel-split {:d 9 :pixels (vec (range 81))} 3)
;; => [[{:d 3, :pixels [0 1 2 9 10 11 18 19 20]} {:d 3, :pixels [3 4 5 12 13 14 21 22 23]} {:d 3, :pixels [6 7 8 15 16 17 24 25 26]}] [{:d 3, :pixels [27 28 29 36 37 38 45 46 47]} {:d 3, :pixels [30 31 32 39 40 41 48 49 50]} {:d 3, :pixels [33 34 35 42 43 44 51 52 53]}] [{:d 3, :pixels [54 55 56 63 64 65 72 73 74]} {:d 3, :pixels [57 58 59 66 67 68 75 76 77]} {:d 3, :pixels [60 61 62 69 70 71 78 79 80]}]]

;; to combine 3x3 squares:
;; take the first 3 pixels for the first large row, combine into first small row
;; take the second 3 pixels for the first large row, combine into second small rows
;; take the third 3 pixels for the first large row, combine into third small row
;; repeat for all large rows

(defn get-nth-partition-of [squares n size]
  (let [pixels (map :pixels squares)
        partitions (map #(partition size %) pixels)]
    (mapcat #(nth % n) partitions)))


(defn pixel-combine [rows]
  (let [first-row (first rows)
        sq-d (:d (first first-row))
        newd (reduce + (map :d first-row))
        newpixels
        (apply concat (for [row rows] (mapcat #(get-nth-partition-of row % sq-d) (range sq-d))))]
  {:d newd :pixels (vec newpixels)}))

(defn enhance-pattern [rules {:keys [d pixels]}]
  {:d (inc d) :pixels (get rules pixels)})

(defn tick [rules pixels]
  (let [square-rows
        (if (= 0 (rem (pattern-size pixels) 2))
          (pixel-split pixels 2)
          (pixel-split pixels 3))
        ]
  (pixel-combine
    (for [row square-rows] (mapv #(enhance-pattern rules %) row)))))


;;     Otherwise, the size is evenly divisible by 3; break the pixels up into
;;     3x3 squares, and convert each 3x3 square into a 4x4 square by following
;;     the corresponding enhancement rule.

;; Because each square of pixels is replaced by a larger one, the image gains
;; pixels and so its size increases.

;; The artist's book of enhancement rules is nearby (your puzzle input);
;; however, it seems to be missing rules. The artist explains that sometimes,
;; one must rotate or flip the input pattern to find a match. (Never rotate or
;; flip the output pattern, though.) Each pattern is written concisely: rows are
;; listed as single units, ordered top-down, and separated by slashes. For
;; example, the following rules correspond to the adjacent patterns:

;; ../.#  =  ..
;;           .#

;;                 .#.
;; .#./..#/###  =  ..#
;;                 ###

;;                         #..#
;; #..#/..../#..#/.##.  =  ....
;;                         #..#
;;                         .##.

;; When searching for a rule to use, rotate and flip the pattern as necessary.
;; For example, all of the following patterns match the same rule:

;; .#.   .#.   #..   ###
;; ..#   #..   #.#   ..#
;; ###   ###   ##.   .#.

(defn flip [pixels]
  (let [new-order
        (case (count pixels)
          4 [1 0 3 2]
          9 [2 1 0 5 4 3 8 7 6])
        ]
    (vec (for [i new-order] (get pixels i)))))



(defn rotate [pixels]
  (let [new-orders (case (count pixels)
                     4 [
                          [2 0 3 1]
                          [3 2 1 0]
                          [1 3 0 2]]
                     9 [
                          [3 0 1 6 4 2 7 8 5]
                          [6 3 0 7 4 1 8 5 2]
                          [7 6 3 8 4 0 5 2 1]
                          [8 7 6 5 4 3 2 1 0]
                          [5 8 7 2 4 6 1 0 3]
                          [2 5 8 1 4 7 0 3 6]
                        [1 2 5 0 4 8 3 6 7]])]
    (map #(vec (for [i %] (get pixels i))) new-orders)))

(defn rules->map [rules]
  (into {}
    (apply concat (for [[in out] rules]
      (let [flipped (flip in)
            rotated (rotate in)
            in-keys (conj rotated flipped in)]
        (map #(vector % out) in-keys))))))


;; Suppose the book contained the following two rules:

(def sample-rulemap (rules->map (map parse
  ["../.# => ##./#../..."
  ".#./..#/### => #..#/..../..../#..#"]
)))


;; As before, the program begins with this pattern:

;; .#.
;; ..#
;; ###

;; The size of the grid (3) is not divisible by 2, but it is divisible by 3. It
;; divides evenly into a single square; the square matches the second rule,
;; which produces:

;; #..#
;; ....
;; ....
;; #..#

;; The size of this enhanced grid (4) is evenly divisible by 2, so that rule is
;; used. It divides evenly into four squares:

;; #.|.#
;; ..|..
;; --+--
;; ..|..
;; #.|.#

;; Each of these squares matches the same rule (../.# => ##./#../...), three of
;; which require some flipping and rotation to line up with the rule. The output
;; for the rule is the same in all four cases:

;; ##.|##.
;; #..|#..
;; ...|...
;; ---+---
;; ##.|##.
;; #..|#..
;; ...|...

;; Finally, the squares are joined into a new grid:

;; ##.##.
;; #..#..
;; ......
;; ##.##.
;; #..#..
;; ......

(def sample-1 (tick sample-rulemap init-pattern))
(:pixels sample-1)

(:pixels (tick sample-rulemap sample-1))
;; Thus, after 2 iterations, the grid contains 12 pixels that are on.

;; How many pixels stay on after 5 iterations?
