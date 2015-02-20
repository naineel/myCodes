;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname regexp) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require "extras.rkt")
(require rackunit)
(require 2htdp/universe)

;;A machineState is one of the 
;;-- AB
;;-- CD
;;-- EE
;;-- ER

;; ms-fn : mState -> ??
;(define (ms-fn ms)
;  (cond
;    [(string=? ms AB)...]
;    [(string=? ms CD)...]
;    [(string=? ms EE)...]
;    [(string=? ms ER)...]))


(define AB "Current State is AB")
(define CD "Current State is CD")
(define EE "This is the final State")
(define ER "Error State,user pressed illegal key")

(define-struct state1(current))
;; state1 is a make-state1 (String)
;; Interp :
;; current is the current state of the machine

;; initial-state : Number -> State 
;; GIVEN: a number
;; RETURNS: a representation of the initial state
;; of your machine.  The given number is ignored.

(define (initial-state x)
   AB)

;; next-state : State KeyEvent -> State
;; GIVEN: a state of the machine and a key event.
;; RETURNS: the state that should follow the given key event.  A key
;; event that is to be discarded should leave the state unchanged.
(define (next-state st ke)   
  (cond
    [(key=? ke "a") (decide-final-state-for-ab st)]
    [(key=? ke "b") (decide-final-state-for-ab st)]
    [(key=? ke "c") (decide-final-state-for-cd st)]
    [(key=? ke "d") (decide-final-state-for-cd st)]
    [(key=? ke "e") (decide-final-state-for-e st)]
    [(= (string-length ke) 1) ER]
    [else st]))


(define (decide-final-state-for-ab s)
  (cond
    [(string=? s CD) ER]
    [(string=? s AB) AB]
    [(string=? s EE) ER]
    [(string=? s ER) ER]))

(define (decide-final-state-for-cd s)
  (cond
    [(string=? s CD) CD]
    [(string=? s AB) ER]
    [(string=? s EE) ER]
    [(string=? s ER) ER]))

(define (decide-final-state-for-e s)
  (cond
    [(string=? s CD) ER]
    [(string=? s AB) ER]
    [(string=? s EE) ER]
    [(string=? s ER) ER]))

(next-state ER "b")
(next-state AB "a")
(next-state EE "e")
(next-state CD "e")
(next-state AB "d")
;; accepting-state? : State -> Boolean
;; GIVEN: a state of the machine
;; RETURNS: true iff the given state is a final (accepting) state
;; STRATEGY : Function Composition
(define (accepting-state? st)
  (and (string=? st EE) true))


;; error-state? : State -> Boolean
;; GIVEN: a state of the machine
;; RETURNS: true iff the string seen so far does not match the specified
;; regular expression and cannot possibly be extended to do so.
;; STRATEGY : Function Composition

(define (error-state? st)
  (and (string=? st ER) true)
 )
(error-state? ER)
;Tests
(begin-for-test
  (check-equal? (accepting-state? EE) true)
  (check-equal? (error-state? ER) true)
  (check-equal? (next-state AB "a") AB)
  (check-equal? (next-state AB "b") AB)
  (check-equal? (next-state AB "c") ER)
  (check-equal? (next-state EE "c") ER)
  (check-equal? (next-state ER "c") ER)
  (check-equal? (next-state AB "d") ER)
  (check-equal? (next-state ER "e") ER)
  (check-equal? (next-state AB "a") AB)
  (check-equal? (initial-state 10) AB)
  (check-equal? (next-state AB "p") ER)
  (check-equal? (next-state AB "naa") AB)
  )