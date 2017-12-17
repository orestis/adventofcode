(ns aoc.2017-day17)

;; --- day 17: Spinlock ---

;; Suddenly, whirling in the distance, you notice what looks like a massive,
;; pixelated hurricane: a deadly spinlock. This spinlock isn't just consuming
;; computing power, but memory, too; vast, digital mountains are being ripped
;; from the ground and consumed by the vortex.

;; If you don't move quickly, fixing that printer will be the least of your problems.

;; This spinlock's algorithm is simple but efficient, quickly consuming
;; everything in its path. It starts with a circular buffer containing only the
;; value 0, which it marks as the current position. It then steps forward
;; through the circular buffer some number of steps (your puzzle input) before
;; inserting the first new value, 1, after the value it stopped on. The inserted
;; value becomes the current position. Then, it steps forward from there the
;; same number of steps, and wherever it stops, inserts after it the second new
;; value, 2, and uses that as the new current position again.

;; It repeats this process of stepping forward, inserting a new value, and using
;; the location of the inserted value as the new current position a total of
;; 2017 times, inserting 2017 as its final operation, and ending with a total of
;; 2018 values (including 0) in the circular buffer.

;; For example, if the spinlock were to step 3 times per insert, the circular
;; buffer would begin to evolve like this (using parentheses to mark the current
;; position after each iteration of the algorithm):

;;     (0), the initial state before any insertions.

;;     0 (1): the spinlock steps forward three times (0, 0, 0), and then inserts
;;     the first value, 1, after it. 1 becomes the current position.

;;     0 (2) 1: the spinlock steps forward three times (0, 1, 0), and then
;;     inserts the second value, 2, after it. 2 becomes the current position.

;;     0 2 (3) 1: the spinlock steps forward three times (1, 0, 2), and then
;;     inserts the third value, 3, after it. 3 becomes the current position.

;; And so on:

;;     0  2 (4) 3  1
;;     0 (5) 2  4  3  1
;;     0  5  2  4  3 (6) 1
;;     0  5 (7) 2  4  3  6  1
;;     0  5  7  2  4  3 (8) 6  1
;;     0 (9) 5  7  2  4  3  8  6  1

;; Eventually, after 2017 insertions, the section of the circular buffer near
;; the last insertion looks like this:

;; 1512  1134  151 (2017) 638  1513  851

;; Perhaps, if you can identify the value that will ultimately be after the last
;; value written (2017), you can short-circuit the spinlock. In this example,
;; that would be 638.

;; What is the value after 2017 in your completed circular buffer?

;; Your puzzle input is 376.

(defn cb-new [] {:pos 0 :buf [0]})

(defn insert-at [v i x]
  (vec (concat (subvec v 0 i) [x] (subvec v i))))

(defn insert [{:keys [pos buf]} steps v]
  (let [next-pos (rem (+ pos steps 1) (count buf))
        next-buf (insert-at buf next-pos v)]
    (if (= 0 (rem v 10000)) (println "inserted value " v))
    {:pos next-pos :buf next-buf}))

(defn part-1 [steps]
  (let [red-fn (fn [cb v] (insert cb steps v))
        cb (reduce red-fn {:pos 0 :buf [0]} (range 1 2018))]
    (get (:buf cb) (inc (:pos cb)))))

(part-1 3)
;; => 638

(part-1 376)
;; => 777


;; --- Part Two ---

;; The spinlock does not short-circuit. Instead, it gets more angry. At least,
;; you assume that's what happened; it's spinning significantly faster than it
;; was a moment ago.

;; You have good news and bad news.

;; The good news is that you have improved calculations for how to stop the
;; spinlock. They indicate that you actually need to identify the value after 0
;; in the current state of the circular buffer.

;; The bad news is that while you were determining this, the spinlock has just
;; finished inserting its fifty millionth value (50000000).

;; What is the value after 0 the moment 50000000 is inserted?

(defn part-2 [steps]
  (let [red-fn (fn [cb v] (insert cb steps v))
        cb (reduce red-fn {:pos 0 :buf [0]} (range 1 (inc 50e6)))
        buf (:buf cb)
        zero-pos (.indexOf buf 0)
        ]
    (get buf (inc zero-pos)) 
    ))


;; again, for 50 million values, at even 1ms per value, we arrive at 13 hours of computation :(
#_(part-2 376)
(part-2 376)


(defn insert-376 [cb v] (insert cb 376 v))

(defn prn-cb [{:keys [buf ^long pos]}]
  (let [s (mapv str buf)
        at-pos (get s pos)
        s' (assoc s pos (str "(" at-pos ")"))]
    (apply str (interpose " " s')))
  )


;; looky here; a nice sequence
(map #(println (prn-cb %)) (reductions insert-376 {:pos 0 :buf [0]} (range 1 393)))
;; => (0 1 1 3 3 3 3 3 3 3 3 11 11 11 11 11 11 11 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37 37)

;; what does it look like?
(sort (keys (group-by identity (map #(first (:buf %)) (reductions insert-376 {:pos 0 :buf [0]} (range 1 10000))))))
;; => (0 1 3 11 18 37 239 361 392 823 950 1612 2539 8280)

;; sloane's doesn't understand this :(

(def cached-reductions (reductions insert-376 {:pos 0 :buf [0]} (range 1 30000)))
(def cached (map #(first (:buf %)) cached-reductions))
(def positions (map #(:pos %) cached-reductions))

(sort (map (fn [[k v]] [k (count v)]) (group-by identity cached)))
;; => ([0 1] [1 2] [3 8] [11 7] [18 19] [37 202] [239 122] [361 31] [392 431] [823 127] [950 662] [1612 927] [2539 5741] [8280 15551] [23831 6169])



;; it seems that we have pairs:
;; N M
;; N+1 = (N+M)
;; M+1 = ??

(map first (sort (map (fn [[k v]] [k (count v)]) (group-by identity cached))))
;; => (0 1 3 11 18 37 239 361 392 823 950 1612 2539 8280 23831)
(map second (sort (map (fn [[k v]] [k (count v)]) (group-by identity cached))))
;; => (1 2 8 7 19 202 122 31 431 127 662 927 5741 15551 6169) ;; last element is always incomplete

(map #(rem (first %) 376) (rest (sort (map (fn [[k v]] [k (count v)]) (group-by identity cached)))))
;; => (1 3 11 18 37 239 361 16 71 198 108 283 8 143)
(map #(rem (second %) 376) (rest (sort (map (fn [[k v]] [k (count v)]) (group-by identity cached)))))
;; => (2 8 7 19 202 122 31 55 127 286 175 101 135 153)

o



;; second try; brute force with a faster implementation

(set! *unchecked-math* :warn-on-boxed)
(set! *warn-on-reflection* true)


(defn part-2-brute [^long steps ^long limit]
  (let [cb (doto (new java.util.ArrayList) (.add 0))]
  (loop [pos 0 length 1 value 1]
    (if (= 0 (rem value 100000)) (println "set value " value))
    (let [new-pos (rem (+ pos steps 1) length)]
      (if (= limit value)
        (let [zeropos (.indexOf cb 0)
              posafter (rem (inc zeropos) length)]
          (.get cb posafter))
        (do
          (.add cb (int new-pos) value)
          (recur new-pos (inc length) (inc value))))))))

(part-2-brute 376 376)

;;; ARGH

;; zero is always last, the element we're looking for is always the first
;; we will get a new first element whenever the current pos is going to be 0
;; let's ignore the first N (N=376) values as there will be repeats;
;; after inserting N values, we will have length N+1, and will be at pos P
;; in our case, we will be at pos 0 after inserting value 392
;; for 393, we will be at pos 376 + 1
;; for 394, we will be at pos 376 + 1 + 376 + 1
;; for 395, we will be at pos 376 + 1 + 376 + 1 + 376 + 2
;; for 396, we will be at pos 376 + 1 + 376 + 1 + 376 + 2 + 376 + 3
;; for 397, we will be at pos 376 + 1 + 376 + 1 + 376 + 2 + 376 + 3 + 376 + 4
;; for 398, we will be at pos 376 + 1 + 376 + 1 + 376 + 2 + 376 + 3 + 376 + 4 + 376 + 5
;; for 399, we will be at pos 7 * 376 + SUM[1, 7) + 1
;; for X, we will be at pos (X-392) * 376 + SUM[1, X-392) + 1
;; for 823,
;; we will be again at pos 0 after inserting value 392, 823, 950, 1612, 2539, 8280, 23831

(map #(int (/ % 376)) [392, 823, 950, 1612, 2539, 8280, 23831])


(:pos (nth cached-reductions 410))
(defn calc-pos [^long n]
  (let [d (- n 392)]
  (mod
   (+
    (* 376 d)
    (reduce + (range d))
    1) n)))

(calc-pos 410)

(rem )

;; BLERG

;; after looking at some other solutions, try again; need to leave soon ...

;; thanks to https://github.com/vvvvalvalval/advent-of-code-2017/blob/master/src/aoc2017/day17.clj
(defn part-2-cheat [^long steps limit]
  (loop [pos 0 length 1 value 1 tracked 0]
    (if (= 0 (rem value 100000)) (println "set value" value))
    (if (= value limit) tracked
        (let [new-pos (rem (+ pos steps) length)
              tracked (if (= 0 new-pos) value tracked)]
          (recur (inc new-pos) (inc length) (inc value) tracked)
          )))) 

(part-2-cheat 376 50000000);; => 39289581
