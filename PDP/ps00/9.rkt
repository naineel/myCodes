;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |9|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
; evenno? : Number -> boolean
; GIVEN:a number
; RETURNS: whether number is even or not
; Example:
; (evenno? 12) => true
; (evenno? 155) => false
; (evenno? 13) => #f

(define (evenno? x)
  (if(= (remainder x 2) 0)
     true
     false))

(check-expect (evenno? 12) true)
(check-expect (evenno? 155) false)
(check-expect (evenno? 13) #f)