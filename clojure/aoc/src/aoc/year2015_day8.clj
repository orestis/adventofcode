(ns aoc.year2015-day8
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(defonce input
  (-> "2015/day8.txt" io/resource slurp str/split-lines))

;; --- Day 8: Matchsticks ---

;; Space on the sleigh is limited this year, and so Santa will be bringing his list
;; as a digital copy. He needs to know how much space it will take up when stored.

;; It is common in many programming languages to provide a way to escape special
;; characters in strings. For example, C, JavaScript, Perl, Python, and even PHP
;; handle special characters in very similar ways.

;; However, it is important to realize the difference between the number of
;; characters in the code representation of the string literal and the number of
;; characters in the in-memory string itself.

;; For example:

;;     "" is 2 characters of code (the two double quotes), but the string contains
;;     zero characters.
;;
;;     "abc" is 5 characters of code, but 3 characters in the
;;     string data.
;;
;;      "aaa\"aaa" is 10 characters of code, but the string itself
;;     contains six "a" characters and a single, escaped quote character, for a
;;     total of 7 characters in the string data.
;;
;;       "\x27" is 6 characters of code,
;;     but the string itself contains just one - an apostrophe ('), escaped using
;;     hexadecimal notation.


(with-test
  (defn charcount [s]
    (-> s
        (str/replace #"(^\")" "")
        (str/replace #"(\"$)" "")
        (str/replace #"(\\\\)" ".")
        (str/replace #"(\\x[0-9a-fA-F]{2})" ".")
        (str/replace #"(\\\")" ".")
        count))
  (testing "Count"
    (doseq [[s c cc] [
                  ["\"\"" 0 2]
                  ["\"julb\"" 4 6]
                  ["\"ab\\\\c\"" 4 7]
                  ["\"abc\"" 3 5]
                  ["\"aaa\\\"aaa\"" 7 10]
                  ["\"aaa\\\\\\\"aaa\"" 8 12]
                  ["\"\\\\\\x27\"" 2 8]
                  ["\"\\x27\"" 1 6]
                  ["\"\\xfb\"" 1 6]
                  ]]
      (testing (str "mem " s)
        (is (= c (charcount s))))
      (testing (str "code " s)
        (is (= cc (count s)))))))


;; Santa's list is a file that contains many double-quoted string literals, one on
;; each line. The only escape sequences used are \\ (which represents a single
;; backslash), \" (which represents a lone double-quote character), and \x plus two
;; hexadecimal characters (which represents a single character with that ASCII
;; code).

;; Disregarding the whitespace in the file, what is the number of characters of
;; code for string literals minus the number of characters in memory for the values
;; of the strings in total for the entire file?

;; For example, given the four strings above, the total number of characters of
;; string code (2 + 5 + 10 + 6 = 23) minus the total number of characters in memory
;; for string values (0 + 3 + 7 + 1 = 11) is 23 - 11 = 12.

(defn diff [s]
  (- (count s) (charcount s)))

(reduce + (map diff input))

;; Your puzzle answer was 1342.


;; Now, let's go the other way. In addition to finding the number of characters of
;; code, you should now encode each code representation as a new string and find
;; the number of characters of the new encoded representation, including the
;; surrounding double quotes.

;; For example:

;; "" encodes to "\"\"", an increase from 2 characters to 6. "abc" encodes to
;; "\"abc\"", an increase from 5 characters to 9. "aaa\"aaa" encodes to
;; "\"aaa\\\"aaa\"", an increase from 10 characters to 16. "\x27" encodes to
;; "\"\\x27\"", an increase from 6 characters to 11.

(str/replace "\"\"" #"\"" "..")
(str/replace "\"abc\"" #"\"" "..")
(str/replace "\"aaa\\\"aaa" #"(\")|(\\)" "..")
(str/replace "\"\\x27\"" #"(\")|(\\)" "..")

(with-test
  (defn enccount [s]
    (-> s
        (str/replace #"(\")|(\\)" "..")
        count
        inc
        inc))
  (testing "Encode Count"
    (doseq [[s c cc] [
                      ["\"\"" 6 2]
                      ["\"abc\"" 9 5]
                      ["\"aaa\\\"aaa\"" 16 10]
                      ["\"\\x27\"" 11 6]
                      ]]
      (testing (str "enc " s)
        (is (= c (enccount s))))
      (testing (str "code " s)
        (is (= cc (count s)))))))

;; Your task is to find the total number of characters to represent the newly
;; encoded strings minus the number of characters of code in each original string
;; literal. For example, for the strings above, the total encoded length (6 + 9 +
;; 16 + 11 = 42) minus the characters in the original code representation (23, just
;; like in the first part of this puzzle) is 42 - 23 = 19.

(defn diff2 [s]
  (- (count s) (enccount s)))

(reduce + (map diff2 input))

;; Your puzzle answer was 2074.

(run-all-tests #"aoc\.year2015-day8")
