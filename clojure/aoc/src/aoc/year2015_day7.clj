(ns aoc.year2015-day7
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(defonce input
  (-> "2015/day7.txt" io/resource slurp str/split-lines))


;; --- Day 7: Some Assembly Required ---

;; This year, Santa brought little Bobby Tables a set of wires and bitwise logic
;; gates! Unfortunately, little Bobby is a little under the recommended age range,
;; and he needs help assembling the circuit.

;; Each wire has an identifier (some lowercase letters) and can carry a 16-bit
;; signal (a number from 0 to 65535). A signal is provided to each wire by a gate,
;; another wire, or some specific value. Each wire can only get a signal from one
;; source, but can provide its signal to multiple destinations. A gate provides no
;; signal until all of its inputs have a signal.

;; The included instructions booklet describes how to connect the parts together: x
;; AND y -> z means to connect wires x and y to an AND gate, and then connect its
;; output to wire z.

;; For example:

;;     123 -> x means that the signal 123 is provided to wire x. x AND y -> z means
;;     that the bitwise AND of wire x and wire y is provided to wire z. p LSHIFT 2
;;     -> q means that the value from wire p is left-shifted by 2 and then provided
;;     to wire q. NOT e -> f means that the bitwise complement of the value from
;;     wire e is provided to wire f.

;; Other possible gates include OR (bitwise OR) and RSHIFT (right-shift). If, for
;; some reason, you'd like to emulate the circuit instead, almost all programming
;; languages (for example, C, JavaScript, or Python) provide operators for these
;; gates.

(defn parse-line [line]
  (let [[left right] (str/split line #" -> ")]
    [left (keyword right)]))

(deftest parse-line-test
  (is (= (parse-line "something -> else") ["something" :else])))

(defn convert-binary [left]
  (let [ops (str/split left #" ")
        shifted-ops
        (if (= 3 (count ops))
          [(nth ops 1) (nth ops 0) (nth ops 2)]
          ops)]
    (str/join " " shifted-ops)))

(deftest convert-binary-test
  (is (= (convert-binary "x AND y") "AND x y")))

(defn parse-left [left]
  (read-string (str "(" left ")")))

(def AND bit-and)
(def OR bit-or)
(def NOT bit-not)
(def LSHIFT bit-shift-left)
(def RSHIFT bit-shift-right)

(RSHIFT 23 5)


(defn parse-gate [line]
  (let [fn (cond
              (str/includes? line "AND") bit-and
              (str/includes? line "OR") bit-or
              (str/includes? line "NOT") bit-not
              (str/includes? line "LSHIFT") bit-shift-left
              (str/includes? line "RSHIFT") bit-shift-right
              :else identity
              )
        
        ]))

(defn parse-circuit [lines]
  lines)

(defn execute-circuit [circuit]
  {})

;; For example, here is a simple circuit:

(def test-circuit
(parse-circuit ["123 -> x"
"456 -> y"
"x AND y -> d"
"x OR y -> e"
"x LSHIFT 2 -> f"
"y RSHIFT 2 -> g"
"NOT x -> h"
"NOT y -> i"]))

;; After it is run, these are the signals on the wires:

(def test-results
{:d 72
:e 507
:f 492
:g 114
:h 65412
:i 65079
:x 123
:y 456})

(deftest sample-circuit
  (is (= test-results (execute-circuit test-circuit))))

(deftest real-circuit
  (is (= 956 (:a (execute-circuit (parse-circuit input))))))

;; In little Bobby's kit's instructions booklet (provided as your puzzle input),
;; what signal is ultimately provided to wire a?

;; Your puzzle answer was 956.

(run-all-tests #"aoc\.year2015-day7")
