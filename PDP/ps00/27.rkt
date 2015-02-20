;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |27|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
(provide string-combine)
;;string-combine : ListOfStrings -> String
;;GIVEN: A list of strings
;;RETURNS: A combined string
;;Examples:
;;(string-combine (list "hello" "how" "are" "you"))
;;(string-combine (list "Naineel" "Shah"))
;;Design Strategy : Function composition

(define (string-combine x)
  (cond
    [(empty? x) ""]
    [else (string-append (string-addspace x) (string-combine(rest x)))]))

;;string-addspace : ListOfStrings -> String
;;GIVEN: A list of strings
;;RETURNS: string with a space
;;Examples:
;;(string-combine (list "hello" "how" "are" "you"))
;;(string-combine (list "Naineel" "Shah"))
;;Design Strategy : Function composition
(define (string-addspace y)
  (cond
    [(empty? y) y]
    [(> (length y) 1)(string-append (first y) " ")]
    [else (string-append (first y))]))

;;Tests
(begin-for-test
 (check-equal? (string-combine (list "hello" "how" "are" "you")) "hello how are you" "Check the string again")
 (check-equal? (string-combine (list "Naineel" "Shah")) "Naineel Shah" "Check the string again")
 (check-equal? (string-combine (list "")) "" "Check the string again")
 )
