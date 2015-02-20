;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname river) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide 
 list-to-pitchers
 pitchers-to-list
 pitchers-after-moves
 move-tgt
 move?
 move-src
 make-move
 solution
 make-fill
 fill-pitcher
 fill?
 make-dump
 dump-pitcher
 dump?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ALGORITHM:
;The initial state of the game consists of a non-empty list of 
;pitchers, each with their capacities. The pitchers are numbered starting from 
;1. All pitchers are empty at the start. The goal of the game is expressed 
;as a number, and the object of the game is to get one pitcher 
;that holds exactly that amount of liquid.
;A move in the game consists of 
;1 .pouring the liquid from one pitcher to another until the first pitcher 
;is empty, or the second pitcher is full, whichever comes first.
;2 .Completely filling one pitcher using fill.
;3 .Completely emptying the contents using dump.

;Firstly, we convert the given PitcherExternalRep to PitcherInternalRep which  
; is in the form of (list (list Capacities) (list Contents)).
;To find the solution, Depth First Search (DFS) algorithm is used. A list of
;valid moves are generated and a list of PitcherInternalRep are generated for
;each move using DFS. If the goal amount can be reached, then the list of Moves
;i.e, the path is returned, else it returns false.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Constants
(define STARTING-INDEX 1)
(define ZERO 0)
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;
(define-struct move (src tgt))
;; A MoveStructure is a (make-move PosInt PosInt)
;; WHERE: src and tgt are different
;; INTERP: (make-move i j) means pour from pitcher i to pitcher j.
;; 'pitcher i' refers to the i-th pitcher in the PitchersExternalRep.
;;
;; TEMPLATE :
;; movestr-fn : MoveStructure -> ??
#;(define (movestr-fn mov)
    (... (move-src mov) 
         (move-tgt mov)))


(define-struct fill (pitcher))
;; A Fill is a (make-fill PosInt)
;; INTERP : (make-fill i) means fill pitcher i from the river.
;; TEMPLATE :
#;(define (fill-fn fil)
    (fill-pitcher fil))

(define-struct dump (pitcher))
;; A Dump is a (make-dump PosInt)
;; INTERP : (make-dump i) means dump the contents of pitcher i into the river.
;; TEMPLATE:
#;(define (dump-fn du)
    (dump-pitcher du))

;; A Move is one of
;; -- (make-move i j)    --pour the contents of pitcher i into pitcher j
;; -- (make-fill i)      --fill pitcher i from the river
;; -- (make-dump i)      --dump the contents of pitcher i into the river.
;;
;; template :
;; move-fn : Move -> ??
#;(define (move-fn mve)
    (cond
      [(move? mve) (...
                    (movestr-fn mve))]
      [(fill? mve) (...
                    (fill-fn mve))]
      [(dump? mve) (...
                    (dump-fn mve))]))

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
;
;; Capacity is NELONI
;; Content is NELONI
;;
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
;; A PitchersInternalRep(PIR) is 
;; -- (cons Capacity Content)
;; WHERE : Length of capacity is equal to length of content.
;; 
;; template :
;; pir-fn : PitchersInternalRep -> ??
#;(define (pir-fn pir)
    (...(neloni-fn (first pir))
        (neloni-fn (second pir))))
;;
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
;;
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
;;
;;; END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; list-to-pitchers : PitchersExternalRep -> PitchersInternalRep
;; RETURNS : the internal representation of the given input
;; EXAMPLES : See test below.
;; STRATEGY : HOFC
(define (list-to-pitchers pexr)
  (list
   (map first pexr)
   (map second pexr)))

;; test for list-to-pitchers
(begin-for-test
  (check-equal? (list-to-pitchers '((8 8) (5 0) (3 0))) '((8 5 3) (8 0 0))
                "Converting external representation to internal 
                 representation"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pitchers-to-list : PitchersInternalRep -> PitchersExternalRep
;; GIVEN : a list of pitchers in internal representation
;; RETURNS : a list of pitchers in external representation
;; EXAMPLES : See test case below
;; STRATEGY : Structural decomposition on pinr : PIR
(define (pitchers-to-list pinr)
  (internal-to-external-rep (first pinr) (second pinr)))

;; TESTS :
(begin-for-test 
  (check-equal? (pitchers-to-list '((8 5 3)(8 0 0))) 
                (list (list 8 8) (list 5 0) (list 3 0)) 
                "internal to external conversion of pitcher representation" ))

;; internal-to-external-rep : Capacity Content -> PitchersExternalRep
;; GIVEN : A list of capacities and a list of contents.
;; RETURNS : A list of pitchers in internal representation.
;; EXAMPLES : See tests below 
;; STRATEGY : Structural decomposition on capacities, contents : 
;; Capacity, Content
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pitchers-after-moves : PitchersInternalRep ListOf<Move> -> 
;; PitchersInternalRep
;; GIVEN : A list of pitchers in internal representation and list of moves
;; RETURNS : The list of pitchers after the list of moves are applied on it.
;; EXAMPLES : See test below
;; HALTING-MEASURE : length of lom
;; TERMINATION ARGUMENT: when the lom becomes empty, the program will halt.
;; STRATEGY : general recursion
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
                 transferred content")
  
  (check-equal? (pitchers-after-moves (list (list 8 5 3 6 7) (list 5 0 3 6 7)) 
                                      (list (make-move 3 2) (make-fill 3) 
                                            (make-dump 5)))
                '((8 5 3 6 7) (5 3 3 6 0)) "Checking dump and fill function"))

;; modify-pitcher : Move PitcherInternalRep -> PitchersInternalRep
;; GIVEN : A single move and the pitcher's Internal representation
;; RETURNS : The pitcher's representation after that move.
;; EXAMPLES : See test below.
;; STRATEGY : function composition
(define (modify-pitcher mve pinr)
  (updated-pitcher-after-move mve pinr STARTING-INDEX))

;; TESTS :
(begin-for-test
  (check-equal? (modify-pitcher (make-move 1 2) '((8 5 3)(8 0 0))) 
                '((8 5 3) (3 5 0)) "pitcher after a move"))

;; updated-pitcher-after-move : Move PitcherInternalRep PosInt -> 
;; PitcherInternalRep 
;; GIVEN : A move, the pitcher's Internal representation and index
;; RETURNS : The pitcher's internal representation after that move.
;; EXAMPLES : See tests below.
;; STRATEGY : Structural decomposition on pinr : PitcherInternalRep
(define (updated-pitcher-after-move mve pinr index)
  (list (first pinr) 
        (modify-contents mve (second pinr) 
                         index (length (second pinr)) pinr)))

;; TESTS :
(begin-for-test
  (check-equal? 
   (updated-pitcher-after-move (make-move 1 2) '((8 5 3)(8 0 0)) 1) 
   (list (list 8 5 3) (list 3 5 0)) "pitcher after a move helper"))

;; modify-contents : Move Content PosInt PosInt PIR -> Content
;; GIVEN : A move, List of contents of the pitcher,index, the no of pitchers
;; and the pitcher's internal representation
;; RETURNS : The list of contents updated after the single move.
;; EXAMPLES : See tests below.
;; HALTING-MEASURE : no-of-pitchers - index + 1
;; TERMINATING ARGUMENT: when the value of halting measure becomes zero, then 
;;                       the program halts.
;; STRATEGY : General recursion

(define (modify-contents mve contents index no-of-pitchers pinr)
  (cond
    [(> index no-of-pitchers) empty]
    [else (cons (check-each-pitcher mve contents index pinr)
                (modify-contents mve contents (add1 index) no-of-pitchers 
                                 pinr))]))

;; TESTS :
(begin-for-test
  (check-equal? (modify-contents (make-move 1 2) '(8 0 0) 1 3 
                                 '((8 5 3) (8 0 0)))
                '(3 5 0) "modify contents of a pitcher"))

;; check-each-pitcher : Move Content PosInt PIR -> NonNegInt 
;; GIVEN : A move, contents, index and the pitcher's internal representation.
;; RETURNS : The value to be updated at the given index depending on whether 
;; its move,fill or dump.
;; EXAMPLES : See tests below.
;; STRATEGY : Structural decomposition on mve : Move

(define (check-each-pitcher mve contents index pinr)
  (cond
    [(move? mve)(value-after-move mve contents index pinr)]
    [(fill? mve)(value-after-fill mve contents pinr index)]
    [(dump? mve)(value-after-dump mve contents pinr index)]))

;TESTS:
(begin-for-test
  (check-equal? 
   (check-each-pitcher (make-move 1 2) '(8 0 0) 1 '((8 5 3) (8 0 0)))
   3 "1st index should become 3")
  
  (check-equal? 
   (check-each-pitcher (make-move 1 2) '(8 0 0) 2 '((8 5 3) (8 0 0)))
   5 "2nd index should become 5")
  
  (check-equal? 
   (check-each-pitcher (make-fill 1) '(0 0 0) 1 '((8 5 3) (0 0 0)))
   8 "1st index should become 8")
  
  (check-equal? 
   (check-each-pitcher (make-dump 1) '(8 0 0) 1 '((8 5 3) (8 0 0)))
   0 "1st index should become 0"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; value-after-move : MoveStructure Content PosInt PIR -> NonNegInt 
;; GIVEN : A move structure, contents, index and the pitcher's internal 
;; representation.
;; RETURNS : The value to be updated at the given index depending on whether 
;; its the source value,target value or neither.
;; EXAMPLES : see test below
;; STRATEGY : Function composition
(define (value-after-move mve contents index pinr)
  (cond
    [(= index (move-src mve)) (source-content 
                               contents 
                               index 
                               (list-ref (first pinr) (sub1 (move-tgt mve))) 
                               mve)]
    [(= index (move-tgt mve)) (+ (list-ref contents (sub1 index))
                                 (target-content 
                                  mve 
                                  (list-ref (first pinr) (sub1 (move-tgt mve))) 
                                  contents 
                                  (list-ref contents (sub1 index))))]
    [else (list-ref contents (sub1 index))]))

;; TESTS :
(begin-for-test
  (check-equal? (value-after-move (make-move 1 2) '(8 0 0) 1 
                                  '((8 5 3) (8 0 0))) 
                3 
                "index is source hence will change to 3"))

;; source-content : Content PosInt NonNegInt MoveStructure -> NonNegInt
;; GIVEN : The contents, The index, Target maximum capacity and the move
;; RETURNS : the updated source quantity.
;; EXAMPLES :see tests below
;; STRATEGY : Function composition
(define (source-content contents index tgtCap mve)
  (if 
   (< (- (list-ref contents (sub1 index)) 
         (- tgtCap (list-ref contents (sub1 (move-tgt mve))))) ZERO)
   ZERO
   (- (list-ref contents (sub1 index)) 
      (- tgtCap (list-ref contents (sub1 (move-tgt mve)))))))

;; TESTS :
(begin-for-test
  (check-equal? (source-content '(8 0 0) 1 5 (make-move 1 2)) 3 
                "source contents"))

;; target-content : MoveStructure NonNegInt Content NonNegInt -> NonNegInt
;; GIVEN : A move structure, A maximum target capacity, content and 
;; the present target content.
;; RETURNS : Updated value for the target after the desired move.
;; EXAMPLES : See tests below
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
;; value-after-fill : Fill Content PIR PosInt -> NonNegInt
;; GIVEN : A fill structure, contents, the pitcher's internal 
;; representation and index.
;; RETURNS : The value to be updated at the given index.
;; EXAMPLES : See test below.
;; STRATEGY : Function composition
(define (value-after-fill mve contents pinr index)
  (cond
    [(= index (fill-pitcher mve)) (list-ref (first pinr) (sub1 index))]
    [else (list-ref contents (sub1 index))]))

(begin-for-test
  (check-equal? (value-after-fill (make-fill 1) '(0 0 0) '((8 5 3) (0 0 0)) 1)
                8 "Fill the index value to capacity"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; value-after-dump : Dump Content PIR PosInt -> NonNegInt
;; GIVEN : A dump structure, contents, the pitcher's internal 
;; representation and index.
;; RETURNS : The value to be updated at the given index.
;; EXAMPLES : see test below.
;; STRATEGY : Function composition
(define (value-after-dump mve contents pinr index)
  (if (= index (dump-pitcher mve))
      ZERO
      (list-ref contents (sub1 index))))

;; TESTS :
(begin-for-test
  (check-equal? (value-after-dump (make-dump 1) '(8 0 0) '((8 5 3) (8 0 0)) 1)
                0 "dump the index value content to empty"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; solution : NEListOf<PosInt> PosInt -> Maybe<ListOf<Move>>
;; GIVEN : A list of the capacities of the pitchers and the goal amount
;; RETURNS : A sequence of moves which, when executed from left to right,
;; results in one pitcher (not necessarily the first pitcher) containing
;; the goal amount.  Returns false if no such sequence exists.
;; EXAMPLES : See tests below.
;; STRATEGY : Function composition
(define (solution lst goal)
  (if (false? (initial-pitcher lst goal))
      false
      (final-moves (get-moves (get-contents lst goal)))))

;; TESTS :
(begin-for-test
  (check-equal? (solution (list 8 5 3) 4) (list (make-fill 1) (make-move 1 2)
                                                (make-dump 1) (make-move 2 1)
                                                (make-fill 2) (make-move 2 1)
                                                (make-dump 1) (make-move 2 1)
                                                (make-fill 2) (make-move 2 1)
                                                (make-fill 2) (make-move 2 1)))
  (check-equal? (solution (list 8 5 3) 10) #f))

;; get-contents : NEListOf<PosInt> PosInt -> NEListOfContent
;; GIVEN : A list of the capacities of the pitchers and the goal amount
;; RETURNS : List of contents from the initial state to target content.
;; EXAMPLES : see test below.
;; STRATEGY : HOFC
(define (get-contents lst goal)
  (reverse 
   (map 
    second
    (initial-pitcher lst goal))))

(begin-for-test
  (check-equal? (get-contents (list 8 5 3) 4) '((0 0 0) (8 0 0) (3 5 0) (0 5 0) 
                                                        (5 0 0) (5 5 0) (8 2 0) 
                                                        (0 2 0) (2 0 0) (2 5 0) 
                                                        (7 0 0) (7 5 0) 
                                                        (8 4 0)) 
                "List of contents to target content"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initial-pitcher: NELOPI PosInt -> MayBe<ListOf<PitcherInternalRep>>
;; GIVEN : a list of pitcher capacities and goal quantity in a pitcher
;; RETURNS : a list of PitcherInternalRep if the path exists, else returns false
;; EXAMPLE :see tests below
;; STRATEGY : Function Composition
(define (initial-pitcher lst goal)
  (path (list (list lst (make-list (length lst) ZERO)))
        (list (list lst (make-list (length lst) ZERO)))
        goal (list lst (make-list (length lst) ZERO)) STARTING-INDEX))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; path: LOPIR LOPIR PosInt PitchersInternalRep PosInt -> MayBeLOPIR
;; GIVEN : a list of PitcherInternalRep which are to be explored used as a 
;; queue, a list of PitcherInternalRep that are explored already,
;; a goal quantity amount, an initial PitcherInternalRep and index value.
;; RESULTS: a List of PitcherInternalRep if the goal can be reached, else 
;; returns false.
;; EXAMPLES : See tests below.
;; STRATEGY : General Recursion
;; HALTING-MEASURE : Length of queue
;; Termination Argument : If Queue becomes empty then there are no
;; more moves to be explored hence the program halts or if the target is found
;; within the possible moves then the program halts.
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; successors : PosInt PosInt PitcherInternalRep -> ListOf<PitcherInternalRep>
;; GIVEN : No of pitchers, a positive integer which is an invariant and a 
;; internal representation of the pitcher
;; RETURNS : All the pitcher representations after each move
;; EXAMPLES : See tests below.
;; STRATEGY : HOFC
(define (successors len index pinr)
  (filter
   ;; PIR -> Boolean
   ;; RETURNS : The list of successors excluding the given original list of 
   ;; pitchers 
   (lambda (one)
     (not (set-equal? one pinr)))
   (all-successors len index pinr)))

;; TESTS :
(begin-for-test
  (check-equal? (successors 3 1 '((8 5 3) (8 0 0))) 
                '(((8 5 3) (0 0 0)) ((8 5 3) (3 5 0))
                                    ((8 5 3) (8 5 0))
                                    ((8 5 3) (5 0 3))
                                    ((8 5 3) (8 0 3))) 
                "Filtered list of successors"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; all-succesors : PosInt PosInt PitcherInternalRep -> LOPIR
;; GIVEN : no of pitchers, an index value and a pitcher in internal 
;; representation
;; RETURNS : the list of PitcherInternalRep which are succesors of the given 
;; input
;; EXAMPLES : See test below
;; STRATEGY : HOFC
(define (all-successors len index pinr)
  (map
   ;; Move -> PIR
   ;; RETURNS : Pitcher representation after the given move.
   (lambda(mve)
     (pitchers-after-moves pinr (list mve)))
   (filtered-moves len index)))

;; TESTS :
(begin-for-test 
  (check-equal? (all-successors 3 1 '((8 5 3)(8 0 0))) '(((8 5 3) (8 0 0))
                                                         ((8 5 3) (8 0 0))
                                                         ((8 5 3) (0 0 0))
                                                         ((8 5 3) (8 0 0))
                                                         ((8 5 3) (3 5 0))
                                                         ((8 5 3) (8 0 0))
                                                         ((8 5 3) (8 0 0))
                                                         ((8 5 3) (8 5 0))
                                                         ((8 5 3) (5 0 3))
                                                         ((8 5 3) (8 0 0))
                                                         ((8 5 3) (8 0 0))
                                                         ((8 5 3) (8 0 3))) 
                "All possible successors of (8 0 0)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get-moves : NEListOfContent -> NEListOfLOI
;; GIVEN : A list of contents after the moves 
;; RETURNS : A list of differences in the two successive contents
;; EXAMPLES : See test below
;; STRATEGY : Structural decomposition on lst : NEListOfContent
(define (get-moves lst)
  (cond
    [(empty? (rest lst)) empty]
    [else 
     (cons (get-values (first lst) (second lst))
           (get-moves (rest lst)))]))

;; TESTS :
(begin-for-test
  (check-equal? (get-moves '((0 0 0) (8 0 0) (3 5 0) (0 5 0) (5 0 0) 
                                     (5 5 0) (8 2 0) (0 2 0) (2 0 0) 
                                     (2 5 0) (7 0 0) (7 5 0) (8 4 0)))
                '((-8 0 0) (5 -5 0) (3 0 0) (-5 5 0) (0 -5 0)
                           (-3 3 0) (8 0 0) (-2 2 0) (0 -5 0)
                           (-5 5 0) (0 -5 0) (-1 1 0)) 
                "check difference in successive moves"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get-values : Content Content -> NEListOf<Integer>
;; GIVEN : list of contents of first and second pitchers
;; RETURNS : a list of Numbers whose values are the subtraction of contents of
;; first pitcher and  contents of second pitcher respectively.
;; EXAMPLES : see tests below
;; STRATEGY : Structural Decomposition on one and two: NELONI 
(define (get-values one two)
  (cond
    [(empty? (rest one)) (list (- (first one) (first two)))]
    [else (cons (- (first one) (first two))
                (get-values (rest one) (rest two)))]))

;; TESTS :
(begin-for-test
  (check-equal? (get-values '(8 0 0) '(3 5 0)) (list 5 -5 0) 
                "difference in pitcher contents"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; final-moves : NEListOfLOI -> LOM
;; GIVEN : A nonempty list of LOI
;; RETURNS : The final moves which are supposed to be taken in order to reach 
;; the goal.
;; EXAMPLES : See test below
;; STRATEGY : Structural decomposition on lst : NEListOfLOI
(define (final-moves lst)
  (cond
    [(empty? (rest lst)) (cons (summing-it-up (first lst)) empty)]
    [else (cons (summing-it-up (first lst))
                (final-moves (rest lst)))]))

(begin-for-test
  (check-equal? (final-moves '((-8 0 0) (5 -5 0))) 
                (list (make-fill 1) (make-move 1 2))
                "The final moves supposed to be taken"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; summing-it-up : NELOI -> Move 
;; GIVEN : A non empty List of Integers
;; RETURNS : The move supposed to be taken it can be move, dump or fill.
;; EXAMPLES : See tests below.
;; STRATEGY : Function composition.
(define (summing-it-up lst)
  (cond
    [(< (sum-list lst) ZERO) (make-fill (check-position (sum-list lst) lst 
                                                        STARTING-INDEX))]
    [(> (sum-list lst) ZERO) (make-dump (check-position (sum-list lst) lst 
                                                        STARTING-INDEX))]
    [else (make-move (check-position (apply max lst) lst STARTING-INDEX) 
                     (check-position (apply min lst) lst STARTING-INDEX))]))

(begin-for-test
  (check-equal? (summing-it-up '(-8 0 0)) (make-fill 1) "Fill to capacity")
  (check-equal? (summing-it-up '(5 -5 0)) (make-move 1 2) 
                "Move from 1st to 2nd")
  (check-equal? (summing-it-up '(8 0 0)) (make-dump 1) "Dump all the contents"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sum-list : NELOI -> Integer
;; GIVEN : A list of integers
;; RETURNS : The sum of the list of integer
;; EXAMPLES : See test below
;; STRATEGY : HOFC
(define (sum-list lst)
  (apply + lst))

(begin-for-test
  (check-equal? (sum-list '(-8 0 0)) -8 "Check sum of the list passed"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check-position : PosInt ListOf<PosInt> PosInt -> PosInt
;; GIVEN : contents of a pitcher, list of contents of all pitchers, an index
;; value
;; RETURNS : the index in the list at which the given posInt is present.
;; EXAMPLES : see tests below
;; STRATEGY : Structural Decomposition on lst: ListOf<PosInt>
(define (check-position x lst index)
  (if (equal? x (first lst)) index
      (check-position x (rest lst) (add1 index))))

;; TESTS :
(begin-for-test
  (check-equal? (check-position 3 '(8 5 3) 1) 3 "finding position"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; GENERATING LIST OF MOVES
;; filtered-moves : PosInt PosInt -> LOM
;; GIVEN : No. of pitchers and index
;; RETURNS : All the moves including dump and fill where the index isn't the 
;; same thus removing redundant moves.
;; EXAMPLES : (filtered-moves 2 1) -> 
;; (list (make-move 2 1) (make-dump 1) (make-fill 1)
;;       (make-move 1 2) (make-dump 2) (make-fill 2))
;; STRATEGY : HOFC 
(define (filtered-moves len index)
  (filter
   ;; Move -> Boolean
   ;; GIVEN: A Move 
   ;; RETURNS : False iff the source and target of the move structure are same.
   (lambda (mve) (filtering-dump-fill-moves mve))
   (all-moves len index)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; filtering-dump-fill-moves : Move -> Boolean
;; GIVEN : A move
;; RETURNS : false iff the source and target of the move is same
;; else returns true.
;; EXAMPLE : See tests below.
;; STRATEGY : Structural decomposition on mve: Move
(define (filtering-dump-fill-moves mve)
  (cond
    [(move? mve) (not (= (move-src mve) (move-tgt mve)))]
    [(fill? mve) true]
    [(dump? mve) true]))

;; TESTS :
(begin-for-test 
  (check-equal? (filtering-dump-fill-moves (make-move 1 1)) false 
                "same target and source pitcher"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; all-moves : PosInt PosInt -> LOM
;; GIVEN : Length of the pitcher list and index
;; RETURNS : The list of all possible moves.
;; EXAMPLES : (all-moves 2 1) -> 
;; (list (make-move 1 1) (make-move 2 1) (make-dump 1) (make-fill 1)
;;       (make-move 1 2) (make-move 2 2) (make-dump 2) (make-fill 2))
;; HALTING-MEASURE : len - index + 1 
;; TERMINATING MEASURE: If the halting measure is zero, then the are no 
;;                      more moves and hence the program halts.
;; STRATEGY : General recursion
(define (all-moves len index)
  (cond
    [(> index len) empty]
    [else (append (build-moves index len) 
                  (all-moves len (add1 index)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; build-moves : PosInt PosInt -> LOM
;; GIVEN : Starting Index and No. of pitchers
;; RETURNS : List of moves
;; EXAMPLES : (build-moves 1 2) -> (list (make-move 1 1) (make-move 1 1)
;; (make-dump 1) (make-fill 1))
;; STRATEGY : HOFC
(define (build-moves index len)
  (append (build-list len
                      ;; PosInt -> MoveStructure
                      ;; GIVEN: a Positive Integer.
                      ;; RETURNS : Move structure with source index incremented.
                      (lambda (n) (make-move (+ n 1) index)))
          (list (make-dump index)) (list (make-fill index))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;