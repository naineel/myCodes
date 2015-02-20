;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |5|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;sq : Number -> Number 
;GIVEN: The number whose square is to be computed
;RETURNS: the result which is square of the input number
;Examples:
;(sq 2)-> 4
;(sq 5)-> 25

(define (sq x)
  (* x x))

(sq 0.038)
(sq 2)
