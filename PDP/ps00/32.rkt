;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |32|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require "extras.rkt")
(require rackunit)
(define-struct point (x y))
;; A Point is a (make-point Number Number).
;; It represents a position on the screen.
;; Interpretation:
;;   x = the x-coordinate on the screen (in pixels from the left).
;;   y = the y-coordinate on the screen (in pixels from the top).

;; distance : ListOfPoints -> PosInt
;; GIVEN: A list of points
;; RETURNS: sum of all distances from the point(0,0)
;; Example:
;; (distance (list (make-point 1 2) (make-point 50 50) (make-point 100 100) (make-point 200 200))) -> 753
;; (distance (list (make-point 10 25) (make-point 30 50) (make-point 5 10) (make-point 200 0))) -> 330

(define (distance x)
  (cond
    [(empty? x) 0]
    [else (+ (sum(first x)) (distance(rest x)))]))
;; sum : point -> PosInt
;; GIVEN : A point(x,y)
;; RETURNS : Manhattan distance of the point(x,y) from point(0,0)
;; Examples:
;; (sum (make-point 1 2)) -> 3
;; (sum (make-point 50 50)) -> 100

(define (sum x)
  (+ (point-x x) (point-y x)))

;;Tests
(begin-for-test 
  (check-equal? (distance (list (make-point 1 2) (make-point 50 50) (make-point 100 100) (make-point 200 200))) 703 "Distance is incorrect")
  (check-equal? (distance (list (make-point 10 25) (make-point 30 50) (make-point 5 10) (make-point 200 0))) 330 "Distance is incorrect"))

    
