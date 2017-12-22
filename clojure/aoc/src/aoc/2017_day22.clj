(ns aoc.2017-day22
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(defn parse [input]
  (let [lines (str/split-lines input)
        infections
          (for [[y line] (map-indexed vector lines)
                [x c] (map-indexed vector line)
                :when (= c \#)]
            [x (- y)])]
    (into #{}  infections)))

(def puzzle-input
  (->> "2017/day22.txt" io/resource slurp parse))


;; --- Day 22: Sporifica Virus ---

;; Diagnostics indicate that the local grid computing cluster has been
;; contaminated with the Sporifica Virus. The grid computing cluster is a
;; seemingly-infinite two-dimensional grid of compute nodes. Each node is either
;; clean or infected by the virus.

;; To prevent overloading the nodes (which would render them useless to the
;; virus) or detection by system administrators, exactly one virus carrier moves
;; through the network, infecting or cleaning nodes as it moves. The virus
;; carrier is always located on a single node in the network (the current node)
;; and keeps track of the direction it is facing.

;; To avoid detection, the virus carrier works in bursts; in each burst, it
;; wakes up, does some work, and goes back to sleep. The following steps are all
;; executed in order one time each burst:

;;     If the current node is infected, it turns to its right. Otherwise, it
;;     turns to its left. (Turning is done in-place; the current node does not
;;     change.)

;;     If the current node is clean, it becomes infected. Otherwise, it becomes
;;     cleaned. (This is done after the node is considered for the purposes of
;;     changing direction.)

;;     The virus carrier moves forward one node in the direction it is facing.

;; Diagnostics have also provided a map of the node infection status (your
;; puzzle input). Clean nodes are shown as .; infected nodes are shown as #.
;; This map only shows the center of the grid; there are many more nodes beyond
;; those shown, but none of them are currently infected.

;; The virus carrier begins in the middle of the map facing up.

;; For example, suppose you are given a map like this:

(def sample-input #{[-1 0] [1 1]})
;; ..#
;; #..
;; ...

(def turn-left {:up :left :left :down :down :right :right :up})
(def turn-right {:up :right :right :down :down :left :left :up})

(defn move [^longs [x y] direction]
  (case direction
    :up [x (inc y)]
    :down [x (dec y)]
    :left [(dec x) y]
    :right [(inc x) y]))

(defn tick [{:keys [grid pos direction infections]}]
  (let [cur-node (grid pos)]
    (if cur-node
      ;; current node is infected
      {:grid (disj grid pos)
       :direction (turn-right direction)
       :pos (move pos (turn-right direction))
       :infections infections}
      ;; current node is clean
      {:grid (conj grid pos)
       :direction (turn-left direction)
       :pos (move pos (turn-left direction))
       :infections (inc infections)}
      )
    )
  )
;; Then, the middle of the infinite grid looks like this, with the virus
;; carrier's position marked with [ ]:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . # . . .
;; . . . #[.]. . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

(nth (iterate tick {:grid sample-input :pos [0 0] :direction :up :infections 0}) 0)

;; The virus carrier is on a clean node, so it turns left, infects the node, and
;; moves left:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . # . . .
;; . . .[#]# . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

(nth (iterate tick {:grid sample-input :pos [0 0] :direction :up :infections 0}) 1)

;; The virus carrier is on an infected node, so it turns right, cleans the node,
;; and moves up:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . .[.]. # . . .
;; . . . . # . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

(nth (iterate tick {:grid sample-input :pos [0 0] :direction :up :infections 0}) 2)

;; Four times in a row, the virus carrier finds a clean, infects it, turns left,
;; and moves forward, ending in the same place and still facing up:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . #[#]. # . . .
;; . . # # # . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

(nth (iterate tick {:grid sample-input :pos [0 0] :direction :up :infections 0}) 6)

;; Now on the same node as before, it sees an infection, which causes it to turn
;; right, clean the node, and move forward:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . # .[.]# . . .
;; . . # # # . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

(nth (iterate tick {:grid sample-input :pos [0 0] :direction :up :infections 0}) 7)
;; After the above actions, a total of 7 bursts of activity had taken place. Of
;; them, 5 bursts of activity caused an infection.

(nth (iterate tick {:grid sample-input :pos [0 0] :direction :up :infections 0}) 7)
;; => {:grid #{[1 0] [1 1] [-1 -1] [1 -1] [0 -1]}, :direction :right, :pos [-2 -1], :infections 5}

;; After a total of 70, the grid looks like this, with the virus carrier facing
;; up:

;; . . . . . # # . .
;; . . . . # . . # .
;; . . . # . . . . #
;; . . # . #[.]. . #
;; . . # . # . . # .
;; . . . . . # # . .
;; . . . . . . . . .
;; . . . . . . . . .

(defn infections-after [grid pos n]
  (as-> {:grid grid :pos pos :direction :up :infections 0} $
       (iterate tick $)
       (nth $ n)
       (:infections $)))
;; By this time, 41 bursts of activity caused an infection (though most of those
;; nodes have since been cleaned).
(infections-after sample-input [0 0] 70)
;; => 41

;; After a total of 10000 bursts of activity, 5587 bursts will have caused an
;; infection.

(infections-after sample-input [0 0] 10000)
;; => 5587

;; Given your actual map, after 10000 bursts of activity, how many bursts cause
;; a node to become infected? (Do not count nodes that begin infected.)

(infections-after puzzle-input [12 -12] 10000)
;; => 5460

;; --- Part Two ---

;; As you go to remove the virus from the infected nodes, it evolves to resist your attempt.

;; Now, before it infects a clean node, it will weaken it to disable your defenses. If it encounters an infected node, it will instead flag the node to be cleaned in the future. So:

(def node-transition {:clean :weak :weak :infected :infected :flagged :flagged :clean})

;;     Clean nodes become weakened.
;;     Weakened nodes become infected.
;;     Infected nodes become flagged.
;;     Flagged nodes become clean.

(defn convert-input [s]
  (into {} (for [pos s] [pos :infected])))

;; Every node is always in exactly one of the above states.

;; The virus carrier still functions in a similar way, but now uses the following logic during its bursts of action:

;;     Decide which way to turn based on the current node:
;;         If it is clean, it turns left.
;;         If it is weakened, it does not turn, and will continue moving in the same direction.
;;         If it is infected, it turns right.
;;         If it is flagged, it reverses direction, and will go back the way it came.
;;     Modify the state of the current node, as described above.
;;     The virus carrier moves forward one node in the direction it is facing.

(defn tick2 [{:keys [grid position direction infections]}]
  (let [node-state (grid position :clean)
        node-state' (node-transition node-state)
        new-direction (case node-state
                        :clean (turn-left direction)
                        :weak direction
                        :infected (turn-right direction)
                        :flagged (turn-right (turn-right direction))
                        )
        new-position (move position new-direction)
        new-infections (case node-state' :infected (inc infections) infections)]
    {:grid (assoc grid position node-state')
     :position new-position
     :direction new-direction
     :infections new-infections}))

(defn infections-after-2 [grid pos n]
  (as-> {:grid grid :position pos :direction :up :infections 0} $
    (iterate tick2 $)
    (nth $ n)
    (:infections $)))

;; Start with the same map (still using . for clean and # for infected) and still with the virus carrier starting in the middle and facing up.

;; Using the same initial state as the previous example, and drawing weakened as W and flagged as F, the middle of the infinite grid looks like this, with the virus carrier's position again marked with [ ]:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . # . . .
;; . . . #[.]. . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

;; This is the same as before, since no initial nodes are weakened or flagged. The virus carrier is on a clean node, so it still turns left, instead weakens the node, and moves left:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . # . . .
;; . . .[#]W . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

;; The virus carrier is on an infected node, so it still turns right, instead flags the node, and moves up:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . .[.]. # . . .
;; . . . F W . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

;; This process repeats three more times, ending on the previously-flagged node and facing right:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . W W . # . . .
;; . . W[F]W . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

;; Finding a flagged node, it reverses direction and cleans the node:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . W W . # . . .
;; . .[W]. W . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

;; The weakened node becomes infected, and it continues in the same direction:

;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . W W . # . . .
;; .[.]# . W . . . .
;; . . . . . . . . .
;; . . . . . . . . .
;; . . . . . . . . .

;; Of the first 100 bursts, 26 will result in infection. Unfortunately, another feature of this evolved virus is speed; of the first 10000000 bursts, 2511944 will result in infection.

(infections-after-2 (convert-input sample-input) [0 0] 100)
;; => 26
(infections-after-2 (convert-input sample-input) [0 0] 10000000)
;; => 2511944

;; Given your actual map, after 10000000 bursts of activity, how many bursts cause a node to become infected? (Do not count nodes that begin infected.)

(infections-after-2 (convert-input puzzle-input) [12 -12] 10000000)
;; => 2511702
