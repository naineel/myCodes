;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname two-bouncing-cats) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")))))
;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
;reader(lib "htdp-beginner-reader.ss" "lang")((modname two-bouncing-cats) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; There are two bouncing cats in the scene.
;; The user can pause/unpause the cats with the space bar.
;; User can change the direction of the cat after selecing the cat
;; and pressing up,down,left and right arrow on keyboard. 

;; start with (main 0)

(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide 
 initial-world
 world-after-tick
 world-after-mouse-event
 world-after-key-event
 world-cat1
 world-cat2
 world-paused?
 cat-x-pos
 cat-y-pos
 cat-selected?
 cat-north?
 cat-east?
 cat-south?
 cat-west?
 )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; MAIN FUNCTION.
;; main : Number -> World
;; GIVEN: the initial y-position of the cats
;; EFFECT: runs the simulation, starting with the cats falling
;; RETURNS: the final state of the world
(define (main x)
  (big-bang (initial-world 100)
            (on-tick world-after-tick 0.5)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; CONSTANTS

(define CAT-IMAGE (bitmap "cat.png"))

;; how fast the cat falls, in pixels/tick
(define CATSPEED 8)

;; dimensions of the canvas
(define CANVAS-WIDTH 450)
(define CANVAS-HEIGHT 400)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
(define CAT1-X-COORD (/ CANVAS-WIDTH 3))
(define CAT2-X-COORD (* 2 CAT1-X-COORD))

;; dimensions of the cat
(define HALF-CAT-WIDTH  (/ (image-width  CAT-IMAGE) 2))
(define HALF-CAT-HEIGHT (/ (image-height CAT-IMAGE) 2))

(define BUFFER 1.5)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; DATA DEFINITIONS

(define-struct world (cat1 cat2 paused?))
;; A World is a (make-world Cat Cat Boolean)
;; cat1 and cat2 are the two cats
;; paused? describes whether or not the world is paused

;; template:
;; world-fn : World -> ??
;; (define (world-fn w)
;;   (... (world-cat1 w) (world-cat2 w) (world-paused? w)))

;; A direction is one of
;; -- "North" Interp: Cat is moving in the north direction
;; -- "South" Interp: Cat is moving in the south direction
;; -- "East" Interp: Cat is moving in the east direction
;; -- "West" Interp: Cat is moving in the west direction

;;template :
;; direction-fn : Direction -> ??
;; (define (direction-fn f)
;;  (cond
;;    [(string=? f "North" )...]
;;    [(string=? f "South" )...]
;;    [(string=? f "East" )...]
;;    [(string=? f "West" )...]))

(define-struct cat (x-pos y-pos selected? direction))
;; A Cat is a (make-cat Integer Integer Boolean direction)
;; Interpretation: 
;; x-pos, y-pos give the position of the cat. 
;; selected? describes whether or not the cat is selected.
;; direction is the specified direction in which the cat is moving

;; template:
;; cat-fn : Cat -> ??
;(define (cat-fn c)
; (... (cat-x-pos c) (cat-y-pos c) (cat-selected? c) (cat-direction c())

;; different cat constants
(define CAT-IN-NORTH-50 (make-cat 50 50 false "North"))
(define cat-in-north-after-tick (make-cat 58 58 false "North"))
(define CAT-IN-SOUTH-50 (make-cat 50 50 false "South"))
(define CAT-IN-WEST-50 (make-cat 50 50 false "West"))
(define CAT-IN-EAST-50 (make-cat 50 50 false "East"))

(define CAT-IN-NORTH-SELECTED-50 (make-cat 50 50 true "North"))
(define CAT-IN-SOUTH-SELECTED-50 (make-cat 50 50 true "South"))
(define CAT-IN-WEST-SELECTED-50 (make-cat 50 50 true "West"))
(define cat-in-east-selected-50 (make-cat 50 50 true "East"))

(define cat-in-north-0(make-cat 0 0 false "North"))
(define cat-in-south-400 (make-cat 400 400 false "South"))
(define cat-in-west-0 (make-cat 0 0 false "West"))
(define cat-in-east-450 (make-cat 450 450 false "East"))

(define cat-in-north-selected-0(make-cat 0 0 true "North"))
(define cat-in-south-selected-400 (make-cat 400 400 true "South"))
(define cat-in-west-selected-0 (make-cat 0 0 true "West"))
(define cat-in-east-selected-450 (make-cat 450 450 true "East"))

(define cat-beyond-northwest-corner-north (make-cat -100 -100 true "North"))
(define cat-beyond-northwest-corner-south (make-cat -100 -100 true "South"))
(define cat-beyond-northwest-corner-east (make-cat -100 -100 true "East"))
(define cat-beyond-northwest-corner-west (make-cat -100 -100 true "West"))

(define cat-beyond-southwest-corner-north (make-cat -100 500 true "North"))
(define cat-beyond-southwest-corner-south (make-cat -100 500 true "South"))
(define cat-beyond-southwest-corner-east (make-cat -100 500 true "East"))
(define cat-beyond-southwest-corner-west (make-cat -100 500 true "West"))

(define cat-beyond-northeast-corner-north (make-cat 500 -100 true "North"))
(define cat-beyond-northeast-corner-south (make-cat 500 -100 true "South"))
(define cat-beyond-northeast-corner-east (make-cat 500 -100 true "East"))
(define cat-beyond-northeast-corner-west (make-cat 500 -100 true "West"))

(define cat-beyond-southeast-corner-north (make-cat 500 500 true "North"))
(define cat-beyond-southeast-corner-south (make-cat 500 500 true "South"))
(define cat-beyond-southeast-corner-east (make-cat 500 500 true "East"))
(define cat-beyond-southeast-corner-west (make-cat 500 500 true "West"))

(define cat-beyond-north-going-north (make-cat 100 -100 true "North"))
(define cat-beyond-north-going-south (make-cat 100 -100 true "South"))
(define cat-beyond-north-going-east (make-cat 100 -100 true "East"))
(define cat-beyond-north-going-west (make-cat 100 -100 true "West"))

(define cat-beyond-south-going-north (make-cat 100 600 true "North"))
(define cat-beyond-south-going-south (make-cat 100 600 true "South"))
(define cat-beyond-south-going-east (make-cat 100 600 true "East"))
(define cat-beyond-south-going-west (make-cat 100 600 true "West"))

(define cat-beyond-east-going-north (make-cat 600 100 true "North"))
(define cat-beyond-east-going-south (make-cat 600 100 true "South"))
(define cat-beyond-east-going-east (make-cat 600 100 true "East"))
(define cat-beyond-east-going-west (make-cat 600 100 true "West"))

(define cat-beyond-west-going-north (make-cat -100 100 true "North"))
(define cat-beyond-west-going-south (make-cat -100 100 true "South"))
(define cat-beyond-west-going-east (make-cat -100 100 true "East"))
(define cat-beyond-west-going-west (make-cat -100 100 true "West"))



;;; END DATA DEFINITIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-tick : World -> World
;; GIVEN: a world w
;; RETURNS: the world that should follow w after a tick.
;; STRATEGY: structural decomposition on w : World
;; Examples : see tests below.

(define (world-after-tick w)
  (if (world-paused? w)
    w
    (make-world
      (cat-after-tick (world-cat1 w))
      (cat-after-tick (world-cat2 w))
      (world-paused? w))))

;; cat-after-tick : Cat -> Cat
;; GIVEN: a cat c
;; RETURNS: the state of the given cat after a tick if it were in an
;; unpaused world.
;; STRATEGY: structural decomposition on c : Cat
;; Examples: See tests below
(define (cat-after-tick c)
  (cond
    [(string=? (cat-direction c) "North") (cat-after-tick-north (cat-x-pos c) (cat-y-pos c)
                                                                (cat-selected? c) (cat-direction c))]
    [(string=? (cat-direction c) "South") (cat-after-tick-south (cat-x-pos c) (cat-y-pos c) 
                                                                (cat-selected? c) (cat-direction c))]
    [(string=? (cat-direction c) "East") (cat-after-tick-east (cat-x-pos c) (cat-y-pos c) 
                                                              (cat-selected? c) (cat-direction c))]
    [(string=? (cat-direction c) "West") (cat-after-tick-west (cat-x-pos c) (cat-y-pos c)
                                                              (cat-selected? c) (cat-direction c))]))

;; cat-after-tick-south : Integer Integer Boolean String -> Cat
;; cat-after-tick-north : Integer Integer Boolean String-> Cat
;; cat-after-tick-east : Integer Integer Boolean String -> Cat
;; cat-after-tick-west : Integer Integer Boolean String -> Cat
;; GIVEN: a position and a value for selected?
;; RETURNS: the cat that should follow one in the given position in an
;; unpaused world 
;; STRATEGY: function composition

(define (cat-after-tick-south x-pos y-pos selected? d)
  (if selected?
    (make-cat x-pos y-pos selected? d)
    (y-limit-for-cat-going-south x-pos y-pos selected? d)))


(define (y-limit-for-cat-going-south x y selected? d)
  (if(<= (+ (+ HALF-CAT-HEIGHT y) CATSPEED) CANVAS-HEIGHT) 
     (make-cat x (+ y CATSPEED) selected? d)
     (make-cat x (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) selected? "North")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
(define (cat-after-tick-north x-pos y-pos selected? d)
  (if selected?
    (make-cat x-pos y-pos selected? d)
    (y-limit-for-cat-going-north x-pos y-pos selected? d)))


(define (y-limit-for-cat-going-north x y  selected? d)
  (if(>= (- (- y HALF-CAT-HEIGHT) CATSPEED) 0) 
     (make-cat x (- y CATSPEED) selected? d)
     (make-cat x (+ BUFFER HALF-CAT-HEIGHT) selected? "South")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (cat-after-tick-east x-pos y-pos selected? d)
  (if selected?
    (make-cat x-pos y-pos selected? d)
    (x-limit-for-cat-going-east x-pos y-pos selected? d)))


(define (x-limit-for-cat-going-east x y  selected? d)
  (if(<= (+ (+ HALF-CAT-WIDTH x) CATSPEED) CANVAS-WIDTH) 
     (make-cat (+ x CATSPEED) y selected? d)
     (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) y selected? "West")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (cat-after-tick-west x-pos y-pos selected? d)
  (if selected?
    (make-cat x-pos y-pos selected? d)
    (x-limit-for-cat-going-west x-pos y-pos selected? d)))


(define (x-limit-for-cat-going-west x y  selected? d)
  (if(>= (- (- x HALF-CAT-WIDTH) CATSPEED) 0) 
     (make-cat (- x CATSPEED) y selected? d)
     (make-cat (+ BUFFER HALF-CAT-WIDTH) y selected? "East")))


(begin-for-test
;Test to check the mouse being in all directions i.e. North,South,East and West after one tick in the world.
(check-equal? (world-after-tick (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false)) (make-world (make-cat 50 60 false "South") (make-cat 50 58 false "South") false))
(check-equal? (world-after-tick (make-world CAT-IN-SOUTH-50 CAT-IN-WEST-50 false)) (make-world (make-cat 50 58 false "South") (make-cat 42 50 false "West") false))
(check-equal? (world-after-tick (make-world CAT-IN-NORTH-50 CAT-IN-EAST-50 false)) (make-world (make-cat 50 60 false "South") (make-cat 58 50 false "East") false))

(check-equal? (world-after-tick (make-world CAT-IN-WEST-50 CAT-IN-NORTH-50 false)) (make-world (make-cat 42 50 false "West") (make-cat 50 60 false "South") false))
(check-equal? (world-after-tick (make-world CAT-IN-WEST-50 CAT-IN-SOUTH-50 false)) (make-world (make-cat 42 50 false "West") (make-cat 50 58 false "South") false))
(check-equal? (world-after-tick (make-world CAT-IN-WEST-50 CAT-IN-EAST-50 false)) (make-world (make-cat 42 50 false "West") (make-cat 58 50 false "East") false)) 

(check-equal? (world-after-tick (make-world CAT-IN-SOUTH-50 CAT-IN-NORTH-50 false)) (make-world (make-cat 50 58 false "South") (make-cat 50 60 false "South") false))
(check-equal? (world-after-tick (make-world CAT-IN-SOUTH-50 CAT-IN-WEST-50 false)) (make-world (make-cat 50 58 false "South") (make-cat 42 50 false "West") false))
(check-equal? (world-after-tick (make-world CAT-IN-SOUTH-50 CAT-IN-EAST-50 false)) (make-world (make-cat 50 58 false "South") (make-cat 58 50 false "East") false))

(check-equal? (world-after-tick (make-world CAT-IN-EAST-50 CAT-IN-NORTH-50 false)) (make-world (make-cat 58 50 false "East") (make-cat 50 60 false "South") false))
(check-equal? (world-after-tick (make-world CAT-IN-EAST-50 CAT-IN-SOUTH-50 false)) (make-world (make-cat 58 50 false "East") (make-cat 50 58 false "South") false))
(check-equal? (world-after-tick (make-world CAT-IN-EAST-50 CAT-IN-WEST-50 false)) (make-world (make-cat 58 50 false "East") (make-cat 42 50 false "West") false))

(check-equal? (world-after-tick (make-world cat-in-north-0 cat-in-west-0 false)) (make-world (make-cat 0 60 false "South") (make-cat 39 0 false "East") false))
(check-equal? (world-after-tick (make-world cat-in-south-400 cat-in-east-450 false)) (make-world (make-cat 400 340 false "North") (make-cat 411 450 false "West") false))

(check-equal? (world-after-tick (make-world cat-in-north-selected-0 cat-in-west-selected-0 true)) (make-world (make-cat 0 0 true "North") (make-cat 0 0 true "West") true))
(check-equal? (world-after-tick (make-world cat-in-south-selected-400 cat-in-east-selected-450 true)) (make-world (make-cat 400 400 true "South") (make-cat 450 450 true "East") true))
(check-equal? (world-after-tick (make-world CAT-IN-NORTH-SELECTED-50 CAT-IN-WEST-SELECTED-50 true)) (make-world (make-cat 50 50 true "North") (make-cat 50 50 true "West") true))
(check-equal? (world-after-tick (make-world CAT-IN-SOUTH-SELECTED-50 cat-in-east-selected-50 true)) (make-world (make-cat 50 50 true "South") (make-cat 50 50 true "East") true))
(check-equal? (cat-after-tick-north 50 50 true "North") (make-cat 50 50 true "North"))

(check-equal? (cat-after-tick-south 50 50 true "South") (make-cat 50 50 true "South"))
(check-equal? (cat-after-tick-east 50 50 true "East") (make-cat 50 50 true "East"))
(check-equal? (cat-after-tick-west 50 50 true "West") (make-cat 50 50 true "West"))
(check-equal? (cat-after-tick-north 100 100 false "North") (make-cat 100 92 false "North")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-to-scene : World -> Scene
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: See tests below.
;; STRATEGY: structural decomposition w : World
(define (world-to-scene w)
  (place-cat
    (world-cat1 w)
    (place-cat
      (world-cat2 w)
      EMPTY-CANVAS)))

;; place-cat : Cat Scene -> Scene
;; RETURNS: a scene like the given one, but with the given cat painted
;; on it.
(define (place-cat c s)
  (place-image
    CAT-IMAGE
    (cat-x-pos c) (cat-y-pos c)
    s))


(begin-for-test
  (check-equal? (world-to-scene (make-world CAT-IN-NORTH-50 CAT-IN-NORTH-50 false)) (place-images (list CAT-IMAGE CAT-IMAGE) (list(make-posn 50 50) (make-posn 50 50)) EMPTY-CANVAS) "World to scene test"))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a world w
;; RETURNS: the world that should follow the given world
;; after the given key event.
;; on space, toggle paused?-- ignore all others
;; EXAMPLES: see tests below
;; STRATEGY: structural decomposition on kev : KeyEvent
(define (world-after-key-event w kev)
  (cond
    [(key=? kev " ") (world-with-paused-toggled w)]
    [(key=? kev "up") (world-north w)]
    [(key=? kev "down") (world-south w)]
    [(key=? kev "left") (world-west w)]
    [(key=? kev "right") (world-east w)]
    [else w]))

;; world-north : World -> World
;; world-south : World -> World
;; world-east : World -> World
;; world-west : World -> World
;; GIVEN : a world w.
;; RETURNS : The world with cats moving in their specified direction.
;; STRATEGY : Structural Decomposition on World.
(define (world-north w)
  (make-world  (cat-change-direction-north (world-cat1 w)) 
               (cat-change-direction-north (world-cat2 w)) (world-paused? w)))


(define (world-south w)
  (make-world (cat-change-direction-south (world-cat1 w)) 
              (cat-change-direction-south (world-cat2 w)) (world-paused? w)))


(define (world-east w)
  (make-world (cat-change-direction-east (world-cat1 w)) 
              (cat-change-direction-east (world-cat2 w)) (world-paused? w)))


(define (world-west w)
  (make-world (cat-change-direction-west (world-cat1 w)) 
              (cat-change-direction-west (world-cat2 w)) (world-paused? w)))


;; cat-change-direction-north : Cat -> Cat
;; cat-change-direction-south : Cat -> Cat
;; cat-change-direction-east : Cat -> Cat
;; cat-change-direction-west : Cat -> Cat
;; GIVEN : A cat 
;; RETURNS : The same cat but moving in a different direction.
;; STRATEGY : Structural Decomposition on Cat

(define (cat-change-direction-north c)
  (if (cat-selected? c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "North")
   c)) 

(define (cat-change-direction-south c)
  (if (cat-selected? c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "South")
  c))

(define (cat-change-direction-east c)
  (if (cat-selected? c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "East")
  c)) 

(define (cat-change-direction-west c)
  (if (cat-selected? c)
  (make-cat (cat-x-pos c) (cat-y-pos c) (cat-selected? c) "West")
  c)) 


;; world-with-paused-toggled : World -> World
;; RETURNS: a world just like the given one, but with paused? toggled
;; STRATEGY: structural decomposition on w : World
(define (world-with-paused-toggled w)
  (make-world
   (world-cat1 w) (world-cat2 w)
   (not (world-paused? w))))

(begin-for-test
 ;Test for the various keyboard events like up,down,left and right have been done to test the cat in all directions i.e. North,South,East and West
(check-equal? (world-after-key-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) " ") (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 true))
(check-equal? (world-after-key-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) "up") (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) "down") (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) "left") (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) "right") (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) "p") (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-WEST-SELECTED-50 cat-in-east-selected-50 false) "up") (make-world CAT-IN-NORTH-SELECTED-50 CAT-IN-NORTH-SELECTED-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-WEST-SELECTED-50 cat-in-east-selected-50 false) "down") (make-world CAT-IN-SOUTH-SELECTED-50 CAT-IN-SOUTH-SELECTED-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-WEST-SELECTED-50 cat-in-east-selected-50 false) "left") (make-world CAT-IN-WEST-SELECTED-50 CAT-IN-WEST-SELECTED-50 false))
(check-equal? (world-after-key-event (make-world CAT-IN-WEST-SELECTED-50 cat-in-east-selected-50 false) "right") (make-world cat-in-east-selected-50 cat-in-east-selected-50 false)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN : a world and a description of a mouse event.
;; RETURNS : the world that should follow the given mouse event.
;; STRATEGY : Structual Decomposition on world.
;; Examples : See tests below.
(define (world-after-mouse-event w mx my mev)
  (make-world
    (cat-after-mouse-event (world-cat1 w) mx my mev )
    (cat-after-mouse-event (world-cat2 w) mx my mev )
    (world-paused? w)))

;; cat-after-mouse-event : Cat Integer Integer MouseEvent -> Cat
;; GIVEN : a cat and a description of a mouse event.
;; RETURNS : the cat that should follow the given mouse event.
;; STRATEGY : Structural Decomposition on mouse events.
;; Examples : See tests below

(define (cat-after-mouse-event c mx my mev)
  (cond
    [(mouse=? mev "button-down") (cat-after-button-down c mx my)]
    [(mouse=? mev "drag") (cat-after-drag c mx my)]
    [(mouse=? mev "button-up") (cat-after-button-up c mx my)]
    [else c]))


;; helper functions:

;; cat-after-button-down : Cat Integer Integer -> Cat
;; RETURNS: the cat following a button-down at the given location.
;; STRATEGY: Structural Decomposition on Cat
(define (cat-after-button-down c mx my)
  (if (in-cat? c mx my)
      (make-cat (cat-x-pos c) (cat-y-pos c) true (cat-direction c))
      c))

;; cat-after-drag : Cat Integer Integer -> Cat
;; RETURNS: the cat following a drag at the given location
;; STRATEGY: Structural decomposition on Cat
(define (cat-after-drag c x y)
  (if (cat-selected? c)
      (make-cat x y true (cat-direction c))
      c))

;; cat-after-button-up : Cat Integer Integer -> Cat
;; RETURNS: the cat following a button-up at the given location
;; STRATEGY: Structural decomposition on Cat
;; Examples : See tests below
(define (cat-after-button-up c x y)
  (if (cat-selected? c)
      (cond 
        [(and (<= (- (cat-x-pos c) HALF-CAT-WIDTH) 0) (<= (- y HALF-CAT-HEIGHT) 0)) (cat-beyond-north-west-corner c)]
        [(and (>= (+ HALF-CAT-WIDTH (cat-x-pos c)) CANVAS-WIDTH) (>= (+ HALF-CAT-HEIGHT (cat-y-pos c)) CANVAS-HEIGHT)) (cat-beyond-north-east-corner c)]
        [(and (<= (- (cat-x-pos c) HALF-CAT-WIDTH) 0) (>= (+ HALF-CAT-HEIGHT (cat-y-pos c)) CANVAS-HEIGHT)) (cat-beyond-south-west-corner c)]
        [(and (>= (+ HALF-CAT-WIDTH (cat-x-pos c)) CANVAS-WIDTH) (<= (- y HALF-CAT-HEIGHT) 0)) (cat-beyond-south-east-corner c)]
        [(<= (- (cat-x-pos c) HALF-CAT-WIDTH) 0) (cat-beyond-west-edge c)]
        [(>= (+ HALF-CAT-WIDTH (cat-x-pos c)) CANVAS-WIDTH) (cat-beyond-east-edge c)]
        [(<= (- y HALF-CAT-HEIGHT) 0) (cat-beyond-north-edge c)]
        [(>= (+ HALF-CAT-HEIGHT (cat-y-pos c)) CANVAS-HEIGHT) (cat-beyond-south-edge c)]
        [else (make-cat (cat-x-pos c) (cat-y-pos c) false (cat-direction c))])
      c))
        

;; cat-beyond-north-west-corner : Cat -> Cat
;; cat-beyond-north-east-corner : Cat -> Cat
;; cat-beyond-south-west-corner : Cat -> Cat
;; cat-beyond-south-east-corner : Cat -> Cat
;; cat-beyond-west-edge : Cat -> Cat
;; cat-beyond-east-edge : Cat -> Cat
;; cat-beyond-north-edge : Cat -> Cat
;; cat-beyond-south-edge : Cat -> Cat
;; GIVEN : A cat at a certain position on the canvas.
;; RETURNS : The same cat but depending on the position will have taken a certain position on the canvas.
;; STRATEGY : Structural decomposition on Cat.
;; Examples : See test
(define (cat-beyond-north-west-corner c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (+ HALF-CAT-WIDTH BUFFER) (+ HALF-CAT-HEIGHT BUFFER) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (+ HALF-CAT-WIDTH BUFFER) (+ HALF-CAT-HEIGHT BUFFER) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (+ HALF-CAT-WIDTH BUFFER) (+ HALF-CAT-HEIGHT BUFFER) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (+ HALF-CAT-WIDTH BUFFER) (+ HALF-CAT-HEIGHT BUFFER) false "East")]))

(define (cat-beyond-north-east-corner c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "East")]))

(define (cat-beyond-south-west-corner c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (+ HALF-CAT-WIDTH BUFFER) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (+ HALF-CAT-WIDTH BUFFER) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (+ HALF-CAT-WIDTH BUFFER) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (+ HALF-CAT-WIDTH BUFFER) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "East")]))

(define (cat-beyond-south-east-corner c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (+ HALF-CAT-HEIGHT BUFFER) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (+ HALF-CAT-HEIGHT BUFFER) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (+ HALF-CAT-HEIGHT BUFFER) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (+ HALF-CAT-HEIGHT BUFFER) false "East")]))

(define (cat-beyond-north-edge c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (cat-x-pos c) (+ HALF-CAT-HEIGHT BUFFER) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (cat-x-pos c) (+ HALF-CAT-HEIGHT BUFFER) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (cat-x-pos c) (+ HALF-CAT-HEIGHT BUFFER) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (cat-x-pos c) (+ HALF-CAT-HEIGHT BUFFER) false "East")]))


(define (cat-beyond-south-edge c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (cat-x-pos c) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (cat-x-pos c) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (cat-x-pos c) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (cat-x-pos c) (- CANVAS-HEIGHT (+ BUFFER HALF-CAT-HEIGHT)) false "East")]))

(define (cat-beyond-east-edge c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (cat-y-pos c) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (cat-y-pos c) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (cat-y-pos c) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (- CANVAS-WIDTH (+ BUFFER HALF-CAT-WIDTH)) (cat-y-pos c) false "East")]))

(define (cat-beyond-west-edge c)
  (cond
    [(string=? (cat-direction c) "North") (make-cat (+ HALF-CAT-WIDTH BUFFER) (cat-y-pos c) false "South")]
    [(string=? (cat-direction c) "South") (make-cat (+ HALF-CAT-WIDTH BUFFER) (cat-y-pos c) false "North")]
    [(string=? (cat-direction c) "East") (make-cat (+ HALF-CAT-WIDTH BUFFER) (cat-y-pos c) false "West")]
    [(string=? (cat-direction c) "West") (make-cat (+ HALF-CAT-WIDTH BUFFER) (cat-y-pos c) false "East")]))


;; in-cat? : Cat Integer Integer -> Cat
;; RETURNS : true iff the given coordinate is inside the bounding box of
;; the given cat.
;; STRATEGY: Structural decomposition on Cat.
;; EXAMPLES: see tests below.

(define (in-cat? c x y)
  (and
    (<= (- (cat-x-pos c) HALF-CAT-WIDTH) x (+ (cat-x-pos c) HALF-CAT-WIDTH))
    (<= (- (cat-y-pos c) HALF-CAT-HEIGHT) y (+ (cat-y-pos c) HALF-CAT-HEIGHT))))

;; initial-world : Integer -> World
;; RETURNS: a world with two unselected cats at the given y coordinate
;; STRATEGY : Function composition

(define (initial-world y)
  (make-world (make-cat CAT1-X-COORD y false "South") 
              (make-cat CAT2-X-COORD y false "South") false))

(begin-for-test
 ;Test for the three mouse events button-down , button-up and drag
(check-equal? (world-after-mouse-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) 50 50 "button-down") (make-world (make-cat 50 50 true "North") (make-cat 50 50 true "South") false))
(check-equal? (world-after-mouse-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) 50 50 "button-up") (make-world (make-cat 50 50 false "North") (make-cat 50 50 false "South") false))
(check-equal? (world-after-mouse-event (make-world CAT-IN-NORTH-50 CAT-IN-SOUTH-50 false) 50 50 "drag") (make-world (make-cat 50 50 false "North") (make-cat 50 50 false "South") false))
(check-equal? (cat-after-drag CAT-IN-NORTH-SELECTED-50 50 50) (make-cat 50 50 true "North"))
(check-equal? (cat-after-button-down CAT-IN-NORTH-SELECTED-50 200 200) (make-cat 50 50 true "North") "Cat is not selected so will remain in the same place")

;For cat going beyond the north-west corner edge in all directions
(check-equal? (cat-after-button-up cat-beyond-northwest-corner-north -50 -50) (make-cat 39 60 false "South"))
(check-equal? (cat-beyond-north-west-corner cat-beyond-northwest-corner-north) (make-cat 39 60 false "South"))
(check-equal? (cat-beyond-north-west-corner cat-beyond-northwest-corner-south) (make-cat 39 60 false "North"))
(check-equal? (cat-beyond-north-west-corner cat-beyond-northwest-corner-west) (make-cat 39 60 false "East"))
(check-equal? (cat-beyond-north-west-corner cat-beyond-northwest-corner-east) (make-cat 39 60 false "West"))
;For cat going beyond the south-west corner edge in all directions
(check-equal? (cat-after-button-up cat-beyond-southwest-corner-north -50 650) (make-cat 39 340 false "South"))
(check-equal? (cat-beyond-south-west-corner cat-beyond-southwest-corner-north) (make-cat 39 340 false "South"))
(check-equal? (cat-beyond-south-west-corner cat-beyond-southwest-corner-south) (make-cat 39 340 false "North"))
(check-equal? (cat-beyond-south-west-corner cat-beyond-southwest-corner-west) (make-cat 39 340 false "East"))
(check-equal? (cat-beyond-south-west-corner cat-beyond-southwest-corner-east) (make-cat 39 340 false "West"))
;For cat going beyond the south-east corner edge in all directions
(check-equal? (cat-after-button-up cat-beyond-southeast-corner-north -50 -50) (make-cat 411 340 false "South"))
(check-equal? (cat-beyond-south-east-corner cat-beyond-southeast-corner-north) (make-cat 411 60 false "South"))
(check-equal? (cat-beyond-south-east-corner cat-beyond-southeast-corner-south) (make-cat 411 60 false "North"))
(check-equal? (cat-beyond-south-east-corner cat-beyond-southeast-corner-west) (make-cat 411 60 false "East"))
(check-equal? (cat-beyond-south-east-corner cat-beyond-southeast-corner-east) (make-cat 411 60 false "West"))
;For cat going beyond the north-east corner edge in all directions
(check-equal? (cat-after-button-up cat-beyond-northeast-corner-north -50 -50) (make-cat 411 60 false "South"))
(check-equal? (cat-beyond-north-east-corner cat-beyond-northeast-corner-north) (make-cat 411 340 false "South"))
(check-equal? (cat-beyond-north-east-corner cat-beyond-northeast-corner-south) (make-cat 411 340 false "North"))
(check-equal? (cat-beyond-north-east-corner cat-beyond-northeast-corner-west) (make-cat 411 340 false "East"))
(check-equal? (cat-beyond-north-east-corner cat-beyond-northeast-corner-east) (make-cat 411 340 false "West"))
;For cat going beyond the south edge in all directions
(check-equal? (cat-beyond-south-edge cat-beyond-south-going-north) (make-cat 100 340 false "South"))
(check-equal? (cat-beyond-south-edge cat-beyond-south-going-south) (make-cat 100 340 false "North"))
(check-equal? (cat-beyond-south-edge cat-beyond-south-going-east) (make-cat 100 340 false "West"))
(check-equal? (cat-beyond-south-edge cat-beyond-south-going-west) (make-cat 100 340 false "East"))
;For cat going beyond the north edge in all directions
(check-equal? (cat-beyond-north-edge cat-beyond-north-going-north) (make-cat 100 60 false "South"))
(check-equal? (cat-beyond-north-edge cat-beyond-north-going-south) (make-cat 100 60 false "North"))
(check-equal? (cat-beyond-north-edge cat-beyond-north-going-east) (make-cat 100 60 false "West"))
(check-equal? (cat-beyond-north-edge cat-beyond-north-going-west) (make-cat 100 60 false "East"))
;For cat going beyond the west edge in all directions
(check-equal? (cat-beyond-west-edge cat-beyond-west-going-north) (make-cat 39 100 false "South"))
(check-equal? (cat-beyond-west-edge cat-beyond-west-going-south) (make-cat 39 100 false "North"))
(check-equal? (cat-beyond-west-edge cat-beyond-west-going-east) (make-cat 39 100 false "West"))
(check-equal? (cat-beyond-west-edge cat-beyond-west-going-west) (make-cat 39 100 false "East"))
;For cat going beyond the east edge in all directions
(check-equal? (cat-beyond-east-edge cat-beyond-east-going-north) (make-cat 411 100 false "South"))
(check-equal? (cat-beyond-east-edge cat-beyond-east-going-south) (make-cat 411 100 false "North"))
(check-equal? (cat-beyond-east-edge cat-beyond-east-going-east) (make-cat 411 100 false "West"))
(check-equal? (cat-beyond-east-edge cat-beyond-east-going-west) (make-cat 411 100 false "East"))
;For cat only going beyondthe four edges and not in the corners
(check-equal? (cat-after-button-up cat-beyond-south-going-north 50 600) (make-cat 100 340 false "South"))
(check-equal? (cat-after-button-up cat-beyond-north-going-north 50 -200) (make-cat 100 60 false "South"))
(check-equal? (cat-after-button-up cat-beyond-west-going-north -100 100) (make-cat 39 100 false "South"))
(check-equal? (cat-after-button-up cat-beyond-east-going-north 600 100) (make-cat 411 100 false "South"))
;for initial world 
(check-equal? (initial-world 50) (make-world (make-cat 150 50 false "South") (make-cat 300 50 false "South") false)))
;(check-equal? (cat-north? ))
;; cat-north? : Cat -> Boolean
;; cat-east?  : Cat -> Boolean
;; cat-south? : Cat -> Boolean
;; cat-west?  : Cat -> Boolean
;; GIVEN: a Cat c
;; RETURNS: true iff c is travelling in the specified direction.
(define (cat-north? c)
  (string=? (cat-direction c) "North"))

(define (cat-south? c)
  (string=? (cat-direction c) "South"))
(define (cat-west? c)
  (string=? (cat-direction c) "West"))
(define (cat-east? c)
  (string=? (cat-direction c) "East"))