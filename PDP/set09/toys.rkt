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
         World<%>
         Toy<%>)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; A ListOfToy<%> is either
;; -- empty interp : There are no toys
;; -- (cons Toy ListOfToy<%>) interp : A list of toys
;;
;; template :
;; lot-fn : ListOfToy<%> -> ??
#;(define (lot-fn toys)
    (cond
      [(empty? toys)...]
      [else (...
             (first toys)
             (lot-fn (rest toys)))]))

;;;END OF DATA DEFINITIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INTERFACES :
(define World<%>
  (interface ()
    
    ;; -> World<%> 
    ;; GIVEN: no arguments
    ;; Returns the World<%> that should follow a tick
    on-tick                             
    
    ;; Integer Integer MouseEvent -> World<%>
    ;; Returns the World<%> that should follow this one after the
    ;; given MouseEvent
    on-mouse
    
    ;; KeyEvent -> World<%>
    ;; GIVEN: a KeyEvent
    ;; Returns the World<%> that should follow this one after the
    ;; given KeyEvent
    on-key
    
    ;; -> Scene
    ;; GIVEN: a Scene
    ;; RETURNS: a scene like the given one, but with this object
    ; painted on it.
    on-draw 
    
    ;; -> Integer
    ;; RETURN: the x and y coordinates of this object
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
    ;; RETURNS: whether or not this object is selected?
    target-selected?
    
    ;; -> ListOfToy<%>
    ;; RETURNS: the list of toys in this world
    get-toys
    
    ;; World% -> Boolean
    ;; RETURNS : true iff the objects are equal 
    for-test:world-equal?
    
    ))

(define Toy<%> 
  (interface ()
    
    ;; -> Toy<%>
    ;; returns the Toy that should follow this one after a tick
    on-tick                             
    
    ;; Scene -> Scene
    ;; Returns a Scene like the given one, but with this toy drawn
    ;; on it.
    add-to-scene
    
    ;; -> PosInt
    ;; RETURNS: the x and y co-ordinates of the toy
    toy-x
    toy-y
    
    ;; -> ColorString
    ;; returns the current color of this toy
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
  (class* object% (World<%>)
    (init-field   x-pos    ;Integer--x-coordinate of the centre of target circle
                  y-pos    ;Integer--y-coordinate of the centre of target circle
                  selected?   ;Boolean -- Tells if the target is selected or not
                  mouse-x     ;Integer -- x-coordinate of the mouse pointer.
                  mouse-y     ;Integer -- y-coordinate of the mouse pointer.
                  speed       ;PosInt -- Speed of the world
                  toys)       ;ListOf<Toys> -- a list of toys which include 
                              ;square toys and circle toys. 
    
    (super-new)
    
    ;; on-tick : -> World
    ;; RETURNS : A world like this one, but as it should be after a tick
    ;; EXAMPLE : See test below.
    ;; STRATEGY : HOFC 
    (define/public (on-tick)
      (new World%
           [x-pos x-pos]
           [y-pos y-pos]
           [selected? selected?]
           [mouse-x mouse-x]
           [mouse-y mouse-y]
           [speed speed]
           [toys (map
                  (lambda(toy) (send toy on-tick))
                  (send this get-toys))]))
    
    ;; on-mouse : Integer Integer MouseEvent -> World
    ;; RETURNS : Returns the World that should follow this one after the
    ;; given MouseEvent
    ;; EXAMPLE : See test below.
    ;; STRATEGY : cases on mev : MouseEvent
    (define/public (on-mouse mx my mev)
      (cond
        [(mouse=? mev "button-down") (send this world-after-button-down mx my)]
        [(mouse=? mev "drag") (send this world-after-drag mx my)]
        [(mouse=? mev "button-up") (send this world-after-button-up)]
        [else this]))
    
    ;; world-after-button-up : -> World
    ;; RETURNS : the world that should follow this one after a button-up
    ;; DETAILS : button-up unselects the target circle if selected otherwise 
    ;; ignores it.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-button-up)
      (if selected?
          (new World%
               [x-pos x-pos]
               [y-pos y-pos]
               [selected? false]
               [mouse-x mouse-x]
               [mouse-y mouse-y]
               [speed speed]
               [toys toys])
          this))
    
    ;; world-after-button-down : Integer Integer -> World
    ;; GIVEN: the location of a mouse event
    ;; RETURNS: the world that should follow this one after a button
    ;; down at the given location
    ;; DETAILS:  If the event is inside
    ;; the target circle, returns a world just like this world, except that it 
    ;; is selected.  Otherwise returns the world is unchanged.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-button-down mx my)
      (if (send this in-circle? mx my)
          (new World%
               [x-pos x-pos]
               [y-pos y-pos]
               [selected? true]
               [mouse-x mx]
               [mouse-y my]
               [speed speed]
               [toys toys])
          this))
    
    ;; world-after-drag : Integer Integer -> World
    ;; GIVEN: the location of a mouse event
    ;; RETURNS: the world that should follow this one after a drag at
    ;; the given location 
    ;; DETAILS: if target circle is selected, move the target circle to the 
    ;; mouse location,otherwise ignore.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-drag mx my)
      (if selected?
          (new World%
               [x-pos (- mx (- mouse-x x-pos))]
               [y-pos (- my (- mouse-y y-pos))]
               [selected? true]
               [mouse-x mx]
               [mouse-y my]
               [speed speed]
               [toys toys])
          this))
    
    ;; in-circle? : Integer Integer -> Boolean
    ;; GIVEN : The location of the mouse coordinates
    ;; RETURNS : True iff the mouse coordinates are inside the circle
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (in-circle? mx my)
      (and
       (<= (- x-pos TAR-CIR-RADIUS) mx (+ x-pos TAR-CIR-RADIUS))
       (<= (- y-pos TAR-CIR-RADIUS) my (+ y-pos TAR-CIR-RADIUS))))
    
    ;; on-key : KeyEvent -> World
    ;; RETURNS : A world like this one but as it should be after the given key 
    ;; event
    ;; DETAILS : On "s", it will add a square toy to the world
    ;; on "c", it will add a circle toy to the world.
    ;; otherwise ignores all other key events
    ;; EXAMPLE : See test below.
    ;; STRATEGY : cases on kev : KeyEvent
    (define/public (on-key kev)
      (cond
        [(key=? kev "s") (send this world-after-s-key)]
        [(key=? kev "c") (send this world-after-c-key)]
        [else this]))
    
    ;; world-after-s-key : -> World
    ;; RETURNS : The given world with a square toy added to the world
    ;; DETAILS : The square toy will be added which will start moving to the 
    ;; right by default by the speed specified
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-s-key)
      (new World%
           [x-pos x-pos]
           [y-pos y-pos]
           [selected? selected?]
           [mouse-x mouse-x]
           [mouse-y mouse-y]
           [speed speed]
           [toys (cons
                  (new SquareToy% [x-pos x-pos] [y-pos y-pos] [right? true] 
                       [speed speed])
                  toys)]))
    
    ;; world-after-c-key : -> World
    ;; RETURNS : The given world with a circle toy added to the world
    ;; DETAILS : The circle toy will be added which will be a solid green 
    ;; by default and will keep changing colour between green and red at every 
    ;; 5 ticks 
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-c-key)
      (new World%
           [x-pos x-pos]
           [y-pos y-pos]
           [selected? selected?]
           [mouse-x mouse-x]
           [mouse-y mouse-y]
           [speed speed]
           [toys (cons
                  (new CircleToy% [x-pos x-pos] [y-pos y-pos] [count ZERO])
                  toys)]))
    
    ;; on-draw : Scene -> Scene
    ;; RETURNS: a scene like the given one, but with this world painted
    ;; on it.
    ;; EXAMPLE : See test below.
    ;; STRATEGY: HOFC
    (define/public (on-draw)
      (foldr
       ;; Toy Scene -> Scene
       ;; RETURNS : The new scene after adding the toy to the given scene
       ;; STRATEGY : Function composition
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
    
    ;; get-toys : -> ListOfToy<%>
    ;; RETURNS : The list of all the toys present in the world.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition.
    (define/public (get-toys)
      toys)
    
    ;; for-test:world-equal? : World% -> Boolean
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
  (class* object% (Toy<%>)
    (init-field
     x-pos        ; PosInt -- the square toy's x position in pixels
     y-pos        ; PosInt -- the square toy's y position in pixels
     speed        ; PosInt -- the square toy's speed in pixels/tick
     right?)      ; Boolean -- the square toy's direction whether right or left
    
    (super-new)
    
    ;; on-tick : SquareToy% -> SquareToy%
    ;; GIVEN : A SquareToy
    ;; RETURNS : a SquareToy that should follow after the tick
    ;; EXAMPLE : See test below.
    ;; STRATEGY :  Function Composition
    (define/public (on-tick)
      (if right?
          (send this check-canvas-limit-right)
          (send this check-canvas-limit-left)
          ))
    
    ;; check-canvas-limit-right : -> SquareToy%
    ;; RETURNS : A square toy moving left if it goes outside the canvas width
    ;; else moves right.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (check-canvas-limit-right)
      (if (> (+ (+ x-pos HALF-SIDE) speed) CANVAS-WIDTH) 
          (new SquareToy% [x-pos (- CANVAS-WIDTH HALF-SIDE)] 
               [y-pos y-pos] [right? false] [speed speed])
          (new SquareToy% [x-pos (+ x-pos speed)] 
               [y-pos y-pos] [right? true] [speed speed])))
    
    ;; check-canvas-limit-left : -> SquareToy
    ;; RETURNS : A square toy moving right if it goes outside the canvas
    ;; else moves left.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (check-canvas-limit-left)
      (if (< (- (- x-pos HALF-SIDE) speed) ZERO)
          (new SquareToy% [x-pos HALF-SIDE] 
               [y-pos y-pos] [right? true] [speed speed])
          (new SquareToy% [x-pos (- x-pos speed)] 
               [y-pos y-pos] [right? false] [speed speed])))
    
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
    
    ;; for-test:toy-right? : -> PosInt
    ;; RETURNS : true iff the given toy is going to the right.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition 
    (define/public (for-test:toy-right?)
      right?)
    
    ;; for-test:toy-equal? : SquareToy% -> Boolean
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
               (send this for-test:toy-right?))    
       ))
    
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A CircleToy is a (new CircleToy% [x-pos PosInt] [y-pos PosInt]
;; [count NonNegInt])
;; Interpretation: A CircleToy contains the x and y co-ordinates of the center
;; of the circle toy and a count to keep track of no of ticks.
(define CircleToy%
  (class* object% (Toy<%>)
    (init-field
     x-pos        ; PosInt -- x-coordinate of the center of the circle toy
     y-pos        ; PosInt -- y-coordinate of the center of the circle toy
     count)       ; NonNegInt -- Counts the number of ticks passed.
    
    (super-new)
    
    ;; on-tick : -> CircleToy%
    ;; GIVEN : a circle toy
    ;; RETURNS : A CircleToy that should follow after the tick
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (on-tick)
      (new CircleToy% [x-pos x-pos] [y-pos y-pos] [count (add1 count)]))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN : A Scene
    ;; RETURNS : a scene with an image of the circle Toy added to it.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function Composition
    (define/public (add-to-scene scene)
      (if (< (remainder count TEN) FIVE)
          (place-image SOLID-GREEN x-pos y-pos scene)
          (place-image SOLID-RED x-pos y-pos scene)
          ))
    
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
          RED
          ))
    
    ;; for-test:toy-count : -> NonNegInt
    ;; GIVEN : A circle toy.
    ;; RETURNS : The color of the circle toy.
    ;; EXAMPLES : See test below.
    ;; STRATEGY : Function composition
    (define/public (for-test:toy-count)
      count)
    
    ;; for-test:toy-equal? : CircleToy% -> Boolean
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
;; make-square-toy : PosInt PosInt PosInt -> SquareToy%
;; GIVEN : an x and a y position which are the centers of the toy, and a speed
;; RETURNS : an object representing a square toy at the given position,
;; travelling right at the given speed.
;; EXAMPLE : See test below.
;; STRATEGY : Function composition
(define (make-square-toy x y speed)
  (new SquareToy% [x-pos x] [y-pos y] [speed speed] [right? true]))

;; make-circle-toy : PosInt PosInt -> CircleToy%
;; GIVEN: an x and a y position
;; RETURNS: an object represeenting a circle toy at the given position
;; with count 0 by default.
;; EXAMPLE : See test below.
;; STRATEGY : Function composition
(define (make-circle-toy x y)
  (new CircleToy% [x-pos x] [y-pos y] [count 0]))

;;; setting up the world:
;; make-world : PosInt -> World
;; GIVEN : speed of the square toy.
;; RETURNS : A world with a helicopter and no bombs.
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

;; run : Number Integer -> World
;; GIVEN : a frame rate, in secs/tick and the speed
;; EFFECT : runs an initial world at the given frame rate
;; RETURNS : the final state of the world
;; EXAMPLES : See test below.
;; STRATEGY : HOFC
(define (run rate speed)
  (big-bang (make-world speed)
            (on-tick
             ;; World -> World
             ;; RETURNS : THe same world like the given world just after one 
             ;; tick
             (lambda (w) (send w on-tick)) rate)
            (on-draw
             ;; World -> Scene
             ;; RETURNS : The scene depicting the givn world
             (lambda (w) (send w on-draw)))
            (on-key
             ;; World KeyEvent -> World
             ;; RETURNS : The world after the key event takes place
             (lambda (w kev) (send w on-key kev)))
            (on-mouse
             ;; World Integer Integer MouseEvent -> World
             ;; RETURNS : The world after the mouse event takes place.
             (lambda (w x y evt) (send w on-mouse x y evt)))
            ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;TESTING FRAMEWORK
(begin-for-test
  (check-equal? (send (new SquareToy% [x-pos 210] [y-pos 200] 
                           [right? true] [speed 10])
                      for-test:toy-equal? 
                      (send (new SquareToy% [x-pos 200] [y-pos 200] 
                                 [right? true] [speed 10]) on-tick)) 
                true "square toys are same")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 200] [count 11]) 
                      for-test:toy-equal? 
                      (send (new CircleToy% [x-pos 200] [y-pos 200] 
                                 [count 10]) on-tick))
                true "cirlce toys are same")
  
  (check-equal? (send (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                           [selected? false] 
                           [mouse-x HALF-WIDTH] [mouse-y HALF-HEIGHT] 
                           [speed 10] [toys empty])
                      for-test:world-equal? (make-world 10)) 
                true "making new world")
  (local
    ((define empty-toy-world (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                                  [selected? false] 
                                  [mouse-x HALF-WIDTH] [mouse-y HALF-HEIGHT] 
                                  [speed 10] [toys empty]))
     
     (define sqtoy1 (new SquareToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                         [speed 10] [right? true]))
     
     (define sqtoy1-on-tick (new SquareToy% [x-pos (+ HALF-WIDTH 10)] 
                                 [y-pos HALF-HEIGHT] [speed 10] [right? true]))
     
     (define sqtoy2 (new SquareToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                         [speed 10] [right? false]))
     
     (define sqtoy2-on-tick (new SquareToy% [x-pos (- HALF-WIDTH 10)] 
                                 [y-pos HALF-HEIGHT] [speed 10] [right? false]))
     
     (define sqtoy1-at-right-boundary (new SquareToy% [x-pos 395] 
                                           [y-pos HALF-HEIGHT] [speed 10] 
                                           [right? true]))
     
     (define sqtoy1-at-right-boundary-on-tick (new SquareToy% [x-pos 380] 
                                                   [y-pos HALF-HEIGHT] 
                                                   [speed 10] [right? false]))
     
     (define sqtoy1-at-left-boundary (new SquareToy% [x-pos 5] 
                                          [y-pos HALF-HEIGHT] [speed 10] 
                                          [right? false]))
     
     (define sqtoy1-at-left-boundary-on-tick (new SquareToy% [x-pos 20] 
                                                  [y-pos HALF-HEIGHT] 
                                                  [speed 10] [right? true])))
    
    (check-equal? (send sqtoy1 for-test:toy-equal? 
                        (make-square-toy 200 250 10)) 
                  true "make square toy")
    
    (check-equal? (send sqtoy1 toy-x) HALF-WIDTH "square toy toy-x")
    
    (check-equal? (send sqtoy1 toy-y) HALF-HEIGHT "square toy toy-y")
    
    (check-equal? (send sqtoy1 toy-color) "red" "square toy color")
    
    (check-equal? (send sqtoy1 for-test:toy-right?) true "square toy right?")
    
    (check-equal? (send sqtoy1 for-test:toy-speed) 10 "square toy speed")
    
    
    (check-equal? (send empty-toy-world for-test:world-equal? 
                        (send empty-toy-world on-tick))
                  true "comparing empty toy worlds after one tick")
    
    (check-equal? (send sqtoy1-on-tick for-test:toy-equal? 
                        (send sqtoy1 on-tick))
                  true "comparing square toys after one tick")
    
    (check-equal? (send sqtoy2-on-tick for-test:toy-equal? 
                        (send sqtoy2 on-tick))
                  true 
                  "comparing square toys after one tick moving to left")
    
    (check-equal? (send sqtoy1-at-right-boundary-on-tick for-test:toy-equal? 
                        (send sqtoy1-at-right-boundary on-tick)) 
                  true "comparing square toys after one tick at right boundary")
    
    (check-equal? (send sqtoy1-at-left-boundary-on-tick
                        for-test:toy-equal? 
                        (send sqtoy1-at-left-boundary on-tick)) 
                  true "comparing square toys after one tick at left boundary")
    
    (check-equal? (send sqtoy1 add-to-scene EMPTY-CANVAS) 
                  (place-image  SQUARE 200 250 EMPTY-CANVAS) 
                  "add to scene square toy"))
  
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 9]) 
                      toy-color) "red" "red color return")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 0]) 
                      for-test:toy-equal? (make-circle-toy 200 250)) 
                true "make-circle-oty")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 9]) toy-x)
                200 "circle toy toy-x")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 9]) toy-y)
                250 "circle toy toy-y")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 9]) 
                      for-test:toy-count) 9 "circle toy toy-count")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 9]) 
                      add-to-scene EMPTY-CANVAS) 
                (place-image SOLID-RED 200 250 EMPTY-CANVAS) 
                "circle add to scene")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 4]) 
                      add-to-scene EMPTY-CANVAS) 
                (place-image SOLID-GREEN 200 250 EMPTY-CANVAS) 
                "circle add to scene")
  
  (check-equal? (send (new CircleToy% [x-pos 200] [y-pos 250] [count 5]) 
                      add-to-scene EMPTY-CANVAS) 
                (place-image SOLID-RED 200 250 EMPTY-CANVAS) 
                "circle add to scene")
  
  (local
    ((define w1 (make-world 10))
     (define w-sqtoy1 (new SquareToy% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT] 
                           [speed 10] [right? true]))
     
     (define w-sqtoy1-on-tick (new SquareToy% [x-pos (+ HALF-WIDTH 10)] 
                                   [y-pos HALF-HEIGHT] [speed 10] 
                                   [right? true]))
     
     (define w-ctoy1 (new CircleToy% [x-pos 200] [y-pos 250] [count 0]))
     
     (define w1-button-down (new World% [x-pos 200] [y-pos 250] 
                                 [selected? true] [mouse-x 200] [mouse-y 250] 
                                 [speed 10] [toys empty]))
     
     (define w1-drag (new World% [x-pos 250] [y-pos 300] [selected? true] 
                          [mouse-x 250] [mouse-y 300] [speed 10] [toys empty]))
     
     (define w1-button-up (new World% [x-pos 200] [y-pos 250] [selected? false]
                               [mouse-x 200] [mouse-y 250] [speed 10] 
                               [toys empty]))
     
     (define w1-on-key-s (new World% [x-pos 200] [y-pos 250] [selected? false]
                              [mouse-x 200] [mouse-y 250] [speed 10] 
                              [toys (list w-sqtoy1)]))
     
     (define w1-on-key-c (new World% [x-pos 200] [y-pos 250] [selected? false]
                              [mouse-x 200] [mouse-y 250] [speed 10] 
                              [toys (list w-ctoy1)]))
     
     (define w1-on-key-s-on-tick (new World% [x-pos 200] [y-pos 250] 
                                      [selected? false] [mouse-x 200] 
                                      [mouse-y 250] [speed 10] 
                                      [toys (list w-sqtoy1-on-tick)])))
    
    (check-equal? (send w1 in-circle? 200 250) true "checking in-circle")
    
    (check-equal? (send w1-button-down for-test:world-equal? 
                        (send w1 on-mouse 200 250 "button-down")) 
                  true "world after button down")
    
    (check-equal? (send w1-button-down for-test:world-equal? 
                        (send w1 world-after-button-down 200 250))
                  true "world after button down")
    
    (check-equal? (send w1-drag for-test:world-equal? 
                        (send w1-button-down on-mouse 250 300 "drag"))
                  true "world after drag")
    
    (check-equal? (send w1-drag for-test:world-equal? 
                        (send w1-button-down world-after-drag 250 300)) 
                  true "world after drag")
    
    (check-equal? (send w1-button-up for-test:world-equal? 
                        (send w1-button-down on-mouse 200 250 "button-up"))
                  true "world after button up")
    
    (check-equal? (send w1-button-up for-test:world-equal? 
                        (send w1-button-down world-after-button-up))
                  true "world after button up")
    
    (check-equal? (send w1 for-test:world-equal? 
                        (send w1 on-mouse 200 250 "button-up"))
                  true "world not selected after button up")
    
    (check-equal? (send w1 for-test:world-equal? 
                        (send w1 world-after-button-up))
                  true "world not selected after button up")
    
    (check-equal? (send w1 for-test:world-equal? 
                        (send w1 on-mouse 200 250 "drag"))
                  true "world not selected after drag")
    
    (check-equal? (send w1 for-test:world-equal? 
                        (send w1 world-after-drag 200 250))
                  true "world not selected after drag")
    
    (check-equal? (send w1 for-test:world-equal? 
                        (send w1 on-mouse 300 350 "button-down"))
                  true "mouse pointer not in boundary")
    
    (check-equal? (send w1 for-test:world-equal? 
                        (send w1 world-after-button-down 300 350))
                  true "mouse pointer not in boundary")
    
    (check-equal? (send w1-button-down for-test:world-equal? 
                        (send w1-button-down on-mouse 200 250 "leave")) 
                  true "other mouse event")
    
    (check-equal? (send w1-on-key-s for-test:world-equal? (send w1 on-key "s"))
                  true "world on key s")
    
    (check-equal? (send w1-on-key-c for-test:world-equal? (send w1 on-key "c"))
                  true "world on key c")
    
    (check-equal? (send w1-on-key-s for-test:world-equal? 
                        (send w1 world-after-s-key))
                  true "world on key s")
    
    (check-equal? (send w1-on-key-c for-test:world-equal? 
                        (send w1 world-after-c-key))
                  true "world on key c")
    
    (check-equal? (send w1 for-test:world-equal? (send w1 on-key "d"))
                  true "world on other key")
    
    (check-equal? (send w1-on-key-s-on-tick for-test:world-equal? 
                        (send w1-on-key-s on-tick))
                  true "world with square toy after tick")
    
    (check-equal? (send w1-on-key-s on-draw)
                  (place-image SQUARE 200 250 
                               (place-image TARGET-CIRCLE 200 250 EMPTY-CANVAS))
                  "square on-draw")
    ))