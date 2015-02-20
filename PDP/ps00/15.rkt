;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |15|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(define-struct student(id name major))
;; A Student is a (make-student PosInt String String).
;; It represents information regarding a particular student.
;; Interpretation:
;; id = the student identity number.
;; name = name of the student.
;; major = Stream of study selected by the student.