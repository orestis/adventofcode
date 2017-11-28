(ns aoc.year2015-day11
  (:use clojure.test)
  (:require [clojure.string :as str]))

(def input "vzbxkghb")

;; --- day 11: Corporate Policy ---

;; Santa's previous password expired, and he needs help choosing a new one.

;; To help him remember his new password after the old one expires, Santa has
;; devised a method of coming up with a password based on the previous one.
;; Corporate policy dictates that passwords must be exactly eight lowercase
;; letters (for security reasons), so he finds his new password by incrementing his
;; old password string repeatedly until it is valid.

;; incrementing is just like counting with numbers: xx, xy, xz, ya, yb, and so
;; on. Increase the rightmost letter one step; if it was z, it wraps around to
;; a, and repeat with the next letter to the left until one doesn't wrap around.

;; Unfortunately for Santa, a new Security-Elf recently started, and he has imposed
;; some additional password requirements:

    ;; passwords must include one increasing straight of at least three letters,
    ;; like abc, bcd, cde, and so on, up to xyz. They cannot skip letters; abd
    ;; doesn't count.

(def triads
  (for [i (range (int \a) (- (int \z) 1))] (str (char i) (char (inc i)) (char (inc (inc i))))))

(defn inc-triad? [s]
  (some #(str/includes? s %) triads))

    ;; Passwords may not contain the letters i, o, or l, as these letters can be
    ;; mistaken for other characters and are therefore confusing.

(defn not-confusing? [s]
  (every? #(not (str/includes? s %)) ["i" "o" "l"]))

    ;; Passwords must contain at least two different, non-overlapping pairs of
    ;; letters, like aa, bb, or zz.

(defn has-two-pairs? [s]
  (let [groups (partition-by identity s)
        counts (map count groups)
        pairs (filter #(>= % 2) counts)]
    (>= (count pairs) 2)))

;; for example:

    ;; hijklmmn meets the first requirement (because it contains the straight
    ;; hij) but fails the second requirement requirement (because it contains i
    ;; and l).

    ;; abbceffg meets the third requirement (because it repeats bb and ff) but
    ;; fails the first requirement.

    ;; abbcegjk fails the third requirement, because it only has one double
    ;; letter (bb).

    ;; The next password after abcdefgh is abcdffaa.

    ;; The next password after ghijklmn is ghjaabcc, because you eventually skip
    ;; all the passwords that start with ghi..., since i is not allowed.

(with-test
  (defn valid? [p]
    (every? #(= true (% p)) [not-confusing? inc-triad? has-two-pairs?]))
  (testing "valid"
    (doseq [[p v] [
                   ["hijklmmn" false]
                   ["abbceffg" false]
                   ["abbcegjk" false]
                   ["abcdffaa" true]
                   ["ghjaabcc" true]
                   ]]
      (testing p
        (is (= v (valid? p)))))))

(< (int \z) (int \y))

(reverse (seq "abc"))

(defn inc-password [p]
  (apply str (reverse
   (loop [chars (reverse (seq p))
          head '()]
      (let [c (int (first chars))]
        (if  (< c (int \z))
          (concat head (cons (char (inc c)) (rest chars)))
          (recur (rest chars) (cons \a head))))))))


(with-test
  (defn next-password [p]
    (let [stream (rest (iterate inc-password p))
          valid (filter valid? stream)]
      (first valid)))
  (testing "next"
    (doseq [
            [c n] [
                   ["abcdefgh" "abcdffaa"]
                   ["ghijklmn" "ghjaabcc"]
                   ]
            ]
      (testing c
        (is (= n (next-password c)))))))


;; Given Santa's current password (your puzzle input), what should his next password be?

;; Your puzzle answer was vzbxxyzz.

(next-password input)

;; --- Part Two ---

;; Santa's password expired again. What's the next one?

(next-password (next-password input))

;; Your puzzle answer was vzcaabcc.

(run-all-tests #"aoc\.year2015-day11")
