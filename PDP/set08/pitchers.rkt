;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pitchers) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide 
 list-to-pitchers
 pitchers-to-list
 pitchers-after-moves
 make-move
 move-tgt
 move-src
 solution)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ALGORITHM:
;The initial state of the game consists of a non-empty list of 
;pitchers, each with their capacities. The pitchers are numbered starting from 
;1. All pitchers are empty at the start. The goal of the game is expressed 
;as a number, and the object of the game is to get one pitcher 
;that holds exactly that amount of liquid.
;A move in the game consists of pouring the liquid from 
;one pitcher to another until the first pitcher is empty, or the second pitcher 
;is full, whichever comes first. 
;Firstly, we convert the given PitcherExternalRep to PitcherInternalRep which  
; is in the form of (list (list Capacities) (list Contents)).

;To find the solution, Depth First Search (DFS) algorithm is used. A list of
;valid moves are generated and a list of PitcherInternalRep are generated for
;each move using DFS. If the goal amount can be reached, then the list of Moves
;i.e, the path is returned, else it returns false.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONSTANTS
(define START-INDEX 1)
(define ZERO 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS

;; A Pitcher is (list NonNegInt NonNegInt)
;; Interp: the first element represent the pitcher's capacity
;;        and the second element represent the pitcher's contents.
;; WHERE: the pitcher's content is less than or equal to the pitcher's capacity.
;; TEMPLATE :
;; pitcher-fn : Pitcher -> ??
#;(define (pitcher-fn pitcher)
    (... (first pitcher)
         (second pitcher)))

;; A ListOfPitcher(LOP) is 
;; -- empty             Interp: It shows empty list
;; --(cons Pitcher LOP) Interp: It shows list with a 
;;                              Pitcher and ListOfPitcher.
;; 
;; TEMPLATE :
;; lop-fn : LOP -> ??
#;(define (lop-fn pitchers)
    (cond
      [(empty? pitchers) ...]
      [else (...
             (pitcher-fn (first pitchers))
             (lop-fn (rest pitchers)))]))

;; A NonEmptyListOfPitcher(NELOP) is 
;; (cons Pitcher LOP)
;; Interpretation: A non-empty ListOfPitcher.

;; TEMPLATE1 :
;; nelop-fn : NELOP -> ??
#;(define (nelop-fn lop)
    (cond
      [(empty? (rest lop)) (... (pitcher-fn (first lop)))]
      [else (... (pitcher-fn (first lop))
                 (nelop-fn (rest lop)))]))
;; TEMPLATE2 :
;; nelop-fn : NELOP -> ??
#;(define (nelop-fn lop)
    (... (pitcher-fn (first lop))
         (lop-fn (rest lop))))
;;
;; PitchersExternalRep is NELOP
;; PitchersExternalRep ::= ((capacity1 contents1)
;;                         (capacity2 contents2)
;;                         ...
;;                         (capacity_n contents_n))
;; WHERE:  n >=1, and for each i, 0 <= contents_i <= capacity_i
;; INTERPRETATION: the list of pitchers, from 1 to n, with their contents
;; and capacity.
;; EXAMPLE: ((10 5) (8 7)) is a list of two pitchers.  The first has
;; capacity 10 and currently holds 5; the second has capacity 8 and
;; currently holds 7.

;;
(define-struct move (src tgt))
;; A Move is a (make-move PosInt PosInt)
;; WHERE: src and tgt are different
;; INTERP: (make-move i j) means pour from pitcher i to pitcher j.
;; 'pitcher i' refers to the i-th pitcher in the PitchersExternalRep.
;;
;; TEMPLATE :
;; move-fn : Move -> ??
#;(define (move-fn mov)
    (... (move-src mov) 
         (move-tgt mov)))

;; A ListOf<move>(LOM) is either
;; -- empty                   Interp: it represents empty list
;; -- (cons move ListOf<move>)Interp: It represents a Move and a LOM.
;;
;; TEMPLATE :
;; lom-fn : LOM -> ??
#;(define (lom-fn lom)
    (cond
      [(empty? lom) ...]
      [else (...
             (move-fn (first lom))
             (lom-fn (rest lom)))]))

;; MayBe<listOf<Move>> is one of
;; -- false   Interp: represents a boolean value false
;; -- LOM     Interp: represents a list of moves
;;
;; TEMPLATE :
;; maybelom-fn : MayBe<listOf<Move>> -> ??
#;(define (maybelom-fn lom)
    (cond
      [(false? lom)...]
      [else (lom-fn lom)]))

;; ListOf<Integer> is one of
;; -- empty                        Interp: represents an empty list
;; --(cons Integer ListOf<Integer>)Interp: represents an integer and 
;;                                         list of Integer

;; TEMPLATE:
;; loi-fn: ListOf<Integer> -> ??
#; (define (loi-fn loi)
     (cond
       [(empty? loi) ...]
       [else (... (first loi)
                  (loi-fn (rest loi)))]))

;; NEListOf<Integer> is a
;; (cons Integer ListOf<integer>)
;; Interpretation: Non-empty list of Integers.

;; TEMPLATE1:
;; neloi-fn: NEListOf<Integer> -> ??
#; (define (neloi-fn neloi)
     (cond
       [(empty? (rest neloi) (... (first neloi)))]
       [else (... (first neloi)
                  (neloi-fn (rest neloi)))]))

;; TEMPLATE2:
;; neloi-fn : NEListOf<Integer>-> ??
#; (define (neloi-fn neloi)
     (... (first neloi)
          (loi-fn (rest neloi))))


;; ListOf<PosInt>(LOPI) is one of
;; -- empty              Interp: represents an empty list
;; -- (cons PosInt LOPI) Interp: represents a PosInt and a list of PosInt

;; template :
;; lopi-fn : LOPI -> ??
#;(define (lopi-fn lop)
    (cond
      [(empty? lop) ...]
      [else (... (first lop)
                 (lopi-fn (rest lop)))]))

;; A NEListOfPosInt (NELOPI) is (cons PosInt LOPI)
;; Interp:  a non-empty ListOfPosInt
;; TEMPLATE1:
;; nelopi-fn : NELOPI -> ??
#;(define (nelopi-fn lopi)
    (cond
      [(empty? (rest lopi)) (... (first lopi))]
      [else (... (first lopi)
                 (nelopi-fn (rest lopi)))]))


;; TEMPLATE2 :
;; nelopi-fn : NELOPI -> ??
#;(define (nelopi-fn lopi)
    (... (first lopi)
         (lopi-fn (rest lopi))))



;; A ListOf<NonNegInt>(LONI) is one of
;; -- empty                 Interp: represents empty list
;; -- (cons NonNegInt LONI) Interp: represent a non negative integer and a LONI

;; TEMPLATE :
;; loni-fn : LONI -> ??
#;(define (loni-fn lon)
    (cond
      [(empty? lon)...]
      [else (...(first lon)
                (loni-fn (rest lon)))]))

;; A NEListOfNonNegInt (NELONI) is a (cons NonNegInt LONI)

;; TEMPLATE1:
;; neloni-fn : NELONI -> ??
#;(define (neloni-fn loni)
    (cond
      [(empty? (rest loni)) (... (first loni))]
      [else (... (first loni))
            (neloni-fn (rest loni))]))


;; TEMPLATE2 :
;; neloni-fn : NELONI -> ??
#;(define (neloni-fn loni)
    (... (first loni)
         (loni-fn (rest loni))))



;;
;; Capacity is NELONI
;; Content is NELONI

;; A ListOfContent(LOC) is one of
;; --empty             Interp: represents an empty list
;; --(cons Content LOC)Interp: represents a Content and list of Content

;; TEMPLATE:
;; loc-fn: LOC->??
#; (define (loc-fn loc)
     (cond
       [(empty? loc) ...]
       [else (... (neloni-fn (first loc))
                  (loc-fn (rest loc)))]))



;; A NEListOfContent (NELOC) is 
;; -- (cons Content LOC)
;; Interpretation: A non-empty list of Content

;; TEMPLATE1:
;; neloc-fn: NELOC -> ??
#; (define (neloc-fn neloc)
     (cond
       [(empty? (rest neloc)) (neloni-fn (first neloc))]
       [else (... (neloni-fn (first neloc))
                  (neloc-fn (rest neloc)))]))

;; TEMPLATE2:
;; neloc-fn: NELOC -> ??
#; (define (neloc-fn neloc)
     (... (neloni-fn (first neloc))
          (loc-fn (rest neloc))))

;; PitchersInternalRep :=  ((capacity1 capacity2 capacity_n ...)
;;                         (contents_1 contents2 contents_n ...))
;; WHERE:  n >=1, and for each i, 0 <= contents_i <= capacity_i


;;
;; A PitchersInternalRep(PIR) is (cons Capacity Content)
;; interp : represents a list of capacities and contents.
;; WHERE : Length of capacity is equal to length of content.
;; 
;; TEMPLATE :
;; pir-fn : PitchersInternalRep -> ??
#;(define (pir-fn pir)
    (... (neloni-fn (first pir))
         (neloni-fn (second pir))))
;;
;; ListOfPIR(LOPIR) is 
;; -- empty            Interp: represents an empty list
;; -- (cons PIR LOPIR) Interp: represents a List of PitcherInternalRep
;; 
;; TEMPLATE :
;; lopir-fn : LOPIR -> ??
#;(define (lopir-fn pirs)
    (cond
      [(empty? pirs) ...]
      [else (... (pir-fn (first pirs))
                 (lopir-fn (rest pirs)))]))
;;
;; NonEmptyListOfPIR(NELOPIR) is (cons PIR LOPIR)
;; Interpretation: It represents a non-empty LOPIR

;; TEMPLATE1:
;; nelopir-fn : NELOPIR -> ??
#;(define (nelopir-fn nepirs)
    (cond
      [(empty? (rest nepirs)) (... (pir-fn (first nepirs)))]
      [else (... (pir-fn (first nepirs))
                 (nelopir-fn (rest nepirs)))]))

;; TEMPLATE2 :
;; nelopir-fn : NELOPIR -> ??
#;(define (nelopir-fn nepirs)
    (... (first nepirs)
         (lopir-fn (rest nepirs))))


;; MayBeNonEmptyLOPIR is
;; -- false   Interp: represents a boolean value false
;; -- NELOPIR Interp: represents a Non-empty ListOfPitcherInternalRep
;;
;; TEMPLATE :
;; maybenelopir-fn : MayBeNonEmptyLOPIR -> ??
#;(define (maybenelopir-fn pi)
    (cond
      [(false? pi)...]
      [else (nelopir-fn pi)]))

;;; END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; list-to-pitchers : PitchersExternalRep -> PitchersInternalRep
;; GIVEN : a list of pitchers in external representation
;; RETURNS : the internal representation of the given input
;; EXAMPLES : See test below.
;; STRATEGY : HOFC
(define (list-to-pitchers pexr)
  (list
   (map first pexr)
   (map second pexr)))

;; TEST :
(begin-for-test
  (check-equal? (list-to-pitchers '((8 8) (5 0) (3 0))) '((8 5 3) (8 0 0))
                "Converting external representation to internal 
                 representation"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pitchers-to-list : PitchersInternalRep -> PitchersExternalRep
;; GIVEN : a list of pitchers in internal representation
;; RETURNS : a list of pitchers in external representation
;; EXAMPLES : See test case below
;; STRATEGY : structural decomposition on pinr : PitchersInternalRep
(define (pitchers-to-list pinr)
  (internal-to-external-rep (first pinr) (second pinr)))

;; TESTS :
(begin-for-test 
  (check-equal? (pitchers-to-list '((8 5 3)(8 0 0))) 
                (list (list 8 8) (list 5 0) (list 3 0)) 
                "internal to external conversion of pitcher representation"))

;; internal-to-external-rep : Capacity Content -> PitchersExternalRep
;; GIVEN : A list of pitcher capacities and a list of pitcher contents
;; RETURNS : A list of pitchers in internal representation
;; EXAMPLES : see tests below 
;; STRATEGY : structural decomposition on capacities,contents : Capacity,Content
(define (internal-to-external-rep capacities contents)
  (cond
    [(empty? (rest capacities)) 
     (list (list (first capacities) (first contents)))]
    [else (append 
           (list (list (first capacities) (first contents))) 
           (internal-to-external-rep (rest capacities) (rest contents)))]))

;; TESTS :
(begin-for-test 
  (check-equal? (internal-to-external-rep '(8 5 3) '(8 0 0)) 
                (list (list 8 8) (list 5 0) (list 3 0)) 
                "converting capacities and contents to external 
                 representation"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pitchers-after-moves : PitchersInternalRep ListOf<Moves> -> 
;; PitchersInternalRep
;; GIVEN : a list of pitchers in internal representation and a list of moves
;; RETURNS : The list of pitchers in internal representation after 
;; the list of moves are applied on it.
;; EXAMPLES : See test below
;; STRATEGY : general recursion
;; HALTING-MEASURE : length of lom
;; TERMINATING-ARGUMENT : When the list of moves becomes empty the program 
;; will halt 
(define (pitchers-after-moves pinr lom)
  (cond
    [(empty? lom) pinr]
    [else (local 
            ((define updated-pinr (modify-pitcher (first lom) pinr)))
            (pitchers-after-moves updated-pinr (rest lom)))]))

;; TESTS :
(begin-for-test
  (check-equal? (pitchers-after-moves (list (list 8 5 3 6 7) (list 5 0 3 6 7)) 
                                      (list (make-move 3 2))) 
                (list (list 8 5 3 6 7) (list 5 3 0 6 7))
                "Moving when move is completely possible")
  
  (check-equal? (pitchers-after-moves (list (list 8 5 3 6 7) (list 5 0 3 2 3)) 
                                      (list (make-move 3 2) (make-move 1 5))) 
                (list (list 8 5 3 6 7) (list 1 3 0 2 7))
                "Moving when move is only partially possible") 
  
  (check-equal? (pitchers-after-moves (list (list 8 5 3 9) (list 5 0 3 0)) 
                                      (list (make-move 3 4) (make-move 1 4))) 
                (list (list 8 5 3 9) (list 0 0 0 8))
                "Moving when target capacity is more than to be 
                 trasferred content")
  
  (check-equal? (pitchers-after-moves (list (list 8 5 3 9) (list 5 0 3 0)) 
                                      (list (make-move 3 4) (make-move 1 4) 
                                            (make-move 4 2))) 
                (list (list 8 5 3 9) (list 0 5 0 3))
                "Moving when target capacity is less than to be 
                 transferred content"))

;; modify-pitcher : Move PitcherInternalRep -> PitchersInternalRep
;; GIVEN : A single move and the pitcher's Internal representation
;; RETURNS : The pitcher's representation after that move.
;; EXAMPLES : see tests below 
;; STRATEGY : Function composition
(define (modify-pitcher mve pinr)
  (updated-pitcher-after-move mve pinr START-INDEX))

;; TESTS :
(begin-for-test
  (check-equal? (modify-pitcher (make-move 1 2) '((8 5 3)(8 0 0))) 
                '((8 5 3) (3 5 0)) "pitcher after a move"))

;; updated-pitcher-after-move : Move PitcherInternalRep PosInt -> 
;; PitcherInternalRep 
;; GIVEN : A move, the pitcher's Internal representation and index starting 
;; with one
;; RETURNS : The pitcher's internal representation after that move.
;; EXAMPLES : See tests below
;; STRATEGY : Structural decomposition on pinr : PitcherInternalRep
(define (updated-pitcher-after-move mve pinr index)
  (list (first pinr) 
        (modify-contents mve 
                         (list-ref (first pinr) (sub1 (move-tgt mve)))
                         (second pinr) index (length (second pinr)))))

;; TESTS :
(begin-for-test
  (check-equal? (updated-pitcher-after-move (make-move 1 2) '((8 5 3)(8 0 0))
                                            1) 
                (list (list 8 5 3) (list 3 5 0)) "updated pitcher after move"))

;; modify-contents : Move NonNegInt Content NonNegInt PosInt -> Content
;; GIVEN : A move, capacity of a target pitcher, List of contents of the 
;; pitcher index and the no of pitchers
;; RETURNS : The list of contents updated after the single move.
;; EXAMPLES : See tests below
;; HALTING-MEASURE : no-of-pitchers - index + 1
;; TERMINATING ARGUMENT : When the value of halting measure becomes 0,
;; then the program will halt.
;; STRATEGY : general recursion
(define (modify-contents mve tgtCap contents index no-of-pitchers)
  (cond
    [(> index no-of-pitchers) empty]
    [else (cons (check-each-pitcher mve tgtCap contents index)
                (modify-contents mve tgtCap contents (add1 index) 
                                 no-of-pitchers))]))

;; TESTS :
(begin-for-test
  (check-equal? (modify-contents (make-move 1 2) 5 '(8 0 0) 1 3)
                '(3 5 0) "modify contents of a pitcher"))

;; check-each-pitcher : Move NonNegInt Content PosInt -> NonNegInt 
;; GIVEN : A move, Capacity of a target pitcher, List of Pitcher contents
;;         and index
;; RETURNS : The value to be updated depending on whether its the source value,
;;           target value or neither.
;; EXAMPLES : See tests below
;; STRATEGY : Function composition
(define (check-each-pitcher mve tgtCap contents index)
  (cond
    [(= index (move-src mve)) (source-content contents index tgtCap mve)]
    [(= index (move-tgt mve)) (+ (list-ref contents (sub1 index))
                                 (target-content mve tgtCap contents 
                                                 (list-ref contents 
                                                           (sub1 index))))]
    [else (list-ref contents (sub1 index))]))

;; TESTS :
(begin-for-test
  (check-equal? (check-each-pitcher (make-move 1 2) 4 '(8 0 0) 1) 4 
                "check-each-pitcher"))

;; source-content : Content PosInt NonNegInt Move -> NonNegInt
;; GIVEN : a list of Pitcher Contents, index, capacity of target pitcher and 
;;         a move.
;; RETURNS : quanity of the source pitcher after the given move.
;; EXAMPLES : See tests below
;; STRATEGY : Function composition

(define (source-content contents index tgtCap mve)
  (if (< (- (list-ref contents (sub1 index)) 
            (- tgtCap (list-ref contents (sub1 (move-tgt mve))))) ZERO)
      ZERO
      (- (list-ref contents (sub1 index)) 
         (- tgtCap (list-ref contents (sub1 (move-tgt mve)))))))

;; TESTS :
(begin-for-test
  (check-equal? (source-content '(8 0 0) 1 5 (make-move 1 2)) 3 
                "source contents"))

;; target-content : Move NonNegInt Content NonNegInt -> NonNegInt
;; GIVEN : A move, capacity of target pitcher, list of pitcher contents
;; and present content in target pitcher
;; RETURNS : Updated content value for the target pitcher after the desired move
;; EXAMPLES : see tests below
;; STRATEGY : Function composition
(define (target-content mve tgtCap contents tgtContent)
  (if (< (- tgtCap tgtContent) (list-ref contents (sub1 (move-src mve)))) 
      (- tgtCap tgtContent)
      (list-ref contents (sub1 (move-src mve)))))

;; TESTS :
(begin-for-test
  (check-equal? (target-content (make-move 1 2) 5 '(8 0 0) 0) 5 
                "modifying target"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; solution : NELOPI PosInt -> Maybe<ListOf<Move>>
;; GIVEN : a list of Pitcher capacities and the goal quantity
;; RETURNS : a sequence of moves which, when executed from left to right,
;; results in one pitcher (not necessarily the first pitcher) containing
;; the goal amount.  Returns false if no such sequence exists.
;; EXAMPLES : See tests below
;; STRATEGY : Function Composition

(define (solution lst goal)
  (if (false? (initial-pitcher lst goal)) 
      false 
      (get-moves (reverse (final-pitcher-states lst goal))))) 

;; TESTS :
(begin-for-test 
  (check-equal? (solution '(8 5 3) 8) empty "no moves required")
  (check-equal? (solution '(8 5 3) 50) false "no solution possible"))

;; initial-pitcher: NELOPI PosInt -> MayBeNonEmptyLOPIR
;; GIVEN : a list of pitcher capacities and goal quantity in a pitcher
;; RETURNS : a list of PitcherInternalRep if the path exists, else returns false
;; EXAMPLE:see tests below
;; STRATEGY : Function Composition

(define (initial-pitcher lst goal)
  (path (list (capacities-to-pitcherInternalRep lst goal))
        (list (capacities-to-pitcherInternalRep lst goal))
        goal  (capacities-to-pitcherInternalRep lst goal) START-INDEX))

;; TESTS :
(begin-for-test 
  (check-equal? (initial-pitcher '(8 5 3) 8) 
                (list (list (list 8 5 3) (list 8 0 0)))
                "result from initial pitcher"))

;; capacities-to-pitcherInternalRep: NELOPI PosInt -> PitcherInternalRep
;; GIVEN : a list of capacities of each pitcher and the goal quantity
;; RETURNS : a pitcherInternaRep which is the initial pitcher state with 
;;          the first pitcher full and the rest empty
;; EXAMPLES : see tests below
;; STRATEGY : Function Composition
(define (capacities-to-pitcherInternalRep lst goal)
  (list lst (cons (list-ref lst ZERO) 
                  (build-list (sub1 (length lst))
                              ;; PosInt -> 0 (ZERO)
                              ;; GIVEN: an index value
                              ;; RETURNS: an integer 0 always
                              (lambda (j) ZERO)))))

;; TESTS :
(begin-for-test 
  (check-equal? (capacities-to-pitcherInternalRep '(8 5 3) 4)
                (list (list 8 5 3) (list 8 0 0)) "making initial pitcher"))

;; final-pitcher-states : NELOPI PosInt -> NELONI
;; GIVEN : A list of pitcher capacities and a goal quantity in a pitcher
;; RETURNS : A list of pitcher contents
;; EXAMPLE : See tests below
;; STRATEGY : HOFC
(define (final-pitcher-states lst goal)
  (map second (initial-pitcher lst goal)))

;; TESTS :
(begin-for-test 
  (check-equal? (final-pitcher-states '(8 5 3) 8) (list (list 8 0 0))
                "final pitcher states"))

;; path: LOPIR LOPIR PosInt PitcherInternalRep PosInt ->  MayBeLOPIR
;; GIVEN : a list of PitcherInternalRep which are to be explored used as a 
;; queue, a list of PitcherInternalRep that are explored already,
;; a goal quantity amount, an initial PitcherInternalRep and index value.
;; RESULTS: a List of PitcherInternalRep if the goal can be reached, else 
;; returns false.
;; HALTING MEASURE: length of queue
;; Termination Argument :if the length of the queue is zero it means that there
;;                       are no more moves to be explored and hence the program 
;;                       halts or the program halts when the target is reached.
;; EXAMPLES : See tests below
;; STRATEGY : General Recursion

(define (path queue explored tgt pinr index)
  (cond
    [(empty? queue) false]    
    [(my-member? tgt (second (first queue))) explored]
    [else (local
            ((define candidates (set-diff 
                                 (successors (length (second (first queue))) 
                                             index (first queue))
                                 explored)))
            (cond
              [(empty? candidates) 
               (path (rest queue) explored tgt pinr index)]
              [else (path (append candidates (rest queue))
                          (cons (first candidates) explored)
                          tgt pinr index)]))]))

;; TESTS :
(begin-for-test 
  (check-equal? (path empty empty 4 '((8 5 3)(8 0 0)) 1) false "queue is empty")
  (check-equal? (path '(((8 5 3)(8 0 0))) empty 4 '((8 5 3)(8 0 0)) 1) 
                (list
                 (list (list 8 5 3) (list 4 1 3))
                 (list (list 8 5 3) (list 2 5 1))
                 (list (list 8 5 3) (list 7 0 1))
                 (list (list 8 5 3) (list 5 3 0))
                 (list (list 8 5 3) (list 2 3 3))
                 (list (list 8 5 3) (list 0 5 3))
                 (list (list 8 5 3) (list 5 0 3))
                 (list (list 8 5 3) (list 8 0 0))
                 (list (list 8 5 3) (list 3 5 0))) 
                "This is the given path"))

;; successors : PosInt PosInt PitcherInternalRep -> LOPIR
;; GIVEN : No of pitchers, an index and a 
;; internal representation of the pitcher.
;; RETURNS : All the pitcher representations after each move.
;; EXAMPLES : See tests below.
;; STRATEGY : HOFC
(define (successors len index pinr)
  (filter
   ;; PitcherInternalRep -> Boolean
   ;; GIVEN : The internal representation of a set of pitchers
   ;; RETURNS : The list of successors excluding the original list of pitchers
   (lambda (one)
     (not (set-equal? one pinr)))
   (all-successors len index pinr)))

;; TESTS :
(begin-for-test
  (check-equal? (successors 3 1 '((8 5 3)(8 0 0))) 
                (list (list (list 8 5 3) (list 3 5 0)) 
                      (list (list 8 5 3) (list 5 0 3))) 
                "returns valid successors"))

;; all-succesors : PosInt PosInt PitcherInternalRep -> LOPIR
;; GIVEN : No of pitchers, an index value and a pitcher in internal 
;; representation.
;; RETURNS : The list of PitcherInternalRep which are succesors of the given 
;; input.
;; EXAMPLES : See tests below.
;; STRATEGY : HOFC
(define (all-successors len index pinr)
  (map
   ;; Move -> PitchersInternalRep
   ;; GIVEN : A single move
   ;; RETURNS : The pitcher representation after the move.
   (lambda(mve)
     (pitchers-after-moves pinr (list mve)))
   (filtered-moves len index)))

;; TESTS :
(begin-for-test 
  (check-equal? (all-successors 2 1 '((8 5)(8 0))) 
                '(((8 5) (8 0)) ((8 5) (3 5))) 
                "Gives all successors of a pitcher"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get-moves : NELOC -> LOM
;; GIVEN : A non-empty list of Contents
;; RETURNS : A list of moves
;; EXAMPLES : See test below
;; STRATEGY : Structural Decomposition on lst: NELONI 
(define (get-moves lst)
  (cond
    [(empty? (rest lst)) empty]
    [else (cons (make-move (source-index (first lst) (second lst)) 
                           (target-index (first lst) (second lst)))
                (get-moves (rest lst)))]))

;; TESTS :
(begin-for-test
  (check-equal? (get-moves '((8 0 0)(3 5 0))) (list (make-move 1 2))
                "get moves"))

;; source-index : Content Content -> PosInt
;; GIVEN : a list of contents of first and second pitcher
;; RETURNS : a positive integer which represent the index at which the source
;; pitcher is present.
;; EXAMPLES : See tests below
;; STRATEGY : HOFC
(define (source-index one two)
  (check-position (apply max (get-values one two)) 
                  (get-values one two) START-INDEX)) 

;; TESTS :
(begin-for-test 
  (check-equal? (source-index '(8 0 0) '(3 5 0)) 1 "finding source"))

;; target-index : Content Content -> PosInt
;; GIVEN : list of contents of first and second pitchers
;; RETURNS : a positive integer which represent the index at which the target
;; pitcher is present
;; EXAMPLES : see tests below
;; STRATEGY : HOFC
(define (target-index one two)
  (check-position (apply min (get-values one two)) (get-values one two) 
                  START-INDEX))

;; TESTS :
(begin-for-test
  (check-equal? (target-index '(3 5 0) '(3 2 3)) 3 "finding target"))

;; get-values: Content Content -> NEListOf<Integer>
;; GIVEN : List of contents of first and second pitchers.
;; RETURNS : A list of Numbers whose values are the subtraction of contents of
;; first pitcher and  contents of second pitcher respectively.
;; EXAMPLES : See tests below
;; STRATEGY : Structural Decomposition on one and two: NELONI 
(define (get-values one two)
  (cond
    [(empty? (rest one)) (list (- (first one) (first two)))]
    [else (cons (- (first one) (first two))
                (get-values (rest one) (rest two)))]))

;; TESTS
(begin-for-test
  (check-equal? (get-values '(8 0 0) '(3 5 0)) (list 5 -5 0) 
                "difference in pitcher contents"))

;; check-position: NonNegInt Content PosInt -> PosInt
;; GIVEN : One of the contents of the pitchers, list of contents of pitchers, 
;; an index value.
;; RETURNS : the index in the list at which the given posInt is present.
;; EXAMPLES : See tests below
;; STRATEGY : Structural Decomposition on lst: ListOf<PosInt>
(define (check-position x lst index)
  (if (equal? x (first lst))
      index
      (check-position x (rest lst) (add1 index))))

;; TESTS :
(begin-for-test
  (check-equal? (check-position 3 '(8 5 3) 1) 3 "finding position"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GENERATING LIST OF MOVES
;;
;; filtered-moves : PosInt PosInt -> LOM
;; GIVEN : No. of pitchers and index
;; RETURNS : All the moves where the index isn't the same thus removing 
;; redundant moves.
;; EXAMPLES : (filtered-moves 3 1) -> 
;; (list
;;  (make-move 2 1) (make-move 3 1) (make-move 1 2)
;;  (make-move 3 2) (make-move 1 3) (make-move 2 3))
;; STRATEGY : HOFC 
(define (filtered-moves len index)
  (filter 
   ;; Move -> Boolean
   ;; RETURNS : If source is same as target then returns true.
   ;; else false.
   (lambda (n) 
     (not (= (move-src n) (move-tgt n))))
   (all-moves len index)))

;; all-moves : PosInt PosInt -> LOM
;; GIVEN : Length of the pitcher list and index.
;; RETURNS : The list of all possible moves.
;; EXAMPLES : (all-moves 3 1) -> 
;; (list (make-move 1 1) (make-move 2 1) (make-move 3 1) (make-move 1 2)
;;      (make-move 2 2) (make-move 3 2) (make-move 1 3) (make-move 2 3)
;;      (make-move 3 3))
;; Halting Measure: value of len-index+1
;; TERMINATING ARGUEMENT: If the halting measure value is zero, it means that
;;                        there are no more new moves to be created and hence
;;                        the program halts
;; STRATEGY : General Recursion

(define (all-moves len index)
  (cond
    [(> index len) empty]
    [else (append (build-moves index len)
                  (all-moves len (add1 index)))]))

;; build-moves : PosInt PosInt -> LOM
;; GIVEN : Starting Index and No. of pitchers
;; RETURNS : List of moves
;; EXAMPLES : (build-moves 3 1) -> (list (make-move 1 3))
;; STRATEGY : HOFC
(define (build-moves index len)
  (build-list len
              ;PosInt -> Move
              ;GIVEN: a positive integer
              ;RETURNS: A new move with its source value incremented.
              (lambda (n) (make-move (+ n START-INDEX) index))))