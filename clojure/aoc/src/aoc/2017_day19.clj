(ns aoc.2017-day19
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(def puzzle-input
  (-> "2017/day19.txt" io/resource slurp))


;; --- Day 19: A Series of Tubes ---

;; Somehow, a network packet got lost and ended up here. It's trying to follow a
;; routing diagram (your puzzle input), but it's confused about where to go.

;; Its starting point is just off the top of the diagram. Lines (drawn with |,
;; -, and +) show the path it needs to take, starting by going down onto the
;; only line connected to the top of the diagram. It needs to follow this path
;; until it reaches the end (located somewhere within the diagram) and stop
;; there.

;; Sometimes, the lines cross over each other; in these cases, it needs to
;; continue going the same direction, and only turn left or right when there's
;; no other option. In addition, someone has left letters on the line; these
;; also don't change its direction, but it can use them to keep track of where
;; it's been. For example:

(def sample-input (str
"    |          
    |  +--+    
    A  |  C    
F---|----E|--+ 
    |  |  |  D 
    +B-+  +--+ "))

(defn parse [diagram]
  (let [lines (str/split-lines diagram)
        diagram-map
          (into {}
          (for [[y row] (map-indexed vector lines)
                [x c] (map-indexed vector row)
                :when (not= c \space)] [[x y] c]))
        entry (ffirst (filter (fn [[idx c]] (= c \|)) (map-indexed vector (lines 0))))
        ]
  [diagram-map [entry 0 :down []]]))

(defn add-pos [[x y d' acc] [x' y' d' acc']]
  [(+ x x') (+ y y') d' acc])

(defn turn [diagram [x y direction acc]]
  "only called by step when we are at a turning point"
  (let [paths
          (case direction
            (:up :down) [[-1 0 :left] [1 0 :right]]
            (:left :right) [[0 -1 :up] [0 1 :down]])
        neighbors (map #(add-pos [x y direction acc] %) paths)
        next-pos (first (filter (fn [[x y]] (diagram [x y])) neighbors))
        ]
    next-pos))

(defn step [diagram [x y direction acc]]
  (if-let [c (diagram [x y])]
    (if (= c \+) (turn diagram [x y direction (conj acc c)])
        (case direction
          :down [x (inc y) direction (conj acc c)]
          :up [x (dec y) direction (conj acc c)]
          :right [(inc x) y direction (conj acc c)]
          :left [(dec x) y direction (conj acc c)]))
    :done))



;; Given this diagram, the packet needs to take the following path:

;;     Starting at the only line touching the top of the diagram, it must go
;;     down, pass through A, and continue onward to the first +.

;;     Travel right, up, and right, passing through B in the process.

;;     Continue down (collecting C), right, and up (collecting D).

;;     Finally, go all the way left through E and stopping at F.

;; Following the path to the end, the letters it sees on its path are ABCDEF.

(defn solve [input]
  (let [[diagram init] (parse input)
        step-fn (partial step diagram)]
    (filter #(Character/isAlphabetic (.hashCode %)) (last (last (take-while #(not= % :done) (iterate step-fn init)))))))

(apply str (solve sample-input))
;; => "ABCDEF"

;; The little packet looks up at you, hoping you can help it find the way. What
;; letters will it see (in the order it would see them) if it follows the
;; path? (The routing diagram is very wide; make sure you view it without line
;; wrapping.)

(apply str (solve puzzle-input))
;; => "SXWAIBUZY"
