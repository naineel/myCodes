;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname outlines) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)
(require rackunit/text-ui)

;; providing the functions
(provide 
 nested-rep?
 nested-to-flat)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS
;; An Sexp is one of
;; -- a String
;; -- a NonNegInt
;; -- a ListOfSexp

;; sexp-fn : Sexp -> ??
;; template : 
;; (define (sexp-fn sexp)
;;   (cond
;;     [(string? sexp)...]
;;     [(integer? sexp)...]
;;     [else ...(first sexp)
;;           (sexp-fn (rest sexp))]))

;; A ListOfSexp(LOS) is one of
;; -- empty
;; -- (cons Sexp ListOfSexp)
;; losexp-fn : ListOfSexp -> ??
;; template :
;; (define (losexp-fn ls)
;;   (cond
;;     [(empty? ls)...]
;;     [else ...(first ls)
;;           (losexp-fn (rest ls))]))
;;
;; A NestedRep is one of
;; -- empty
;; -- a String
;; -- a ListOfNestedRep

;; nes-rep-fn : NestedRep -> ??
;; template :
;;(define (nes-rep-fn nr)
;;  (cond
;;    [(empty? nr)...]
;;    [(string? nr)...]
;;    [else ...(first nr)
;;          (nes-rep-fn (rest nr))]))

;; A ListOfNestedRep(LONR) is one of
;; -- empty
;; -- (cons NestedRep ListOfNestedRep)
;; lonr-fn : ListOfNestedRep -> ??
;; template :
;; (define (lonr-fn nr)
;;   (cond
;;    [(empty? nr)...]
;;    [else ....(first nr)
;;          (lonr-fn (rest nr))]))

;; A FlatRep is one of
;; -- a NonNegInt
;; -- a String
;; -- a ListOfFlatRep

;; flat-fn : FlatRep -> ??
;; template:
;; (define (flat-fn fr)
;;   (cond
;;     [(integer? fr)...]
;;     [(string? fr)...]
;;     [else ...(first fr)
;;           (flat-fn (rest fr))]))

;; A ListOfFlatRep(LOFR) is one of
;; -- empty
;; -- (cons FlatRep ListOfFlatRep)
;; lofp-fn : ListOfFlatRep -> ??
;; template :
;; (define (lofp-fn fr)
;;   (cond
;;     [(empty? fr)...]
;;     [else...(first fr)
;;             (lofp-fn (rest fr))]))
;;;END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Data constants

(define NESTED-LIST-1 '(("The first section"
                         ("A subsection with no subsections")
                         ("Another subsection"
                          ("This is a subsection of 1.2"))
                         ("The last subsection of 1"))
                        ("Another section"
                         ("More stuff")
                         ("Still more stuff"))
                        ("Another section1"
                         ("More stuff2")
                         ("Still more stuff3"))))

(define FLAT-LIST-1 '(((1) "The first section")
                      ((1 1) "A subsection with no subsections")
                      ((1 2) "Another subsection")
                      ((1 2 1) "This is a subsection of 1.2")
                      ((1 3) "The last subsection of 1")
                      ((2) "Another section")
                      ((2 1) "More stuff")
                      ((2 2) "Still more stuff")
                      ((3) "Another section1")
                      ((3 1) "More stuff2")
                      ((3 2) "Still more stuff3")))

(define FALSE-NESTED-STRING '((" The first section"
                               (" " "A subsection with no subsections")
                               ("Another subsection" 
                                ("This is a subsection of 1.2")
                                ("This is another subsection of 1.2"))
                               ("The last  subsection of 1"))
                              ("Another section"
                               ("More stuff")
                               ("Still more stuff"))))

(define FALSE-NESTED-INT '((" The first section"
                            (2 "A subsection with no subsections")
                            ("Another subsection" 
                             ("This is a subsection of 1.2")
                             ("This is another subsection of 1.2"))
                            ("The last  subsection of 1"))
                           ("Another section"
                            ("More stuff")
                            ("Still more stuff"))))

(define LIST-1 '(1))

(define STRING-1 "pdp")

(define INT-1 1)

;; End of Data constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; nested-rep? : Sexp -> Boolean
;; GIVEN: an sexp
;; RETURNS: true iff it is the nested representation of some outline.
;; Examples : See main function for tests.
;; STRATEGY : Structural decomposition on a-sexp : Sexp
(define (nested-rep? a-sexp)
  (cond
    [(string? a-sexp) false]
    [(integer? a-sexp) false]
    [else (if (list? (first a-sexp)) 
              (check-nested-for-list a-sexp false)
              false)]))

;; check-nested-for-list : Sexp -> Boolean
;; GIVEN: an Sexp
;; RETURNS: true iff it is the nested representation of some outline
;; Examples : (check-nested-for-list empty true) -> true
;; STRATEGY : structural decomposition on a-slist : NestedRep
(define (check-nested-for-list a-slist flag)
  (cond
    [(empty? a-slist) true]
    [else 
     (if (string? (first a-slist))
         (and (str-nested? (first a-slist) flag)
              (check-nested-for-list (rest a-slist) true))
         (and (str-nested? (first a-slist) false)
              (check-nested-for-list (rest a-slist) false)))]))

;; str-nested? : String Boolean -> Boolean
;; GIVEN: an String and a Boolean
;; RETURNS: true iff it is the nested representation of some outline
;; Examples : (str-nested? false false) -> false 
;; STRATEGY : structural decomposition on str : FlatRep
(define (str-nested? str flag)
  (cond
    [(integer? str) false]
    [(string? str) (if (boolean=? flag true) 
                       false 
                       true)]
    [else (check-nested-for-list str flag)]))

;; TESTS:
(define-test-suite nested-rep?-test-suite
  (check-equal? (nested-rep? NESTED-LIST-1) true)
  (check-equal? (nested-rep? LIST-1) false)
  (check-equal? (nested-rep? FALSE-NESTED-STRING) false)
  (check-equal? (nested-rep? FALSE-NESTED-INT) false)
  (check-equal? (nested-rep? STRING-1) false)
  (check-equal? (nested-rep? INT-1) false))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; nested-to-flat : NestedRep -> FlatRep
;; GIVEN: the representation of an outline as a nested list.
;; RETURNS: the flat representation of the outline.
;; Example : See test case below.
;; STRATEGY : Function composition
(define (nested-to-flat lst)
  (flat-transform lst empty 1))

;; flat-transform : NestedRep List Integer -> FlatRep
;; GIVEN: the representation of an outline as a nested list.
;; RETURNS: the flat representation of the outline.
;; Example : (flat-transform NESTED-LIST-1 empty 1) -> FLAT-LIST-1
;; STRATEGY : structural decomposition on nested-list : LONR
(define (flat-transform nested-list num-list n)
  (cond
    [(empty? nested-list) nested-list]
    [else 
     (append (making-flat-response (first nested-list) num-list n)
             (flat-transform (rest nested-list) num-list (+ n 1)))]))

;; making-flat-response : List List NonNegInt-> List
;; GIVEN: A section , Number list and integer.
;; RETURNS: the flat representation of the outline.
;; Example : (making-flat-response (("Another subsection"
;; ("This is a subsection of 1.2")) (list 1) 1) ->
;; (((1 1) ("Another subsection" ("This is a subsection of 1.2"))))
;; STRATEGY : structural decomposition on section : LONR
(define (making-flat-response section num-list n)
  (cons
   (cons (append-to-list num-list n)
         (list (first section)))
   (flat-transform (rest section) (append-to-list num-list n) 1)))

;; append-to-list : List NonNegInt -> List
;; GIVEN: A list and integer.
;; RETURNS: List with integer appended to it or if its empty then create a list
;; of that integer.
;; Example : (append-to-list empty 1) -> (list 1)
;; STRATEGY : Structural decomposition on num-list : LONR
(define (append-to-list num-list n)
  (cond 
    [(empty? num-list) (list n)]
    [else (append num-list (list n))]))

;; TESTS:
(define-test-suite nested-to-flat-test-suite
  (check-equal? (nested-to-flat NESTED-LIST-1) FLAT-LIST-1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Running the test suite
(run-tests nested-to-flat-test-suite)
(run-tests nested-rep?-test-suite)

