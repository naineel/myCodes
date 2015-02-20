;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname snacks) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require "extras.rkt")
(require rackunit)
(provide initial-machine
         machine-next-state
         machine-chocolates
         machine-carrots
         machine-bank )

;; A CustomerInput is one of
;; -- PosInt            interp: insert the specified number of cents
;; -- "chocolate"       interp: request a chocolate bar
;; -- "carrots"         interp: request a package of carrot sticks
;; -- "release"         interp: return all the coins that the customer has put in

;; CustomerInput-fn : CustomerInput -> ??
;; (define (CustomerInput-fn c)
;;   (cond 
;;     [(number? c)...]
;;     [(string=? "chocolate" c)...]
;;     [(string=? "carrots" c)...]
;;     [(string=? "release" c)]))

(define-struct machine (customer-money chocobar carrot-sticks container-bank))

;; A machine is a make-machine( NonNegInt NonNegInt NonNegInt NonNegInt)
;; Interp : 
;; customer-money is the amount inserted by the customer in cents.
;; chocobar is the number of chocolates in the machine.
;; carrot-sticks is the number of carrot sticks in the machine.
;; container-bank is the amount of money in the bank in cents.
;; Template :
;; Machine1-fn : machine -> ??
;; (define (machine-fn m)
;;   (...
;;    (machine-customer-money m)
;;    (machine-chocobar m)
;;    (machine-carrot-sticks m)
;;    (machine-container-bank m)))



;; initial-machine : NonNegInt NonNegInt -> Machine
;; GIVEN: The number of chocolate bars and the number of packages of
;; carrot sticks
;; RETURNS: A machine loaded with the given number of chocolate bars and
;; carrot sticks, with an empty bank.
;; STRATEGY: Fuction Composition
;; (initial-machine 10 20) -> (make-machine 0 10 20 0))

(define (initial-machine x y)
  (make-machine 0 x y 0))


;; machine-next-state : Machine CustomerInput -> Machine
;; GIVEN : A machine state and a customer input
;; RETURNS : The state of the machine that should follow the customer's input
;; STRATEGY : Structural Decomposition
;; Examples : 
;; (machine-next-state (make-machine 200 10 10 0) 100) -> (make-machine 100 10 10 0)
;; (machine-next-state (make-machine 200 10 10 0) "chocolate") -> (make-machine 25 9 10 175)
;; (machine-next-state (make-machine 200 10 10 0) "carrots") -> (make-machine 130 10 9 70)
;; (machine-next-state (make-machine 200 10 10 0) "release") -> (make-machine 0 10 10 0)

(define (machine-next-state mac customer)
  (cond 
    [(number? customer)(make-machine customer (machine-chocobar mac) 
                                      (machine-carrot-sticks mac) (machine-container-bank mac))]
    
    [(string=? "chocolate" customer)  (if(and (> (machine-chocobar mac) 0) (> (- (machine-customer-money mac) 175) 0)) 
                                         (make-machine (- (machine-customer-money mac) 175) (- (machine-chocobar mac) 1) 
                                                       (machine-carrot-sticks mac) (+ (machine-container-bank mac) 175)) empty)]
    
    [(string=? "carrots" customer) (if (and (> (machine-carrot-sticks mac) 0) (> (- (machine-customer-money mac) 70) 0))
                                         (make-machine (- (machine-customer-money mac) 70) (machine-chocobar mac) 
                                                       (- (machine-carrot-sticks mac) 1) (+ (machine-container-bank mac) 70)) empty)]
    
    [(string=? "release" customer) (make-machine 0 (machine-chocobar mac) (machine-carrot-sticks mac) (machine-container-bank mac))]))


;; machine-chocolates : Machine ->  NonNegInt
;; GIVEN: A machine state
;; RETURNS: The number of chocolate bars left in the machine
;; STRATEGY : Function Composition
;; Examples : (machine-chocolates (make-machine 122 34 23 333)) -> 34

(define (machine-chocolates mach)
  (machine-chocobar mach))


;; machine-carrots : Machine ->  NonNegInt
;; GIVEN: A machine state
;; RETURNS: The number of packages of carrot sticks left in the machine
;; STRATEGY : Function Composition
;; Examples : (machine-carrots (make-machine 122 34 23 333)) -> 23

(define (machine-carrots mach)
  (machine-carrot-sticks mach))


;; machine-bank : Machine ->  NonNegInt
;; GIVEN: A machine state
;; RETURNS: The amount of money in the machine's bank, in cents
;; STRATEGY : Function Composition
;; Examples : (machine-bank (make-machine 122 34 23 333)) -> 333

(define (machine-bank mach)
  (machine-container-bank mach))


;Tests
(begin-for-test
  (check-equal? (initial-machine 10 20) (make-machine 0 10 20 0))
  (check-equal? (machine-next-state (make-machine 200 10 10 0) 100) (make-machine 100 10 10 0))
  (check-equal? (machine-next-state (make-machine 200 10 10 0) "chocolate") (make-machine 25 9 10 175))
  (check-equal? (machine-next-state (make-machine 160 10 10 0) "chocolate") empty)
  (check-equal? (machine-next-state (make-machine 200 10 10 0) "carrots") (make-machine 130 10 9 70))
  (check-equal? (machine-next-state (make-machine 200 10 0 0) "carrots") empty)
  (check-equal? (machine-next-state (make-machine 200 10 10 0) "release") (make-machine 0 10 10 0))
  (check-equal? (machine-chocolates (make-machine 122 34 23 333)) 34)
  (check-equal? (machine-carrots (make-machine 122 34 23 333)) 23)
  (check-equal? (machine-bank (make-machine 122 34 23 333)) 333))

