(ns aoc.year2015-day16
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(def input
  (-> "2015/day16.txt" io/resource slurp str/split-lines))

(defn parse [line]
  (let [[_, n] (re-find #"Sue (\d+)" line)
        attrs (re-seq #"(\w+): (\d+)" line)]
    [n, (into #{} (map rest attrs))]
  ))


(def aunts (map parse input))
;; --- Day 16: Aunt Sue ---

;; Your Aunt Sue has given you a wonderful gift, and you'd like to send her a
;; thank you card. However, there's a small problem: she signed it "From, Aunt
;; Sue".

;; You have 500 Aunts named "Sue".

;; So, to avoid sending the card to the wrong person, you need to figure out
;; which Aunt Sue (which you conveniently number 1 to 500, for sanity) gave you
;; the gift. You open the present and, as luck would have it, good ol' Aunt Sue
;; got you a My First Crime Scene Analysis Machine! Just what you wanted. Or
;; needed, as the case may be.

;; The My First Crime Scene Analysis Machine (MFCSAM for short) can detect a few
;; specific compounds in a given sample, as well as how many distinct kinds of
;; those compounds there are. According to the instructions, these are what the
;; MFCSAM can detect:

;;     children, by human DNA age analysis.
;;     cats. It doesn't differentiate individual breeds.
;;     Several seemingly random breeds of dog: samoyeds, pomeranians, akitas, and vizslas.
;;     goldfish. No other kinds of fish.
;;     trees, all in one group.
;;     cars, presumably by exhaust or gasoline or something.
;;     perfumes, which is handy, since many of your Aunts Sue wear a few kinds.

;; In fact, many of your Aunts Sue have many of these. You put the wrapping from
;; the gift into the MFCSAM. It beeps inquisitively at you a few times and then
;; prints out a message on ticker tape:

(def ^:dynamic *instructions* (into #{} (map #(str/split % #": ") [
"children: 3"
"cats: 7"
"samoyeds: 2"
"pomeranians: 3"
"akitas: 0"
"vizslas: 0"
"goldfish: 5"
"trees: 3"
"cars: 2"
"perfumes: 1"])))

(take 1 aunts)
(second (first aunts))
(into #{} (second (first aunts)))
(clojure.set/subset? #{'("akitas" "3")} #{["akitas" "3"]})

(= ["akitas" "3"] '("akitas" "3"))

(defn aunt? [aunt]
  (clojure.set/subset? (second aunt) *instructions*))


;; You make a list of the things you can remember about each Aunt Sue. Things
;; missing from your list aren't zero - you simply don't remember the value.

;; What is the number of the Sue that got you the gift?

(filter aunt? aunts)
;; => (["373" #{("pomeranians" "3") ("perfumes" "1") ("vizslas" "0")}])

;; Your puzzle answer was 373.

;; --- Part Two ---

;; As you're about to send the thank you note, something in the MFCSAM's
;; instructions catches your eye. Apparently, it has an outdated
;; retroencabulator, and so the output from the machine isn't exact values -
;; some of them indicate ranges.

;; In particular, the cats and trees readings indicates that there are greater
;; than that many (due to the unpredictable nuclear decay of cat dander and tree
;; pollen), while the pomeranians and goldfish readings indicate that there are
;; fewer than that many (due to the modial interaction of magnetoreluctance).

(def *exact-instructions* (into #{} (map #(str/split % #": ") [
"children: 3"
"samoyeds: 2"
"akitas: 0"
"vizslas: 0"
"cars: 2"
"perfumes: 1"])))

;; weird behaviour of into {}, needs everything to be a vector
(defn get-in-set [s k]
  (get (into {} (mapv vec s)) k))


(defn greater-than? [aunt k g]
  (let [v (get-in-set (second aunt) k)]
    (if (nil? v) true ;; if we don't know, we can't assume
        (> (Integer/parseInt v) g))))

;; "cats: 7"
;; "trees: 3"
(greater-than? (first aunts) "akitass" 3)

"goldfish: 5"
"pomeranians: 3"
(defn less-than? [aunt k g]
  (let [v (get-in-set (second aunt) k)]
    (if (nil? v) true ;; if we don't know, we can't assume
        (< (Integer/parseInt v) g))))


(defn aunt2? [aunt]
  (clojure.set/superset? *exact-instructions* aunt)
  )
;; What is the number of the real Aunt Sue?

(filter aunt2? aunts)

;; Your puzzle answer was 260.

(run-tests)
