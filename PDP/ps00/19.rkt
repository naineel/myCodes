;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |19|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require 2htdp/image)
(require "extras.rkt") 
;; rel-rec-sequence: PosReal PosReal -> Rectangle
;; Takes two numbers and returns a solid blue rectangle, where the first number is
;; the width of the rectangle, and the second number is the proportion of width
;; and height of the rectangle to be produced (i.e. height = width * proportion).

(define (rel-rec-sequence x y)
  (rectangle x (* x y) "solid" "blue"))

;Tests
(begin-for-test
(check-equal? (rel-rec-sequence 2 4) (rectangle 2 8 "solid" "blue") 
              "Rectangle is a 2*8 rectangle")
(check-equal? (rel-rec-sequence 3 7) (rectangle 3 21 "solid" "blue") 
              "Rectangle is a 3*21 rectangle"))

