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

(parse-line "b -> a")

(deftest parse-line-test
  (is (= (parse-line "something -> else") ["something" :else])))

(defn convert-binary [left]
  (let [ops (str/split left #" ")
        shifted-ops
        (cond (= 3 (count ops))
              [(nth ops 1) (nth ops 0) (nth ops 2)]
          :else ops)]
    shifted-ops))

(deftest convert-binary-test
  (is (= (convert-binary "x AND y") ["AND" "x" "y"])))

(def AND bit-and)
(def OR bit-or)
(def NOT bit-not)
(def LSHIFT bit-shift-left)
(def RSHIFT bit-shift-right)

(def funs {"AND" AND "OR" OR "NOT" #(+ 65536 (bit-not %)) "LSHIFT" LSHIFT "RSHIFT" RSHIFT})

(defn parse-int [i]
  (try (Integer/parseInt i)
       (catch NumberFormatException _ nil)))

(defn keyword-if-needed [v]
  (if-let [i (parse-int v)] i
      (keyword v)))



(defn parse-left [left]
  (let [f (first left)
        args (rest left)
        keywords (map keyword-if-needed args)
        all (concat [(get funs f (keyword f))] keywords)]

    (seq all)))
    ;;(read-string (str "(" (list all) ")"))))

(parse-left ["AND" "x" "y"])
(parse-left ["LSHIFT" "x" "2"])
(parse-left ["a"])


;; For example, here is a simple circuit:


(def sample-circuit ["123 -> x"
                     "456 -> y"
                     "x AND y -> d"
                     "x OR y -> e"
                     "x LSHIFT 2 -> f"
                     "y RSHIFT 2 -> g"
                     "NOT x -> h"
                     "NOT y -> i"])

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


(parse-int "123")
(parse-int "x AND y")

(defn left->expr [input]
  (if-let [v (parse-int input)] v (parse-left (convert-binary input))))

(defn line->expr [line]
  (let [[left right] (parse-line line)]
    {right (left->expr left)}))

(line->expr "x AND y -> d")
(line->expr "x AND y -> d")


(defn lookup [circuit key]
  (let [v (get circuit key)]
    (println "key " key "has val" v)
    (cond
      (integer? v) v
      :else (nested-lookup circuit v)
    )))

(def lookup-memo (memoize lookup))

(defn lookup-or-val [circuit key-or-val]
  (if (integer? key-or-val) key-or-val
      (lookup-memo circuit key-or-val)))

(defn nested-lookup [circuit v]
  (println "v" v)
  (let [f (first v)
        args (rest v)
        resolved (mapv #(lookup-or-val circuit %) args)
        result (apply f resolved)]
    (println  "    results in" result)
    result
    ))

(defn parse-circuit [lines]
  (into {} (map line->expr lines)))

(lookup (parse-circuit sample-circuit) :x)
(lookup (parse-circuit sample-circuit) :y)
(lookup (parse-circuit sample-circuit) :h)
(lookup (parse-circuit sample-circuit) :e)
(lookup (parse-circuit sample-circuit) :f)
(nested-lookup (parse-circuit sample-circuit) [bit-not :x])


(defn execute-circuit [circuit keys]
  (zipmap keys (map (partial lookup-memo circuit) keys)))

(execute-circuit (parse-circuit sample-circuit) [:x :y :d :e :h :i :f :g :h :i])

(execute-circuit (parse-circuit input) [:lx])

(deftest sample-circuit-test
  (is (= test-results (execute-circuit (parse-circuit sample-circuit) [:x :y :d :e :f :g :h :i]))))

(deftest real-circuit-test
  (is (= 956 :a (execute-circuit (parse-circuit input) [:a]))))

;; In little Bobby's kit's instructions booklet (provided as your puzzle input),
;; what signal is ultimately provided to wire a?

;; Your puzzle answer was 956.


;; Now, take the signal you got on wire a, override wire b to that signal, and reset the other wires (including wire a). What new signal is ultimately provided to wire a?

(def patched-circuit (assoc (parse-circuit input) :b 956))
(execute-circuit patched-circuit [:lx])
;; Your puzzle answer was 40149.



(run-all-tests #"aoc\.year2015-day7")
