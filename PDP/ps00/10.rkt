;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |10|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
; sum-large2: Number Number Number -> Number
; GIVEN : three numbers
; RETURNS : sum of the largest two numbers
; Example:
; (sum-large2 10 8 6) => 18
; (sum-large2 20 50 48) => 98
; (sum-large2 55 45 45) => 100

(define (sum-large2 x y z)
  (if(> x y)
     (if(> y z)
        (+ x y)
        (+ x z))
     (if(> x z)
        (+ y x)
        (+ y z))
     ))

(check-expect (sum-large2 10 8 6) 18)
(check-expect (sum-large2 20 50 48) 98)
(check-expect (sum-large2 55 45 45) 100)
(check-expect (sum-large2 10 10 10) 20)