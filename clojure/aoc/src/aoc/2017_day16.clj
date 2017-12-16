(ns aoc.2017-day16
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(def input
  (-> "2017/day16.txt" io/resource slurp str/trim-newline (str/split #",")))

;; --- Day 16: Permutation Promenade ---

;; You come upon a very unusual sight; a group of programs here appear to be
;; dancing.

;; There are sixteen programs in total, named a through p. They start by
;; standing in a line: a stands in position 0, b stands in position 1, and so on
;; until p, which stands in position 15.

;; The programs' dance consists of a sequence of dance moves:

;;     Spin, written sX, makes X programs move from the end to the front, but
;;     maintain their order otherwise. (For example, s3 on abcde produces
;;     cdeab).

(defn spin [state n]
  (let [pivot (- (count state) n)]
    (vec (concat (subvec state pivot) (subvec state 0 pivot)))))

(spin [:a :b :c :d :e] 1)
;; => (:e :a :b :c :d)

;;     Exchange, written xA/B, makes the programs at positions A and B swap places.

(defn exchange [state x y]
  (let [a (state x) b (state y)]
    (assoc state x b y a)))

(exchange [:e :a :b :c :d] 3 4)
;; => [:e :a :b :d :c]

;;     Partner, written pA/B, makes the programs named A and B swap places.

(defn partner [state a b]
  (let [indexed (into {} (map-indexed #(vector %2 %1) state))
        x (get indexed a)
        y (get indexed b)]
    (exchange state x y)))

(partner [:e :a :b :d :c] :e :b)
;; => [:b :a :e :d :c]

;; For example, with only five programs standing in a line (abcde), they could
;; do the following dance:


;;     s1, a spin of size 1: eabcd.
;;     x3/4, swapping the last two programs: eabdc.
;;     pe/b, swapping programs e and b: baedc.

;; After finishing their dance, the programs end up in order baedc.

(defn instruction [state instr]
  (cond
    (str/starts-with? instr "s") (spin state (Integer/parseInt (subs instr 1)))
    (str/starts-with? instr "p") (apply partner state (map keyword (str/split (subs instr 1) #"/")))
    (str/starts-with? instr "x") (apply exchange state (map #(Integer/parseInt %) (str/split (subs instr 1) #"/")))))

(defn programs [] (mapv (comp keyword str) "abcdefghijklmnop"))

(def sample-instructions ["s1" "x3/4" "pe/b"])

(as-> (programs) $
    (take 5 $)
    (vec $)
    (reduce instruction $ sample-instructions)
    (map name $)
    (apply str $))
;; => "baedc"

;; You watch the dance for a while and record their dance moves (your puzzle
;; input). In what order are the programs standing after their dance?


(time
(as-> (programs) $
  (reduce instruction $ input)
  (map name $)
  (apply str $)))
;; => "dcmlhejnifpokgba"

;; --- Part Two ---

;; Now that you're starting to get a feel for the dance moves, you turn your
;; attention to the dance as a whole.

;; Keeping the positions they ended up in from their previous dance, the
;; programs perform it again and again: including the first dance, a total of
;; one billion (1000000000) times.

;; In the example above, their second dance would begin with the order baedc,
;; and use the same dance moves:

;; s1, a spin of size 1: cbaed.
;; x3/4, swapping the last two programs: cbade.
;; pe/b, swapping programs e and b: ceadb.

;; In what order are the programs standing after their billion dances?

(defn dance-billion [dance-moves]
  (let [state (programs)
        moves-count (count dance-moves)
        dances (take (* moves-count 1e9) (cycle dance-moves))]
    (as-> state $
      (reduce instruction $ dances)
      (map name $)
      (apply str $))))


;; haha, good try; 34 ms for the first dance, times 1 billion, 45 days. Merry easter :)
#_(dance-billion input)

(defn dance [state]
  (reduce instruction state input))

(defn state->str [state] (apply str (map name state)))

(second (filter (fn [[idx s]] (= s (programs))) (map-indexed vector (take 1000 (iterate dance (programs))))))
;; => [24 [:a :b :c :d :e :f :g :h :i :j :k :l :m :n :o :p]]

(nth (filter (fn [[idx s]] (= s (programs))) (map-indexed vector (take 1000 (iterate dance (programs))))) 2)
;; => [48 [:a :b :c :d :e :f :g :h :i :j :k :l :m :n :o :p]]

(nth (filter (fn [[idx s]] (= s (programs))) (map-indexed vector (take 1000 (iterate dance (programs))))) 3)
;; => [72 [:a :b :c :d :e :f :g :h :i :j :k :l :m :n :o :p]]

(nth (filter (fn [[idx s]] (= s (programs))) (map-indexed vector (take 1000 (iterate dance (programs))))) 4)
;; => [96 [:a :b :c :d :e :f :g :h :i :j :k :l :m :n :o :p]]

(nth (filter (fn [[idx s]] (= s (programs))) (map-indexed vector (take 1000 (iterate dance (programs))))) 5)
;; => [120 [:a :b :c :d :e :f :g :h :i :j :k :l :m :n :o :p]]

(rem 1e9 24)

(state->str
(nth (iterate dance (programs)) 16))
;; => "ifocbejpdnklamhg"
