;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |8|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
; circle-area : Number -> Number
; GIVEN: the radius r of a circle
; RETURNS: its area using the formula pi * r^2
; Example:
; (circle-area 1) => 3.141592653589793
; (circle-area 5) => 78.53981633974483
; (circle-area 7) => 153.93804002589985

(define (circle-area r)
  (* pi (sqr r)))
 
(check-within (circle-area 1) 3.1415 1.0)  
(check-within (circle-area 5) 78.5398 1.0)
(check-within (circle-area 7) 153.9380 1.0) 