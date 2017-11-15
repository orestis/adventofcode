(ns aoc.year2015-day6
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

;; --- Day 6: Probably a Fire Hazard ---

;; Because your neighbors keep defeating you in the holiday house decorating
;; contest year after year, you've decided to deploy one million lights in a
;; 1000x1000 grid.
(def input
  (-> "2015/day6.txt" io/resource slurp str/split-lines))

;; Furthermore, because you've been especially nice this year, Santa has mailed you
;; instructions on how to display the ideal lighting configuration.

;; Lights in your grid are numbered from 0 to 999 in each direction; the lights at
;; each corner are at 0,0, 0,999, 999,999, and 999,0. The instructions include
;; whether to turn on, turn off, or toggle various inclusive ranges given as
;; coordinate pairs. Each coordinate pair represents opposite corners of a
;; rectangle, inclusive; a coordinate pair like 0,0 through 2,2 therefore refers to
;; 9 lights in a 3x3 square. The lights all start turned off.

;; To defeat your neighbors this year, all you have to do is set up your lights by
;; doing the instructions Santa sent you in order.

;; For example:

;;     turn on 0,0 through 999,999 would turn on (or leave on) every light. toggle
;;     0,0 through 999,0 would toggle the first line of 1000 lights, turning off
;;     the ones that were on, and turning on the ones that were off. turn off
;;     499,499 through 500,500 would turn off (or leave off) the middle four
;;     lights.

(def lights
  (let [l (for [x (range 9) y (range 9)] [x y])]
    (zipmap l (repeat :off))
    ))
;; After following the instructions, how many lights are lit?

(defn initial-lights [w h]
  (let [l (for [x (range w) y (range h)] [x y])]
    (zipmap l (repeat :off))
    ))
  



(defn parse-coords [s]
  (let [parts (str/split s #",")]
    (mapv #(Integer/parseInt %) parts)))

(defn parse-on [line]
  (let [parts (str/split line #" ")
        from (nth parts 2)
        to (nth parts 4)]
    {:op :on,:from (parse-coords from),:to (parse-coords to)}))

(defn parse-off [line]
  (let [parts (str/split line #" ")
        from (nth parts 2)
        to (nth parts 4)]
    {:op :off,:from (parse-coords from),:to (parse-coords to)}))

(defn parse-toggle [line]
  (let [parts (str/split line #" ")
        from (nth parts 1)
        to (nth parts 3)]
    {:op :toggle,:from (parse-coords from),:to (parse-coords to)}))

(defn parse-line [line]
  (condp #(when (str/starts-with? %2 %1) %2) line
    "turn on" :>> parse-on
    "turn off" :>> parse-off
    "toggle" :>> parse-toggle))

(def instructions (map parse-line input))

(defn on-fn [_ v] v)
(defn off-fn [_ v] v)
(defn toggle-fn [v _] (if (= v :on) :off :on))

(defn expand-instruction [inst]
  (let [{:keys [op from to]} inst
        update-fn (case op
                    :on on-fn
                    :off off-fn
                    :toggle toggle-fn)
        to-update
        (for [x (range (first from) (+ 1 (first to)))
              y (range (second from) (+ 1 (second to)))]
          [x y])]
    [to-update update-fn op]
    ))

(expand-instruction {:op :on, :from [1 2], :to [3, 4]})


(defn apply-instruction
  [lights inst]
  (println "applying instru" inst)
  (let [[ops fn val] (expand-instruction inst)]
    (reduce #(update %1 %2 fn val) lights ops)))

(defn count-lit [lights]
  (count (filter #(= % :on) (vals lights))))

(count lights)

(count-lit lights)
(count-lit (apply-instruction lights {:op :on :from [1 2], :to [3 4]}))

(def test-lights
  (reduce apply-instruction (initial-lights 10 10) (take 10 instructions)))
(def solution-lights
  (reduce apply-instruction (initial-lights 1000 1000) instructions))

;; Your puzzle answer was 377891.
(count-lit solution-lights)

