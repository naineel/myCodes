;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |20|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
(define head (circle 20 "solid" "blue"))
(define chest (rectangle 30 60 "solid" "yellow"))
(define leg (rectangle 10 50 "solid" "red"))
(define leg1 (rectangle 10 50 "solid" "white"))
(define hand (rectangle 50 15 "solid" "black"))

(above head (beside/align "top" hand chest hand)(beside leg leg1 leg))
