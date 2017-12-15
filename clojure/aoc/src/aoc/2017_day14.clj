(ns aoc.2017-day14
  (:use clojure.test)
  (:require [aoc.2017-day10 :refer [knot-hash]]))

(def input "jzgqcdpd")

;; --- Day 14: Disk Defragmentation ---

;; Suddenly, a scheduled job activates the system's disk defragmenter. Were the
;; situation different, you might sit and watch it for a while, but today, you
;; just don't have that kind of time. It's soaking up valuable system resources
;; that are needed elsewhere, and so the only option is to help it finish its
;; task as soon as possible.

;; The disk in question consists of a 128x128 grid; each square of the grid is
;; either free or used. On this disk, the state of the grid is tracked by the
;; bits in a sequence of knot hashes.

;; A total of 128 knot hashes are calculated, each corresponding to a single row
;; in the grid; each hash contains 128 bits which correspond to individual grid
;; squares. Each bit of a hash indicates whether that square is free (0) or
;; used (1).

;; The hash inputs are a key string (your puzzle input), a dash, and a number
;; from 0 to 127 corresponding to the row. For example, if your key string were
;; flqrgnkx, then the first row would be given by the bits of the knot hash of
;; flqrgnkx-0, the second row from the bits of the knot hash of flqrgnkx-1, and
;; so on until the last row, flqrgnkx-127.

(defn rows [prefix]
  (map #(str prefix "-" %) (range 128)))

(take 3 (rows "flqrgnkx"))
;; => ("flqrgnkx-0" "flqrgnkx-1" "flqrgnkx-2")

;; The output of a knot hash is traditionally represented by 32 hexadecimal
;; digits; each of these digits correspond to 4 bits, for a total of 4 * 32 =
;; 128 bits. To convert to bits, turn each hexadecimal digit to its equivalent
;; binary value, high-bit first: 0 becomes 0000, 1 becomes 0001, e becomes 1110,
;; f becomes 1111, and so on; a hash that begins with a0c2017... in hexadecimal
;; would begin with 10100000110000100000000101110000... in binary.

(defn hexchar->binary [s]
  (as-> s %
    (Character/digit % 16)
    (Integer/toBinaryString %)
    (format "%4s" %)
    (.replace % " " "0")))

(defn hex->binary [s]
  (apply str (map hexchar->binary s)))

(hex->binary "a0c2017")

;; Continuing this process, the first 8 rows and columns for key flqrgnkx appear
;; as follows, using # to denote used squares, and . to denote free ones:

(hex->binary ())

;; ##.#.#..-->
;; .#.#.#.#   
;; ....#.#.   
;; #.#.##.#   
;; .##.#...   
;; ##..#..#   
;; .#...#..   
;; ##.#.##.-->
;; |      |   
;; V      V   

(defn grid [prefix]
  (let [r (rows prefix)
        hashed (map knot-hash r)
        blocks (map hex->binary hashed)]
    blocks))

(defn count-used [g]
  (let [filtered (map #(filter (fn [c] (= \1 c)) %) g)
        row-counts (map count filtered)]
    (reduce + row-counts)))

;; In this example, 8108 squares are used across the entire 128x128 grid.

(count-used (grid "flqrgnkx"))
;; => 8108

;; Given your actual key string, how many squares are used?
(count-used (grid input))
;; => 8074

;; Your puzzle input is jzgqcdpd.

;; --- Part Two ---

;; Now, all the defragmenter needs to know is the number of regions. A region is
;; a group of used squares that are all adjacent, not including diagonals. Every
;; used square is in exactly one region: lone used squares form their own
;; isolated regions, while several adjacent squares all count as a single
;; region.

;; In the example above, the following nine regions are visible, each marked
;; with a distinct digit:

;; 11.2.3..-->
;; .1.2.3.4   
;; ....5.6.   
;; 7.8.55.9   
;; .88.5...   
;; 88..5..8   
;; .8...8..   
;; 88.8.88.-->
;; |      |   
;; V      V   

;; Of particular interest is the region marked 8; while it does not appear
;; contiguous in this small view, all of the squares marked 8 are connected when
;; considering the whole 128x128 grid. In total, in this example, 1242 regions
;; are present.

(def sample-grid (grid "flqrgnkx"))



(defn grid->xyset [g]
  (into #{}
        (for [[y row] (map-indexed vector g) [x c] (map-indexed vector row) :when (= c \1)] [x y] )))

(def sample-xyset (grid->xyset sample-grid))

(defn neighbors [^ints [x y]]
  [
    [(inc x) y]
    [(dec x) y]
   [x (inc y)]
   [x (dec y)]])

(defn find-regions [xyset]
  (loop [c 1
         region #{(first xyset)}
         remaining (apply disj xyset region)]
    (if (some? (seq remaining))
      ;; there are still unchecked squares
      (let [new-neighbors (clojure.set/intersection remaining (clojure.set/difference (into #{} (mapcat neighbors region)) region))]
        (if (some? (seq new-neighbors))
          ;; if there are new neighbors in this region, add them to region and repeat
          (recur c (clojure.set/union region new-neighbors) (clojure.set/difference remaining new-neighbors))
          ;; no new neighbors, region is over, start a new one
          (let [next-region #{(first remaining)}]
            (recur (inc c) next-region (apply disj remaining next-region)))))
      ;; there are no unchecked squares, the current region is already accounted for, we are done
      c)))


(find-regions sample-xyset)
;; => 1242
;; How many regions are present given your key string?

(find-regions (grid->xyset (grid input)))
;; => 1212

