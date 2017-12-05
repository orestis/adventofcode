(ns aoc.2017-day5
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str])
  (:use clojure.test))

;; --- Day 5: A Maze of Twisty Trampolines, All Alike ---

;; An urgent interrupt arrives from the CPU: it's trapped in a maze of jump
;; instructions, and it would like assistance from any programs with spare
;; cycles to help find the exit.

;; The message includes a list of the offsets for each jump. Jumps are relative:
;; -1 moves to the previous instruction, and 2 skips the next one. Start at the
;; first instruction in the list. The goal is to follow the jumps until one
;; leads outside the list.

;; In addition, these instructions are a little strange; after each jump, the
;; offset of that instruction increases by 1. So, if you come across an offset
;; of 3, you would move three instructions forward, but change it to a 4 for the
;; next time it is encountered.

;; For example, consider the following list of jump offsets:

;; 0
;; 3
;; 0
;; 1
;; -3

(def sample-instr [0 3 0 1 -3])

(defn jump
  ([instr] (jump instr 0 0))
  ([instr n c]
   (if (>= n (count instr)) c
   (let [i (nth instr n)
         n' (+ n i)
         i' (inc i)
         instr' (assoc instr n i')]
     (recur instr' n' (inc c))))
   ))


;; Positive jumps ("forward") move downward; negative jumps move upward. For
;; legibility in this example, these offset values will be written all on one
;; line, with the current instruction marked in parentheses. The following steps
;; would be taken before an exit is found:

;;     (0) 3  0  1  -3  - before we have taken any steps.
;;     (1) 3  0  1  -3  - jump with offset 0 (that is, don't jump at all). Fortunately, the instruction is then incremented to 1.
;;      2 (3) 0  1  -3  - step forward because of the instruction we just modified. The first instruction is incremented again, now to 2.
;;      2  4  0  1 (-3) - jump all the way to the end; leave a 4 behind.
;;      2 (4) 0  1  -2  - go back to where we just were; increment -3 to -2.
;;      2  5  0  1  -2  - jump 4 steps forward, escaping the maze.

;; In this example, the exit is reached in 5 steps.
(jump sample-instr)
;; => 5

(def input
  (-> "2017/day5.txt" io/resource slurp str/split-lines))
;; How many steps does it take to reach the exit?
(jump (mapv #(Integer/parseInt %) input))
;; => 372139

;; --- Part Two ---

;; Now, the jumps are even stranger: after each jump, if the offset was three or
;; more, instead decrease it by 1. Otherwise, increase it by 1 as before.

(defn jump2
  ([instr] (jump2 instr 0 0))
  ([instr n c]
   (if (>= n (count instr)) c
       (let [i (nth instr n)
             n' (+ n i)
             i' (if (>= i 3) (dec i) (inc i))
             instr' (assoc instr n i')]
         (recur instr' n' (inc c))))
   ))


;; Using this rule with the above example, the process now takes 10 steps, and
;; the offset values after finding the exit are left as 2 3 2 3 -1.

(jump2 sample-instr)
;; => 10

;; How many steps does it now take to reach the exit?
(time 
(jump2 (mapv #(Integer/parseInt %) input)))
;; 23169 msecs
;; => 29629538

(defn jump2i
  [instructions]
   (let [^ints instr (int-array instructions) bounds (alength instr)]
     (loop [n 0 c 0]
       (if (>= n bounds) c
           (let [i (aget instr n)
                 n' (+ n i)
                 i' (if (>= i 3) (dec i) (inc i))]
             (aset instr n i')
             (recur n' (inc c)))))))


(set! *warn-on-reflection* true)
(jump2i (int-array sample-instr))
(time
 (jump2i (mapv #(Integer/parseInt %) input)))
;; => 29629538
;;  380ms

;; from @val_waeselynck
(defn run2
  [offsets]
  (let [^ints offsets (into-array Integer/TYPE offsets)]
    (loop [i 0
           t 0]
      (if (and (<= (int 0) i) (< i (alength offsets)))
        (let [o (aget offsets i)]
          (aset offsets i
                (if (> o (int 2))
                  (dec o)
                  (inc o)))
          (recur (+ i o) (inc t)))
        t))))
(time
 (run2 (mapv #(Integer/parseInt %) input)))
;; 650ms
