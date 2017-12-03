(ns aoc.2017-day3
  (:use clojure.test))

(defn abs "(abs n) is the absolute value of n" [n]
  (cond
    (not (number? n)) (throw (IllegalArgumentException.
                              "abs requires a number"))
    (neg? n) (- n)
    :else n))
(def input 361527)
;; --- Day 3: Spiral Memory ---

;; You come across an experimental new kind of memory stored on an infinite
;; two-dimensional grid.

;; Each square on the grid is allocated in a spiral pattern starting at a
;; location marked 1 and then counting up while spiraling outward. For example,
;; the first few squares are allocated like this:

;; 17  16  15  14  13
;; 18   5   4   3  12
;; 19   6   1   2  11
;; 20   7   8   9  10
;; 21  22  23---> ...


;; 1
;; 8  = 3 * 2 + 1 * 2
;; 16 = 5 * 2 + 3 * 2
;; 24 = 7 * 2 + 5 * 2
;; 32 = 9 * 2 + 7 * 2

(defn side [n]
  (- (* 2 n) 1))

(side 2)
(side 3)
(side 4)

(defn square [n]
  (if (= n 1) 1
      (let [n' (side n)]
      (* 2 (+ n' (- n' 2))))))

(square 1)
(square 2)
(square 3)
(square 4)
(square 5)
(square 6)

(defn bottom-right [n]
  (reduce + (map square (range 1 (inc n)))))

(bottom-right 1)
(bottom-right 2)
(bottom-right 3)
(bottom-right 4)
(bottom-right 5)



;; While this is very space-efficient (no squares are skipped), requested data
;; must be carried back to square 1 (the location of the only access port for
;; this memory system) by programs that can only move up, down, left, or right.
;; They always take the shortest path: the Manhattan Distance between the
;; location of the data and square 1.

;; For example:

;;     Data from square 1 is carried 0 steps, since it's at the access port.
;;     Data from square 12 is carried 3 steps, such as: down, left, left.
;;     Data from square 23 is carried only 2 steps: up twice.
;;     Data from square 1024 must be carried 31 steps.

;; How many steps are required to carry the data from the square identified in
;; your puzzle input all the way to the access port?


(last (take-while #(< (bottom-right %) input) (iterate inc 1)))

(bottom-right 301)
(square 301)
(/ (dec (side 301)) 2)
(def middle (+ (bottom-right 301) (/ (dec (side 301)) 2)))

;; move 26 down from 361527, then 300 left to 1; 326

;; Your puzzle input is 361527.

;; --- Part Two ---

;; As a stress test on the system, the programs here clear the grid and then
;; store the value 1 in square 1. Then, in the same allocation order as shown
;; above, they store the sum of the values in all adjacent squares, including
;; diagonals.

;; So, the first few squares' values are chosen as follows:

;;     Square 1 starts with the value 1.
;;     Square 2 has only one adjacent filled square (with value 1), so it also stores 1.
;;     Square 3 has both of the above squares as neighbors and stores the sum of their values, 2.
;;     Square 4 has all three of the aforementioned squares as neighbors and stores the sum of their values, 4.
;;     Square 5 only has the first and fourth squares as neighbors, so it gets the value 5.

;; Once a square is written, its value does not change. Therefore, the first few
;; squares would receive the following values:

;; 147  142  133  122   59
;; 304    5    4    2   57
;; 330   10    1    1   54
;; 351   11   23   25   26
;; 362  747  806--->   ...



(with-test
  (defn direction [[x y]]
    (cond
      (= [x y] [0 0]) [1 0]
      (and (pos? y) (= x y)) [-1 0] ;; top right, go left
      (and (neg? y) (= x y)) [1 0] ;; bottom left, go right
      (and (pos? y) (= (- x) y)) [0 -1] ;; top left, go down
      (and (neg? y) (= (- x) y)) [1 0] ;; bottom right, start a new spiral
      (and (pos? x) (> x (abs y))) [0 1] ;; left side, go up
      (and (pos? y) (> y (abs x))) [-1 0] ;; top side, go left
      (and (neg? x) (> (abs x) (abs y))) [0 -1] ;; right side, go down
      (and (neg? y) (> (abs y) (abs x))) [1 0] ;; bottom side, go right
    ))
  (is (= (direction [0 0]) [1 0]))
  (is (= (direction [1 0]) [0 1]))
  (is (= (direction [1 1]) [-1 0]))
  (is (= (direction [0 1]) [-1 0]))
  (is (= (direction [-1 1]) [0 -1]))
  (is (= (direction [-1 0]) [0 -1]))
  (is (= (direction [-1 -1]) [1 0]))
  (is (= (direction [0 -1]) [1 0]))
  (is (= (direction [1 -1]) [1 0]))
  (is (= (direction [2 -1]) [0 1]))
  (is (= (direction [2 0]) [0 1]))
  (is (= (direction [2 1]) [0 1]))
  (is (= (direction [2 2]) [-1 0]))
  (is (= (direction [1 2]) [-1 0]))
  (is (= (direction [0 2]) [-1 0]))
  (is (= (direction [-1 2]) [-1 0]))
  (is (= (direction [-2 2]) [0 -1]))
  (is (= (direction [-2 1]) [0 -1]))
  (is (= (direction [-2 0]) [0 -1]))
  (is (= (direction [-2 -1]) [0 -1]))
  (is (= (direction [-2 -2]) [1 0]))
  (is (= (direction [-1 -2]) [1 0]))
  (is (= (direction [0 -2]) [1 0]))
  (is (= (direction [1 -2]) [1 0]))
  (is (= (direction [2 -2]) [1 0]))
  (is (= (direction [3 -2]) [0 1]))
  )

(defn next-coords [[x y]]
  (mapv + [x y] (direction [x y]))
  )

(defn spiral [[x y]] (iterate next-coords [x y]))


(defn neighbors [[x y]]
  [
  [(inc x) (inc y)]
  [x (inc y)]
  [(dec x) (inc y)]
  [(dec x) y]
  [(dec x) (dec y)]
  [x (dec y)]
  [(inc x) (dec y)]
  [(inc x) y]
  ])

(defn val-larger-than [n]
  (loop [
         cache {[0 0] 1}
         sp (spiral [1 0])]
    (let [coords (first sp)
          neigb (neighbors coords)
          vals (map #(get cache % 0) neigb)
          v (reduce + vals)]
      (if (> v n) v
          (recur (assoc cache coords v) (rest sp))))))

(val-larger-than input)
;; => 363010

;; What is the first value written that is larger than your puzzle input?

(run-tests)


