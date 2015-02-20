;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |18|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;rec-sequence : PosInt -> Image
;GIVEN : Number which gives the sequence number
;RETURNS: nth element of the sequence which is a solid blue 
;rectangle of particular size
;EXAMPLES :
;(rec-sequence 2)-> (rectangle 4 8 "solid" "blue")
;(rec-sequence 3)-> (rectangle 8 16 "solid" "blue")
;Design strategy : Function composition
(require rackunit)
(require "extras.rkt") 
(require 2htdp/image)
(define (rec-sequence n)
  (rectangle (expt 2 n) (* 2 (expt 2 n)) "solid" "blue"))
;; TESTS
(begin-for-test
  (check-equal? (rec-sequence 2) (rectangle 4 8 "solid" "blue") 
    "Rectangle should be 4 * 8")
  (check-equal? (rec-sequence 4) (rectangle 16 32 "solid" "blue") 
    "Rectangle should be 16 * 32"))

  

