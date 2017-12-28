(ns aoc.2017-day24
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(defn parse [line]
  (let [[a b] (str/split line #"/")]
    {:ports [(Integer/parseInt a) (Integer/parseInt b)]}))

(def puzzle-input
  (->> "2017/day24.txt" io/resource slurp str/split-lines (map parse) (into #{})))

;; --- Day 24: Electromagnetic Moat ---

;; The CPU itself is a large, black building surrounded by a bottomless pit.
;; Enormous metal tubes extend outward from the side of the building at regular
;; intervals and descend down into the void. There's no way to cross, but you
;; need to get inside.

;; No way, of course, other than building a bridge out of the magnetic
;; components strewn about nearby.

;; Each component has two ports, one on each end. The ports come in all
;; different types, and only matching types can be connected. You take an
;; inventory of the components by their port types (your puzzle input). Each
;; port is identified by the number of pins it uses; more pins mean a stronger
;; connection for your bridge. A 3/7 component, for example, has a type-3 port
;; on one side, and a type-7 port on the other.

;; Your side of the pit is metallic; a perfect surface to connect a magnetic,
;; zero-pin port. Because of this, the first port you use must be of type 0. It
;; doesn't matter what type of port you end with; your goal is just to make the
;; bridge as strong as possible.

;; The strength of a bridge is the sum of the port types in each component. For
;; example, if your bridge is made of components 0/3, 3/7, and 7/4, your bridge
;; has a strength of 0+3 + 3+7 + 7+4 = 24.

;; For example, suppose you had the following components:

(def sample-input (->>
"0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10" str/split-lines (map parse) (into #{})))

;;debugging parts of expressions
(defmacro dbg[x] `(let [x# ~x] (println "dbg:" '~x "=" x#) x#))

(defn compatible [{:keys [available]} {:keys [ports]}]
  (let [[a] available
        [bx by] ports]
    (or
     (= a bx)
     (= a by))))

(defn connect-port [{:keys [ports] :as component} port]
  (let [[x y] ports]
    (if (= port x)
      (assoc component :available [y])
      (assoc component :available [x]))))

(defn available-port [{:keys [available]}]
  (first available))

(available-port (connect-port {:ports [0 2]} 0))

(defn connect [comp1 comp2]
  (connect-port comp2 (available-port comp1)))

(connect (connect-port {:ports [0 2]} 0) {:ports [2 3]})

(defn gen-bridge [start rest-components]
  ;; each node is a tuple of [[path-so-far] set-of-rest-components]
  (let [root [[(connect-port start 0)] rest-components]
        possible-children (fn [component other-components] (filter (partial compatible component) other-components))
        branch? (fn [[path-so-far other-components]]
                  (seq (possible-children (last path-so-far) other-components)))
        children (fn [[path-so-far other-components]]
                   (let [parent (last path-so-far)
                         generate-node (fn [child]
                                         [(conj path-so-far (connect parent child))
                                          (disj other-components child)]
                                         )]
                     (mapv generate-node (possible-children parent other-components))))]
    (tree-seq branch? children root)))

(doseq [bridge
    (gen-bridge {:ports [0 2]} (disj sample-input {:ports [0 2]}))]
  (println "bridge" (->> bridge first (map :ports))))

(defn find-roots [components]
  (let [roots (filter (fn [{:keys [ports]}] (some zero? ports)) components)]
    roots))



;; With them, you could make the following valid bridges:

;;     0/1
;;     0/1--10/1
;;     0/1--10/1--9/10
;;     0/2
;;     0/2--2/3
;;     0/2--2/3--3/4
;;     0/2--2/3--3/5
;;     0/2--2/2
;;     0/2--2/2--2/3
;;     0/2--2/2--2/3--3/4
;;     0/2--2/2--2/3--3/5

(defn possible-bridges [components]
  (let [roots (find-roots components)
        roots-and-pools (map #(vector % (disj components %)) roots)]
    (->> roots-and-pools
         (mapcat #(apply gen-bridge %))
         (map first) ;; get only the paths
         (map #(map :ports %))
          ;; and from there the ports
         )))

(possible-bridges sample-input)

(defn find-strongest-bridge [components]
  (->> (possible-bridges components)
       (map #(reduce + (flatten %)))
       (apply max))
  )

;; (Note how, as shown by 10/1, order of ports within a component doesn't
;; matter. However, you may only use each port on a component once.)

;; Of these bridges, the strongest one is 0/1--10/1--9/10; it has a strength of
;; 0+1 + 1+10 + 10+9 = 31.

(find-strongest-bridge sample-input)
;; => 31

;; What is the strength of the strongest bridge you can make with the components
;; you have available?

(find-strongest-bridge puzzle-input)
;; => 1859


;; --- Part Two ---

;; The bridge you've built isn't long enough; you can't jump the rest of the way.

;; In the example above, there are two longest bridges:

(defn find-longest-strongest-bridge [components]
  (->> (possible-bridges components)
       (sort-by count)
       (partition-by count)
       (last) ;; longest bridges only
       (map #(reduce + (flatten %)))
       (apply max)
       ))

;; 0/2--2/2--2/3--3/4
;; 0/2--2/2--2/3--3/5

;; Of them, the one which uses the 3/5 component is stronger; its strength is
;; 0+2 + 2+2 + 2+3 + 3+5 = 19.

(find-longest-strongest-bridge sample-input)
;; => 19


;; What is the strength of the longest bridge you can make? If you can make
;; multiple bridges of the longest length, pick the strongest one.


(find-longest-strongest-bridge puzzle-input);; => 1799
