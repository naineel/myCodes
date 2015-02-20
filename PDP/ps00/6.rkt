;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |6|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;quadratic-root : Number Number Number -> Number
;GIVEN:a,b,c are cofficients of the quadratic equation
;RETURNS:root of the quadratic equation
;Examples:
;(quadratic-root 2 4 4) => -1+1i
;(quadratic-root 1 4 4) => -2
(define (quadratic-root a b c)
  (/(- (sqrt(- (* b b) (* 4 a c))) b) (* 2 a)))

(check-expect (quadratic-root 2 4 4) -1+1i)
(check-expect (quadratic-root 1 4 4) -2)
