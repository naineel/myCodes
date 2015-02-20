;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |1|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;Ex 1: Write an expression whose value s the number of seconds in a leap year (a leap year has 366 days). 
;Next, write 2 more expressions that have the same value.
(* 366 24 60 60)
(* (+ 2 (* 52 7)) 24 3600)
(+ (* 24 60 60) (* 365 24 60 60))