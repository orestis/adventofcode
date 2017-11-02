(ns aoc.year2015-day4
  (:require [clojure.string :as str] ))
(import 'java.security.MessageDigest
        'java.math.BigInteger)
;; --- Day 4: The Ideal Stocking Stuffer ---

;; Santa needs help mining some AdventCoins (very similar to bitcoins) to use as
;; gifts for all the economically forward-thinking little girls and boys.

;; To do this, he needs to find MD5 hashes which, in hexadecimal, start with at
;; least five zeroes. The input to the MD5 hash is some secret key (your puzzle
;; input, given below) followed by a number in decimal. To mine AdventCoins, you
;; must find Santa the lowest positive number (no leading zeroes: 1, 2, 3, ...)
;; that produces such a hash.

;; For example:

;; If your secret key is abcdef, the answer is 609043, because the MD5 hash of
;; abcdef609043 starts with five zeroes (000001dbbfa...), and it is the lowest
;; such number to do so. If your secret key is pqrstuv, the lowest number it
;; combines with to make an MD5 hash starting with five zeroes is 1048970; that
;; is, the MD5 hash of pqrstuv1048970 looks like 000006136ef....



;; Your puzzle input was ckczppom.
(def input "ckczppom")


(defn md5 [^String s]
  (let [algorithm (MessageDigest/getInstance "MD5")
        raw (.digest algorithm (.getBytes s))]
    (format "%032x" (BigInteger. 1 raw))))

(md5 "abcdef609043")
(md5 "pqrstuv1048970")

(str input 1)

(defn hash-n
  [prefix n]
  [(md5 (str prefix n)) n])

(hash-n "abcdef" 609043)

(defn hashes
  [prefix]
  (map (partial hash-n prefix) (iterate inc 1)))

(take 100 (hashes input))

(str/starts-with? "00000" "1")

(first (drop-while #(not (str/starts-with? (first %) "00000")) (hashes input)))

;; Your puzzle answer was 117946.


;; Now find one that starts with six zeroes.

;; Your puzzle answer was 3938038.
(first (drop-while #(not (str/starts-with? (first %) "000000")) (hashes input)))

