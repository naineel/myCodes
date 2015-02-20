;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname editor) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require "extras.rkt")
(require rackunit)
(require 2htdp/universe)
(provide edit
         string-first
         string-rest
         string-last
         string-remove-last
         make-editor
         editor-pre
         editor-post)
;; DATA DEFINITIONS
(define-struct editor(pre post))

;; An Editor is a (make-editor String String)
;; Interp:
;; pre is the First part of the whole string.
;; post is the second part of the whole string.

;; TEMPLATE:
;; editor-fn : Editor -> ??
;; (define (editor-fn e)
;;   (...
;;    (editor-pre e)
;;    (editor-post e)))

;; edit : Editor KeyEvent -> Editor
;; GIVEN : an editor and a key event which is defined above
;; RETURNS: Editor which shows the effect of the KeyEvent
;; STRATEGY: Cases on KeyEvents
;; Examples :
;; (edit (make-editor "Hello" "World") "\b") -> (make-editor "Hell" "World")
;; (edit (make-editor "Hello" "World") "left") -> 
;; (edit (make-editor "Hello" "World") "right") -> 
;; (edit (make-editor "Hello" "World") " ") -> 
;; (edit (make-editor "Hello" "World") "p") -> 

(define (edit ed ke)
  (cond
    [(key=? ke "left")(make-editor (string-remove-last (editor-pre ed))
                                   (string-append (string-last (editor-pre ed)) (editor-post ed)))]
    [(key=? ke "right")(make-editor (string-append (editor-pre ed) (string-first(editor-post ed))) 
                                    (string-rest(editor-post ed)))]
    [(key=? ke "\b")(make-editor (string-remove-last (editor-pre ed)) 
                                 (editor-post ed))]
    [(key=? ke " ")(make-editor (string-append (editor-pre ed) " ") (editor-post ed))]
    [(= (string-length ke) 1) (make-editor (string-append (editor-pre ed) ke) (editor-post ed))]))

;; string-first : String -> String
;; GIVEN : A string
;; RETURNS : A string
;; STRATEGY : Functional Composition
;; Examples :
;; (string-first "Super") -> "S"

(define (string-first s)
  (string-ith s 0))


;; string-rest : String -> String
;; GIVEN : A string
;; RETURNS : A string
;; STRATEGY : Functional Composition
;; Examples :
;; (string-rest "Super") -> "uper"

(define(string-rest s)
  (substring s 1))


;; string-last : String -> String
;; GIVEN : A string
;; RETURNS : A string
;; STRATEGY : Functional Composition
;; Examples :
;; (string-last "Super") -> "r"

(define(string-last s)
  (string-ith s (- (string-length s) 1)))



;; string-remove-last : String -> String
;; GIVEN : A string
;; RETURNS : A string
;; STRATEGY : Functional Composition
;; Examples :
;; (string-last "Super") -> "Supe"

(define(string-remove-last s)
  (substring s 0 (- (string-length s) 1)))



;;Tests
(begin-for-test
 (check-equal? (string-first "String") "S")
 (check-equal? (string-rest "Super") "uper")
 (check-equal? (string-last "West") "t")
 (check-equal? (string-remove-last "Yellow") "Yello")
 (check-equal? (edit (make-editor "Hello" "World") "\b") (make-editor "Hell" "World"))
 (check-equal? (edit (make-editor "Hello" "World") "left") (make-editor "Hell" "oWorld"))
 (check-equal? (edit (make-editor "Hello" "World") "right") (make-editor "HelloW" "orld"))
 (check-equal? (edit (make-editor "Hello" "World") " ") (make-editor "Hello " "World"))
 (check-equal? (edit (make-editor "Hello" "World") "p") (make-editor "Hellop" "World")) 
 )