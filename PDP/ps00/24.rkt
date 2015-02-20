;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |24|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
;;list-product : List -> Number
;;GIVEN : A list of all numbers 
;;RETURNS : products of all numbers in the list
;;Examples : 
;; (list-product empty) = 0
;; (list-product (list 1 2 3)) = 6

(define (list-product x)
  (cond
    [(empty? x) 1]
    [else (* (first x) (list-product (rest x)))]))
(list-product (list 10 12 2)) 

;Tests
(begin-for-test
(check-equal? (list-product (list 10 12 2)) 240 
              "Product of the list should be 240")
(check-equal? (list-product (list 12 5 2)) 120 
              "Product of the list should be 120"))
