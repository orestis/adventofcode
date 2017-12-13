(ns aoc.2017-day13
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(def input
  (-> "2017/day13.txt" io/resource slurp str/split-lines))

;;--- Day 13: Packet Scanners ---

;; You need to cross a vast firewall. The firewall consists of several layers,
;; each with a security scanner that moves back and forth across the layer. To
;; succeed, you must not be detected by a scanner.

;; By studying the firewall briefly, you are able to record (in your puzzle
;; input) the depth of each layer and the range of the scanning area for the
;; scanner within it, written as depth: range. Each layer has a thickness of
;; exactly 1. A layer at depth 0 begins immediately inside the firewall; a layer
;; at depth 1 would start immediately after that.

;; For example, suppose you've recorded the following:

(def sample-input [
"0: 3"
"1: 2"
"4: 4"
"6: 4"])

(defn parse [line]
  (->>
    (str/split line #": ")
    (mapv #(Integer/parseInt %))))

(def sample-layers
  (into {} (map parse sample-input)))

(def input-layers
  (into {} (map parse input)))

;; This means that there is a layer immediately inside the firewall (with range
;; 3), a second layer immediately after that (with range 2), a third layer which
;; begins at depth 4 (with range 4), and a fourth layer which begins at depth
;; 6 (also with range 4). Visually, it might look like this:

;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;; Within each layer, a security scanner moves back and forth within its range.
;; Each security scanner starts at the top and moves down until it reaches the
;; bottom, then moves up until it reaches the top, and repeats. A security
;; scanner takes one picosecond to move one step. Drawing scanners as S, the
;; first few picoseconds look like this:


;; Picosecond 0:
;;  0   1   2   3   4   5   6
;; [S] [S] ... ... [S] ... [S]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;; Picosecond 1:
;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;; Picosecond 2:
;;  0   1   2   3   4   5   6
;; [ ] [S] ... ... [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]

;; Picosecond 3:
;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] ... [ ]
;; [S] [S]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [S]     [S]

;; Your plan is to hitch a ride on a packet about to move through the firewall.
;; The packet will travel along the top of each layer, and it moves at one layer
;; per picosecond. Each picosecond, the packet moves one layer forward (its
;; first move takes it into layer 0), and then the scanners move one step. If
;; there is a scanner at the top of the layer as your packet enters it, you are
;; caught. (If a scanner moves into the top of its layer while you are there,
;; you are not caught: it doesn't have time to notice you before you leave.) If
;; you were to do this in the configuration above, marking your current position
;; with parentheses, your passage through the firewall would look like this:

;; Initial state:
;;  0   1   2   3   4   5   6
;; [S] [S] ... ... [S] ... [S]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;; Picosecond 0:
;;  0   1   2   3   4   5   6
;; (S) [S] ... ... [S] ... [S]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; ( ) [ ] ... ... [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]


;; Picosecond 1:
;;  0   1   2   3   4   5   6
;; [ ] ( ) ... ... [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] (S) ... ... [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]


;; Picosecond 2:
;;  0   1   2   3   4   5   6
;; [ ] [S] (.) ... [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [ ] (.) ... [ ] ... [ ]
;; [S] [S]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [S]     [S]


;; Picosecond 3:
;;  0   1   2   3   4   5   6
;; [ ] [ ] ... (.) [ ] ... [ ]
;; [S] [S]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [S]     [S]

;;  0   1   2   3   4   5   6
;; [S] [S] ... (.) [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [S]     [S]
;;                 [ ]     [ ]


;; Picosecond 4:
;;  0   1   2   3   4   5   6
;; [S] [S] ... ... ( ) ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [S]     [S]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... ( ) ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]


;; Picosecond 5:
;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] (.) [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [S] ... ... [S] (.) [S]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [ ]     [ ]
;;                 [ ]     [ ]


;; Picosecond 6:
;;  0   1   2   3   4   5   6
;; [ ] [S] ... ... [S] ... (S)
;; [ ] [ ]         [ ]     [ ]
;; [S]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] ... ( )
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

(defn scanner-movement [depth]
  (let [d' (dec depth)]
  (cycle (concat (range d') (range d' 0 -1)))))

(defn make-state [layers]
  {:scanners (into {} (map (fn [[l d]] [l (scanner-movement d)]) layers))
   :caught []})

(def sample-initial-state (make-state sample-layers))
(def initial-state (make-state input-layers))

(defn advance [{:keys [scanners caught] :as state} pos]
  (let [current-scanner (first (get scanners pos))
        caught' (if (= 0 current-scanner) (conj caught pos) caught)
        scanners' (into {} (map (fn [[l s]] [l (rest s)]) scanners))]
    (assoc state :scanners scanners' :caught caught')))


;; In this situation, you are caught in layers 0 and 6, because your packet
;; entered the layer when its scanner was at the top when you entered it. You
;; are not caught in layer 1, since the scanner moved into the top of the layer
;; once you were already there.
(:caught (reduce advance sample-initial-state (range 0 7)))
;; => [0 6]


;; The severity of getting caught on a layer is equal to its depth multiplied by
;; its range. (Ignore layers in which you do not get caught.) The severity of
;; the whole trip is the sum of these values. In the example above, the trip
;; severity is 0*3 + 6*4 = 24.

(defn severity [caught layers]
  (let [depths (map #(get layers %) caught)
        severities (map * caught depths)]
    (reduce + severities)))

(severity
  (:caught (reduce advance sample-initial-state (range 0 7)))
  sample-layers)
;; => 24

;; Given the details of the firewall you've recorded, if you leave immediately,
;; what is the severity of your whole trip?

(severity
 (:caught (reduce advance initial-state (range 0 (inc (apply max (keys input-layers))))))
 input-layers)
;; => 2508

;; --- Part Two ---

;; Now, you need to pass through the firewall without being caught - easier said
;; than done.

;; You can't control the speed of the packet, but you can delay it any number of
;; picoseconds. For each picosecond you delay the packet before beginning your
;; trip, all security scanners move one step. You're not in the firewall during
;; this time; you don't enter layer 0 until you stop delaying the packet.

;; In the example above, if you delay 10 picoseconds (picoseconds 0 - 9), you
;; won't get caught:

;; State after delaying:
;;  0   1   2   3   4   5   6
;; [ ] [S] ... ... [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]

;; Picosecond 10:
;;  0   1   2   3   4   5   6
;; ( ) [S] ... ... [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; ( ) [ ] ... ... [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]


;; Picosecond 11:
;;  0   1   2   3   4   5   6
;; [ ] ( ) ... ... [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [S] (S) ... ... [S] ... [S]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]


;; Picosecond 12:
;;  0   1   2   3   4   5   6
;; [S] [S] (.) ... [S] ... [S]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [ ] (.) ... [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]


;; Picosecond 13:
;;  0   1   2   3   4   5   6
;; [ ] [ ] ... (.) [ ] ... [ ]
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [S] ... (.) [ ] ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]


;; Picosecond 14:
;;  0   1   2   3   4   5   6
;; [ ] [S] ... ... ( ) ... [ ]
;; [ ] [ ]         [ ]     [ ]
;; [S]             [S]     [S]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... ( ) ... [ ]
;; [S] [S]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [S]     [S]


;; Picosecond 15:
;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] (.) [ ]
;; [S] [S]         [ ]     [ ]
;; [ ]             [ ]     [ ]
;;                 [S]     [S]

;;  0   1   2   3   4   5   6
;; [S] [S] ... ... [ ] (.) [ ]
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [S]     [S]
;;                 [ ]     [ ]


;; Picosecond 16:
;;  0   1   2   3   4   5   6
;; [S] [S] ... ... [ ] ... ( )
;; [ ] [ ]         [ ]     [ ]
;; [ ]             [S]     [S]
;;                 [ ]     [ ]

;;  0   1   2   3   4   5   6
;; [ ] [ ] ... ... [ ] ... ( )
;; [S] [S]         [S]     [S]
;; [ ]             [ ]     [ ]
;;                 [ ]     [ ]

;; Because all smaller delays would get you caught, the fewest number of
;; picoseconds you would need to delay to get through safely is 10.

(defn caught? [layers time-delay]
  (let [initial-state (make-state layers)
        delayed-state (reduce advance initial-state (repeat time-delay 0))
        fresh-state (assoc delayed-state :caught [])
        traversed-state (reduce advance fresh-state (range 0 (inc (apply max (keys layers)))))]
    (some? (seq (:caught traversed-state)))))

(first (remove (partial caught? sample-layers) (range)))
;; => 10

;; unfortunately, this takes a huge amount of time
#_(first (remove (partial caught? input-layers) (range)))

(defn find-delay [layers]
  (let [initial-state (make-state layers)
        path (range 0 (inc (apply max (keys layers))))
        delay-state (fn [s t] (assoc (reduce advance s (repeat t 0)) :caught []))]
    (loop [state initial-state d 0]
      (let [traversed-state (reduce advance state path)]
        (if (= 0 (rem d 100)) (println "delaying" d))
        (if (nil? (seq (:caught traversed-state))) d
            (recur (delay-state state 1) (inc d)))))))

(find-delay sample-layers)
;; => 10

;; this is also fantastically slow. Using cycle was probably not a good idea :)
#_(find-delay input-layers)

;; What is the fewest number of picoseconds that you need to delay the packet to
;; pass through the firewall without being caught?

(defn tick-scanner [{:keys [pos depth dir] :as s}]
  (let [x' (+ pos dir)]
    (cond
        (= x' depth) (tick-scanner (assoc s :dir (- dir)))
        (= x' -1) (tick-scanner (assoc s :dir (- dir)))
        :else (assoc s :pos x'))))

(defn caught? [scanners pos]
  (= 0 (:pos (get scanners pos))))

(defn tick-all-scanners [scanners]
  (into {} (map (fn [[l s]] [l (tick-scanner s)]) scanners)))

(defn run-successful? [scanners until]
  (loop [s scanners pos 0]
    (cond
      (caught? s pos) false
      (= pos until) true
      :else (recur (tick-all-scanners s) (inc pos)))))

(defn find-delay-2 [layers]
  (let [until (inc (apply max (keys layers)))
        initial-scanners (into {} (map (fn [[l d]] [l {:pos 0 :dir 1 :depth d}]) layers))]
        (loop [delay 0 scanners initial-scanners]
          (if (= 0 (rem delay 1000)) (println "delaying" delay))
          (if (run-successful? scanners until) delay
              (recur (inc delay) (tick-all-scanners scanners))))))

(find-delay-2 sample-layers);; => 10
(time
  (find-delay-2 input-layers))
;; => 3913186
;; "Elapsed time: 536598.496201 msecs"

;; scanner with depth D catches every P ticks
(defn scanner-catching-period [depth]
  (+ depth depth -2))

;; will scanner at layer L with depth D catch you if you start with delay T?
(defn scanner-catches? [delay layer depth]
  (let [period (scanner-catching-period depth)]
    (= 0 (rem (+ layer delay) period))))

(scanner-catches? 10 0 3) ;; => false
(scanner-catches? 10 1 2) ;; => false
(scanner-catches? 10 4 4) ;; => false
(scanner-catches? 10 6 4) ;; => false

(defn will-be-caught? [layers delay]
  (let [catches? (partial scanner-catches? delay)]
    (true? (some (fn [[l d]] (catches? l d)) layers))))

(will-be-caught? sample-layers 0) ;; => true
(will-be-caught? sample-layers 10) ;; => false

(defn find-delay-3 [layers]
  (let [pred (partial will-be-caught? layers)]
    (first (remove pred (range)))))

(find-delay-3 sample-layers)
(time
  (find-delay-3 input-layers))
;; => 3913186

;; "Elapsed time: 8226.279105 msecs"

