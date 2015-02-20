;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |30|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require "extras.rkt")
(require rackunit)

;; boolean-reverse : ListOfBoolean -> ListOfBoolean
;;GIVEN : A list of boolean values
;;RETURNS : list of reversed boolean values
;;Examples:
;;(boolean-reverse (list true false false) -> (cons false (cons true (cons true empty)))
;;(boolean-reverse (list false true) -> (cons false (cons true empty))
;;Design strategy : Function composition
(define (boolean-reverse x)
  (cond
    [(empty? x) x]
    [else (cons (not(first x)) (boolean-reverse (rest x)))]))
    
;;tests
(begin-for-test
  (check-equal? (boolean-reverse (list true false false)) (cons false (cons true (cons true empty))) "All boolean values are not reversed")
  (check-equal? (boolean-reverse (list true false)) (cons false (cons true empty)) "All boolean values are not reversed"))
