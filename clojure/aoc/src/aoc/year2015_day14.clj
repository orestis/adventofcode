(ns aoc.year2015-day14
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.math.combinatorics :as combo])
  (:require [clojure.string :as str]))

(defonce input
  (-> "2015/day14.txt" io/resource slurp str/split-lines))

;; --- Day 14: Reindeer Olympics ---

;; This year is the Reindeer Olympics! Reindeer can fly at high speeds, but must
;; rest occasionally to recover their energy. Santa would like to know which of his
;; reindeer is fastest, and so he has them race.

;; Reindeer can only either be flying (always at their top speed) or resting (not
;; moving at all), and always spend whole seconds in either state.

;; For example, suppose you have the following Reindeer:

(defn pInt [x] (Integer/parseInt x))

(def sample-input [
    "Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds."
    "Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds."
])

(defn parse [line]
  (let [[_ name speed duration rest]
        (re-find #"(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds." line)]
    {:name (keyword name) :speed (pInt speed) :duration (pInt duration) :rest (pInt rest)}))




;; After one second, Comet has gone 14 km, while Dancer has gone 16 km. After ten
;; seconds, Comet has gone 140 km, while Dancer has gone 160 km. On the eleventh
;; second, Comet begins resting (staying at 140 km), and Dancer continues on for a
;; total distance of 176 km. On the 12th second, both reindeer are resting. They
;; continue to rest until the 138th second, when Comet flies for another ten
;; seconds. On the 174th second, Dancer flies for another 11 seconds.

(with-test
  (defn speed-for-time [{:keys [speed duration rest]} t]
    (let [t' (rem t (+ duration rest))]
      (if (= t' 0) 0
        (if (> t' duration) 0 speed))))
  (testing "speed-for-time"
    (is (= 0 (speed-for-time {:speed 14 :duration 10 :rest 127} 0)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 1)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 2)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 3)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 4)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 5)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 6)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 7)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 8)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 9)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 10)))
    (is (= 0 (speed-for-time {:speed 14 :duration 10 :rest 127} 11)))
    (is (= 0 (speed-for-time {:speed 14 :duration 10 :rest 127} 12)))
    (is (= 0 (speed-for-time {:speed 14 :duration 10 :rest 127} 137)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 138)))
    (is (= 14 (speed-for-time {:speed 14 :duration 10 :rest 127} 147)))
    (is (= 1 (speed-for-time {:speed 1 :duration 11 :rest 162} 174)))
    (is (= 0 (speed-for-time {:speed 14 :duration 10 :rest 127} 148)))))

(defn run [deer]
  (map #(speed-for-time deer %) (iterate inc 1))
  )

;; In this example, after the 1000th second, both reindeer are resting, and Comet
;; is in the lead at 1120 km (poor Dancer has only gotten 1056 km by that point).
;; So, in this situation, Comet would win (if the race ended at 1000 seconds).

(def sample-deers (map parse sample-input))

(defn position-after [deers t]
  (let [runs (map run deers)
        limited (map (partial take t) runs)
        distances (map (partial reduce +) limited)]
    distances))

(position-after sample-deers 1000)

;; Given the descriptions of each reindeer (in your puzzle input), after exactly
;; 2503 seconds, what distance has the winning reindeer traveled?

(apply max (position-after (map parse input) 2503))

;; Your puzzle answer was 2640.

;; --- Part Two ---

;; Seeing how reindeer move in bursts, Santa decides he's not pleased with the old
;; scoring system.

;; Instead, at the end of each second, he awards one point to the reindeer
;; currently in the lead. (If there are multiple reindeer tied for the lead, they
;; each get one point.) He keeps the traditional 2503 second time limit, of course,
;; as doing otherwise would be entirely ridiculous.

;; Given the example reindeer from above, after the first second, Dancer is in the
;; lead and gets one point. He stays in the lead until several seconds into Comet's
;; second burst: after the 140th second, Comet pulls into the lead and gets his
;; first point. Of course, since Dancer had been in the lead for the 139 seconds
;; before that, he has accumulated 139 points by the 140th second.


(defn points-after [deers t]
  (let [runs (map run deers)
        limited (map (partial take t) runs)
        positions (atom (vec (repeat (count deers) 0)))
        score (atom (vec (repeat (count deers) 0)))]
    (loop [race limited]
      (if (every? seq race)
        (let [speeds (map first race)]
          (swap! positions #(mapv + % speeds))
          (let [furthest (apply max @positions)
                points-round (mapv #(if (= furthest %) 1 0) @positions)]
                  (swap! score #(mapv + % points-round))
                  (recur (map rest race))))
        @score))))

(points-after sample-deers 1000)

;; After the 1000th second, Dancer has accumulated 689 points, while poor Comet,
;; our old champion, only has 312. So, with the new scoring system, Dancer would
;; win (if the race ended at 1000 seconds).

;; Again given the descriptions of each reindeer (in your puzzle input), after
;; exactly 2503 seconds, how many points does the winning reindeer have?

(apply max (points-after (map parse input) 2503))
;; Your puzzle answer was 1102.

(run-all-tests #"aoc\.year2015-day14")
