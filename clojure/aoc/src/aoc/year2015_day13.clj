(ns aoc.year2015-day13
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(defonce input
  (-> "2015/day13.txt" io/resource slurp str/split-lines))

;; --- Day 13: Knights of the Dinner Table ---

;; In years past, the holiday feast with your family hasn't gone so well. Not
;; everyone gets along! This year, you resolve, will be different. You're going to
;; find the optimal seating arrangement and avoid all those awkward conversations.

;; You start by writing up a list of everyone invited and the amount their
;; happiness would increase or decrease if they were to find themselves sitting
;; next to each other person. You have a circular table that will be just big
;; enough to fit everyone comfortably, and so each person will have exactly two
;; neighbors.

;; For example, suppose you have only four attendees planned, and you calculate
;; their potential happiness as follows:

(def sample-input [
"Alice would gain 54 happiness units by sitting next to Bob."
"Alice would lose 79 happiness units by sitting next to Carol."
"Alice would lose 2 happiness units by sitting next to David."
"Bob would gain 83 happiness units by sitting next to Alice."
"Bob would lose 7 happiness units by sitting next to Carol."
"Bob would lose 63 happiness units by sitting next to David."
"Carol would lose 62 happiness units by sitting next to Alice."
"Carol would gain 60 happiness units by sitting next to Bob."
"Carol would gain 55 happiness units by sitting next to David."
"David would gain 46 happiness units by sitting next to Alice."
"David would lose 7 happiness units by sitting next to Bob."
"David would gain 41 happiness units by sitting next to Carol."])

(defn parse [line]
  (let [[_ from diff units to]
        (re-find #"(\w+) would (gain|lose) (\d+) happiness units by sitting next to (\w+)" line)
        sign (case diff "gain" 1 "lose" -1)
        units (* sign (Integer/parseInt units))
        ]
    {[(keyword from) (keyword to)] units})
  )

;; Then, if you seat Alice next to David, Alice would lose 2 happiness
;; units (because David talks so much), but David would gain 46 happiness
;; units (because Alice is such a good listener), for a total change of 44.

;; If you continue around the table, you could then seat Bob next to Alice (Bob
;; gains 83, Alice gains 54). Finally, seat Carol, who sits next to Bob (Carol
;; gains 60, Bob loses 7) and David (Carol gains 55, David gains 41). The
;; arrangement looks like this:

;;      +41 +46
;; +55   David    -2
;; Carol       Alice
;; +60    Bob    +54
;;      -7  +83

(def sample-pairs (into {} (map parse sample-input)))

(sample-pairs [:Alice :Bob])

(defn happiness [arr hapmap]
  (let [v (vec arr)
        cycled (conj v (first v))
        pairs (partition 2 1 cycled)
        pairs' (map reverse pairs)
        cw (map hapmap pairs)
        ccw (map hapmap pairs')]
    (reduce + (concat cw ccw))))

(happiness [:David :Alice :Bob :Carol] sample-pairs)

;; After trying every other seating arrangement in this hypothetical scenario, you
;; find that this one is the most optimal, with a total change in happiness of 330.

(defn guests [pairs] (-> pairs keys flatten distinct))

(defn gen-seatings [pairs]
  (combo/permutations (guests pairs)))

(def input-pairs (into {} (map parse input)))


;; What is the total change in happiness for the optimal seating arrangement of the
;; actual guest list?

(apply max (map #(happiness % input-pairs) (gen-seatings input-pairs)))

;; Your puzzle answer was 618.

;; --- Part Two ---

;; In all the commotion, you realize that you forgot to seat yourself. At this
;; point, you're pretty apathetic toward the whole thing, and your happiness
;; wouldn't really go up or down regardless of who you sit next to. You assume
;; everyone else would be just as ambivalent about sitting next to you, too.

;; So, add yourself to the list, and give all happiness relationships that involve
;; you a score of 0.

(take 5 input-pairs)

(def my-pairs 
  (into {} (for [g (guests input-pairs)] {[g :Orestis] 0 [:Orestis g] 0})))

(def input-pairs-me (merge input-pairs my-pairs))

;; What is the total change in happiness for the optimal seating arrangement that
;; actually includes yourself?

(apply max (map #(happiness % input-pairs-me) (gen-seatings input-pairs-me)))

;; Your puzzle answer was 601.
