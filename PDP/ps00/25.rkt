;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |25|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
;Boolean ListOfBoolean -> Boolean
;ListOfBoolean -> Boolean
;;GIVEN: A list of booleans
;;RETURNS : True if List contains all True values else False
;;Examples:
;;(check-boolean (list true true false)) -> false
;;(check-boolean (list true true true true)) -> true

(define (check-boolean x)
  (if(member false x)
     false
     true )) 
     
;Tests
(begin-for-test
(check-equal? (check-boolean (list true true false)) false 
              "List contains false")
(check-equal? (check-boolean (list true true true true)) true 
              "List contains false"))