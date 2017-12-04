(ns aoc.2017-day4
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str])
  (:use clojure.test))

(def input
  (-> "2017/day4.txt" io/resource slurp str/split-lines))



;; --- Day 4: High-Entropy Passphrases ---

;; A new system policy has been put in place that requires all accounts to use a
;; passphrase instead of simply a password. A passphrase consists of a series of
;; words (lowercase letters) separated by spaces.

;; To ensure security, a valid passphrase must contain no duplicate words.

(defn valid-passphrase? [passphrase]
  (let [words (str/split passphrase #"\s+")]
    (= (count words) (count (distinct words)))))

;; For example:

;; aa bb cc dd ee is valid.
(valid-passphrase? "aa bb cc dd ee")
;; aa bb cc dd aa is not valid - the word aa appears more than once.
(valid-passphrase? "aa bb cc dd aa")
;; aa bb cc dd aaa is valid - aa and aaa count as different words.
(valid-passphrase? "aa bb cc dd aaa")


;; The system's full passphrase list is available as your puzzle input. How many
;; passphrases are valid?

(count (filter valid-passphrase? input))
;; => 455

;; --- Part Two ---

;; For added security, yet another system policy has been put in place. Now, a
;; valid passphrase must contain no two words that are anagrams of each other -
;; that is, a passphrase is invalid if any word's letters can be rearranged to
;; form any other word in the passphrase.

(defn valid-passphrase-anagram? [passphrase]
  (let [words (str/split passphrase #"\s+")
        sorted-words (map sort words)]
    (= (count sorted-words) (count (distinct sorted-words)))))


;; For example:

;; abcde fghij is a valid passphrase.
(valid-passphrase-anagram? "abcde fghij")
;; abcde xyz ecdab is not valid - the letters from the third word can be rearranged to form the first word.
(valid-passphrase-anagram? "abcde xyz ecdab")
;; a ab abc abd abf abj is a valid passphrase, because all letters need to be used when forming another word.
(valid-passphrase-anagram? "a ab abc abd abf abj")
;; iiii oiii ooii oooi oooo is valid.
(valid-passphrase-anagram? "iiii oiii ooii oooi oooo")
;; oiii ioii iioi iiio is not valid - any of these words can be rearranged to form any other word.
(valid-passphrase-anagram? "oiii ioii iioi iiio")

;; Under this new system policy, how many passphrases are valid?

(count (filter valid-passphrase-anagram? input))
;; => 186

(run-tests)
