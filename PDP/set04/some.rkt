#lang racket
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide run
         initial-world
         world-after-key-event
         world-after-mouse-event
         world-after-tick
         world-balls
         ball-x-pos
         ball-y-pos)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN FUNCTION

;; run : PosInt PosReal -> World
;; GIVEN: A ball speed and a frame rate, in secs/tick.
;; EFFECT: runs the world.
;; RETURNS: the final state of the world.
;; EXAMPLE: (run 8 0.25) creates and runs a world in
;; which each ball travels at 8 pixels per tick and
;; each tick is 0.25 secs.
;; STRATEGY : function composition
(define (run x y)
  (big-bang (initial-world x)
            (on-draw world-to-scene)
            (on-tick world-after-tick y)
            (on-mouse world-after-mouse-event)
            (on-key world-after-key-event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CONSTANTS
;;
;; dimensions of the canvas
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
;;radius of the two circles used
(define RADIUS 20)
(define OUTLINE-BALL (circle RADIUS "outline" "Red"))
(define SOLID-BALL (circle RADIUS "solid" "Red"))
;;
(define-struct ball(x-pos y-pos mouse-x mouse-y direction))
;; 
(define-struct world(lob speed))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-tick : World -> World
;; GIVEN: A world.
;; RETURNS: The world that should follow w after a tick.
;; Examples : See test cases below.
;; STRATEGY: Structural decomposition on w : World.
(define (world-after-tick w)
      (make-world (ball-after-tick (world-lob w) (world-speed w)) 
                  (world-speed w)))

;; balls-after-tick : LOB PosInt -> LOB
;; GIVEN : A list of balls and speed of each ball.
;; RETURNS : A list of balls after tick.
;; Examples : See test cases below.
;; STRATEGY : HOFC
(define (ball-after-tick lob speed)
  (map
   ;; Ball -> Ball
   ;; GIVEN : A ball
   ;; RETURNS : A ball after a single tick.
   (lambda (b)(breaking-the-ball b speed)) 
   lob))

;; breaking-the-ball : Ball PosInt -> Ball
;; GIVEN : A ball and the speed of the ball
;; RETURNS : A ball after one tick in an unpaused world.
;; Examples : See test case below.
;; STRATEGY : Structural decomposition on b : Ball
(define(breaking-the-ball b speed)
  (ball-after-tick-direction (ball-x-pos b) (ball-y-pos b) 
                             (ball-mouse-x b) (ball-mouse-y b) 
                             (ball-direction b) speed))

;; ball-after-tick-direction : Ball PosInt -> Ball
;; GIVEN : A ball and the speed at which it will travel.
;; RETURNS : The same ball after a tick.
;; Examples : See test cases below.
;; STRATEGY : Structural decomposition on dir : Direction
(define (ball-after-tick-direction x y mx my dir speed)
  (cond  
    [(string=? dir "left") 
     (ball-after-tick-left x y mx my dir speed)]
    [(string=? dir "right") 
     (ball-after-tick-right x y mx my dir speed)]))

;; ball-after-tick-left : Integer Integer Boolean String Integer Integer String
;;                        PosInt -> Ball
;; ball-after-tick-right : Integer Integer Boolean String Integer Integer 
;;                         String PosInt-> Ball
;; GIVEN : A position of the ball,mouse coordinates,
;;         whether the ball is selected or not,direction and speed of the ball.
;; RETURNS : The ball that would follow the one in the given position
;;           in a unpaused world.
;; Examples : See test cases below.
;; STRATEGY : function composition.

(define (ball-after-tick-left x-pos y-pos mx my d speed)
      (x-limit-for-ball-going-left x-pos y-pos mx my d speed))

(define (ball-after-tick-right x-pos y-pos mx my d speed)
      (x-limit-for-ball-going-right x-pos y-pos mx my d speed))

;; x-limit-for-ball-going-left : Real Real Boolean Integer Integer Direction 
;;                               PosInt -> Ball
;; x-limit-for-ball-going-right : Real Real Boolean Integer Integer Direction 
;;                                PosInt -> Ball
;; GIVEN : A position of the ball,mouse coordinates,
;; whether the ball is selected or not,direction and speed of the ball.
;; RETURNS : The ball that would follow the one in the given position
;; in a unpaused world.
;; Examples : See test case below.
;; STRATEGY : function composition.

(define (x-limit-for-ball-going-left x-pos y-pos mx my d speed)
  (if (<= (- (- x-pos RADIUS) speed) 0)
      (make-ball RADIUS y-pos mx my "right")
      (make-ball (- x-pos speed) y-pos mx my d)))

(define (x-limit-for-ball-going-right x-pos y-pos mx my d speed)
  (if (>= (+ (+ x-pos RADIUS) speed) CANVAS-WIDTH) 
      (make-ball (- CANVAS-WIDTH RADIUS) y-pos mx my "left")
      (make-ball (+ x-pos speed) y-pos mx my d)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-to-scene : World -> Scene
;; GIVEN : A world w.
;; RETURNS : An image that portrays the balls in the image.
;; STRATEGY: Structural decomposition on w : World.
;; Examples : See test cases below.
(define (world-to-scene w)
  (foldr placing-the-image EMPTY-CANVAS (world-lob w)))

;; placing-the-image : Ball Scene -> Scene
;; GIVEN : A ball and an empty scene.
;; RETURNS : A scene with the ball placed on the initial scene.
;; Examples : See test cases below.
;; STRATEGY : Structural decomposition on ball : Ball.
(define (placing-the-image ball image)
  (place-image OUTLINE-BALL (ball-x-pos ball) 
               (ball-y-pos ball) image))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initial-world : PosInt -> World
;; GIVEN: a ball speed.
;; RETURNS: a world with no balls, but with the
;; property that any balls created in that world
;; will travel at the given speed.
;; Examples : See test cases below.
;; STRATEGY : Function Composition.
(define (initial-world x)
  (make-world (list ) x))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-key-event : World KeyEvent -> World
;; GIVEN : A World and a keyevent.
;; RETURNS: The world that should follow the given world after the given
;; key event.
;; STRATEGY : Structural decomposition on kev: KeyEvent.
;; Examples : See test cases below.
(define (world-after-key-event w kev)
  (cond
    [(key=? kev "n") (world-after-n-key w)]
    [(key=? kev " ") (world-with-pause-toggled w)]
    [else w]))

;; world-with-paused-toggled : World -> World
;; RETURNS: a world just like the given one, but with paused? toggled
;; STRATEGY: structural decomposition on w : World

(define (world-with-pause-toggled w)
  (make-world (world-lob w) (world-speed w)))

;; world-after-n-key : World -> World
;; GIVEN : A world
;; RETURNS : A world like the given one with the change after pressing
;; the n key.
;; Example: See test cases below.
;; STRATEGY : structural decomposition on 
(define (world-after-n-key w)
  (make-world (cons (make-ball 200 150 0 0 "right") (world-lob w)) 
              (world-speed w)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: A world, the location of a mouse event, and the mouse event itself
;; RETURNS: the world that should follow the given world after the given
;; mouse event at the given location.
;; STRATEGY : Structural decomposition on w : World
;; Examples : See test cases below.
(define (world-after-mouse-event w mx my mev)
  (make-world (making-the-ball-after-key-event (world-lob w) mx my mev) 
              (world-speed w)))

;; making-the-ball-after-key-event : LOB Integer Integer MouseEvent -> LOB
;; GIVEN : A list of balls,mouse co-ordinates and a specfic mouse event.
;; RETURNS : A list of balls after application of the mouse event.
;; Examples : See test cases below.
;; STRATEGY : HOFC
(define (making-the-ball-after-key-event lob mx my mev)
  (map
   ;; Ball -> Ball
   ;; GIVEN : A ball
   ;; RETURNS : A ball after the specified mouse event. 
   (lambda(ball)(ball-after-mouse-event ball mx my mev)) 
   lob))

;; ball-after-mouse-event : Ball Integer Integer MouseEvent -> Ball
;; GIVEN : A ball,the location of the mouse pointer and the mouse event
;; RETURNS : A ball after the specific mouse event takes place.
;; STRATEGY : Structural decomposition on mev : MouseEvent
;; Examples : See test cases below.
(define (ball-after-mouse-event ball mx my mev)
  (cond
    [(mouse=? mev "button-down") (ball-after-button-down ball mx my)]
    ;[(mouse=? mev "drag") (ball-after-drag ball mx my)]
    [(mouse=? mev "button-up") (ball-after-button-up ball mx my)]
    [else ball]))

;; ball-after-button-down : Ball Integer Integer -> Ball
;; GIVEN : A ball and the mouse x,y coordinates.
;; RETURNS : A Ball with selected true if the mouse pointer is inside the ball
;; area else returns the same ball.
;; STRATEGY : Structural decomposition on ball : Ball.
;; Examples : See test cases below.
(define (ball-after-button-down ball mx my)
  (if (in-circle? ball mx my)
      (make-ball (ball-x-pos ball) (ball-y-pos ball) mx my 
                 (ball-direction ball))
      ball))

;; in-circle? : Ball Integer Integer -> Boolean
;; GIVEN : A ball and the mouse x,y coordinates.
;; RETURNS : true iff the given coordinates are inside the circle.
;; STRATEGY : structural decomposition on ball : Ball.
;; Examples : See test cases below.
(define (in-circle? ball x y)
  (<= (+ (sqr(- (ball-x-pos ball) x)) (sqr (- y (ball-y-pos ball)))) 
      (sqr RADIUS)))

;; ball-after-drag : Ball Integer Integer -> Ball
;; GIVEN : A ball and the mouse x,y coordinates.
;; RETURNS : A ball with the mouse pointer adjusted to remain at the same place
;; even after dragging.
;; STRATEGY : Structural decomposition on ball : Ball.
;; Examples : See test cases below.
#;(define (ball-after-drag ball mx my)
    (if(ball-selected? ball)
       (make-ball (- mx (- (ball-mouse-x ball) (ball-x-pos ball))) 
                  (- my (- (ball-mouse-y ball) (ball-y-pos ball))) mx my 
                  (ball-direction ball)) 
       ball))

;; ball-after-button-up : Ball Integer Integer -> Ball
;; GIVEN : A ball and the mouse x,y coordinates.
;; RETURNS : A ball with selected? turned to false if the ball is selected.
;; STRATEGY : Structural decomposition on ball : Ball.
;; Examples : See test cases below.
(define (ball-after-button-up ball mx my)
      ball)

;; world-balls : World -> ListOfBalls
;; GIVEN: A world w.
;; RETURNS: The list of balls that are in the canvas.
;; STRATEGY : Function Composition.
;; Examples : See the test cases below.
(define (world-balls w)
  (world-lob w))
