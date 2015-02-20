#lang racket
;; CS5010 Problem Set 10
;; This program consists of toys on a canvas. 
;; The canvas is of size 400x500 pixels.
;; On the canvas, the system displays a circle of radius 10 in outline mode 
;; The circle initially appears in the center of the canvas. We call this 
;; circle the "target"
;; The target can be moved around the canvas by dragging it with the mouse.
;; The color of the target will change to orange when selected otherwise it
;; will be black.
;; When we press "s" key, a new square-shaped toy pops up. It is represented as
;; a 30x30 pixel outline green square, with its center located at the center of
;; the target.
;; Squares can be selected and on selection their color will change to red.
;; They move by smooth dragging.
;; Squares may also move if they are buddies with another toy. Squares become 
;; buddies when they overlap while one of those squares is moving. Once two 
;; squares are buddies they stay that way forever.
;; Two squares overlap if they intersect at any point.
;; The relationship of overlapping is not transitive. 
;; If A is buddies with B,and A is dragged so that B (not A) intersects with C:
;; then B and C are overlapping, but that doesn't make A and C overlapping.
;; Buddies travel together. If A and B are buddies, and A is dragged in some 
;; direction, then B moves the same way.
;; The relationship of being a buddy is symmetric and but not transitive: 
;; if A is a buddy of B, then B becomes a buddy of A. 
;; If A is a buddy of B and B is a buddy of C, 
;; that does not mean that A is also a buddy of C, although it may be.
;; A square moves only when it is dragged or when one of its buddies is 
;; dragged. 
;; If A is a buddy of B and B is a buddy of C, and A and C are not buddies, 
;; then:
;; If A is dragged, B moves with it, but not C, since C is not a buddy of A.
;; If B is dragged, A and C move with it, since they are both buddies of B.
;; If C is dragged, B moves with it, but not A, since A is not a buddy of C.
;; This program can be run by using the run command in the interaction window.
;; Example :
;; (run 0.25)
;; 0.25 is the frame-rate in secs/tick.It can be any positive number.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions to be provided
(provide World%
         SquareToy%
         make-world
         run
         StatefulWorld<%>
         StatefulToy<%>)

;; Required Files and libraries
(require rackunit)
(require 2htdp/universe)
(require 2htdp/image)
(require "extras.rkt")
(require "sets.rkt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CONSTANTS
;; CANVAS DIMENSIONS
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500)
(define HALF-WIDTH (/ CANVAS-WIDTH 2))
(define HALF-HEIGHT (/ CANVAS-HEIGHT 2))
;; Side of the square
(define SIDE 30)
;; Half side of the square
(define HALF-SIDE (/ SIDE 2))
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
;; COLOR STRING CONSTANTS
(define GREEN "green")
(define RED "red")
(define BLACK "black")
(define ORANGE "orange")
;; Target circle radius
(define TAR-CIR-RADIUS 10)
;; Target circle image
(define TARGET-CIRCLE (circle TAR-CIR-RADIUS "outline" BLACK))
(define TARGET-CIRCLE-SELECTED (circle TAR-CIR-RADIUS "outline" ORANGE))
(define SQUARE (square SIDE "outline" GREEN))

;;; END OF CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS
;; A ColorString is one of 
;; -- "green" interp : The colour is green.
;; -- "red"   interp : The colour is red.
;; 
;; template :
;; color-str-fn : ColorString -> ??
#;(define (color-str-fn c)
    (cond
      [(string=? c GREEN)...]
      [(string=? c RED)...]))
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
;;
;;;END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INTERFACE

(define StatefulWorld<%>
  (interface ()
    
    ;; -> Void
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after a tick.
    on-tick                             
    
    ;; Integer Integer MouseEvent -> Void
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after the given MouseEvent
    on-mouse
    
    ;; KeyEvent -> Void
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after the given KeyEvent
    on-key
    
    ;; -> Scene
    ;; Returns a Scene depicting this StatefulWorld<%> on it.
    on-draw 
    
    ;; -> Integer
    ;; RETURN: the x and y coordinates of the target
    target-x
    target-y
    
    ;; -> Boolean
    ;; Is the target selected?
    target-selected?
    
    ;; -> ColorString
    ;; color of the target
    target-color
    
    ;; -> ListOfStatefulToy<%>
    get-toys
    
    ;; -> Integer
    ;; RETURNS : Mouse x-coordinate.
    for-test:target-mx
    
    ;; -> Integer
    ;; RETURNS : Mouse y-coordinate.
    for-test:target-my
    
    ;; StatefulWorld<%> -> Boolean
    ;; RETURNS : True iff the given world and the world object will be equal
    for-test:world-equal?
    
    ))

(define StatefulToy<%> 
  (interface ()
    
    ;; Integer Integer MouseEvent -> Void
    ;; EFFECT: updates this StatefulToy<%> to the 
    ;;         state that it should be in after the given MouseEvent
    on-mouse
    
    ;; Scene -> Scene
    ;; Returns a Scene like the given one, but with this  
    ;; StatefulToy<%> drawn on it.
    add-to-scene
    
    ;; -> Int
    ;; returns the center co-ordinates of the  toy
    toy-x
    toy-y
    
    ;; -> Int
    ;; returns the co-ordinates of the mouse pointer 
    toy-mouse-x
    toy-mouse-y
    
    ;; -> ColorString
    ;; returns the current color of this StatefulToy<%>
    toy-color
    
    ;; -> Boolean
    ;; Is this StatefulToy<%> selected?
    toy-selected?
    
    ;; ->ListOfStatefulToys<%>
    ;; RETURNS: the list of buddies for the given toy
    for-test:get-buddies
    
    ;; StatefulToy<%> -> Boolean
    ;; RETURNS: whether the given toy is same as this toy or not.
    for-test:toy-equal?
    
    ))

(define Publisher<%>
  (interface()
    ;; StatefulToy<%> Integer Integer -> Void
    ;; GIVEN: a Square toy and the location of the mouse event
    ;; EFFECT: Updates the SquareToy by adding the given square toy as its buddy
    ;;         and the mouse pointer fields modified to the givne mouse event
    ;;         location
    subscribe-as-buddy
    ))

(define Subscriber<%>
  (interface()
    ;; -> Void
    ;; EFFECT: color of the toy is updated to green
    buddy-after-button-up
    
    ;; Integer Integer -> Void
    ;; GIVEN: location of the mosue pointer
    ;; EFFECT: the square toy is updated with its color to red and the center
    ;;         and mouse pointer location modified to the dragged position.
    buddy-after-drag
    
    ;; Integer Integer -> Void
    ;; GIVEN: location of the mouse event
    ;; EFFECT: the toy's state is updated by changing the color to red and its
    ;;         mouse-x and mouse-y fields modified to the given location.
    buddy-after-button-down
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A World is a (new World% [x-pos Integer] [y-pos Integer] [selected? Boolean] 
;; [mouse-x Integer] [mouse-y Integer] [toys ListOf<StatefulToy%>])      
;; interpretation : represents a world, containing the x and y co-ordinates of 
;; the center of the target circle, whether it is selected or not, x and y 
;; co-ordinates of mouse pointer and list of toys in the world.

(define World%
  (class* object% (StatefulWorld<%>)
    (init-field   x-pos    ;Integer--x-coordinate of the centre of target circle
                  y-pos    ;Integer--y-coordinate of the centre of target circle
                  selected?   ;Boolean -- Tells if the target is selected or not
                  mouse-x     ;Integer -- x-coordinate of the mouse pointer.
                  mouse-y     ;Integer -- y-coordinate of the mouse pointer.
                  toys)       ;ListOf<StatefulToy<%>> -- a list of toys which 
    ;include square toys. 
    
    (super-new)
    
    ;; on-tick : -> Void
    ;;EFFECT: updates this World to the state that it should be in after
    ;; a tick    
    ;;EXAMPLE: See test below
    ;; STRATEGY : Function Composition 
    (define/public (on-tick)
      this)
    
    ;; on-mouse : Integer Integer MouseEvent -> Void
    ;; EFFECT: updates this World to the state that it should be in
    ;; after the given MouseEvent
    ;; EXAMPLE : See test below.
    ;; STRATEGY : cases on mev : MouseEvent
    (define/public (on-mouse mx my mev)
      (begin
        (cond
          [(mouse=? mev "button-down") 
           (send this world-after-button-down mx my)]
          [(mouse=? mev "drag") (send this world-after-drag mx my)]
          [(mouse=? mev "button-up") (send this world-after-button-up)]
          [else this])
        (for-each
         ;; StatefulToy<%> -> Void
         ;; GIVEN : A square toy
         ;; EFFECT : Makes a buddy if possible and sets the effect of mouse
         ;; event on the toys.
         (lambda (toy)
           (begin
             (send toy making-buddy (set-remove toys toy) mx my mev)
             (send toy on-mouse mx my mev)))
         toys)))
    
    ;; world-after-button-up : -> Void
    ;; EFFECT: Updates the state of the world with unselecting the target circle
    ;; if it is selected else does nothing.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-button-up)
      (if selected?
          (set! selected? false)
          this))
    
    ;; world-after-button-down : Integer Integer -> Void
    ;; GIVEN: the location of a mouse event
    ;; EFFECT: Updates the state of the world with the target circle being
    ;; selected and mouse co-ordinates modified for smooth dragging if the 
    ;; mouse pointers are inside the circle else does nothing.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-button-down mx my)
      (if (send this in-circle? mx my)
          (begin
            (set! selected? true)
            (set! mouse-x (- mx x-pos))
            (set! mouse-y (- my y-pos)))
          this))
    
    ;; world-after-drag : Integer Integer -> Void
    ;; GIVEN: the location of a mouse event
    ;; EFFECT: if target circle is selected, move the target circle to the 
    ;; mouse location,otherwise ignore. 
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-drag mx my)
      (if selected?
          (send this change-world mx my)
          this))
    ;; change-world: Integer Integer -> Void
    ;; GIVEN: the location of the mouse event
    ;; EFFECT: modify the x and y co-ordinates of the target circle 
    ;; EXAMPLE: See test below
    ;; STRATEGY: function composition
    (define/public (change-world mx my)
      (begin
        (set! x-pos (- mx mouse-x))
        (set! y-pos (- my mouse-y))))
    
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
    ;; GIVEN: A key event
    ;; EFFECT : On "s", it will add a square toy to the world , otherwise
    ;;          ignores all other key events.
    ;; EXAMPLE : See test below.
    ;; STRATEGY : cases on kev : KeyEvent
    (define/public (on-key kev)
      (cond
        [(key=? kev "s") (send this world-after-s-key)]
        [else this]))
    
    ;; world-after-s-key : -> Void
    ;; EFFECT : On "s", it will add a square toy to the world having its center
    ;;          same as the target circle
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function composition
    (define/public (world-after-s-key)
      (set! toys (cons
                  (new SquareToy% [x-pos x-pos] [y-pos y-pos] [selected? false] 
                       [mouse-x x-pos] [mouse-y y-pos] [color GREEN] 
                       [ListOfBuddies empty])
                  toys)))
    
    ;; on-draw : Scene -> Scene
    ;; RETURNS: a scene like the given one, but with this world painted
    ;; on it.
    ;; EXAMPLE : See test below.
    ;; STRATEGY: HOFC
    (define/public (on-draw)
      (foldr
       ;; Toy Scene -> Scene
       ;; RETURNS : The new scene after adding the toy to the given scene
       (lambda(toy scene) (send toy add-to-scene scene))
       (if selected?  
           (place-image TARGET-CIRCLE-SELECTED x-pos y-pos EMPTY-CANVAS)    
           (place-image TARGET-CIRCLE x-pos y-pos EMPTY-CANVAS))
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
    
    ;; target-color -> ColorString
    ;; returns the current color of target
    (define/public (target-color)
      (if selected?
          ORANGE
          BLACK))
    
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
    
    ;; get-toys : -> ListOfStatefulToy<%>
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
       (equal? (send w1 target-color)
               (send this target-color))
       (andmap
        ;; StatefulToy<%> StatefulToy<%> -> Boolean
        ;; GIVEN : Two toys
        ;; RETURNS : If the two toy objects are equal or not
        (lambda (t1 t2) (send t1 for-test:toy-equal? t2))
        (send w1 get-toys)
        (send this get-toys))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A SquareToy is a (new SquareToy% [x-pos Integer] [y-pos Integer]
;; [selected? Boolean] [mouse-x Integer] [mouse-y Integer] [color ColorString] 
;; [ListOfBuddies ListOfStatefulToy<%>])
;; Intepretation : Represents a square toy with x y coordinate giving the 
;; center of the toy, whether the toy is selected or not, x y coordinates of 
;; the mouse pointer, color of the toy and list of buddies of the toy

(define SquareToy%
  (class* object% (StatefulToy<%> Publisher<%> Subscriber<%>)
    (init-field
     x-pos        ; Integer -- the square toy's x position in pixels
     y-pos        ; Integer -- the square toy's y position in pixels
     selected?    ; Boolean -- whether the square toy is selected or not
     mouse-x      ; Integer -- x co-ordinate of the mouse event
     mouse-y      ; Integer -- y co-ordinate of the mouse event
     color        ; ColorString -- color of the toy
     ListOfBuddies); ListOfStatefulToy<%> -- list of toys which are its buddies
    
    (super-new)
    
    ;; on-mouse : Integer Integer MouseEvent -> Void
    ;; EFFECT : updates this square toy to the 
    ;;          state that it should be in after the given MouseEvent
    ;; EXAMPLE : See test below
    ;; STRATEGY : Cases on mev: MouseEvent.
    (define/public (on-mouse mx my mev)
      (cond
        [(mouse=? mev "button-down") 
         (send this square-after-button-down mx my)]
        [(mouse=? mev "drag") (send this square-after-drag mx my)]
        [(mouse=? mev "button-up") (send this square-after-button-up)]
        [else this]))
    
    ;; square-after-button-down : Integer Integer -> Void
    ;; GIVEN : the location of the mouse event
    ;; EFFECT : If the mouse event is with in the square then the toy is 
    ;;         selected, its color is changed to red, its mouse positions are
    ;;         modified and all its buddies are also updated to the state they 
    ;;         should be in after a button down event
    ;; EXAMPLE : see test beow
    ;; STRATEGY : HOFC
    (define/public (square-after-button-down mx my)
      (if (send this in-square? mx my)
          (begin
            (set! selected? true)
            (set! mouse-x mx)
            (set! mouse-y my)
            (set! color RED)
            (for-each
             ;; StatefulToy<%> -> Void
             ;; GIVEN : A buddy toy
             ;; EFFECT : Makes changes to the toy for mouse button down event
             (lambda (buddy) 
               (send buddy buddy-after-button-down mx my))
             ListOfBuddies))
          this))
    
    ;; buddy-after-button-down : Integer Integer -> Void
    ;; GIVEN : location of the mouse event
    ;; EFFECT : the toy's state is updated by changing the color to red and its
    ;;         mouse-x and mouse-y fields modified to the given location.
    ;; EXAMPLE : see test below
    ;; STRATEGY : Function composition
    (define/public (buddy-after-button-down mx my)
      (begin
        (set! color RED)
        (set! mouse-x mx)
        (set! mouse-y my)))
    
    
    ;; in-square: Integer Integer -> Boolean
    ;; GIVEN: Location of the mouse event
    ;; RETURNS: whether or not the mouse event happened with in the square toy
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function Composition
    (define/public (in-square? mx my)
      (and (<= (- x-pos HALF-SIDE) mx (+ x-pos HALF-SIDE))
           (<= (- y-pos HALF-SIDE) my (+ y-pos HALF-SIDE))))
    
    
    ;; square-after-drag: Ineger Integer -> Void
    ;; GIVEN: location of the mouse event
    ;; EFFECT: if the given square toy is selected then, its ceter location and
    ;;         mouse pointer fields are updated to the dragged position and also
    ;;         toys buddies are updated to the state they should be in after 
    ;;         a drag event.
    ;; EXAMPLE: see test below
    ;; STRATEGY: HOFC
    (define/public (square-after-drag mx my)
      (if selected?
          (begin
            (set! x-pos (- mx (- mouse-x x-pos)))
            (set! y-pos (- my (- mouse-y y-pos)))
            (set! mouse-x mx)
            (set! mouse-y my)
            (for-each
             ;; StatefulToy<%> -> Void
             ;; GIVEN : A buddy toy
             ;; EFFECT : Makes changes to the toy for mouse drag event.
             (lambda (buddy) 
               (send buddy buddy-after-drag mx my)) 
             ListOfBuddies))
          this))
    
    ;; buddy-after-drag: Integer Integer -> Void
    ;; GIVEN: location of the mosue pointer
    ;; EFFECT: the square toy is updated with its color to red and the center
    ;;         and mouse pointer location modified to the dragged position.
    ;; EXAMPLE: See test below
    ;; STRATEGY: Function Composition.
    (define/public (buddy-after-drag mx my)
      (begin
        (set! x-pos (- mx (- mouse-x x-pos)))
        (set! y-pos (- my (- mouse-y y-pos)))      
        (set! mouse-x mx)
        (set! mouse-y my)    
        (set! color RED)))
    
    
    ;; square-after-button-up: -> Void
    ;; EFFECT: if the toy is selected, its unselected and its color is changed
    ;; to green and all its buddies are updated to the state they should be in
    ;; after a button up event on them.
    ;; EXAMPLE: See test below.
    ;; STRATEGY: HOFC
    (define/public (square-after-button-up)
      (if selected?
          (begin
            (set! selected? false)
            (set! color "green")
            (for-each
             ;; StatefulToy<%> -> Void
             ;; GIVEN : A buddy toy
             ;; EFFECT : Makes changes to the toy for mouse button up event.
             (lambda (buddy) 
               (send buddy buddy-after-button-up))
             ListOfBuddies))
          this))
    
    ;; buddy-after-button-up: -> Void
    ;; EFFECT: color of the toy is updated to green
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function composition
    (define/public (buddy-after-button-up)
      (set! color "green"))
    
    ;; making-buddy: StatefulToy<%> Integer Integer MouseEvent -> Void
    ;; GIVEN: a square toy, location of the mouse event and a mouse event
    ;; EFFECT: if the mouse event is drag then new buddies are added to the toy
    ;;         if possible else does nothing
    ;; EXAMPLE: See test below
    ;; STRATEGY: HOFC
    (define/public (making-buddy toys mx my mev)
      (if (mouse=? "drag" mev)
          (for-each
           ;; StatefulToy<%> -> Void
           ;; GIVEN : A square toy
           ;; EFFECT : creates a buddy after checking if it is possible
           ;; and adds the toy to the toy's list of buddies and vice versa
           (lambda (toy)
             (send this buddy-creation toy mx my))
           toys)
          this))
    
    ;; buddy-possible?: StatefulToy<%> -> Boolean
    ;; GIVEN: a square toy
    ;; RETURNS: whether or not the given toy can be made a buddy
    ;; EXAMPLE: See test below
    ;; STRATEGY: Cases on color: ColorString 
    (define/public (buddy-possible? toy)
      (cond
        [(string=? color GREEN) false]
        [(string=? color RED) (send this buddy-intersects? toy)]))
    
    ;; buddy-intersects?: StatefulToy<%> -> Boolean
    ;; GIVEN: a square toy
    ;; RETURNS: whether or not the square toy intersects with this toy.
    ;; EXAMPLE: See test below
    ;; STRATEGY: Function composition
    (define/public (buddy-intersects? toy)
      (and (>= (+ x-pos HALF-SIDE) (- (send toy toy-x) HALF-SIDE))
           (<= (- x-pos HALF-SIDE) (+ (send toy toy-x) HALF-SIDE))
           (>= (+ y-pos HALF-SIDE) (- (send toy toy-y) HALF-SIDE))
           (<= (- y-pos HALF-SIDE) (+ (send toy toy-y) HALF-SIDE))))
    
    ;; buddy-creation: StatefulToy<%> Integer Integer -> Void
    ;; GIVEN: a square toy and the location of mouse event
    ;; EFFECT: if the given square toy intersects with this toy and not a buddy
    ;;         already then make it a buddy and update the state of the buddy
    ;;         to add this toy as its buddy.
    ;; EXAMPLE: See test below
    ;; STRATEGY: Function composition
    (define/public (buddy-creation toy mx my)
      (if (and
           (send this buddy-possible? toy)
           (not (my-member? toy ListOfBuddies)))
          (begin
            (set! ListOfBuddies (cons toy ListOfBuddies))
            (send toy subscribe-as-buddy this mx my))
          this))
    
    ;; subscribe-as-buddy: StatefulToy<%> Integer Integer -> Void
    ;; GIVEN: a Square toy and the location of the mouse event
    ;; EFFECT: Updates the SquareToy by adding the given square toy as its buddy
    ;;         and the mouse pointer fields modified to the givne mouse event
    ;;         location
    ;; EXAMPLE: see test below
    ;; STRATEGY: Function Composition
    (define/public (subscribe-as-buddy toy mx my)
      (begin
        (set! mouse-x mx)
        (set! mouse-y my)
        (set! ListOfBuddies (cons toy ListOfBuddies))))
    
    ;; add-to-scene: Scene -> Scene
    ;; GIVEN: A Scene
    ;; RETURNS: A scene with an image of square toy on it
    ;; EXAMPLE : See test below.
    ;; STRATEGY: Function Composition
    (define/public (add-to-scene scene)
      (place-image (square SIDE "outline" color) x-pos y-pos scene))
    
    ;; toy-x: -> Integer
    ;; GIVEN: A Square toy
    ;; RETURNS: x position of the centre of the square toy
    ;; EXAMPLE : See test below.
    ;; STRATEGY:Function Composition
    (define/public (toy-x)
      x-pos)
    
    ;; toy-y: -> Integer
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
      (if selected?
          GREEN
          RED))
    
    ;; toy-selected? : -> Boolean
    ;; GIVEN : a square toy
    ;; RETURNS : selected or not
    ;; STRATEGY : Function Composition
    (define/public (toy-selected?)
      selected?)
    
    ;; toy-mouse-x : -> Integer
    ;; toy-mouse-y : -> Integer
    ;; GIVEN : A Square toy
    ;; RETURNS : x and y co-ordinate of the mouse pointer location
    ;; EXAMPLE : See test below.
    ;; STRATEGY : Function Composition 
    (define/public (toy-mouse-x)
      mouse-x)
    
    (define/public (toy-mouse-y)
      mouse-y)
    
    ;;for-test:get-buddies: ->ListOfStatefulToy<%>
    ;;RETURNS: the list of buddies for the given toy
    ;;EXAMPLE: See test below
    ;;STRATEGY; Function Composition
    (define/public (for-test:get-buddies)
      ListOfBuddies)
    
    ;;for-test:toy-equal?: StatefulToy<%> -> Boolean
    ;;RETURNS: whether the given toy is same as this toy or not.
    ;;EXAMPLE: see test below
    ;;STRATEGY: Function Composition
    (define/public (for-test:toy-equal? c1)
      (and (= (send c1 toy-x)
              (send this toy-x))
           (= (send c1 toy-y)
              (send this toy-y))
           (equal? (send c1 toy-selected?)
                   (send this toy-selected?))
           (= (send c1 toy-mouse-x)
              (send this toy-mouse-x))
           (= (send c1 toy-mouse-y)
              (send this toy-mouse-y))
           (equal? (send this toy-color)
                   (send c1 toy-color))
           (if (empty? (send c1 for-test:get-buddies))
               true
               (send (first (send c1 for-test:get-buddies)) 
                     for-test:buddy-equal?
                     (first (send this for-test:get-buddies))))))
    
    ;;for-test:buddy-equal? : StatefulToy<%> -> Boolean
    ;;RETURNS : whether the given toy is same as this toy or not.
    ;;EXAMPLE : See test below
    ;;STRATEGY : Function Composition
    (define/public (for-test:buddy-equal? c1)
      (and (= (send c1 toy-x)
              (send this toy-x))
           (= (send c1 toy-y)
              (send this toy-y))
           (equal? (send c1 toy-selected?)
                   (send this toy-selected?))
           (= (send c1 toy-mouse-x)
              (send this toy-mouse-x))
           (= (send c1 toy-mouse-y)
              (send this toy-mouse-y))
           (equal? (send this toy-color)
                   (send c1 toy-color))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; setting up the world:
;; make-world : Integer -> StatefulWorld<%>
;; GIVEN : speed of the square toy.
;; RETURNS : A world with target at the center of the canvas and toys empty.
;; EXAMPLE : See test below 
;; STRATEGY : Function Composition
(define (make-world)
  (new World% 
       [x-pos HALF-WIDTH]
       [y-pos HALF-HEIGHT]
       [selected? false]
       [mouse-x HALF-WIDTH]
       [mouse-y HALF-HEIGHT]
       [toys empty]))

;; run : Number -> StatefulWorld<%>
;; GIVEN : a frame rate, in secs/tick
;; EFFECT : runs an initial world at the given frame rate
;; RETURNS : the final state of the world
;; EXAMPLES : See test below.
;; STRATEGY : HOFC
(define (run rate)
  (big-bang (make-world)
            (on-tick
             ;; StatefulWorld<%> -> StatefulWorld<%>
             ;; RETURNS : THe same world like the given world just after one 
             ;; tick
             (lambda (w) (send w on-tick) w) rate)
            (on-draw
             ;; StatefulWorld<%> -> Scene
             ;; RETURNS : The scene depicting the givn world
             (lambda (w) (send w on-draw)))
            (on-key
             ;; StatefulWorld<%> KeyEvent -> StatefulWorld<%>
             ;; RETURNS : The world after the key event takes place
             (lambda (w kev) (send w on-key kev) w))
            (on-mouse
             ;; StatefulWorld<%> Integer Integer MouseEvent -> StatefulWorld<%>
             ;; RETURNS : The world after the mouse event takes place.
             (lambda (w x y evt) (send w on-mouse x y evt) w))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;TESTING FRAMEWORK
(begin-for-test
  (local
    ((define sqtoy (new SquareToy% [x-pos 200] [y-pos 200] [selected? false]
                        [mouse-x 200] [mouse-y 200] [color "green"]
                        [ListOfBuddies empty]))
     (define sqtoy1 (new SquareToy% [x-pos 200] [y-pos 200] [selected? true]
                         [mouse-x 200] [mouse-y 200] [color "red"]
                         [ListOfBuddies empty]))
     (define sqtoy2 (new SquareToy% [x-pos 200] [y-pos 200] [selected? false]
                         [mouse-x 200] [mouse-y 200] [color "red"]
                         [ListOfBuddies empty]))
     (define sqtoy3 (new SquareToy% [x-pos 200] [y-pos 200] [selected? true]
                         [mouse-x 200] [mouse-y 200] [color "red"]
                         [ListOfBuddies empty]))
     (define sqtoy4 (new SquareToy% [x-pos 250] [y-pos 250] [selected? true]
                         [mouse-x 250] [mouse-y 250] [color "red"]
                         [ListOfBuddies empty]))
     (define sqtoy5 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                         [mouse-x 250] [mouse-y 250] [color "green"]
                         [ListOfBuddies empty]))
     (define sqtoy6 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                         [mouse-x 250] [mouse-y 250] [color "red"]
                         [ListOfBuddies empty]))
     (define sqtoy7 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                         [mouse-x 250] [mouse-y 250] [color "green"]
                         [ListOfBuddies empty]))
     (define sqtoy8 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                         [mouse-x 270] [mouse-y 270] [color "green"]
                         [ListOfBuddies empty]))
     (define sqtoy9 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                         [mouse-x 250] [mouse-y 250] [color "green"]
                         [ListOfBuddies (list sqtoy8)]))
     (define sqtoy10 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies empty]))
     (define sqtoy11 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 270] [mouse-y 270] [color "green"]
                          [ListOfBuddies empty]))
     (define sqtoy12 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies (list sqtoy11)]))
     (define sqtoy13 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies empty]))
     (define sqtoy14 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 270] [mouse-y 270] [color "green"]
                          [ListOfBuddies empty]))
     (define sqtoy15 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies (list sqtoy14)]))
     (define sqtoy16 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies empty]))
     (define sqtoy17 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 270] [mouse-y 270] [color "red"]
                          [ListOfBuddies empty]))
     (define sqtoy18 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies (list sqtoy17)]))
     (define sqtoy19 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies (list sqtoy16)]))
     (define sqtoy20 (new SquareToy% [x-pos 250] [y-pos 250] [selected? true]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies (list sqtoy19)]))
     (define sqtoy21 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies (list sqtoy16)]))
     (define sqtoy22 (new SquareToy% [x-pos 250] [y-pos 250] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies (list sqtoy21)]))
     (define sqtoy23 (new SquareToy% [x-pos 250] [y-pos 250] [selected? true]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies empty]))
     (define sqtoy24 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 250] [mouse-y 250] [color "green"]
                          [ListOfBuddies empty]))
     (define sqtoy25 (new SquareToy% [x-pos 300] [y-pos 300] [selected? false]
                          [mouse-x 280] [mouse-y 280] [color "red"]
                          [ListOfBuddies (list sqtoy23)]))
     (define sqtoy26 (new SquareToy% [x-pos 280] [y-pos 280] [selected? true]
                          [mouse-x 280] [mouse-y 280] [color "red"]
                          [ListOfBuddies (list sqtoy25)]))
     (define sqtoy27 (new SquareToy% [x-pos 250] [y-pos 250] [selected? true]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies empty]))
     (define sqtoy28 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 270] [mouse-y 270] [color "green"]
                          [ListOfBuddies empty]))
     (define sqtoy29 (new SquareToy% [x-pos 250] [y-pos 250] [selected? true]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies (list sqtoy28)]))
     (define sqtoy30 (new SquareToy% [x-pos 250] [y-pos 250] [selected? true]
                          [mouse-x 250] [mouse-y 250] [color "red"]
                          [ListOfBuddies (list sqtoy28)]))
     (define sqtoy31 (new SquareToy% [x-pos 270] [y-pos 270] [selected? false]
                          [mouse-x 270] [mouse-y 270] [color "green"]
                          [ListOfBuddies empty]))
     )
    
    (check-equal? (send sqtoy toy-x) 200 "toy x")
    (check-equal? (send sqtoy toy-y) 200 "toy y")
    (check-equal? (send sqtoy toy-color) "red" "toy color unselected")
    (check-equal? (send sqtoy1 toy-color) "green" "toy color selected")
    (check-equal? (send sqtoy toy-selected?) false "toy selected?")
    (check-equal? (send sqtoy toy-mouse-x) 200 "toy mouse x")
    (check-equal? (send sqtoy toy-mouse-y) 200 "toy mouse y")
    (check-equal? (send sqtoy for-test:get-buddies) empty "get buddies")
    (check-equal? (send sqtoy add-to-scene EMPTY-CANVAS)
                  (place-image (square SIDE "outline" "green") 200 200 
                               EMPTY-CANVAS))
    (send sqtoy on-mouse 200 200 "leave")
    (check-equal?  (send sqtoy for-test:toy-equal? sqtoy) true "on mouse else")
    (send sqtoy buddy-after-button-down 200 200)
    (check-equal?  (send sqtoy for-test:toy-equal? sqtoy2)
                   true "buddy after button down")
    (check-equal? (send sqtoy in-square? 200 200) true "in square?")
    (send sqtoy3 buddy-after-drag 250 250)
    (check-equal? (send sqtoy3 for-test:toy-equal? sqtoy4)
                  true "buddy after drag")
    (check-equal? (send sqtoy5 buddy-possible? sqtoy5) false 
                  "buddy nt possible")
    (check-equal? (send sqtoy6 buddy-possible? sqtoy8) true "buddy possible")
    (send sqtoy4 buddy-after-button-up)
    (check-equal? (send sqtoy6 for-test:toy-equal? sqtoy7) 
                  true "buddy after button up")
    (send sqtoy7 subscribe-as-buddy sqtoy8 250 250)
    (check-equal? (send sqtoy7 for-test:toy-equal? sqtoy9)
                  true "buddy add")
    (send sqtoy16 buddy-creation sqtoy17 250 250)
    (check-equal? (send sqtoy16 for-test:toy-equal? sqtoy18)
                  true "buddy creation")
    (send sqtoy16 buddy-creation sqtoy17 250 250)
    (check-equal? (send sqtoy16 for-test:toy-equal? sqtoy16)
                  true "buddy creation this")
    (send sqtoy16 square-after-button-down 250 250)
    (check-equal? (send sqtoy16 for-test:toy-equal? sqtoy20)
                  true "square after button down")
    (send sqtoy16 square-after-button-down 500 500)
    (check-equal? (send sqtoy16 for-test:toy-equal? sqtoy16)
                  true "square after button down else condition")
    (send sqtoy20 square-after-button-up)
    (check-equal? (send sqtoy20 for-test:toy-equal? sqtoy22)
                  true "square after button up")
    (send sqtoy22 square-after-button-up)
    (check-equal? (send sqtoy22 for-test:toy-equal? sqtoy22)
                  true "square after button up else condition")
    (send sqtoy22 square-after-drag 250 250)
    (check-equal? (send sqtoy22 for-test:toy-equal? sqtoy22)
                  true "square after drag else condition")
    (send sqtoy23 buddy-creation sqtoy24 250 250)
    (send sqtoy23 square-after-drag 280 280)
    (check-equal? (send sqtoy23 for-test:toy-equal? sqtoy26)
                  true "square after drag condition")
    (send sqtoy26 on-mouse 1000 1000 "drag")
    (send sqtoy26 on-mouse 1000 1000 "button-up")
    (send sqtoy26 on-mouse 1000 1000 "button-down")
    (check-equal? (send sqtoy26 for-test:toy-equal? sqtoy26)
                  true "on mouse of square toy")
    (send sqtoy27 making-buddy (list sqtoy28) 250 250 "drag")
    (check-equal? (send sqtoy27 for-test:toy-equal? sqtoy29)
                  true "making buddy")
    (check-equal? (send sqtoy30 buddy-intersects? sqtoy31) 
                  true "buddy intersects"))
  (local
    ((define sqtoy (new SquareToy% [x-pos 200] [y-pos 250] [selected? false] 
                        [mouse-x 200] [mouse-y 250] [color "green"] 
                        [ListOfBuddies empty]))
     (define sqtoy1 (new SquareToy% [x-pos 200] [y-pos 250] [selected? false] 
                         [mouse-x 200] [mouse-y 250] [color "green"] 
                         [ListOfBuddies empty]))
     (define sqtoy2 (new SquareToy% [x-pos 200] [y-pos 250] [selected? false] 
                         [mouse-x 200] [mouse-y 250] [color "green"] 
                         [ListOfBuddies empty]))
     (define sqtoy3 (new SquareToy% [x-pos 200] [y-pos 250] [selected? false] 
                         [mouse-x 200] [mouse-y 250] [color "green"] 
                         [ListOfBuddies empty]))
     (define world1 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT]  [toys empty]))
     (define world2 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT]  [toys (list sqtoy)]))
     (define world3 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] [toys (list sqtoy)]))
     (define world4 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] 
                         [toys (list sqtoy)]))
     (define world5 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT]  
                         [toys (list sqtoy1 sqtoy)]))
     (define world6 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] 
                         [toys (list sqtoy2 sqtoy1 sqtoy)]))
     (define world7 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? false] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] 
                         [toys (list sqtoy2 sqtoy1 sqtoy)]))
     (define world8 (new World% [x-pos HALF-WIDTH] [y-pos HALF-HEIGHT]
                         [selected? true] [mouse-x HALF-WIDTH] 
                         [mouse-y HALF-HEIGHT] 
                         [toys empty]))
     (define world9 (new World% [x-pos 50] [y-pos 0]
                         [selected? true] [mouse-x 200] 
                         [mouse-y 250] 
                         [toys empty]))
     (define world10 (new World% [x-pos 100] [y-pos 50]
                          [selected? true] [mouse-x 200] 
                          [mouse-y 250]  
                          [toys empty]))
     (define world11 (new World% [x-pos 100] [y-pos 50]
                          [selected? false] [mouse-x 200] 
                          [mouse-y 250]  
                          [toys empty]))
     (define world12 (new World% [x-pos 100] [y-pos 50]
                          [selected? true] [mouse-x 200] 
                          [mouse-y 250]  
                          [toys empty]))
     (define world13 (new World% [x-pos 100] [y-pos 50]
                          [selected? false] [mouse-x 200] 
                          [mouse-y 250]  
                          [toys empty]))
     (define w1-on-key-s (new World% [x-pos 200] [y-pos 250] [selected? false]
                              [mouse-x 200] [mouse-y 250] 
                              [toys (list sqtoy3)]))
     (define w1-on-key-s1 (new World% [x-pos 200] [y-pos 250] [selected? true]
                               [mouse-x 200] [mouse-y 250] 
                               [toys (list sqtoy3)]))
     (define world15 (new World% [x-pos 100] [y-pos 50]
                          [selected? true] [mouse-x 0] 
                          [mouse-y 0]  
                          [toys empty]))
     (define world16 (new World% [x-pos 100] [y-pos 50]
                          [selected? true] [mouse-x 0] 
                          [mouse-y 0]  
                          [toys (list sqtoy)])))
    
    ;;testcase for make-world  in World%
    (check-equal? (send (make-world) for-test:world-equal? world1) 
                  true "checking worlds equal")
    ;;testcase for for-test:world-equal? in World%
    (check-equal? (send world2 for-test:world-equal? world3) 
                  true "checking worlds are equal")
    ;;testcase for get-toys in World%
    (check-equal? (send world2 get-toys) (list sqtoy) 
                  "get toys in world")  
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
                  true "world after button down this condition")
    ;;testcase for world-after-button-down in World%
    (send world11 world-after-button-down 100 50)
    (check-equal? (send world11 for-test:world-equal? world15)
                  true "world after button down update condition")
    ;;testcase for on-mouse in World%
    (send world16 on-mouse 200 200 "leave")
    (check-equal? (send world16 for-test:world-equal? world16)
                  true "on mouse else condition")
    ;;testcase for on-mouse in World%
    (send world12 on-mouse 100 50 "button-up")
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
                  (place-image 
                   SQUARE 200 250 
                   (place-image TARGET-CIRCLE 200 250 EMPTY-CANVAS))
                  "square on-draw")
    ;;testcase for on-draw in World%
    (check-equal? (send w1-on-key-s1 on-draw)
                  (place-image 
                   SQUARE 200 250 
                   (place-image TARGET-CIRCLE-SELECTED 200 250 EMPTY-CANVAS))
                  "square on-draw 1")
    ;;testcase for on-tick in World%
    (send world1 on-tick)
    (check-equal? (send world1 for-test:world-equal? world1)
                  true "world on-tick")    
    ))