#lang racket
;; This program consists of toys on a canvas. 
;; The canvas is of size 400x500 pixels.
;; On the canvas, the system displays a circle of radius 10 in outline mode. 
;; The circle initially appears in the center of the canvas. We call this 
;; circle the "target."
;; When we type "s", a new square-shaped toy pops up. It is represented as
;; a 40x40 pixel outline square, with its center located at the center of the 
;; target.
;; When a square-shaped toy appears, it begins travelling rightward at a 
;; constant rate and bounces off the left and the right edge.
;; When we type "c", a new circle-shaped toy of radius 5 appears, with 
;; its center located at the center of the target. These circular toys do not 
;; move, but they alternate between solid red and solid green every 5 ticks. 
;; The circle is initially solid green.
;; The target can be moved around the canvas by dragging it with the mouse. 
;; The toys are not draggable.
;; We can run this program by using the run function
;; Example :
;; (run 0.25 10)
;; where 0.25 is the fram rate/tick.
;; 10 is the speed of each tick.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Required files and libraries
(require rackunit)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")
(require "sets.rkt")

;; Functions to be provided
(provide World%
         SquareToy%
         CircleToy%
         make-world
         run
         make-square-toy
         make-circle-toy
         StatefulWorld<%>
         StatefulToy<%>)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CONSTANTS
;; CANVAS DIMENSIONS
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500)
(define HALF-WIDTH (/ CANVAS-WIDTH 2))
(define HALF-HEIGHT (/ CANVAS-HEIGHT 2))

(define SIDE 40)
(define HALF-SIDE (/ SIDE 2))

(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

(define GREEN "green")
(define RED "red")

(define TAR-CIR-RADIUS 10)
(define CIR-RADIUS 5)

(define TARGET-CIRCLE (circle TAR-CIR-RADIUS "outline" GREEN))
(define SQUARE (square SIDE "outline" RED))

(define SOLID-GREEN (circle CIR-RADIUS "solid" GREEN))
(define SOLID-RED (circle CIR-RADIUS "solid" RED))

(define ZERO 0)
(define FIVE 5)
(define TEN 10)
;;
;;; END OF CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS
;; A ColorString is one of 
;; -- "green" interp : the colour is green
;; -- "red" interp : the colour is red
;; 
;; template :
;; color-str-fn : ColorString -> ??
#;(define (color-str-fn c)
    (cond
      [(string=? c "green")...]
      [(string=? c "red")...]))
;;
;; A ListOfStatefulToy<%> is either
;; -- empty                                       interp : There are no toys
;; -- (cons StatefulToy<%> ListOfStatefulToy<%>)  interp : A list of toys
;;
;; template :
;; lot-fn : ListOfStatefulToy<%> -> ??
#;(define (lot-fn toys)
    (cond
      [(empty? toys)...]
      [else (...
             (first toys)
             (lot-fn (rest toys)))]))

;;;END OF DATA DEFINITIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INTERFACES :
(define StatefulWorld<%>
  (interface ()
    
    ;; -> Void 
    ;; GIVEN: no arguments
    ;; EFFECT: updates StatefulWorld<%> to the state that it should be in after
    ;; a tick.
    on-tick                             
    
    ;; Integer Integer MouseEvent -> Void
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be in
    ;; after the given MouseEvent
    on-mouse
    
    ;; KeyEvent -> Void
    ;; GIVEN: a KeyEvent
    ;; EFFECT: updates StatefulWorld<%> to the state that it should be in
    ;; after the given KeyEvent
    on-key
    
    ;; -> Scene
    ;; GIVEN: a Scene
    ;; RETURNS : a Scene depicting this world StatefulWorld<%>
    ;; on it.
    on-draw 
    
    ;; -> Integer
    ;; RETURN: the x and y coordinates of the target
    target-x
    target-y
    
    ;; -> Integer
    ;; RETURNS : Mouse x-coordinate.
    for-test:target-mx
    
    ;; -> Integer
    ;; RETURNS : Mouse y-coordinate.
    for-test:target-my
    
    ;; -> PosInt
    ;; RETURNS : The speed with which the world will move.
    for-test:target-speed
    
    ;; -> Boolean
    ;; RETURNS: whether or not the target is selected?
    target-selected?
    
    ;; -> ListOfStatefulToy<%>
    ;; RETURNS: the list of toys in this world
    get-toys
    
    ;; World% -> Boolean
    ;; RETURNS : true iff the objects are equal 
    for-test:world-equal?
    
    ))

(define StatefulToy<%> 
  (interface ()
    
    ;; -> Void
    ;; EFFECT: updates this StatefulToy<%> to the state it should be in after a
    ;; tick.
    on-tick                             
    
    ;; Scene -> Scene
    ;; Returns a Scene like the given one, but with this StatefulToy<%> drawn
    ;; on it.
    add-to-scene
    
    ;; -> PosInt
    ;; RETURNS: the x and y co-ordinates of the toy
    toy-x
    toy-y
    
    ;; -> ColorString
    ;; returns the current color of this StatefulToy<%>
    toy-color
    
    ;; -> Boolean
    ;; RETURNS : True iff the toy objects are equal
    for-test:toy-equal?
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A World is a (new World% [x-pos Integer] [y-pos Integer] [selected? Boolean] 
;; [mouse-x Integer] [mouse-y Integer] [speed PosInt] [toys ListOf<Toy>])      
;; interpretation : represents a world, containing the x and y co-ordinates of 
;; the center of the target circle, whether it is selected or not, x and y 
;; co-ordinates of mouse pointer and list of toys in the world.

(define World%
  (class* object% (StatefulWorld<%>)
    (init-field   x-pos    ;Integer--x-coordinate of the centre of target circle
                  y-pos    ;Integer--y-coordinate of the centre of target circle
                  selected?  ;Boolean -- Tells if the target is selected or not
                  mouse-x    ;Integer -- x-coordinate of the mouse pointer.
                  mouse-y    ;Integer -- y-coordinate of the mouse pointer.
                  speed      ;PosInt -- Speed of the world
                  toys)      ;ListOfStatefulToy<%> -- a list of toys which 
    ;include square toys and circle toys. 
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; EFFECT: updates this World to the state that it should be in after
    ;; a tick.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : HOFC 
    (define/public (on-tick)
      (for-each
       ;; StatefulToy<%> -> Void
       ;; GIVEN : A toy
       ;; EFFECT : Makes changes to the given toy for on-tick function
       (lambda(toy) (send toy on-tick))
       (send this get-toys)))
    
    ;; on-mouse : Integer Integer MouseEvent -> Void
    ;; EFFECT: updates this World to the state that it
    ;; should be in after the given MouseEvent
    ;; EXAMPLE : See test below.
    ;; STRATEGY : cases on mev : MouseEvent
    (define/public (on-mouse mx my mev)
      (cond
        [(mouse=? mev "button-down") (send this world-after-button-down mx my)]
        [(mouse=? mev "drag") (send this world-after-drag mx my)]
        [(mouse=? mev "button-up") (send this world-after-button-up)]
        [else this]))
    
    ;; world-after-button-up : -> Void
    ;; EFFECT: updates this World to the state that it
    ;; should be in after the button-up MouseEvent
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-button-up)
      (if selected?
          (set! selected? false)
          this))
    
    ;; world-after-button-down : Integer Integer -> Void
    ;; EFFECT: updates this World to the state that it
    ;; should be in after the button-down MouseEvent
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-button-down mx my)
      (if (send this in-circle? mx my)
          (set! selected? true)
          this))
    
    ;; world-after-drag : Integer Integer -> Void
    ;; EFFECT: updates this World to the state that it
    ;; should be in after the drag MouseEvent
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-drag mx my)
      (if selected?
          (send this change-world mx my)
          this))
    
    ;; change-world : Integer Integer -> Void
    ;; EFFECT: updates this World by modifing its x-pos,y-pos, mouse-x,mouse-y 
    ;; fields to the given integer positions of the mouse pointer
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (change-world mx my)
      (set! x-pos (- mx (- mouse-x x-pos)))
      (set! y-pos (- my (- mouse-y y-pos)))
      (set! mouse-x mx)
      (set! mouse-y my))
    
    ;; in-circle? : Integer Integer -> Boolean
    ;; GIVEN : The location of the mouse coordinates
    ;; RETURNS : True iff the mouse coordinates are inside the circle
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (in-circle? mx my)
      (and
       (<= (- x-pos TAR-CIR-RADIUS) mx (+ x-pos TAR-CIR-RADIUS))
       (<= (- y-pos TAR-CIR-RADIUS) my (+ y-pos TAR-CIR-RADIUS))))
    
    ;; on-key : KeyEvent -> Void
    ;; EFFECT: updates this World<%> to the state that it should be in
    ;; after the given KeyEvent    ;; EXAMPLE : See test below.
    ;; STRATEGY : cases on kev : KeyEvent
    (define/public (on-key kev)
      (cond
        [(key=? kev "s") (send this world-after-s-key)]
        [(key=? kev "c") (send this world-after-c-key)]
        [else this]))
    
    ;; world-after-s-key : -> Void
    ;; EFFECTS: Updates the world by adding a Square toy which keeps
    ;; moving to the right to it.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-s-key)
      (set! toys (cons
                  (new SquareToy% [x-pos x-pos] [y-pos y-pos] [right? true] 
                       [speed speed])
                  toys)))
    
    ;; world-after-c-key : -> Void
    ;; EFFECTS: Updates the world by adding a Circle toy which keeps
    ;; changing the colors between red and green every 5 counts starting with
    ;; green.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-c-key)
      (set! toys (cons
                  (new CircleToy% [x-pos x-pos] [y-pos y-pos] [count ZERO])
                  toys)))
    
    ;; on-draw : Scene -> Scene
    ;; RETURNS: a scene like the given one, but with this world painted
    ;; on it.
    ;; EXAMPLE : See test below.
    ;; STRATEGY: HOFC
    (define/public (on-draw)
      (foldr
       ;; StatefulToy<%> Scene -> Scene
       ;; RETURNS : The new scene after adding the toy to the given scene
       (lambda(toy scene) (send toy add-to-scene scene))
       (place-image TARGET-CIRCLE x-pos y-pos EMPTY-CANVAS)
       toys))
    
    ;; target-x : -> Integer
    ;; RETURNS : The x-coordinate of the center of the target circle.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition.
    (define/public (target-x)
      x-pos)
    
    ;; target-y : -> Integer
    ;; RETURNS : The y-coordinate of the center of the target circle.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (target-y)
      y-pos)
    
    ;; target-selected? : -> Boolean
    ;; RETURNS : True iff the the target circle is selected.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (target-selected?)
      selected?)
    
    ;; for-test:target-mx : -> Integer
    ;; RETURNS : Mouse x-coordinate.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (for-test:target-mx)
      mouse-x)
    
    ;; for-test:target-my : -> Integer
    ;; RETURNS : Mouse y-coordinate.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition    
    (define/public (for-test:target-my)
      mouse-y)
    
    ;; for-test:target-speed : -> PosInt
    ;; RETURNS : The speed with which the world will move.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (for-test:target-speed)
      speed)
    
    ;; get-toys : -> ListOfStatefulToy<%>
    ;; RETURNS : The list of all the toys present in the world.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition.
    (define/public (get-toys)
      toys)
    
    ;; for-test:world-equal? : StatefulWorld<%> -> Boolean
    ;; RETURNS : True iff the given world and the world object will be equal
    ;; EXAMPLES : See test below
    ;; STRATEGY : Function composition
    (define/public (for-test:world-equal? w1)
      (and
       (= (send w1 target-x)
          (send this target-x))
       (= (send w1 target-y)
          (send this target-y))
       (equal? (send w1 target-selected?)
               (send this target-selected?))
       (= (send w1 for-test:target-mx)
          (send this for-test:target-mx))
       (= (send w1 for-test:target-my)
          (send this for-test:target-my))
       (= (send w1 for-test:target-speed)
          (send this for-test:target-speed))
       (andmap
        ;; StatefulToy<%> StatefulToy<%> -> Boolean
        ;; GIVEN : Two toys
        ;; RETURNS : If the two toy objects are equal or not
        (lambda (t1 t2) (send t1 for-test:toy-equal? t2))
        (send w1 get-toys)
        (send this get-toys))))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A SquareToy is a (new SquareToy% [x-pos PosInt] [y-pos PosInt]
;; [speed PosInt] [right? Boolean])
;; Intepretation : Represents a square toy with x y coordinate giving the center
;; of the toy, speed giving the speed of the movement of the toy and right? 
;; tells if toy is moving on the right or not 

(define SquareToy%
  (class* object% (StatefulToy<%>)
    (init-field
     x-pos        ; PosInt -- the square toy's x position in pixels
     y-pos        ; PosInt -- the square toy's y position in pixels
     speed        ; PosInt -- the square toy's speed in pixels/tick
     right?)      ; Boolean -- the square toy's direction whether right or left
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN : A SquareToy
    ;; EFFECT : updates this SquareToy% to the state that it should be in after
    ;; a tick.
    ;; EXAMPLE : See test below.
    ;; STRATEGY :  Function Composition
    (define/public (on-tick)
      (if right?
          (send this check-canvas-limit-right)
          (send this check-canvas-limit-left)))
    
    ;; check-canvas-limit-right : -> Void
    ;; EFFECT: updates the give SquareToy%'s direction to left if hits the right
    ;; canvas and also its position after the tick else updates just the 
    ;; position after a tick.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (check-canvas-limit-right)
      (if (> (+ (+ x-pos HALF-SIDE) speed) CANVAS-WIDTH) 
          (send this change-direction-to-left)
          (send this move-right)))
    
    ;; change-direction-to-left: -> Void
    ;; EFFECT: Updates the given square toy's state to that it should be in 
    ;; after a tick i.e toggle right? and toy's right side attached to the
    ;; right canvas.
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function Composition
    (define/public (change-direction-to-left)
      (set! x-pos (- CANVAS-WIDTH HALF-SIDE))
      (set! right? false))
    
    ;; move-right: -> Void
    ;; EFFECT: Updates the given square toy's state to that it should be in 
    ;; after a tick i.e x-pos incremented by speed.
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function Composition
    (define/public (move-right)
      (set! x-pos (+ x-pos speed)))
    
    ;; check-canvas-limit-left : -> Void
    ;; EFFECT: updates the give square toy's direction to left if hits the left
    ;; canvas and also its position after the tick else updates just the 
    ;; position after a tick.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (check-canvas-limit-left)
      (if (< (- (- x-pos HALF-SIDE) speed) ZERO)
          (send this change-direction-to-right)
          (send this move-left)))
    
    ;; change-direction-to-right: -> Void
    ;; EFFECT: Updates the given square toy's state to that it should be in 
    ;; after a tick i.e toggle right? and toy's right side attached to the
    ;; left canvas.
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function Composition
    (define/public (change-direction-to-right)
      (set! x-pos HALF-SIDE)
      (set! right? true))
    
    ;; move-left: -> Void
    ;; EFFECT: Updates the given square toy's state to that it should be in 
    ;; after a tick i.e x-pos decremented by speed.
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function Composition
    (define/public (move-left)
      (set! x-pos (- x-pos speed)))
    
    
    ;; add-to-scene: Scene -> Scene
    ;; GIVEN: A Scene
    ;; RETURNS: A scene with an image of square toy on it
    ;; EXAMPLE : See test below.
    ;; STRATEGY: Function Composition
    (define/public (add-to-scene scene)
      (place-image SQUARE x-pos y-pos scene))
    
    ;; toy-x: -> PosInt
    ;; GIVEN: A Square toy
    ;; RETURNS: x position of the centre of the square toy
    ;; EXAMPLE : See test below.
    ;; STRATEGY:Function Composition
    (define/public (toy-x)
      x-pos)
    
    ;; toy-y: -> PosInt
    ;; GIVEN : A Square toy
    ;; RETURNS: y co-ordinate of the centre of the square toy
    ;; EXAMPLE : See test below.
    ;; STRATEGY:Function Composition
    (define/public (toy-y)
      y-pos)
    
    ;; toy-color : -> ColorString
    ;; GIVEN : a square toy
    ;; RETURNS : the color of the square toy
    ;; STRATEGY : Function Composition
    (define/public (toy-color)
      "red")
    
    ;; for-test:toy-speed : -> PosInt
    ;; RETURNS : the speed for the given toy.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (for-test:toy-speed)
      speed)
    
    ;; for-test:toy-right? : -> Boolean
    ;; RETURNS : true iff the given toy is going to the right.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition 
    (define/public (for-test:toy-right?)
      right?)
    
    ;; for-test:toy-equal? : StatefulToy<%> -> Boolean
    ;; RETURNS : true iff the given toy is equal to the toy object.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition. 
    (define/public (for-test:toy-equal? s1)
      (and 
       (= (send s1 toy-x)
          (send this toy-x))
       (= (send s1 toy-y)
          (send this toy-y))
       (equal? (send s1 toy-color)
               (send this toy-color))
       (= (send s1 for-test:toy-speed)
          (send this for-test:toy-speed))
       (equal? (send s1 for-test:toy-right?)
               (send this for-test:toy-right?))))
    
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A CircleToy is a (new CircleToy% [x-pos PosInt] [y-pos PosInt]
;; [count NonNegInt])
;; Interpretation: A CircleToy contains the x and y co-ordinates of the center
;; of the circle toy and a count to keep track of no of ticks.
(define CircleToy%
  (class* object% (StatefulToy<%>)
    (init-field
     x-pos        ; PosInt -- x-coordinate of the center of the circle toy
     y-pos        ; PosInt -- y-coordinate of the center of the circle toy
     count)       ; NonNegInt -- Counts the number of ticks passed.
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN : a circle toy
    ;; EFFECT : updates this CircleToy% to the state it should be in after a
    ;;          tick.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (on-tick)
      (set! count (add1 count)))
    
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : A Scene
    ;; RETURNS : a scene with an image of the circle Toy added to it.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (add-to-scene scene)
      (if (< (remainder count TEN) FIVE)
          (place-image SOLID-GREEN x-pos y-pos scene)
          (place-image SOLID-RED x-pos y-pos scene)))
    
    ;; toy-x : -> PosInt
    ;; GIVEN : A circle toy 
    ;; RETURNS : x co-ordinate of the center of the circle toy
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (toy-x)
      x-pos)
    
    ;; toy-y : -> PosInt
    ;; GIVEN : A circle toy
    ;; RETURNS : y co-ordinate of the center of the circle toy
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (toy-y)
      y-pos)
    
    ;; toy-color : -> ColorString
    ;; GIVEN : A circle toy
    ;; RETURNS : The color of the circle toy.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function composition    
    (define/public (toy-color)
      (if (< (remainder count TEN) FIVE)
          GREEN
          RED))
    
    ;; for-test:toy-count : -> NonNegInt
    ;; GIVEN : A circle toy.
    ;; RETURNS : The color of the circle toy.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function composition
    (define/public (for-test:toy-count)
      count)
    
    ;; for-test:toy-equal? : StatefulToy<%> -> Boolean
    ;; RETURNS : true iff the given toy is equal to the toy object.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition 
    (define/public (for-test:toy-equal? c1)
      (and (= (send c1 toy-x)
              (send this toy-x))
           (= (send c1 toy-y)
              (send this toy-y))
           (equal? (send c1 toy-color)
                   (send this toy-color))))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make-square-toy : PosInt PosInt PosInt -> StatefulToy<%>
;; GIVEN : an x and a y position which are the centers of the toy, and a speed
;; RETURNS : an object representing a square toy at the given position,
;; travelling right at the given speed.
;; EXAMPLE : See test below.
;; STRATEGY : Function composition
(define (make-square-toy x y speed)
  (new SquareToy% [x-pos x] [y-pos y] [speed speed] [right? true]))

;; make-circle-toy : PosInt PosInt -> StatefulToy<%>
;; GIVEN: an x and a y position
;; RETURNS: an object representing a circle toy at the given position
;; with count 0 by default.
;; EXAMPLE : See test below.
;; STRATEGY : Function composition
(define (make-circle-toy x y)
  (new CircleToy% [x-pos x] [y-pos y] [count ZERO]))

;;; setting up the world:
;; make-world : PosInt -> StatefulWorld<%>
;; GIVEN : Speed of the square toy.
;; RETURNS : A world with a target at the center of the canvas.
;; EXAMPLE : See test below 
;; STRATEGY : Function Composition
(define (make-world speed)
  (new World% 
       [x-pos HALF-WIDTH]
       [y-pos HALF-HEIGHT]
       [selected? false]
       [mouse-x HALF-WIDTH]
       [mouse-y HALF-HEIGHT]
       [speed speed]
       [toys empty]
       ))

;; run : PosNum PosInt -> StatefulWorld<%>
;; GIVEN : a frame rate, in secs/tick and the speed
;; EFFECT : runs an initial world at the given frame rate
;; RETURNS : the final state of the world
;; EXAMPLES : See test below.
;; STRATEGY : HOFC
(define (run rate speed)
  (big-bang (make-world speed)
            (on-tick
             ;; StatefulWorld<%> -> StatefulWorld<%>
             ;; RETURNS : The same world like the given world just after one 
             ;; tick
             (lambda (w) (send w on-tick) w) rate)
            (on-draw
             ;; StatefulWorld<%> -> Scene
             ;; RETURNS : The scene depicting the given world
             (lambda (w) (send w on-draw)))
            (on-key
             ;; StatefulWorld<%> KeyEvent -> StatefulWorld<%>
             ;; RETURNS : The world after the key event takes place
             (lambda (w kev) (send w on-key kev) w))
            (on-mouse
             ;; StatefulWorld<%> Integer Integer MouseEvent -> StatefulWorld<%>
             ;; RETURNS : The world after the mouse event takes place.
             (lambda (w x y evt) (send w on-mouse x y evt) w))
            ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;TESTING FRAMEWORK
(begin-for-test
  ;;testcases for SquareToy%
  (local
    ((define sqtoy (new SquareToy% [x-pos 200] [y-pos 200] 
                        [right? true] [speed 10]))
     (define sqtoy1 (new SquareToy% [x-pos 210] [y-pos 200] 
                         [right? true] [speed 10]))
     (define sqtoy2 (new SquareToy% [x-pos 210] [y-pos 200] 
                         [right? false] [speed 10]))
     (define sqtoy3 (new SquareToy% [x-pos 200] [y-pos 200] 
                         [right? false] [speed 10]))
     (define sqtoy4 (new SquareToy% [x-pos 500] [y-pos 200] 
                         [right? true] [speed 10]))
     (define sqtoy5 (new SquareToy% [x-pos 380] [y-pos 200] 
                         [right? false] [speed 10]))
     (define sqtoy6 (new SquareToy% [x-pos 200] [y-pos 200] 
                         [right? true] [speed 10]))
     (define sqtoy7 (new SquareToy% [x-pos 210] [y-pos 200] 
                         [right? true] [speed 10]))
     (define sqtoy8 (new SquareToy% [x-pos -10] [y-pos 200] 
                         [right? false] [speed 10]))
     (define sqtoy9 (new SquareToy% [x-pos 20] [y-pos 200] 
                         [right? true] [speed 10]))
     (define sqtoy10 (new SquareToy% [x-pos 200] [y-pos 200] 
                          [right? false] [speed 10]))
     (define sqtoy11 (new SquareToy% [x-pos 190] [y-pos 200] 
                          [right? false] [speed 10]))
     (define sqtoy12 (new SquareToy% [x-pos -10] [y-pos 200] 
                          [right? false] [speed 10]))
     (define sqtoy13 (new SquareToy% [x-pos 500] [y-pos 200] 
                          [right? true] [speed 10]))
     (define sqtoy14 (new SquareToy% [x-pos 200] [y-pos 200] 
                          [right? true] [speed 10]))
     )
    
    ;;testcase for for-test:toy-equal? in SquareToy%
    (send sqtoy on-tick)
    (check-equal? (send sqtoy for-test:toy-equal? sqtoy1) 
                  true "square toy after tick")
    ;;testcase for on-tick in SquareToy%
    (send sqtoy10 on-tick)
    (check-equal? (send sqtoy10 for-test:toy-equal? sqtoy11) 
                  true "square toy on-tick left")
    
    ;;testcase for make-square-toy
    (check-equal? (send (make-square-toy 20 200 10) for-test:toy-equal? sqtoy9)
                  true "make square toy")
    ;;testcase for for-test:toy-right? in SquareToy%
    (check-equal? (send sqtoy1 for-test:toy-right?) 
                  true "toy right in square toy")
    ;;testcase for for-test:toy-speed in SquareToy%
    (check-equal? (send sqtoy1 for-test:toy-speed) 
                  10 "toy speed in square toy")
    ;;testcase for toy-color in SquareToy%
    (check-equal? (send sqtoy1 toy-color) 
                  "red" "toy color in square toy")
    ;;testcase for toy-x in SquareToy%
    (check-equal? (send sqtoy1 toy-x) 
                  210 "toy x-pos in square toy")
    ;;testcase for toy-x in SquareToy%
    (check-equal? (send sqtoy1 toy-y) 
                  200 "toy y-pos in square toy")
    ;;testcase for move-left in SquareToy%
    (send sqtoy2 move-left)
    (check-equal? (send sqtoy2 for-test:toy-equal? sqtoy3) 
                  true "square toy move left")
    ;;testcase for change-direction-to-left in SquareToy%
    (send sqtoy4 change-direction-to-left)
    (check-equal? (send sqtoy4 for-test:toy-equal? sqtoy5) 
                  true "square toy change direction to left")
    ;;testcase for move-right in SquareToy%
    (send sqtoy6 move-right)
    (check-equal? (send sqtoy6 for-test:toy-equal? sqtoy7) 
                  true "square toy move right")
    ;;testcase for change-direction-to-right in SquareToy%
    (send sqtoy8 change-direction-to-right)
    (check-equal? (send sqtoy8 for-test:toy-equal? sqtoy9) 
                  true "square toy change direction to right")
    ;;testcase for check-canvas-limit-left in SquareToy%
    (send sqtoy12 check-canvas-limit-left)
    (check-equal? (send sqtoy12 for-test:toy-equal? sqtoy9) 
                  true "square toy check-canvas-limit-left")
    ;;testcase for check-canvas-limit-right in SquareToy%
    (send sqtoy13 check-canvas-limit-right)
    (check-equal? (send sqtoy13 for-test:toy-equal? sqtoy5) 
                  true "square toy check-canvas-limit-right")
    ;;testcase for add-to-scene in SquareToy%
    (check-equal? (send sqtoy14 add-to-scene EMPTY-CANVAS) 
                  (place-image  SQUARE 200 200 EMPTY-CANVAS) 
                  "add to scene square toy")
    )
  
  ;;CircleToy% testcases
  (local
    ((define cirtoy (new CircleToy% [x-pos 200] [y-pos 250] [count 4]))
     (define cirtoy2 (new CircleToy% [x-pos 200] [y-pos 250] [count 5]))
     (define cirtoy3 (new CircleToy% [x-pos 200] [y-pos 250] [count 0])))
    
    ;;testcase for for-test:toy-count in CircleToy%
    (check-equal? (send cirtoy for-test:toy-count) 4 "circle toy count")
    ;;testcase for toy-color in CircleToy%
    (check-equal? (send cirtoy toy-color) "green" "circle green color")
    ;;testcase for toy-color in CircleToy%
    (check-equal? (send cirtoy2 toy-color) "red" "circle red color")
    ;;testcase for toy-x in CircleToy%
    (check-equal? (send cirtoy2 toy-x) 200 "circle toy-x")
    ;;testcase for toy-y in CircleToy%
    (check-equal? (send cirtoy2 toy-y) 250 "circle toy-y")
    ;;testcase for on-tick in CircleToy%
    (send cirtoy on-tick)
    ;;testcase for for-test:toy-equal? in CircleToy%
    (check-equal? (send cirtoy for-test:toy-equal? cirtoy2) 
                  true "circle toys equal")
    ;;testcase for make-circle-toy
    (check-equal? (send (make-circle-toy 200 250) for-test:toy-equal? cirtoy3) 
                  true "circle toys equal")
    ;;testcase for add-to-scene in CircleToy%
    (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 9]) 
                        add-to-scene EMPTY-CANVAS) 
                  (place-image SOLID-RED 200 250 EMPTY-CANVAS) 
                  "circle add to scene")
    ;;testcase for add-to-scene in CircleToy% for green circle
    (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 4]) 
                        add-to-scene EMPTY-CANVAS) 
                  (place-image SOLID-GREEN 200 250 EMPTY-CANVAS) 
                  "circle add to scene"))
  ;;World test cases
  (local
    ((define sqtoy (new SquareToy% [x-pos 200] [y-pos 200] 
                        [right? true] [speed 10]))
     (define sqtoy1 (new SquareToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                         [right? true] [speed 10]))
     (define sqtoy2 (new SquareToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                         [right? true] [speed 10]))
     (define sqtoy3 (new SquareToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                         [right? true] [speed 10]))
     (define sqtoy4 (new SquareToy% [x-pos 210] [y-pos HALF-HEIGHT] 
                         [right? true] [speed 10]))
     (define cirtoy (new CircleToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                         [count 0]))
     (define cirtoy1 (new CircleToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                          [count 0]))
     
     (define world1 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] [toys empty]))
     (define world2 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] [toys (list sqtoy)]))
     (define world3 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] [toys (list sqtoy)]))
     (define world4 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] 
                         [toys (list sqtoy)]))
     (define world5 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] 
                         [toys (list sqtoy1 sqtoy)]))
     (define world6 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] 
                         [toys (list sqtoy2 sqtoy1 sqtoy)]))
     
     (define world7 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] 
                         [toys (list cirtoy sqtoy2 sqtoy1 sqtoy)]))
     
     (define world8 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? true] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [speed 10] 
                         [toys empty]))
     
     (define world9 (new World% [x-pos 250] [y-pos 250]
                         [selected? true] [mouse-x 250] 
                         [mouse-y 250] [speed 10] 
                         [toys empty]))
     
     (define world10 (new World% [x-pos 300] [y-pos 300]
                          [selected? true] [mouse-x 300] 
                          [mouse-y 300] [speed 10] 
                          [toys empty]))
     (define world11 (new World% [x-pos 300] [y-pos 300]
                          [selected? false] [mouse-x 300] 
                          [mouse-y 300] [speed 10] 
                          [toys empty]))
     (define world12 (new World% [x-pos 300] [y-pos 300]
                          [selected? true] [mouse-x 300] 
                          [mouse-y 300] [speed 10] 
                          [toys empty]))
     
     (define world13 (new World% [x-pos 300] [y-pos 300]
                          [selected? false] [mouse-x 300] 
                          [mouse-y 300] [speed 10] 
                          [toys empty]))
     (define w1-on-key-s (new World% [x-pos 200] [y-pos 250] [selected? false]
                              [mouse-x 200] [mouse-y 250] [speed 10] 
                              [toys (list sqtoy3)]))
     
     (define world14 (new World% [x-pos 200] [y-pos 250] [selected? false]
                          [mouse-x 200] [mouse-y 250] [speed 10] 
                          [toys (list sqtoy4)])))
    
    ;;testcase for make-world  in World%
    (check-equal? (send (make-world 10) for-test:world-equal? world1) 
                  true "checking worlds equal")
    ;;testcase for for-test:world-equal? in World%
    (check-equal? (send world2 for-test:world-equal? world3) 
                  true "checking worlds are equal")
    ;;testcase for get-toys in World%
    (check-equal? (send world2 get-toys) (list sqtoy) 
                  "get toys in world")
    ;;testcase for for-test:target-speed in World%
    (check-equal? (send world2 for-test:target-speed) 10
                  "speed from world")   
    ;;testcase for target-x in World%
    (check-equal? (send world2 target-x) HALF-WIDTH
                  "x-pos from world")
    ;;testcase for target-y in World%
    (check-equal? (send world2 target-y) HALF-HEIGHT
                  "y-pos from world")
    ;;testcase for target-selected? in World%
    (check-equal? (send world2 target-selected?) false "selected? from world")
    ;;testcase for in-circle? in World%
    (check-equal? (send world3 in-circle? HALF-WIDTH HALF-HEIGHT) 
                  true "check in circle?")
    ;;testcase for world-after-s-key in World%
    (send world4 world-after-s-key)
    (check-equal? (send world4 for-test:world-equal? world5) 
                  true "world after s key")
    ;;testcase for on-key in World% -> else condition
    (send world5 on-key "d")
    (check-equal? (send world5 for-test:world-equal? world5) 
                  true "on -key else condition in world")
    ;;testcase for on-key in World% -> s key
    (send world5 on-key "s")
    (check-equal? (send world5 for-test:world-equal? world6) 
                  true "on-key s condition")
    ;;testcase for on-key in world% -> c key
    (send world5 on-key "c")
    (check-equal? (send world5 for-test:world-equal? world7) 
                  true "on-key c condition")
    ;;testcase for world-after-c-key in World%
    (send world6 world-after-c-key)
    (check-equal? (send world6 for-test:world-equal? world7) 
                  true "world after c key")
    ;;testcase for world-after-drag in World%
    (send world7 world-after-drag 250 250)
    (check-equal? (send world7 for-test:world-equal? world7)
                  true "world after drag world not selected")
    ;;testcase for world-after-drag in World%
    (send world8 world-after-drag 250 250)
    (check-equal? (send world8 for-test:world-equal? world9)
                  true "world after drag world selected")
    
    ;;testcase for change-world in World%
    (send world8 change-world 300 300)
    (check-equal? (send world8 for-test:world-equal? world10)
                  true "change world")
    ;;testcase for world-after-button-up in World%
    (send world10 world-after-button-up)
    (check-equal? (send world10 for-test:world-equal? world10)
                  true "world after button up this condition")
    ;;testcase for world-after-button-up in World%
    (send world10 world-after-button-up)
    (check-equal? (send world10 for-test:world-equal? world11)
                  true "world after button up update condition")
    ;;testcase for world-after-button-down in World%
    (send world11 world-after-button-down 400 400)
    (check-equal? (send world11 for-test:world-equal? world11)
                  true "world after button button this condition")
    ;;testcase for world-after-button-down in World%
    (send world11 world-after-button-down 300 300)
    (check-equal? (send world11 for-test:world-equal? world12)
                  true "world after button button update condition")
    ;;testcase for on-mouse in World%
    (send world12 on-mouse 200 200 "leave")
    (check-equal? (send world12 for-test:world-equal? world12)
                  true "on mouse else condition")
    ;;testcase for on-mouse in World%
    (send world12 on-mouse 200 200 "button-up")
    (check-equal? (send world12 for-test:world-equal? world13)
                  true "on mouse button up condition")
    ;;testcase for on-mouse in World%
    (send world13 on-mouse 200 200 "drag")
    (check-equal? (send world13 for-test:world-equal? world13)
                  true "on mouse drag condition")
    ;;testcase for on-mouse in World%
    (send world13 on-mouse 10 10 "button-down")
    (check-equal? (send world13 for-test:world-equal? world13)
                  true "on mouse button down condition")
    ;;testcase for on-draw in World%
    (check-equal? (send w1-on-key-s on-draw)
                  (place-image SQUARE 200 250 
                               (place-image TARGET-CIRCLE 200 250 EMPTY-CANVAS))
                  "square on-draw")
    ;;testcase for on-tick in World%
    (send w1-on-key-s on-tick)
    (check-equal? (send w1-on-key-s for-test:world-equal? world14)
                  true "world on-tick")
    
    ))
