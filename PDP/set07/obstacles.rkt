;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname obstacles) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
(require "sets.rkt")
(require rackunit/text-ui)

(provide 
 position-set-equal?
 obstacle?
 blocks-to-obstacles)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA DEFINITIONS
;; A Position is a
;; -- (list PosInt PosInt)
;; (x y) represents the position x, y.
;; template :
;; posn-fn : Position -> ??
;; (define (posn-fn pos)
;;  ...(first pos)
;;     (second pos)...)

;; A PositionSet is a 
;; -- Position
;; -- (cons Position PositionSet)
;; WHERE : no two positions are the same.

;; template:
;; posset-fn : PositionSet -> ??
;; (define (posset-fn set)
;;   (cond
;;     [(empty? set)...]
;;     [else (...(posn-fn (first set))
;;               (posset-fn (rest set)))]))

;; A PositionSetSet is a list of PositionSets without duplication,
;; that is,
;; -- empty
;; -- (cons PositionSet PositionSetSet)
;; WHERE : no two position-sets denote the same set of positions.

;; template :
;; posetset-fn : PositionSetSet -> ??
;; (define (posetset-fn setset)
;;   (cond
;;     [(empty? setset)...]
;;     [else (posset-fn(first setset)
;;               (posetset-fn (rest setset)))]))
;; END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; position-set-equal? : PositionSet PositionSet -> Boolean
;; GIVEN : two PositionSets
;; RETURNS : true iff they denote the same set of positions.
;; Example : 
;; (position-set-equal? (list (list 4 2) (list 1 2) (list 5 6) (list 2 3)) 
;;                      (list (list 1 2) (list 2 3) (list 5 6) (list 4 2)))
;; -> true
;; STRATEGY : Function composition
(define (position-set-equal? ps1 ps2)
  (set-equal? ps1 ps2))
 

;; TESTS :
(define-test-suite position-set-equal?-test-suite
  (check-equal? (position-set-equal? (list (list 4 2) (list 1 2) (list 2 3)) 
                                     (list (list 1 2) (list 2 3) (list 4 2)))
                true " Set is equal")
  (check-equal? (position-set-equal? (list (list 1 2)) empty) false 
                "Set is unequal")
  (check-equal? (position-set-equal? empty empty) true "Set is equal")
  (check-equal? (position-set-equal? empty (list (list 1 2))) false 
                "Set is unequal"))

;;
;; Constants :
(define CONSTANT-SET (list (list 1 2) (list 2 3) (list 3 4) 
                           (list 3 2) (list 4 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; obstacle? : PositionSet -> Boolean
;; GIVEN: a PositionSet
;; RETURNS: true iff the set of positions would be an obstacle if they
;; were all occupied and all other positions were vacant.
;; Example : (obstacle? (list (list 1 2) (list 2 3)))
;; -> true
;; STRATEGY : function composition on 
(define (obstacle? set)
  (occupied-blocks? set set))

;; occupied-blocks? : PositionSet PositionSet -> Boolean
;; GIVEN: a PositionSet and the entire same set as the context
;; WHERE: entire-set is same as PositionSet but represents the context
;; RETURNS: true iff the set of positions would be an obstacle if they
;; were all occupied and all other positions were vacant.
;; Example : (occupied-blocks? (list (list 1 2) (list 2 3)) 
;;                             (list (list 1 2) (list 2 3)))
;; -> true
;; STRATEGY : Structural decomposition on set : PositionSet
(define (occupied-blocks? set entire-set)
  (cond
    [(empty? set) false]
    [(empty? (rest set)) true]
    [else (and (adjacent-exists-in-set? (first set) entire-set) 
               (occupied-blocks? (rest set) entire-set))]))

;; adjacent-exists-in-set? : Position PositionSet -> Boolean
;; GIVEN: the Position and the PositionSet
;; WHERE: entire-set is same as PositionSet but represents the context
;; RETURNS: true iff the set of positions would be an obstacle if they
;; were all occupied and all other positions were vacant.
;; Example : (adjacent-exists-in-set? (list 1 2) (list (list 1 2) (list 2 2)))
;; -> true
;; STRATEGY : Structural decomposition on set : PositionSet
(define (adjacent-exists-in-set? one set)
  (cond
    [(equal? (list (+ (first one) 1) (+ (second one) 1)) (first set)) true]
    [(equal? (list (+ (first one) 1) (- (second one) 1)) (first set)) true]
    [(equal? (list (- (first one) 1) (+ (second one) 1)) (first set)) true]
    [(equal? (list (- (first one) 1) (- (second one) 1)) (first set)) true]
    [else (adjacent-exists-in-set? one (rest set))]))

;; TESTS :
(define-test-suite obstacle?-test-suite
  (check-equal? (obstacle? empty) false)
  (check-equal? (obstacle? (list (list 1 1) (list 2 2) (list 3 3) (list 4 4))) 
                true "It is an obstacle")
  (check-equal? (obstacle? (list (list 1 1) (list 2 2) (list 4 4) (list 3 3))) 
                true "It is an obstacle")
  (check-equal? (obstacle? (list (list 1 2) (list 2 1) (list 3 2) (list 4 1))) 
                true "It is an obstacle")
  (check-equal? (obstacle? (list (list 1 1))) true "It is an obstacle"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; blocks-to-obstacles : PositionSet -> PositionSetSet
;; GIVEN: the set of occupied positions on some chessboard
;; RETURNS: the set of obstacles on that chessboard.
;; Example : (blocks-to-obstacles (list (list 3 3) (list 4 4) (list 1 2)))
;; -> (list (list (list 4 4) (list 3 3))  (list (list 1 2)))
;; STRATEGY : Function composition
(define (blocks-to-obstacles set)
  (main-function set set))

;; main-function : PositionSet PositionSet-> PositionSetSet
;; GIVEN: the set of occupied positions on some chessboard and a 
;; full list of all occupied positions
;; RETURNS: the set of obstacles on that chessboard.
;; Example : (main-function (list (list 3 3)) CONSTANT-SET)
;; ->(list (list (list 3 3)) (list (list 4 1) (list 3 4) (list 3 2) 
;;                             (list 2 3) (list 1 2)))
;; STRATEGY : General recursion
(define (main-function set constant-set)
  (if (empty? set) 
      empty
      (cons (blocks-to-obstacles-recur (first set) constant-set)
            (blocks-to-obstacles (remaining-pos 
                                  (blocks-to-obstacles-recur 
                                   (first set) constant-set) 
                                  constant-set)))))

;; remaining-pos : PositionSet PositionSet-> PositionSet
;; GIVEN: the set of occupied positions on some chessboard and a 
;; full list of all occupied positions
;; WHERE : set is a subset of the given full-set
;; RETURNS: the set of obstacles on that chessboard.
;; Example : (remaining-pos (list (list 2 2)) CONSTANT-SET)
;;-> ((1 2) (2 3) (3 4) (3 2) (4 1))
;; STRATEGY : Structural decomposition on set : PositionSet
(define (remaining-pos set full-set)
  (filter (lambda (x) (not (member? x set))) full-set))

;; blocks-to-obstacles-recur : Position PositionSet -> PositionSet
;; GIVEN : A Position on the chessboard and the full list of occupied positions
;; RETURNS : Set of obstacles 
;; Examples : (blocks-to-obstacles-recur (list 2 3) CONSTANT-SET)
;;->(list (list 1 2) (list 2 3) (list 3 4) (list 3 2) (list 4 1))
;; STRATEGY : Function composition
(define (blocks-to-obstacles-recur pos full-list)
  (obstacles-recur-one pos (list pos) full-list))

;; obstacles-recur-one : Position PositionSet PositionSet -> PositionSet
;; GIVEN : A Position, the same position as a list that represents 
;; the positions already explored and the full list of occupied positions
;; WHERE : explored is the set of positions which is a sublist of full-list
;; RETURNS : Set of obstacles 
;; Examples : (obstacles-recur-one (list 1 2) (list (list 2 2)) CONSTANT-SET)
;;->(list (list 2 2))
;; HALTING MEASURE : (# of blocks reachable from full-list) - 
;; (# of blocks in explored)
;; STRATEGY : General recursion
(define (obstacles-recur-one pos explored full-list)
  (local
    ((define new-nodes (all-successors explored full-list)))
    (if (subset? new-nodes explored)
        explored
        (obstacles-recur-one pos
                             (set-union new-nodes explored) full-list))))

;; obstacles-recur-two : Position PositionSet -> PositionSet
;; GIVEN : A position on the chessboard and 
;; the entire list of occupied position.
;; RETURNS : List of all adjacent nodes with the given position on 
;; the chessboard.
;; Examples : (obstacles-recur-two (list 1 2) CONSTANT-SET)
;;-> (list (list 2 3))
;; STRATEGY : Structural decomposition on full-list : PositionSet
(define (obstacles-recur-two pos full-list)
  (cond
    [(empty? full-list) empty]
    [else (if (adjacent? pos (first full-list)) 
              (set-union (list (first full-list)) 
                         (obstacles-recur-two pos 
                                              (rest full-list)))
              (obstacles-recur-two pos (rest full-list)))]))

;; all-successors : PositionSet PositionSet -> PositionSet
;; GIVEN : Explored positions on the chessboard and the full list of positions
;; RETURNS : set of all successors of the explored
;; Example : (all-successors (list (list 1 2) (list 1 3)) CONSTANT-SET)
;; (list (list 2 3))
;; STRATEGY : Function composition
(define (all-successors explored full-list)
  (foldr
   (lambda (node s)
     (set-union
      (obstacles-recur-two node full-list)
      s))
   empty
   explored))

;; adjacent? : Position Position -> Boolean
;; GIVEN : two positions on the chessboard
;; RETURNS : true iff they are adjacent to each other.
;; Example : (adjacent? (list 1 2) (list 2 3)) -> true
;; STRATEGY : Function composition
(define (adjacent? one two)
  (and
   (or (= (second one) (- (second two) 1))
       (= (second one) (+ (second two) 1)))
   (or (= (first one) (+ (first two) 1))
       (= (first one) (- (first two) 1)))))

;; TESTS :
(define-test-suite blocks-to-obstacles-test-suite
  (check-equal? (blocks-to-obstacles (list (list 3 3) (list 4 4)))
                (list (list (list 4 4) (list 3 3))) 
                "These are the blocks-to-obstacles")
  (check-equal? (blocks-to-obstacles (list (list 2 1) (list 1 2)))
                (list (list (list 1 2) (list 2 1))) 
                "These are the blocks-to-obstacles"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Running the test suite
(run-tests position-set-equal?-test-suite)
(run-tests obstacle?-test-suite)
(run-tests blocks-to-obstacles-test-suite)

