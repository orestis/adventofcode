(ns aoc.2017-day7
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str])))

(def input
  (-> "2017/day7.txt" io/resource slurp str/split-lines))

;; --- Day 7: Recursive Circus ---

;; Wandering further through the circuits of the computer, you come upon a tower
;; of programs that have gotten themselves into a bit of trouble. A recursive
;; algorithm has gotten out of hand, and now they're balanced precariously in a
;; large tower.

;; One program at the bottom supports the entire tower. It's holding a large
;; disc, and on the disc are balanced several more sub-towers. At the bottom of
;; these sub-towers, standing on the bottom disc, are other programs, each
;; holding their own disc, and so on. At the very tops of these
;; sub-sub-sub-...-towers, many programs stand simply keeping the disc below
;; them balanced but with no disc of their own.

;; You offer to help, but first you need to understand the structure of these
;; towers. You ask each program to yell out their name, their weight, and (if
;; they're holding a disc) the names of the programs immediately above them
;; balancing on that disc. You write this information down (your puzzle input).
;; Unfortunately, in their panic, they don't do this in an orderly fashion; by
;; the time you're done, you're not sure which program gave which information.

;; For example, if your list is the following:

(def sample-input [
"pbga (66)"
"xhth (57)"
"ebii (61)"
"havc (66)"
"ktlj (57)"
"fwft (72) -> ktlj, cntj, xhth"
"qoyq (66)"
"padx (45) -> pbga, havc, qoyq"
"tknk (41) -> ugml, padx, fwft"
"jptl (61)"
"ugml (68) -> gyxo, ebii, jptl"
"gyxo (61)"
"cntj (57)"])

(with-test
  (defn parse [line]
    (let [[_ name weight children] (re-find #"(\w+) \((\d+)\)(?: -> (.*))?" line)]
      (if-not (nil? children) 
        {:name name :weight (Integer/parseInt weight) :children (str/split children #", ")}
        {:name name :weight (Integer/parseInt weight) :children nil}
      )
      ))
  (are [x y] (= x y)
    {:name "pbga" :weight 66 :children nil} (parse "pbga (66)")
    {:name "padx" :weight 45 :children ["pbga" "havc" "qoyq"]} (parse "padx (45) -> pbga, havc, qoyq")
    ))

;; ...then you would be able to recreate the structure of the towers that looks
;; like this:

;;                 gyxo
;;               /     
;;          ugml - ebii
;;        /      \     
;;       |         jptl
;;       |        
;;       |         pbga
;;      /        /
;; tknk --- padx - havc
;;      \        \
;;       |         qoyq
;;       |             
;;       |         ktlj
;;        \      /     
;;          fwft - cntj
;;               \     
;;                 xhth

;; In this example, tknk is at the bottom of the tower (the bottom program), and
;; is holding up ugml, padx, and fwft. Those programs are, in turn, holding up
;; other programs; in this example, none of those programs are holding up any
;; other programs, and are all the tops of their own towers. (The actual tower
;; balancing in front of you is much larger.)

;; Before you're ready to help them, you need to make sure your information is
;; correct. What is the name of the bottom program?

(defn find-root [programs]
  (let [parents (keep #(when (:children %) %) programs)
        children (set (mapcat :children parents))
        names (set (map :name parents))]
    (clojure.set/difference names children)))

(find-root (map parse sample-input))
;; => #{"tknk"}
(find-root (map parse input))
;; => #{"svugo"}

;; --- Part Two ---

;; The programs explain the situation: they can't get down. Rather, they could
;; get down, if they weren't expending all of their energy trying to keep the
;; tower balanced. Apparently, one program has the wrong weight, and until it's
;; fixed, they're stuck here.

;; For any program holding a disc, each program standing on that disc forms a
;; sub-tower. Each of those sub-towers are supposed to be the same weight, or
;; the disc itself isn't balanced. The weight of a tower is the sum of the
;; weights of the programs in that tower.

;; In the example above, this means that for ugml's disc to be balanced, gyxo,
;; ebii, and jptl must all have the same weight, and they do: 61.

;; However, for tknk to be balanced, each of the programs standing on its disc
;; and all programs above it must each match. This means that the following sums
;; must all be the same:

;;     ugml + (gyxo + ebii + jptl) = 68 + (61 + 61 + 61) = 251
;;     padx + (pbga + havc + qoyq) = 45 + (66 + 66 + 66) = 243
;;     fwft + (ktlj + cntj + xhth) = 72 + (57 + 57 + 57) = 243

;; As you can see, tknk's disc is unbalanced: ugml's stack is heavier than the
;; other two. Even though the nodes above ugml are balanced, ugml itself is too
;; heavy: it needs to be 8 units lighter for its stack to weigh 243 and keep the
;; towers balanced. If this change were made, its weight would be 60.

(defn weight [name programs]
  (let [program (get programs name)]
  (if (nil? (:children program))
    (:weight program)
    (apply + (:weight program) (map #(weight % programs) (:children program))))))

(def sample-input-map (into {} (for [p (map parse sample-input)] [(:name p) p])))

(weight "gyxo" sample-input-map)
(weight "ugml" sample-input-map)
(weight "tknk" sample-input-map)

(defn is-balanced [name programs]
  (let [program (get programs name)]
    (if (nil? (:children program)) true
        (apply = (map #(weight % programs) (:children program))))))
(is-balanced "gyxo" sample-input-map)
(is-balanced "ugml" sample-input-map)
(is-balanced "tknk" sample-input-map)
(is-balanced "padx" sample-input-map)

(remove #(is-balanced % sample-input-map) (keys sample-input-map))
;; => ("tknk")

(def input-map (into {} (for [p (map parse input)] [(:name p) p])))

(defn find-unbalanced [programs]
  (let [u (remove #(is-balanced % programs) (keys programs))
        unbalanced (map #(get programs %) u)
        weights ]
    unbalanced))

(find-unbalanced input-map)
;; => ({:name "gjxqx", :weight 14, :children ["yruivis" "rizjob" "qsfwl" "asckjlv" "sfqwrge" "bncdhrm"]} {:name "svugo", :weight 32, :children ["xolvnpy" "gjxqx" "gtzxxav" "njorjq" "qpiklvf"]} {:name "yruivis", :weight 2760, :children ["oxipms" "ggpau" "sphbbz"]})

(weight "yruivis" input-map)
(weight "rizjob" input-map)
(weight "qsfwl" input-map)
(map #(weight % input-map) ["oxipms" "ggpau" "sphbbz"])
(map #(get input-map %) ["oxipms" "ggpau" "sphbbz"])

(- 1161 9)

;; Given that exactly one program is the wrong weight, what would its weight
;; need to be to balance the entire tower?

(run-tests)
