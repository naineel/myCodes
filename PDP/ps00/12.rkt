;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |12|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(define-struct point(x y))
(make-point 5 3) 
;o/p -> (make-point 5 3)
(point? 5)
;o/p -> false
(point? true)
;o/p -> false
(point? (make-point 2 1))
;o/p -> true
(point-x (make-point 8 5))
;o/p -> 8
(point-y (make-point 42 15))
;o/p -> 15