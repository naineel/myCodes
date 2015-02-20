;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
;; Imagine an infinite chessboard. The board begins at (1,1) and 
;; streaches out infinitely in two directions. 
;; We say that two positions on the board are adjacent iff they share a corner,
;; but not an edge. So positions (1,2) and (2,3) are adjacent, and so are (1,2) 
;; and (2,1), but positions (1,2) and (1,3) are not adjacent because they share 
;; an edge.We say a position p is adjacent to some
;; set of positions S iff it is adjacent to some position q in S.
;; The board also contains some blocks. Each block sits at exactly one position 
;; on the chessboard, and completely fills that position. 
;; On the chessboard, we have a robot and some blocks. The robot occupies a 
;; single square on the chessboard, as do the blocks. The robot can move any 
;; number of squares north, east, south, or west.
;; path function will give the path for the robot from the start position to 
;; the target position without passing over any blocks. and will return false
;; if there is no path possible
;; ALGORITHM :
;; Take the starting position and all its successors and put it into list of 
;; list of positions.
;; Find neighbours of all the positions in the newly formed list of positions.
;; Continue this till target node is reached or we get no neighbours.
;; Take the target node and find its neighbour in the last list of list 
;; of position 
;; then make neighbour the new target and continue doing this till the new 
;; target is the starting position.This gives the list of positions to follow 
;; from start position to end position
;; Now convert the list to plan by getting directions for each position and
;; its subsequent positions by measuring distances between the positions to get
;; the direction right.
;; This will finally give the list of moves to take from the start position to 
;; the end position to be taken by the robot.

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide path)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS :
;;
;; A Position is a 
;; -- (list PosInt PosInt)
;; (x y) represents the position x, y.
;;
;; template :
;; pos-fn : Position -> ??
;; (define (pos-fn pos)
;;  ...(first pos)
;;     (second pos)...)

;; A ListOf<Position>(LOP) is either
;; -- empty
;; -- (cons Position ListOf<Position>) 
;; template :
;; lop-fun : LOP -> ??
;; (define (lop-fun lp)
;;   (cond
;;     [(empty? lp) ...]
;;     [else (... (pos-fn (first lop)
;;                (lop-fun (rest lop))]))

;; MaybeListOf<Position> is either
;; --false
;; --(cons Position ListOf<Position>)

;; template :
;; maybe-fn : MaybeListOf<Position> -> ??
;; (define (maybe-fn mlop)
;;   (cond
;;     [(false? mlop) ...]
;;     [else ...(lop-fn mlop)]))

;; A Direction is one of
;; -- "north" interp : It is the north direction.
;; -- "east" interp : It is the east direction.
;; -- "south" interp : It is the south direction.
;; -- "west" interp : It is the west direction.
;;
;; direct-fn : Direction -> ??
;; (define (direct-fn dir)
;;   (cond
;;     [(string=? dir "north")...]
;;     [(string=? dir "south")...]
;;     [(string=? dir "east")...]
;;     [(string=? dir "west")...]))

;; A Move is a 
;; -- (list Direction PosInt)
;; Interp: a move of the specified number of steps in the indicated
;; direction. 
;; 
;; template :
;; mov-fun : Move -> ??
;; (define (mov-fun mov)
;;   (... (direction-fn(first mov))
;;        (second mov)))

;; A Plan is either
;; -- empty            interp:
;; -- (cons Move Plan) interp:

;; A Plan is a ListOf<Move>(LOM)
;; WHERE: the list does not contain two consecutive moves in the same
;; direction. 

;; template :
;; plan-fun : LOM -> ??
;; (define (plan-fun lom)
;;   (cond
;;     [(empty? lom) ...]
;;     [else (... (mov-fun (first lom))
;;                (plan-fun (rest lom)))]))

;; A Maybe<Plan> is one of
;; -- false
;; -- Plan
;; template :
;; maybe-plan-fun : MaybePlan -> ??
;; (define (maybe-plan-fun mplan)
;;   (cond
;;     [(false? mplan) ...]
;;     [else ...(plan-fun mplan)]))
;;; END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Examples of chessboard blocked positions
(define board0
  (list (list 1 2) (list 1 3) (list 2 3)
        (list 3 2) (list 3 4) (list 4 1)
        (list 4 4)))
(define board1 (list (list 4 1) (list 4 2) (list 4 3) (list 4 4)
                     (list 1 4) (list 2 4) (list 3 4)))
(define board2 (list
                (list 2 2) (list 3 2) (list 4 2) (list 2 3)
                (list 4 3) (list 2 4) (list 3 4) (list 4 4)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; path : Position Position ListOf<Position> -> Maybe<Plan>
;; GIVEN:
;; 1. the starting position of the robot,
;; 2. the target position that robot is supposed to reach
;; 3. A list of the blocks on the board
;; RETURNS: A plan that, when executed, will take the robot from
;; the starting position to the target position without passing over any
;; of the blocks, or false if no such sequence of moves exists.
;; Examples : (path (list 1 2) (list 3 3) (list (list 1 1) (list 2 4)) 
;; --> (list (list "south" 1)(list "east" 2))
;; STRATEGY : general recursion  
(define (path start-pos end-pos obstacles-set)
  (path-from-start-to-target (final-list-of-positions-to-goal start-pos end-pos 
                                                              obstacles-set)))

;; final-list-of-positions-to-goal : Position Position ListOf<Position> -> 
;; Maybe<LoP>
;; GIVEN : Start position, Target position, block positions
;; RETURNS : empty iff the start position is the same as end position.
;; else will return the list of positions to target position
;; Examples : (final-list-of-positions-to-goal (list 1 1) (list 1 1) empty) ->
;; empty.
;; STRATEGY : Function composition
(define (final-list-of-positions-to-goal start-pos end-pos obstacles-set)
  (if (equal? start-pos end-pos)
      empty
      (final-list-of-positions-to-goal-when-unequal 
       start-pos end-pos obstacles-set
       (maximum-x start-pos end-pos obstacles-set)
       (maximum-y start-pos end-pos obstacles-set))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; final-list-of-positions-to-goal-when-unequal : Position Position 
;; ListOf<Position> -> MaybeListOf<Position>
;; GIVEN : A start position , target position and set of obstacles.
;; RETURNS : false iff the target node is not reachable from the start position
;; else returns the list of positions to goal.
;; Examples : (final-list-of-positions-to-goal-when-unequal (list 1 1)
;; (list 5 5) board2 5 5) -> false
;; STRATEGY : Function composition
(define (final-list-of-positions-to-goal-when-unequal start-pos end-pos 
                                                      obstacles-set 
                                                      x-max y-max)
  (if (false? (possible-to-reach? start-pos end-pos obstacles-set x-max y-max))
      false
      (final-list-to-goal start-pos end-pos obstacles-set
                          (possible-to-reach? start-pos end-pos obstacles-set
                                              x-max y-max)
                          (list end-pos) x-max y-max)))

;; final-list-to-goal : Position Position ListOf<Position> ListOf<Position> 
;; ListOf<Position> PosInt PosInt -> ListOf<Position>
;; GIVEN : A starting position,Target position, list of blocks,maximum x and y 
;; limit of the chessboard.
;; WHERE :
;; lop is the sublist of (list (list position)) accessible from start position.
;; cuurent-path-list is the path list upto a certain position on the board.
;; RETURNS : List of positions giving the path from start to end position.
;; Example : (final-list-to-goal (list 1 1) (list 2 2) empty (list (list 1 1)) 
;; empty 5 5) -> ((1 1))
;; HALTING MEASURE : When starting position is the pre-target position
;; STRATEGY : General recursion
(define (final-list-to-goal start-pos end-pos obstacles-set lop 
                            current-path-list x-max y-max)
  (cond
    [(empty? lop) current-path-list]
    [else
     (local
       ((define new-target (reachable-target-from-successor start-pos end-pos 
                                                            obstacles-set 
                                                            (first lop)
                                                            x-max y-max)))
       (cond
         [(equal? start-pos new-target) (cons start-pos current-path-list)]
         [else (final-list-to-goal start-pos new-target obstacles-set
                                   (rest lop)
                                   (cons new-target current-path-list)
                                   x-max y-max)]))]))

(begin-for-test
  (check-equal? 
   (final-list-to-goal (list 1 1) (list 4 4) board1 empty empty 5 5) 
   empty))


;; reachable-target-from-successor : Position Position ListOf<Position> 
;; ListOf<Position> PosInt PosInt -> Position
;; GIVEN : A start position, current target ,a list of blocks, first 
;; list of list of positions,maximum x and y limit.
;; RETURNS : A position which is reachable from the start position 
;; and current targetposition
;; Examples : See test case below
;; STRATEGY : Structural decomposition on 1st-lop : List

(define (reachable-target-from-successor start-pos current-target obstacles-set 
                                         first-list-position x-max y-max)
  (cond
    [(empty? first-list-position) start-pos]
    [else (if (and
               (my-member? (first first-list-position)
                           (filtering-the-list current-target obstacles-set 
                                               x-max y-max))
               (list? (possible-to-reach? start-pos (first first-list-position) 
                                          obstacles-set x-max y-max)))
              (first first-list-position)
              (reachable-target-from-successor start-pos current-target 
                                               obstacles-set
                                               (rest first-list-position) 
                                               x-max y-max))]))

;; possible-to-reach? : Position Position ListOf<Position> PosInt PosInt -> 
;; MaybeListOf<Position>s
;; GIVEN : A start position, end position, List of blocks on board, 
;; board x and y limits
;; RETURNS : false iff the path doesn't exist.
;; Examples : See tests below.
;; STRATEGY : Function composition
(define (possible-to-reach? start-pos end-pos obstacles-set x-max y-max)
  (reachable? (list start-pos) end-pos obstacles-set (list (list start-pos)) 
              x-max y-max))


;; TESTS
(begin-for-test
  (check-equal?
   (possible-to-reach? (list 2 2) (list 3 3) board0 5 5)
   false)
  (check set-equal?
         (possible-to-reach? (list 3 3) (list 1 4) board0 5 5)
         (list
          (list (list 1 5) (list 2 4))
          (list (list 2 5))
          (list (list 3 5))
          (list (list 4 5))
          (list (list 5 5) (list 5 1))
          (list (list 5 2) (list 5 4))
          (list (list 5 3) (list 4 2))
          (list (list 4 3))
          (list (list 3 3)))))

;; reachable? : ListOf<Position> Position ListOf<Position> ListOf<Position> 
;; PosInt PosInt -> MaybeListOf<Position>
;; GIVEN : new list of positions which are not blocked or explored, 
;; Target position, Set of obstacles, List of finalised 
;; positions, maximum x and y limit 
;; RETURNS : false iff the list of successors are empty
;; else will return a list of all successor positions
;; Examples : (reachable? (list (list 1 1)) (list 5 5) empty empty 6 6) ->
;; (((6 3) (5 4) (4 5) (3 6)) ((2 6) (3 5) (4 4) (5 3) (6 2))
;; ((6 1) (5 2) (4 3) (3 4) (2 5) (1 6))
;; ((1 5) (2 4) (3 3) (5 1) (4 2))
;; ((4 1) (3 2) (2 3) (1 4))
;; ((1 3) (1 1) (3 1) (2 2))
;; ((2 1) (1 2)))
;; HALTING MEASURE : Successors are empty or the target is present in the 
;; candidates list.
;; STRATEGY : General recursion
(define (reachable? new end-pos obstacles-set lops-till-now x-max y-max)
  (local
    ((define successors (check-searched-successors
                         (all-the-successors-after-blocked 
                          new obstacles-set x-max y-max)
                         lops-till-now)))
    (cond
      [(empty? successors) false]
      [(my-member? end-pos successors) lops-till-now]
      [else (reachable? successors end-pos obstacles-set 
                        (cons successors lops-till-now)
                        x-max y-max)])))

;; check-searched-successors : ListOf<Position> 
;; GIVEN : A list of successors and a list of position sets
;; RETURNS : A l
;; Examples : (check-searched-successors '((5 4) (3 6)) 
;; '((6 3) (4 5) (3 6) (5 4))) -> ((5 4) (3 6))
(define (check-searched-successors neighbors lops)
  (set-diff neighbors (remove-duplicate lops)))

;; remove-duplicates : ListOf<Position>Set -> ListOf<Position>
;; GIVEN : A List of positions 
;; RETURNS : A list of positions with the common ones removed.
;; Example : (remove-duplicate '(((6 3) (5 4) (4 5) (3 6) (5 4))) ->
;; ((6 3) (5 4) (4 5) (3 6))
;; STRATEGY : HOFC
(define (remove-duplicate lops)
  (foldl
   (lambda(lop lop-so-far)
     (set-union lop lop-so-far))
   empty
   lops))

;; all-the-successors-after-blocked : ListOf<Position> ListOf<Position> PosInt 
;; PosInt -> ListOf<Position>
;; GIVEN : List Of positions, list of blocks, maximum x and y coordinates
;; RETURNS : All the successors of the given list of positions which are not 
;; blocked by the list of blocks
;; Examples :
;; (all-the-successors-after-blocked (list (list 3 3) (list 2 2)) 
;; board0 5 5) => (list (list 2 1) (list 4 3))
(define (all-the-successors-after-blocked lop block-lop x-max y-max)
  (foldl
   ;; Position ListOf<Position> -> ListOf<Position>
   ;; RETURNS : a list of positions which is not included in the given blocked
   ;; lop and is neighbor to the given position
   (lambda(p ps)
     (set-union (filtering-the-list p block-lop x-max y-max) ps))
   empty
   lop))

;; filtering-the-list : Position ListOf<Position> PosInt PosInt -> 
;; ListOf<Position>
;; GIVEN : a position, a list of blocks, and board x y maximum
;; RETURNS : a set of positions not included in the blocked position-set 
;; which is the neighbors of the given position
;; Examples : See tests below.
;; STRATEGY : HOFC
(define (filtering-the-list pos block-lop x-max y-max)
  (filter
   ; Position -> Boolean
   ; RETURNS : true iff the given position's neighbors is NOT
   ; in the given position-set
   (lambda(p)
     (not (my-member? p block-lop)))
   (get-successors (first pos) (second pos) x-max y-max)))

;; TESTS:
(begin-for-test
  (check set-equal?
         (filtering-the-list (list 1 1) board0 5 5)
         (list (list 2 1))
         "filtering-the-list of (1,1)")
  (check set-equal?
         (filtering-the-list (list 5 1) board0 5 5)
         (list (list 5 2))
         "filtering-the-list of (5,1)")
  (check set-equal?
         (filtering-the-list (list 1 5) board0 5 5)
         (list (list 1 4) (list 2 5))
         "filtering-the-list of (1,5)")
  (check set-equal?
         (filtering-the-list (list 5 5) board0 5 5)
         (list (list 5 4) (list 4 5))
         "filtering-the-list of (5,5)")
  
  (check set-equal?
         (filtering-the-list (list 1 4) board0 5 5)
         (list (list 2 4) (list 1 5))
         "filtering-the-list of (1,4)") 
  (check set-equal?
         (filtering-the-list (list 2 1) board0 5 5)
         (list (list 1 1) (list 3 1) (list 2 2))
         "filtering-the-list of (2,1)")
  (check set-equal?
         (filtering-the-list (list 5 2) board0 5 5)
         (list (list 5 1) (list 4 2) (list 5 3))
         "filtering-the-list of (5,2)")
  (check set-equal?
         (filtering-the-list (list 3 5) board0 5 5)
         (list (list 2 5) (list 4 5))
         "filtering-the-list of (3,5)")
  
  (check set-equal?
         (filtering-the-list (list 2 2) board0 5 5)
         (list (list 2 1))
         "filtering-the-list of (2,2)")
  (check set-equal?
         (filtering-the-list (list 4 3) board0 5 5)
         (list (list 3 3) (list 4 2) (list 5 3))
         "filtering-the-list of (4,3)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get-successors : PosInt PosInt PosInt PosInt -> ListOf<Position>
;; GIVEN : position x and y, and board x and y boundary
;; RETURNS : All successors of the given position
;; Examples : (get-successors 2 3 5 5) =>
;; (list (list 1 3) (list 3 3) (list 2 2) (list 2 4))
;; STRATEGY : Cases on x,y,x-max,y-max : PosInt
(define (get-successors x y x-max y-max)
  (cond
    [(and (= x 1) (= y 1)) (list (list (+ x 1) y)
                                 (list x (+ y 1)))]
    [(and (= x 1) (= y y-max)) (list (list x (- y 1))
                                     (list (+ x 1) y))]
    [(and (= x x-max) (= y 1)) (list (list (- x 1) y)
                                     (list x (+ y 1)))]
    [(and (= x x-max) (= y y-max)) (list (list (- x 1) y)
                                         (list x (- y 1)))]   
    [(and (= x 1) (< 1 y y-max)) (list (list (+ x 1) y)
                                       (list x (- y 1))
                                       (list x (+ y 1)))]
    [(and (= x x-max) (< 1 y y-max)) (list (list (- x 1) y)
                                           (list x (- y 1))
                                           (list x (+ y 1)))]
    [(and (< 1 x x-max) (= y 1)) (list (list (- x 1) y)
                                       (list (+ x 1) y)
                                       (list x (+ y 1)))]
    [(and (< 1 x x-max) (= y y-max)) (list (list (- x 1) y)
                                           (list (+ x 1) y)
                                           (list x (- y 1)))]
    [else (get-all-successors x y)]))

;; get-all-successors : Position -> ListOf<Position>
;; GIVEN : A position with x and y co-ordinates.
;; RETURNS : All successors of the given position
;; Examples : (get-all-successors 1 2) -> (list (list 0 2) (list 2 2) (list 1 1)
;; (list 1 3))
;; STRATEGY : Function composition
(define (get-all-successors x y)
  (list (list (- x 1) y)
        (list (+ x 1) y)
        (list x (- y 1))
        (list x (+ y 1))))

;; maximum-x : Position Position ListOf<Position> -> PosInt
;; maximum-y : Position Position ListOf<Position> -> PosInt
;; RETURNS : The maximum x and y coordinate among the start ,target and list 
;; of block positions
;; Examples :
;; (maximum-x (list 6 7) (list 1 7) board0) => 6
;; (maximum-y (list 10 8) (list 2 5) board0) => 10
;; STRATEGY : HOFC
(define (maximum-x start-pos end-pos lop)
  (+ 1 (max (first start-pos) (first end-pos) (maximum-value first lop))))

(define (maximum-y start-pos end-pos lop)
  (+ 1 (max (second start-pos) (second end-pos) (maximum-value second lop))))

;; maximum-value : Function ListOf<Position> -> PosInt
;; GIVEN  : first and list of positions
;; RETURNS : the maximum value of position
;; Examples : (maximum-value first (list (list 2 3) (list 3 4)) -> 3
;; STRATEGY : HOFC
(define (maximum-value fn lop)
  (foldr
   ; Position -> PosInt
   ; RETURNS : maximum position
   (lambda(p m)
     (max m (fn p)))
   1
   lop))

;; TESTS
(begin-for-test
  (check-equal? (maximum-x (list 1 4) (list 4 2) board0)
                5)
  (check-equal? (maximum-y (list 1 4) (list 4 2) board0)
                5))

;; set-diff : SetOf<X> SetOf<X> -> setOf<X>
;; GIVEN : two sets
;; RETURNS : a sets contains the members that is in the first set, but not
;; in the second set.
;; Examples : (set-diff (list 1 2 3 4) (list 3 4)) => (list 1 2)
;; STRATEGY : HOFC
(define (set-diff set1 set2)
  (filter
   ; X -> Boolean
   ; RETURNS : true iff the x is not in set2
   (lambda (x) (not (my-member? x set2)))
   set1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; path-from-start-to-target : ListOf<Position> -> ListOf<Position>
;; GIVEN : A list of position to be folowed from start position to target 
;; position.
;; RETURNS : The path list from start to target position
;; Examples : (path-from-start-to-target (list (list 1 1) (list 1 2))) -> 
;; (("south" 1)) 
;; STRATEGY : Function composition
(define (path-from-start-to-target pos-list)
  (cond
    [(false? pos-list) pos-list]
    [else (path-to-plan pos-list empty empty)]))

;; path-to-plan : ListOf<Position> Position ListOf<Position> -> ListOf<Position>
;; GIVEN : A list of positions, Previous move taken and the final list of moves
;; WHERE : lastMove is the previous move taken on the list of positions
;; RETURNS : The path list from start to target position
;; Examples : (path-to-plan (list (list 1 1) (list 1 2)) empty empty) -> 
;; (("south" 1)) 
;; HALTING MEASURE : Position list is empty or rest of the list is empty
;; STRATEGY : General recursion
(define (path-to-plan pos-list lastMove finalList)
  (cond
    [(empty? pos-list) empty]
    [(empty? (rest pos-list)) (append finalList (list lastMove))]
    [else 
     (local
       ((define current-direction 
          (get-current-direction-from-position (first pos-list) 
                                               (second pos-list))))
       (update-path current-direction pos-list lastMove finalList))]))

;; get-current-direction-from-position : Position Position -> Direction
;; GIVEN : Two positions on the chess board
;; RETURNS : The direction of the move from the second position to the first.
;; Examples : (get-current-direction-from-position (list 1 1) (list 1 2)) ->
;; "south"
;; STRATEGY : Function composition
(define (get-current-direction-from-position pos1 pos2)
  (direction (- (first pos1) (first pos2))
             (- (second pos1) (second pos2))))

;; direction : Integer Integer -> Direction
;; GIVEN : X-coordinate difference between two positions and 
;; Y-coordinate difference between the two positions.
;; RETURNS : The direction of the move
;; EXAMPLES : (direction 1 0) -> "east"
;; STRATEGY : Function composition
(define (direction posx posy)
  (cond
    [(and (= posx 1) (= posy 0)) "east"]
    [(and (= posx 0) (= posy 1)) "south"]
    [(and (= posx 0) (= posy -1)) "north"]
    [(and (= posx -1) (= posy 0)) "west"]))

;; update-path : Direction ListOf<Position> Position ListOf<Position> -> 
;; GIVEN : A direction, list of positions, previous move taken and 
;; the final list of positions.
;; RETURNS :  updated path
;; Examples :see tests below
;; STRATEGY : Structural decomposition on 
(define (update-path dir pos-list lastMove finalList)
  (cond
    [(string=? dir "north") 
     (add-to-path "north" pos-list lastMove finalList)]
    [(string=? dir "west") 
     (add-to-path "west" pos-list lastMove finalList)]
    [(string=? dir "east") 
     (add-to-path "east" pos-list lastMove finalList)]
    [(string=? dir "south") 
     (add-to-path "south" pos-list lastMove finalList)]))

;; add-to-path : Direction ListOf<Position> Position ListOf<Position> -> Plan
;; GIVEN : A direction, a list of positions , the previous move and the final 
;; list of positions
;; WHERE :
;; LastMove is updated with the given direction and passed onto the path-to-plan
;; function.
;; RETURNS :  The list from start to end
;; Examples : (add-to-path "north" (list 1 1) empty empty) -> (("north" 1))
;; STRATEGY : Function Composition
(define (add-to-path dir pos-list lastMove finalList)
  (if (empty? lastMove)
      (path-to-plan (rest pos-list) (list dir 1) finalList)
      (add-to-path-with-last-move dir pos-list lastMove finalList)))

;; add-to-path-with-lastmove : Direction ListOf<Position> Position 
;; ListOf<Position> -> Plan
;; GIVEN : A direction, a list of positions , the previous move and the final 
;; list of positions
;; WHERE :
;; pos-list is the list of positions to be taken from start to end
;; lastMove is changed according to the list of positions
;; finallist is updated if the previous direction is different from the next 
;; direction 
;; RETURNS : The move incremented if the previous move had the same direction
;; as the current move else a new move was added to the final list.
;; Examples : (add-to-path-with-last-move "north" (list 2 2) '("north" 1) empty)
;; -> (("north" 2))
;; STRATEGY :
(define (add-to-path-with-last-move dir pos-list lastMove finallist)
  (if (same-direction-as-previous? (first lastMove) dir)
      (path-to-plan (rest pos-list) (increment-current-direction lastMove) 
                    finallist)
      (path-to-plan (rest pos-list) (list dir 1) 
                    (append finallist (list lastMove)))))

;; same-direction-as-previous? : Direction Direction -> Boolean
;; GIVEN : The direction of the previous move and the current move
;; RETURNS : True iff the previous direction matches the current direction.
;; Examples : (same-direction-as-previous? "north" "north") -> True
;; STRATEGY : Function composition
(define (same-direction-as-previous? lastmoveDir dir)
  (string=? lastmoveDir dir))

;; increment-current-direction : Move -> Move
;; GIVEN : A move
;; WHERE : the previous move is the same as the current move
;; RETURNS : The previous move with the number of steps in the specified 
;; direction incremented.
;; Examples : (increment-current-direction '("north" 1)) -> ("north" 2)
;; STRATEGY : Function composition
(define (increment-current-direction lastMove)
  (list (first lastMove)
        (+ 1 (second lastMove))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Tests for path
(begin-for-test
  (check-equal? (path (list 1 1) (list 1 1) empty) empty 
                "Start pos is same as end pos")
  (check-equal? (path (list 1 1) (list 3 3) board0) false)
  (check-equal? (path (list 3 3) (list 1 4) board0) 
                '(("west" 2) ("north" 2) ("east" 4) ("south" 1)))
  (check-equal? (path (list 5 5) (list 1 1) board1) false)
  (check-equal? (path (list 1 1) (list 5 5) board1) false)
  (check-equal? (path (list 1 1) (list 5 5) empty) 
                '(("west" 2) ("north" 2) ("west" 1) ("north" 1) ("west" 1) 
                             ("north" 1)))
  (check-equal? (path (list 1 1) (list 3 3) board2) false) 
  
  (check-equal? (path (list 3 3) (list 1 1) board2) false)
  (check-equal? (path (list 11 11) (list 1 1) empty) 
                '(("east" 2) ("south" 2)
                             ("east" 1) ("south" 1)
                             ("east" 1) ("south" 1)
                             ("east" 1) ("south" 1)
                             ("east" 1) ("south" 1)
                             ("east" 1) ("south" 1)
                             ("east" 1) ("south" 1) 
                             ("east" 1) ("south" 1) ("east" 1) ("south" 1)))
  (check-equal? (path (list 1 5) (list 5 1) 
                      (list (list 1 1) (list 2 2) (list 3 3) (list 4 4) 
                            (list 5 5) (list 6 6))) '(("west" 3)
                                                      ("north" 1)
                                                      ("west" 1)
                                                      ("north" 1)
                                                      ("west" 2)
                                                      ("south" 4)
                                                      ("east" 1)
                                                      ("south" 1)
                                                      ("east" 1)
                                                      ("south" 1))))