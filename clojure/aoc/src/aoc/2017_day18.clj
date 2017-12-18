(ns aoc.2017-day18
  (:use clojure.test)
  (:require [clojure.java.io :as io])
  (:require [clojure.string :as str]))

(def puzzle-input
  (-> "2017/day18.txt" io/resource slurp str/split-lines))

(defn parse [line]
  (let [[instr reg v] (clojure.edn/read-string (str "[" line "]"))]
    [(keyword instr) reg v]))

;; --- Day 18: Duet ---

;; You discover a tablet containing some strange assembly code labeled
;; simply "Duet". Rather than bother the sound card with it, you decide to run
;; the code yourself. Unfortunately, you don't see any documentation, so you're
;; left to figure out what the instructions mean on your own.

;; It seems like the assembly is meant to operate on a set of registers that are
;; each named with a single letter and that can each hold a single integer. You
;; suppose each register should start with a value of 0.

;; There aren't that many instructions, so it shouldn't be hard to figure out
;; what they do. Here's what you determine:

(declare ^:dynamic *current-program*)
(def ^:dynamic *part-2* false)

(defn value [regs name-or-int]
    (if (integer? name-or-int) name-or-int (get regs name-or-int 0)))

(binding [*part-2* true *current-program* 0]
  (value {} "p"))

(ns-unmap *ns* 'dispatch)

(defmulti dispatch (fn [state [instr _ _]] instr))

;;     snd X plays a sound with a frequency equal to the value of X.
(defmethod dispatch :snd [{last-sound :last-sound pc :pc regs :regs :as state} [_ reg _]]
  (assoc state :last-sound (regs reg) :pc (inc pc)))

;;     set X Y sets register X to the value of Y.
(defmethod dispatch :set [{pc :pc regs :regs :as state} [_ reg v]]
  (assoc state :regs (assoc regs reg (value regs v)) :pc (inc pc)))

;;     add X Y increases register X by the value of Y.
(defmethod dispatch :add [{pc :pc regs :regs :as state} [_ reg v]]
  (assoc state :regs (update regs reg (fnil + 0) (value regs v)) :pc (inc pc)))

;;     mul X Y sets register X to the result of multiplying the value contained
;;     in register X by the value of Y.
(defmethod dispatch :mul [{pc :pc regs :regs :as state} [_ reg v]]
  (assoc state :regs (update regs reg (fnil * 0) (value regs v)) :pc (inc pc)))

;;     mod X Y sets register X to the remainder of dividing the value contained
;;     in register X by the value of Y (that is, it sets X to the result of X
;;     modulo Y).
(defmethod dispatch :mod [{pc :pc regs :regs :as state} [_ reg v]]
  (assoc state :regs (update regs reg (fnil mod 0) (value regs v)) :pc (inc pc)))

;;     rcv X recovers the frequency of the last sound played, but only when the
;;     value of X is not zero. (If it is zero, the command does nothing.)
(defmethod dispatch :rcv [{pc :pc regs :regs last-sound :last-sound :as state} [_ reg v]]
  (if (zero? (value regs reg)) (assoc state :pc (inc pc))
      {:received last-sound}))

;;     jgz X Y jumps with an offset of the value of Y, but only if the value of
;;     X is greater than zero. (An offset of 2 skips the next instruction, an
;;     offset of -1 jumps to the previous instruction, and so on.)
(defmethod dispatch :jgz [{pc :pc regs :regs :as state} [_ reg v]]
  (if (pos? (value regs reg)) (update state :pc + (value regs v))
      (update state :pc inc)))

;; Many of the instructions can take either a register (a single letter) or a
;; number. The value of a register is the integer it contains; the value of a
;; number is that number.

;; After each jump instruction, the program continues with the instruction to
;; which the jump jumped. After any other instruction, the program continues
;; with the next instruction. Continuing (or jumping) off either end of the
;; program terminates it.

;; For example:

(def sample-program
  (->>
  "set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2" str/split-lines (mapv parse)))


(defn run [program]
  (loop [state {:pc 0 :regs {}}]
    (let [instr (program (:pc state))
          state' (dispatch state instr)]
      (if-let [last-sound (get state' :received)] last-sound
          (recur state')))))

;;     The first four instructions set a to 1, add 2 to it, square it, and then
;;     set it to itself modulo 5, resulting in a value of 4.

;;     Then, a sound with frequency 4 (the value of a) is played.

;;     After that, a is set to 0, causing the subsequent rcv and jgz
;;     instructions to both be skipped (rcv because a is 0, and jgz because a is
;;     not greater than 0).

;;     Finally, a is set to 1, causing the next jgz instruction to activate,
;;     jumping back two instructions to another jump, which jumps again to the
;;     rcv, which ultimately triggers the recover operation.

;; At the time the recover operation is executed, the frequency of the last
;; sound played is 4.

(run sample-program)
;; => 4

;; What is the value of the recovered frequency (the value of the most recently
;; played sound) the first time a rcv instruction is executed with a non-zero
;; value?

(run (mapv parse puzzle-input))
;; => 3423

;; --- Part Two ---

;; As you congratulate yourself for a job well done, you notice that the
;; documentation has been on the back of the tablet this entire time. While you
;; actually got most of the instructions correct, there are a few key
;; differences. This assembly code isn't about sound at all - it's meant to be
;; run twice at the same time.

(defn parse2 [line]
  (let [[instr reg v] (clojure.edn/read-string (str "[" line "]"))]
    (if (#{'snd 'rcv} instr)
      [(keyword (str instr "2")) reg v]
      [(keyword instr) reg v])))


;; Each running copy of the program has its own set of registers and follows the
;; code independently - in fact, the programs don't even necessarily run at the
;; same speed. To coordinate, they use the send (snd) and receive (rcv)
;; instructions:

;;     snd X sends the value of X to the other program. These values wait in a
;;     queue until that program is ready to receive them. Each program has its
;;     own message queue, so a program can never receive a message it sent.
(defmethod dispatch :snd2 [{pc :pc regs :regs outbox :outbox snd-count :snd-count :as state} [_ reg _]]
  (assoc state :pc (inc pc) :outbox (conj outbox (value regs reg)) :snd-count (inc snd-count)))

;;     rcv X receives the next value and stores it in register X. If no values
;;     are in the queue, the program waits for a value to be sent to it.
;;     Programs do not continue to the next instruction until they have received
;;     a value. Values are received in the order they are sent.


(defmethod dispatch :rcv2 [{pc :pc regs :regs :as state} [_ reg _]]
  (assoc state :receive reg)) ;; this is the only instructions that doesn't increase pc

;; Each program also has its own program ID (one 0 and the other 1); the
;; register p should begin with this value.

;; For example:

  (def sample-program-2 (->>
"snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d" str/split-lines (mapv parse2)))

(take 10 sample-program-2)

;; Both programs begin by sending three values to the other. Program 0 sends 1,
;; 2, 0; program 1 sends 1, 2, 1. Then, each program receives a value (both 1)
;; and stores it in a, receives another value (both 2) and stores it in b, and
;; then each receives the program ID of the other program (program 0 receives 1;
;; program 1 receives 0) and stores it in c. Each program now sees a different
;; value in its own copy of register c.

(defn other-program [n]
  (if (= n 0) 1 0))

(defn merge-inbox [prev cur]
  ;; inboxes are FIFO
  ;; first of prev is first, last of prev is last
  ;; first of cur is first
  (vec (concat prev cur)))

(defn run-attempt [program start-state cur-prog]
  (binding [*part-2* true
            *current-program* cur-prog]
    (println "running program" cur-prog)
    (if (= :terminated (:condition start-state)) start-state
  (loop [state (dissoc start-state :condition)]
    (let [pc (:pc state)]
      (if (and (>= pc 0) (< pc (count program)))
        (let [instr (program pc)
              state' (dispatch state instr)]
          ;; check for recv
          (if-let [reg-to-receive (:receive state')]
            (if-let [msg (first (:inbox state'))]
              ;; consume message, update reg, continue at next instruction
              (let [state'' (-> state'
                                (update :regs assoc reg-to-receive msg)
                                (update :inbox (comp vec rest))
                                (update :pc inc)
                                (dissoc :receive))]
                (recur state''))
              ;; block; pc stays at the rcv instruction, which will be executed again
              (assoc state :condition :blocked))
            ;; no recv, continue as normal
            (recur state')))
        (assoc state :condition :terminated) ;; program jumped off, terminate
        ))))))

(defn deadlocked? [[s1 s2]]
  (let [{cond1 :condition inbox1 :inbox outbox1 :outbox} s1
        {cond2 :condition inbox2 :inbox outbox2 :outbox} s2
        ]
    (case [cond1 cond2]
          [nil nil] false
          [nil :terminated] false
          [:terminated nil] false
          [nil :blocked] false
          [:blocked nil] false
          [:terminated :terminated] true
          [:terminated :blocked] (and (empty? inbox2) (empty? outbox1))
          [:blocked :terminated] (and (empty? inbox1) (empty? outbox2))
          [:blocked :blocked] (and (empty? inbox1) (empty? inbox2) (empty? outbox1) (empty? outbox2))
    )))

  (defn run-both [program]
    (loop [states [{:pc 0 :regs {'p 0} :outbox [] :inbox [] :snd-count 0} {:pc 0 :regs {'p 1} :outbox [] :inbox [] :snd-count 0}] cur-prog 0]
      (println "ran" cur-prog "states" states)
      (if (deadlocked? states) states
        (let [state' (run-attempt program (states cur-prog) cur-prog)
              outbox (:outbox state' [])
              state'' (-> state' (assoc :outbox []))]
            (recur
                        (-> states
                          (assoc cur-prog state'')
                          (update (other-program cur-prog)
                                    #(update % :inbox merge-inbox outbox)))
                          (other-program cur-prog))))))

(run-both sample-program-2)


;; Finally, both programs try to rcv a fourth time, but no data is waiting for
;; either of them, and they reach a deadlock. When this happens, both programs
;; terminate.

;; It should be noted that it would be equally valid for the programs to run at
;; different speeds; for example, program 0 might have sent all three values and
;; then stopped at the first rcv before program 1 executed even its first
;; instruction.

;; Once both of your programs have terminated (regardless of what caused them to
;; do so), how many times did program 1 send a value?


(run-both (mapv parse2 puzzle-input))

