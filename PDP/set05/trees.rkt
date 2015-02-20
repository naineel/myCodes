;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; This program designs and implements a system for a graphical 
;; interface for trees. This system will allow you to create and manipulate 
;; trees on a canvas. You can add, delete , drag each node of the tree.
;; Pressing "t", allows you to make a new root node.
;; Pressing "n" when a node is selected, allows you to add a new child node
;; Pressing "d" when a node is selected will allow you to delete the node 
;; and all its children.
;; Pressing "u" will delete the nodes which are in the upper half of the canvas.
;; There is a red vertical line on the canvas which shows the position of the 
;; new node which will be created.
;; The selected node will turn red when no more child nodes can be created.
;; start with (run any)
;; run can take anything as an argument as it has no effect on the world.
;; eg. (run 12)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)
(require rackunit/text-ui)

;; providing the functions
(provide 
 initial-world
 run
 world-after-mouse-event
 world-after-key-event
 world-to-roots
 node-to-center
 node-to-sons
 node-to-selected?)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN FUNCTION
;; run : Any -> World
;; GIVEN: Any value
;; EFFECT: runs a copy of an initial world.
;; RETURNS: the final state of the world. The given value is ignored.
;; Examples: (run 8)
;; STRATEGY : function composition
(define (run x)
  (big-bang (initial-world x)
            (on-draw world-to-scene)
            (on-mouse world-after-mouse-event)
            (on-key world-after-key-event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CONSTANTS
;;
;; dimensions of the canvas
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 400)
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))
;; radius of the two circles used
(define LENGTH 20)
(define HALF-LENGTH (/ LENGTH 2))
;; three types of nodes possible
(define OUTLINE-SQUARE (square LENGTH "outline" "Green"))
(define SOLID-SQUARE (square LENGTH "solid" "Green"))
(define RED-SQUARE (square LENGTH "solid" "Red"))
;;
;;
;;; END OF CONSTANTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;DATA DEFINITIONS
;; 
(define-struct node (x-pos y-pos selected? children deleted?)) 
;; A Node is a (make-node Integer Integer Boolean Nodes Boolean)
;; Interpretation :
;; x-pos gives the x-coordinate of the node's center.
;; y-pos gives the y-coordinate of the node's center.
;; selected? describes whether the node is selected or not.
;; children is list of children that parent node will have.
;; deleted? denotes if the node is deleted or not.

;; Nodes is either
;; -- empty               interp : No nodes present
;; -- (cons Node Nodes)   interp : List of nodes present.
;;
;; node-fn : Node -> ??
;;(define (node-fn nd)
;;  (...(node-x-pos nd) (node-y-pos nd)
;;      (node-selected? nd)
;;      (nodes-fn (node-children nd)
;;      (node-deleted? nd)))
;;
;; nodes-fn : Nodes -> ??
;;(define (nodes-fn lon)
;;  (cond
;;    [(empty? lon)...]
;;    [else (...(node-fn (first lon))
;;              (nodes-fn (rest lon)))]))

(define-struct world (lon))
;; A World is a (make-world Nodes)
;; Interpretation :
;; lon is a List of root nodes currently present in the world.
;; template:
;; world-fn : World -> ??
;; (define (world-fn w)
;;   (...(world-lon w)))
;;
;;; END OF DATA DEFINITIONS

;;; EXAMPLES AND TESTS CONSTANTS
(define INITIAL-WORLD (make-world empty))
(define INITIAL-SCENE (place-image EMPTY-CANVAS 200 200 EMPTY-CANVAS))
(define NODE-1 (make-node 200 10 false empty false))
(define NODE-2 (make-node 300 10 false 
                          (list 
                           (make-node 300 70 false empty false)) false))
(define UNSELECTED-ONE-GRANDCHILD-TWO-TREE-WORLD 
  (make-world (list NODE-1 NODE-2)))
(define SCENE-1 (place-image OUTLINE-SQUARE 200 10 EMPTY-CANVAS))
(define SCENE-2 (place-image OUTLINE-SQUARE 300 10 SCENE-1))
(define SCENE-3 (place-image OUTLINE-SQUARE 300 70 SCENE-2))
(define UNSELECTED-ONE-GRANDCHILD-TWO-TREE-SCENE 
  (scene+line SCENE-3 300 10 300 70 "Blue"))         
(define ONLY-NODE-SELECTED (make-node 200 10 true empty false))
(define ONLY-NODE-SELECTED-WORLD (make-world (list ONLY-NODE-SELECTED)))
(define SCENE-4 (place-image SOLID-SQUARE 200 10 EMPTY-CANVAS))
(define ONLY-NODE-SELECTED-SCENE (scene+line SCENE-4 190 0 190 400 "Red"))
(define NODE-WITH-CHILDREN-SELECTED 
  (make-node 300 10 true (list (make-node 300 70 false empty false)) false))
(define NODE-WITH-CHILDREN-SELECTED-WORLD 
  (make-world (list NODE-WITH-CHILDREN-SELECTED)))
(define SCENE-5 (place-image SOLID-SQUARE 300 10 EMPTY-CANVAS))
(define SCENE-6 (place-image OUTLINE-SQUARE 300 70 SCENE-5))
(define SCENE-7 (scene+line SCENE-6 300 10 300 70 "Blue")) 
(define NODE-WITH-CHILDREN-SELECTED-SCENE 
  (scene+line SCENE-7 250 0 250 400 "Red"))
(define ONLY-SELECTED-NODE-CROSSING-BORDER-WORLD 
  (make-world (list (make-node 5 10 true empty false))))
(define SCENE-8 (place-image RED-SQUARE 5 10 EMPTY-CANVAS))
(define ONLY-SELECTED-NODE-CROSSING-BORDER-SCENE 
  (scene+line SCENE-8 -5 0 -5 400 "Red"))
(define NODE-WITH-CHILDREN-CROSSING-BORDER 
  (make-node 30 10 true 
             (list (make-node 30 70 false empty false)) false))
(define NODE-WITH-CHILDREN-CROSSING-BORDER-WORLD 
  (make-world (list NODE-WITH-CHILDREN-CROSSING-BORDER)))
(define SCENE-9 (place-image RED-SQUARE 30 10 EMPTY-CANVAS))
(define SCENE-10 (place-image OUTLINE-SQUARE 30 70 SCENE-9))
(define SCENE-11 (scene+line SCENE-10 30 10 30 70 "Blue"))
(define NODE-WITH-CHILDREN-CROSSING-BORDER-SCENE 
  (scene+line SCENE-11 -10 0 -10 400 "Red"))
(define NEW-CHILD-FOR-ONLY-NODE 
  (make-node 200 10 true (list (make-node 200 70 false empty false)) false))
(define NEW-CHILD-FOR-NODE-WITH-CHILDREN 
  (make-node 300 10 true (list 
                          (make-node 260 70 false empty false)
                          (make-node 300 70 false empty false)) false))
(define OFF-CANVAS-NODE-WITH-CHILDREN-SELECTED 
  (make-node 30 10 true (list (make-node 30 70 false empty false)) 
             false))
(define OFF-CANVAS-NODE-WITH-CHILDREN-SELECTED-WORLD 
  (make-world (list OFF-CANVAS-NODE-WITH-CHILDREN-SELECTED)))
(define UNSELECTED-NODE-CROSSING-BORDER-WORLD 
  (make-world (list (make-node -2 10 false empty false))))
(define NODE-LOWER-HALF-WORLD 
  (make-world (list (make-node 200 300 false empty false))))
(define NODE-WITH-GRANDCHILD 
  (make-node 300 10 false (list 
                           (make-node 300 70 false empty false)) false))
(define NODE-WITH-GRANDCHILD-SELECTED 
  (make-node 300 10 false (list 
                           (make-node 300 70 true empty false)) false))
;;
;;; END OF CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-to-scene : World -> Scene
;; GIVEN : A world w.
;; RETURNS : A scene that portrays the given world.
;; Examples : See test cases below.
;; STRATEGY : Structural decomposition on w : World.
(define (world-to-scene w)
  (foldr place-the-image EMPTY-CANVAS (all-nodes (world-lon w))))

;; all-nodes : Nodes -> Nodes
;; GIVEN : A list of nodes
;; RETURNS : Returns a list of nodes with all children appended
;; to the main list.
;; Examples : 
;; (all-nodes (list (make-node 300 70 true 
;;                             (list (make-node 300 70 true empty false))
;;                             false) 
;;                  (make-node 300 70 true  
;;                             (list (make-node 300 70 true empty false))
;;                             false))) ->
;;
;;(list
;; (make-node 300 70 true (list (make-node 300 70 true empty false)) false)
;; (make-node 300 70 true empty false)
;; (make-node 300 70 true (list (make-node 300 70 true empty false)) false)
;; (make-node 300 70 true empty false))
;; STRATEGY : Structural decomposition on lon : Nodes
(define (all-nodes lon)
  (cond
    [(empty? lon) empty]
    [else (append (append-child (first lon))
                  (all-nodes (rest lon)))]))

;; append-child : Node -> Nodes 
;; GIVEN : A node.
;; RETURNS : A list of nodes with all its children appended.
;; Examples :
;; (append-child (make-node 300 70 true 
;;                              (list (make-node 300 70 true empty false))
;;                              false)) ->
;; (list (make-node 300 70 true (list (make-node 300 70 true empty false)) 
;;                  false) 
;;       (make-node 300 70 true empty false))
;; STRATEGY : Structural decomposition on nd : Node
(define (append-child nd)
  (cons nd (all-nodes (node-children nd))))

;; place-the-image : Node Scene -> Scene
;; GIVEN : A node and a scene.
;; RETURNS : A scene with the node placed on the initial scene depending on
;; whether or not a Node has any children or not.
;; Examples : See main function for tests. 
;; STRATEGY : Structural decomposition on nd : Node.
(define (place-the-image nd image) 
  (if (empty? (node-children nd))
      (only-node nd image)
      (node-with-children nd image)))

;; only-node : Node Scene -> Scene
;; GIVEN : A node and a scene.
;; RETURNS : Depending on whether a node is selected or not
;; It will return the correspoding node image and a red line showing the 
;; position of the next child.
;; Iff node is not selected a simple outline image is shown.
;; Examples : See main function for tests.
;; STRATEGY : structural decomposition on nd : Node
(define (only-node nd image)  
  (if (node-selected? nd)
      (scene+line (line-on-canvas nd image)
                  (- (node-x-pos nd) HALF-LENGTH)
                  0
                  (- (node-x-pos nd) HALF-LENGTH)
                  CANVAS-HEIGHT
                  "Red")
      (place-image OUTLINE-SQUARE (node-x-pos nd) 
                   (node-y-pos nd) image)))

;; line-on-canvas : Node Scene -> Scene
;; GIVEN : A node and a scene.
;; WHERE : A node is necessarily selected.
;; RETURNS :  A solid red square iff the red line position is out of the canvas
;; otherwise it will create a solid green square.
;; Examples : (line-on-canvas (make-node 200 10 true empty false EMPTY-CANVAS))
;; -> (place-image SOLID-SQUARE 200 10 EMPTY-CANVAS)
;; STRATEGY : structural decomposition on nd : Node.
(define (line-on-canvas nd image)
  (if (< (- (node-x-pos nd) HALF-LENGTH) 0)
      (place-image RED-SQUARE (node-x-pos nd) (node-y-pos nd) image)
      (place-image SOLID-SQUARE (node-x-pos nd) (node-y-pos nd) image)))

;; node-with-children : Node Scene -> Scene
;; GIVEN : A node and an image.
;; RETURNS : An image where the red line is shown to be to the left of 
;; the left-most node with the node children connected to the root node 
;; iff the node is selected otherwise only the node children connected 
;; to the root node are shown.
;; Examples : (node-with-children NODE-2 EMPTY-CANVAS) ->
;; (place-image NODE-2 300 70 EMPTY-CANVAS)
;; STRATEGY : structural decomposition on nd : Node 
(define (node-with-children nd image)
  (if (node-selected? nd)
      (scene+line 
       (make-connections nd image)
       (- (minimum-x (node-children nd)) (+ (* 2 LENGTH) HALF-LENGTH))
       0
       (- (minimum-x (node-children nd)) (+ (* 2 LENGTH) HALF-LENGTH))
       CANVAS-HEIGHT
       "Red")
      (making-connections-unselected nd image)))

;; make-connections : Node Scene -> Scene
;; GIVEN : A node and an existing image.
;; WHERE : The node is necessarily selected.
;; RETURNS : The root node connected with its children depending on if the node
;; is selected or not.
;; Examples : See main function test cases.
;; STRATEGY : Function Composition
(define (make-connections nd image)
  (make-center-lines nd (line-on-canvas-with-sons nd image)))

;; line-on-canvas-with-sons : Node Scene -> Scene
;; GIVEN : A node and a scene.
;; WHERE : A node is necessarily selected.
;; RETURNS :  A solid red square iff the red line position is out of the canvas
;; otherwise it will create a solid green square.
;; Examples : See main function for test cases.
;; STRATEGY : structural decomposition on nd : Node.
(define (line-on-canvas-with-sons nd image)
  (if (< (- (minimum-x (node-children nd)) (+ (* 2 LENGTH) HALF-LENGTH)) 0)
      (place-image RED-SQUARE (node-x-pos nd) (node-y-pos nd) image)
      (place-image SOLID-SQUARE (node-x-pos nd) (node-y-pos nd) image)))

;; make-center-lines : Node Scene -> Scene
;; GIVEN : A node and an exisiting scene.
;; RETURNS : A node with lines connecting it to its children node.
;; Examples : See main function for test cases. 
;; STRATEGY : Structural decomposition on nd : Node.
(define (make-center-lines nd image)
  (foldr
   ;; Node Scene -> Scene
   ;; GIVEN : A node and a scene 
   ;; RETURNS : A scene with node placed on the given scene. 
   (lambda (son scene) 
     (draw-center-lines nd son scene))
   image
   (node-children nd)))


;; making-connections-unselected : Node Scene -> Scene
;; GIVEN : A Node and a scene
;; WHERE : The node is necessarily unselected
;; RETURNS : An image of an unselected node with lines joining the root node 
;; to each of its child node. 
;; Examples : See main function for test cases.
;; STRATEGY : Structural decomposition on nd : Node
(define (making-connections-unselected nd image)
  (make-center-lines nd (place-image OUTLINE-SQUARE 
                                     (node-x-pos nd) 
                                     (node-y-pos nd) 
                                     image)))

;; get-x-coordinate : Node -> Integer
;; GIVEN : A node
;; RETURNS : The x-position of the node's center.
(define (get-x-coordinate nd)
  (node-x-pos nd))

;; get-y-coordinate : Node -> Integer
;; GIVEN : A node
;; RETURNS : The y-position of the node's center.
(define (get-y-coordinate nd)
  (node-y-pos nd))

;; draw-center-lines : Node Node Scene -> Scene
;; GIVEN : A node and an exisiting image
;; RETURNS : A scene in which a single line is drawn from the parent node
;; to the child node which is passed.
;; Examples : See main function for test cases.
;; STRATEGY : Structural decomposition on nd : Node.
(define (draw-center-lines nd son image)
  (scene+line image
              (node-x-pos nd)
              (node-y-pos nd)
              (get-x-coordinate son)
              (get-y-coordinate son)
              "Blue"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EXAMPLES AND TESTS
(define-test-suite world-to-scene-tests-suite
  (check-equal? (world-to-scene INITIAL-WORLD) INITIAL-SCENE 
                "world-to-scene empty")
  (check-equal? (world-to-scene UNSELECTED-ONE-GRANDCHILD-TWO-TREE-WORLD) 
                UNSELECTED-ONE-GRANDCHILD-TWO-TREE-SCENE
                "world-to-scene multiple target nodes")
  (check-equal? (world-to-scene ONLY-NODE-SELECTED-WORLD) 
                ONLY-NODE-SELECTED-SCENE
                "world-to-scene selecting just one node")
  (check-equal? (world-to-scene NODE-WITH-CHILDREN-SELECTED-WORLD) 
                NODE-WITH-CHILDREN-SELECTED-SCENE
                "world-to-scene selecting a target with children")
  (check-equal? (world-to-scene ONLY-SELECTED-NODE-CROSSING-BORDER-WORLD) 
                ONLY-SELECTED-NODE-CROSSING-BORDER-SCENE
                "world-to-scene just one node turned red when selected")
  (check-equal? (world-to-scene NODE-WITH-CHILDREN-CROSSING-BORDER-WORLD) 
                NODE-WITH-CHILDREN-CROSSING-BORDER-SCENE
                "world-to-scene target node with children turned red"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; initial-world : Any -> World
;; GIVEN: any value
;; RETURNS: an initial world which is empty.  The given value is ignored.
;; Example : See test below.
;; STRATEGY : Function composition.
(define (initial-world x)
  (make-world empty))

;; Examples and Tests
(define-test-suite initial-world-test-suite
  (check-equal? (initial-world 0) INITIAL-WORLD))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World and a key-event
;; RETURNS: the state of the world as it should be following the given 
;; key event
;; Examples : See test cases below.
;; STRATEGY : Cases on kev: KeyEvent.
(define (world-after-key-event w kev)
  (cond
    [(key=? kev "n") (world-after-n-key w)]
    [(key=? kev "t") (world-after-t-key w)]
    [(key=? kev "d") (world-after-d-key w)]
    [(key=? kev "u") (world-after-u-key w)]
    [else w]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-t-key : World -> World
;; GIVEN : A world
;; RETURNS : A world like the given one with the root node added after pressing
;; the t key.
;; Example: (world-after-t-key (make-world empty)) ->
;; (make-world (list (make-node 200 10 false empty false)))
;; STRATEGY : Structural decomposition on w : World
(define (world-after-t-key w)
  (make-world (cons (make-node 200 (- LENGTH HALF-LENGTH) 
                               false empty false) 
                    (world-lon w))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-n-key : World -> World
;; GIVEN : A world
;; RETURNS : A world like the given one with the change after pressing
;; the n key.
;; Example: (world-after-n-key INITIAL-WORLD) -> (make-world empty)
;; STRATEGY : structural decomposition on w : World
(define (world-after-n-key w) 
  (make-world (nodes-after-n-key (world-lon w))))

;; nodes-after-n-key : Nodes -> Nodes
;; GIVEN : A list of nodes
;; RETURNS : A root node with a child node added only if the root node 
;; is selected and the red line on canvas is inside the canvas.
;; Pressing n-key will not add a node when the root node turns red.
;; Example : (nodes-after-n-key (list NODE-1 Node-2) ->
;; (list
;;  (make-node 200 10 false empty false)
;;  (make-node 300 10 false (list (make-node 300 70 false empty false)) false))
;; STRATEGY : HOFC
(define (nodes-after-n-key lon)
  (map create-child lon))

;; create-child : Node -> Node
;; GIVEN : A node.
;; RETURNS : A node with a fixed position depending on the 
;; condition if the node is selected and if it has children or not. 
;; Examples : (create-child NODE-1) -> (make-node 200 10 false empty false)
;; STRATEGY : structural decomposition on nd : Node
(define (create-child nd) 
  (if (node-selected? nd)
      (check-for-children nd) 
      (make-node (node-x-pos nd) (node-y-pos nd) 
                 (node-selected? nd)
                 (nodes-after-n-key (node-children nd))
                 (node-deleted? nd))))

;; check-for-children : Node -> Node
;; GIVEN : A node
;; WHERE : The node is necessarily selected.
;; RETURNS : A node directly under the parent if its the first node
;; or returns another node after finding the left-most node and making
;; the node on the left of it if onlt its possible.
;; Examples : (check-for-children NODE-2)->
;; (make-node 300 10 false (list (make-node 260 70 false empty false) 
;;                               (make-node 300 70 false empty false)) false)
;; STRATEGY : Structural decomposition on nd : Node
(define (check-for-children nd)
  (if (empty? (node-children nd))
      (make-node (node-x-pos nd) (node-y-pos nd) (node-selected? nd) 
                 (adding-the-child-directly-below nd)
                 (node-deleted? nd))
      (make-node-after-minimum nd)))

;; adding-the-child-directly-below : Node -> Nodes
;; GIVEN : A node
;; WHERE : The node has no children.
;; RETURNS : A node which is added as the child node.
;; Examples : 
;; (adding-the-child-directly-below (make-node 0 10 true empty false)) ->
;; empty
;; STRATEGY : Structural decomposition on nd : Node
(define (adding-the-child-directly-below nd)
  (if (> (- (node-x-pos nd) HALF-LENGTH) 0)
      (cons (make-node (node-x-pos nd) (+ (node-y-pos nd) (* 3 LENGTH)) 
                       false empty false) 
            empty)
      empty)) 

;; make-node-after-minimum : Node -> Node
;; GIVEN : A node
;; WHERE : The node has no children. 
;; RETURNS : A node iff the red line is on the canvas otherwise it returns
;; the same node.
;; Examples : (make-node-after-minimum NODE-2) ->
;; (make-node 300 10 false
;;           (list (make-node 260 70 false empty false) 
;;                 (make-node 300 70 false empty false)) false)
;; STRATEGY : Structural decomposition on node : Node
(define (make-node-after-minimum nd)      
  (if (>= (- (minimum-x (node-children nd)) (+ (* 2 LENGTH) HALF-LENGTH)) 0)
      (make-node (node-x-pos nd) 
                 (node-y-pos nd) 
                 (node-selected? nd)
                 (adding-child-to-the-left-of-leftmost nd)
                 (node-deleted? nd)) 
      (make-node (node-x-pos nd) 
                 (node-y-pos nd) 
                 (node-selected? nd)
                 (nodes-after-n-key (node-children nd))
                 (node-deleted? nd))))

;; adding-child-to-the-left-of-leftmost : Node -> Nodes
;; GIVEN : A node
;; RETURNS : A list of nodes with a new node created on the left of the 
;; existing leftmost node.
;; Examples : (adding-child-to-the-left-of-leftmost NODE-2) ->
;; (list (make-node 260 70 false empty false) 
;;       (make-node 300 70 false empty false))
;; STRATEGY : Structural decomposition on nd : Node
(define (adding-child-to-the-left-of-leftmost nd)
  (cons (make-node (- (minimum-x (node-children nd)) 
                      (* 2 LENGTH)) 
                   (+ (node-y-pos nd) (* 3 LENGTH)) 
                   false 
                   empty
                   (node-deleted? nd)) 
        (nodes-after-n-key (node-children nd))))


;; minimum-x : Nodes -> Integer
;; GIVEN : A list of child nodes
;; RETURNS : The value of the x-coordinate of the left-most child node.
;; Examples : (minimum-x (list NODE-1 NODE-2)) -> 200
;; STRATEGY : structural decomposition on child-list : Nodes
(define (minimum-x child-list)
  (cond
    [(empty? child-list) 400]
    [else (min (node-x-pos (first child-list))
               (minimum-x (rest child-list)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-d-key : World -> World
;; GIVEN : A world w.
;; RETURNS : A World after d key is pressed.
;; Examples : (world-after-d-key INITIAL-WORLD) -> INITIAL-WORLD
;; STRATEGY : structural decomposition on w : World.
(define (world-after-d-key w)
  (make-world (node-list-after-d-key (world-lon w))))

;; node-list-after-d-key : Nodes -> Nodes
;; GIVEN : A list of nodes.
;; RETURNS : A filtered list of nodes which do not include the nodes 
;; to be deleted.
;; Examples : (node-list-after-d-key (list NODE-WITH-CHILDREN-SELECTED))-> empty
;; STRATEGY : HOFC.
(define (node-list-after-d-key lon)
  (filter-the-list
   (map node-after-d-key lon)))

;; node-after-d-key : Node -> Node
;; GIVEN : A node.
;; RETURNS : A node iff selected..deleted made true.
;; Examples : (node-after-d-key (make-node 200 10 true empty false)) ->
;; (make-node 200 10 true empty true)
;; STRATEGY : Structural decomposition on nd : Node
(define (node-after-d-key nd)
  (if (node-selected? nd)
      (make-node (node-x-pos nd) (node-y-pos nd)
                 (node-selected? nd)
                 empty 
                 true)
      (make-node (node-x-pos nd) (node-y-pos nd)
                 (node-selected? nd)
                 (node-list-after-d-key (node-children nd))
                 (node-deleted? nd))))

;; filter-the-list : Nodes -> Nodes
;; GIVEN : A list of nodes
;; RETURNS : A filtered list of nodes where each node has its deleted as false
;; Examples :
;; (filter-the-list (list
;;                   (make-node 300 10 true 
;;                    (list (make-node 300 70 false empty false)) true)
;;                   NODE-1))
;; -> (list NODE-1)
;; STRATEGY : Structural decomposition on nd : Node.
(define (filter-the-list lon)
  (filter 
   ;; Node -> Boolean
   ;; GIVEN : A node
   ;; RETURNS : The same node iff deleted is false 
   (lambda (nd) 
     (not (node-deleted? nd)))
   lon))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-u-key : World -> World
;; GIVEN : A world w.
;; RETURNS : A World after u key is pressed.
;; Examples : (world-after-u-key (list NODE-WITH-CHILDREN-SELECTED-WORLD)) ->
;; (make-world empty)
;; STRATEGY : Structural decomposition on w : World.
(define (world-after-u-key w)
  (make-world (node-list-after-u-key (world-lon w))))

;; node-list-after-u-key : Nodes -> Nodes
;; GIVEN : A list of nodes.
;; RETURNS : A filtered list of nodes which do not include any nodes which are
;; in the upper half of the canvas.
;; Examples : (node-list-after-u-key (list NODE-WITH-CHILDREN-SELECTED-WORLD) ->
;; empty
;; STRATEGY : HOFC.
(define (node-list-after-u-key lon)
  (filter-the-list
   (map node-after-u lon)))

;; node-after-u : Node -> Node
;; GIVEN : A node.
;; RETURNS : A node with deleted true iff it is in the upper half of the canvas.
;; Examples : 
;; (node-after-u (make-node 200 10 true empty false)) ->
;; (make-node 200 10 true empty true)
;; STRATEGY : Structural decomposition on nd : Node.
(define (node-after-u nd)
  (if (node-in-upper-half? nd)
      (make-node (node-x-pos nd) (node-y-pos nd)
                 (node-selected? nd)
                 empty
                 true)
      (make-node (node-x-pos nd) (node-y-pos nd)
                 (node-selected? nd)
                 (node-list-after-u-key (node-children nd))
                 (node-deleted? nd))))

;; node-in-upper-half? : Node -> Boolean
;; GIVEN : A node.
;; RETURNS : True iff the y-coordinate of the node's center is in the uppper
;; half of the canvas.
;; Examples : (node-in-upper-half? (make-node 200 10 true empty false) -> True
;; STRATEGY : Structural decomposition on nd : Node.
(define (node-in-upper-half? nd)
  (< (node-y-pos nd) (/ CANVAS-HEIGHT 2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Examples and Tests:
(define-test-suite world-after-key-event-test-suite
  
  (check-equal? (world-after-key-event INITIAL-WORLD "n") 
                (make-world (nodes-after-n-key empty))
                "world-after-n-key empty")
  
  (check-equal? (world-after-key-event 
                 (make-world (list (make-node 0 10 true empty false))) "n") 
                (make-world (list (make-node 0 10 true empty false)))
                "world with one node selected and outside the canvas 
                 so node shouldn't be created")
  
  (check-equal? (world-after-n-key UNSELECTED-NODE-CROSSING-BORDER-WORLD) 
                UNSELECTED-NODE-CROSSING-BORDER-WORLD
                "world-after-n-key unselected single node at the border")
  
  (check-equal? (world-after-n-key (make-world (list ONLY-NODE-SELECTED))) 
                (make-world (list NEW-CHILD-FOR-ONLY-NODE))
                "world-after-n-key creating new node on only selected node")
  
  (check-equal? (world-after-n-key 
                 (make-world (list NODE-WITH-CHILDREN-SELECTED))) 
                (make-world (list NEW-CHILD-FOR-NODE-WITH-CHILDREN))
                "world-after-n-key new child for target node with children")
  
  (check-equal? (world-after-n-key 
                 OFF-CANVAS-NODE-WITH-CHILDREN-SELECTED-WORLD) 
                OFF-CANVAS-NODE-WITH-CHILDREN-SELECTED-WORLD
                "world-after-n-key node with children turned red")
  
  (check-equal? (world-after-key-event INITIAL-WORLD "t") 
                (make-world 
                 (list (make-node 200 
                                  (- LENGTH HALF-LENGTH) 
                                  false 
                                  empty 
                                  false)))
                "world-after-t-key create new node at the top")
  
  (check-equal? (world-after-key-event 
                 NODE-WITH-CHILDREN-SELECTED-WORLD "d") 
                (make-world empty)
                "world-after-d-key empty")
  
  (check-equal? (world-after-key-event 
                 UNSELECTED-ONE-GRANDCHILD-TWO-TREE-WORLD "d") 
                UNSELECTED-ONE-GRANDCHILD-TWO-TREE-WORLD
                "world-after-d-key deleting unselected node")
  
  (check-equal? (world-after-key-event 
                 NODE-WITH-CHILDREN-SELECTED-WORLD "u") 
                (make-world empty)
                "world-after-u-key empty")
  
  (check-equal? (world-after-key-event 
                 NODE-LOWER-HALF-WORLD "u") 
                NODE-LOWER-HALF-WORLD
                "world-after-u-key no nodes in the upper half")
  
  (check-equal? (world-after-key-event 
                 INITIAL-WORLD "f") 
                INITIAL-WORLD
                "world-after-key after any other key pressed"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: A world, the location of a mouse event, and the mouse event itself.
;; RETURNS: the world that should follow the given world after the given
;; mouse event at the given location.
;; Examples : See test cases below.
;; STRATEGY : Structural decomposition on w : World
(define (world-after-mouse-event w mx my mev)
  (make-world (check-node-mouse-event (world-lon w) mx my mev)))

;; check-node-mouse-event : Nodes Integer Integer MouseEvent -> Nodes
;; GIVEN : A list of nodes,mouse co-ordinates and a specfic mouse event.
;; RETURNS : A list of nodes after the mouse event.
;; Examples : (check-node-mouse-event (list NODE-1 NODE-1) 200 10 "drag") ->
;; (list (make-node 200 10 false empty false) 
;;       (make-node 200 10 false empty false))
;; STRATEGY : HOFC
(define (check-node-mouse-event lon mx my mev)
  (map
   ;; Node -> Node
   ;; GIVEN : A node
   ;; RETURNS : A node after the mouse event mev.
   (lambda(nd)(check-mouse-event nd mx my mev))
   lon))

;; check-mouse-event : Node Integer Integer MouseEvent -> Node
;; GIVEN : A node,the location of the mouse pointer and the mouse event
;; RETURNS : A node after the mouse event.
;; Examples :
;; (check-mouse-event NODE-1 200 10 "button-down") ->
;; (make-node 200 10 true empty false)
;; STRATEGY : Cases on mev : MouseEvent
(define (check-mouse-event nd mx my mev)
  (cond
    [(mouse=? mev "button-down") (node-after-button-down nd mx my)]
    [(mouse=? mev "drag") (node-after-drag nd mx my)]
    [(mouse=? mev "button-up") (node-after-button-up nd mx my)]
    [else nd]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; in-square? : Node Integer Integer -> Boolean
;; GIVEN : A node and the mouse x,y coordinates.
;; RETURNS : true iff the given coordinates are inside the square.
;; Examples : (in-square? NODE-1 200 10) -> True
;; STRATEGY : Structural decomposition on nd : Node.
(define (in-square? nd mx my)
  (and
   (<= (- (node-x-pos nd) HALF-LENGTH) mx (+ (node-x-pos nd) HALF-LENGTH))
   (<= (- (node-y-pos nd) HALF-LENGTH) my (+ (node-y-pos nd) HALF-LENGTH))))

;; node-after-button-down : Node Integer Integer -> Node
;; GIVEN : A node and the mouse x,y coordinates.
;; RETURNS : A node with selected true if the mouse pointer is inside the node
;; area else returns the same node.
;; Examples : (node-after-button-down NODE-1 200 10) ->
;; (make-node 200 10 true empty false)
;; STRATEGY : Structural decomposition on nd : Node.
(define (node-after-button-down nd mx my)
  (if (in-square? nd mx my)
      (make-node (node-x-pos nd) (node-y-pos nd) true
                 (check-children-node (node-children nd) mx my)
                 (node-deleted? nd))
      (make-node (node-x-pos nd) (node-y-pos nd) false
                 (check-children-node (node-children nd) mx my)
                 (node-deleted? nd))))

;; check-children-node : Nodes Integer Integer -> Nodes
;; GIVEN : A list of child nodes, mouse x,y coordinates.
;; RETURNS : A list of nodes in which the chilld which is selected 
;; will have selected? as true.
;; Examples : (check-children-node (list NODE-1 NODE-2) 200 10)
;; (list
;;  (make-node 200 10 true empty false)
;;  (make-node 300 10 false (list (make-node 300 70 false empty false)) false))
;; STRATEGY : Structural decomposition on child-list : Nodes
(define (check-children-node child-list mx my)
  (cond
    [(empty? child-list) child-list]
    [else (cons (selecting-node (first child-list) mx my)
                (check-children-node (rest child-list) mx my))]))

;; selecting-node : Node Integer Integer -> Node
;; GIVEN :  A child node.
;; RETURNS : The same node but with selected? as true if mouse 
;; coordinates are inside the node else returns the same node.
;; Examples : (selecting-node NODE-1 200 10) ->
;; (make-node 200 10 true empty false)
;; STRATEGY : Structural decomposition on child : Node
(define (selecting-node child mx my)
  (if (in-square? child mx my)
      (make-node (node-x-pos child) (node-y-pos child) true
                 (node-children child)
                 (node-deleted? child))
      (make-node (node-x-pos child) (node-y-pos child) false
                 (check-children-node(node-children child) mx my)
                 (node-deleted? child))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; node-after-drag : Node Integer Integer -> Node
;; GIVEN : A node and the mouse x,y coordinates.
;; RETURNS : A node with the mouse pointer adjusted to remain at the same place
;; even after dragging.
;; Examples : (node-after-drag NODE-1 300 400) ->
;; (make-node 200 10 false empty false)
;; STRATEGY : Structural decomposition on nd : Node.
(define (node-after-drag nd mx my)
  (if (node-selected? nd)
      (making-the-node-after-drag nd mx my)
      (make-node (node-x-pos nd) (node-y-pos nd) false 
                 (check-node-mouse-event 
                  (node-children nd) mx my "drag")
                 (node-deleted? nd))))

;; making-the-node-after-drag : Node Integer Integer -> Node
;; GIVEN : A node.
;; WHERE : The node is selected.
;; RETURNS : The same node with
;; Examples : (making-the-node-after-drag NODE-2 200 10) ->
;; (make-node 200 10 false (list (make-node 200 70 false empty false)) false)
;; STRATEGY : Structural decomposition on nd : Node.
(define (making-the-node-after-drag nd mx my)
  (make-node mx my (node-selected? nd) 
             (children-dragging 
              (check-node-mouse-event (node-children nd) mx my "drag") 
              nd mx my) 
             (node-deleted? nd)))

;; children-dragging : Nodes Node Integer Integer -> Nodes
;; GIVEN : A list of children nodes with the parent node
;; RETURNS : The same nodes but with selected made true.
;; Examples : 
;; (children-dragging (list NODE-1 NODE-1) NODE-1 200 10) ->
;; (list (make-node 200 10 false empty false) (make-node 200 10 false empty 
;;                                                       false))
;; STRATEGY : Structural decomposition on child-list : Nodes
(define(children-dragging child-list nd mx my)
  (cond 
    [(empty? child-list) empty]
    [else (cons (making-the-node-after-drag (first child-list) 
                                            (+ (- mx (get-x-coordinate nd)) 
                                               (node-x-pos (first child-list))) 
                                            (+ (- my (get-y-coordinate nd)) 
                                               (node-y-pos (first child-list))))
                (children-dragging (rest child-list) nd mx my))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; node-after-button-up : Node Integer Integer -> Node
;; GIVEN : A node and the mouse x,y coordinates.
;; RETURNS : A node with selected? turned to false if the node is selected.
;; Examples :
;; (node-after-button-up NODE-1 200 10) -> (make-node 200 10 false empty false)
;; STRATEGY : Structural decomposition on node : Node.
(define (node-after-button-up nd mx my)
  (if (node-selected? nd)
      (make-node (node-x-pos nd) (node-y-pos nd) false 
                 (check-children-after-button-down (node-children nd))
                 (node-deleted? nd))
      (make-node (node-x-pos nd) (node-y-pos nd) false
                 (check-children-after-button-down (node-children nd))
                 (node-deleted? nd)))) 

;; check-children-after-button-down : Nodes -> Nodes
;; GIVEN : A list of child nodes
;; RETURNS : The same list of child nodes with selected? made false
;; Examples : 
;; (check-children-after-button-down (list NODE-1 NODE-1)) ->
;; (list (make-node 200 10 false empty false) 
;;       (make-node 200 10 false empty false))
;; STRATEGY : Structural decomposition on child-list : Nodes
(define (check-children-after-button-down child-list)
  (map make-child-false child-list))

;; make-child-false : Node -> Node
;; GIVEN : A node
;; RETURNS : The same node with selected? made false.
;; Examples : (make-child-false NODE-WITH-GRANDCHILD-SELECTED) -> 
;; (make-node 300 10 false (list (make-node 300 70 false empty false)) false)
;; STRATEGY : Structural decomposition on child : Nodes
(define (make-child-false child)
  (make-node (node-x-pos child) (node-y-pos child) false
             (check-children-after-button-down (node-children child))
             (node-deleted? child)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Test cases for mouse events

(define-test-suite world-after-mouse-event-tests-suite
  (check-equal? (world-after-mouse-event INITIAL-WORLD 0 0 "button-down") 
                (make-world empty)
                "world-after-mouse-event after button-down")
  (check-equal? (check-mouse-event NODE-2 200 200 "button-down") 
                NODE-2
                "world-after-button-down click outside the node")
  (check-equal? (check-mouse-event NODE-1 200 10 "button-down") 
                (make-node 200 10 true empty false)
                "world-after-button-down click on the node")
  (check-equal? (check-mouse-event NODE-WITH-GRANDCHILD 300 70 "button-down") 
                NODE-WITH-GRANDCHILD-SELECTED
                "world-after-button-down selecting grand child")
  (check-equal? (check-mouse-event NODE-2 200 200 "drag") 
                NODE-2
                "world-after-drag dragging outside the node")
  (check-equal? (check-mouse-event ONLY-NODE-SELECTED 200 10 "drag") 
                ONLY-NODE-SELECTED
                "world-after-drag dragging only selected node")
  (check-equal? (check-mouse-event NODE-WITH-GRANDCHILD-SELECTED 300 70 "drag") 
                NODE-WITH-GRANDCHILD-SELECTED
                "world-after-drag dragging selected grand child")
  (check-equal? (check-mouse-event NODE-WITH-CHILDREN-SELECTED 300 10 "drag") 
                NODE-WITH-CHILDREN-SELECTED
                "world-after-drag dragging target node with children")
  (check-equal? (check-mouse-event ONLY-NODE-SELECTED 200 10 "button-up") 
                (make-node 200 10 false empty false)
                "world-after-button-up unselecting the selected node")
  (check-equal? (check-mouse-event 
                 NODE-WITH-GRANDCHILD-SELECTED 
                 300 70 "button-up") 
                NODE-WITH-GRANDCHILD
                "world-after-button-up grand child unselect")
  (check-equal? (check-mouse-event NODE-2 200 200 "button-up") 
                NODE-2
                "world-after-button-up button-up outside the the node")
  (check-equal? (check-mouse-event NODE-1 200 200 "leave") 
                NODE-1
                "world-after-mouse-event any other events"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; world-to-roots : World -> ListOf<Node>
;; GIVEN: a World
;; RETURNS: a list of all the root nodes in the given world.
;; Examples : See test below.
;; STRATEGY : Structural decomposition on w : World.
(define (world-to-roots w)
  (world-lon w))

; Tests:
(define-test-suite world-to-roots-tests-suite
  (check-equal? (world-to-roots INITIAL-WORLD) 
                empty
                "world-to-roots empty"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; node-to-center : Node -> Posn
;; RETURNS: the center of the given node as it is to be displayed on the scene.
;; Examples : See test below.
;; STRATEGY : Structural decomposition on nd : Node. 
(define (node-to-center nd)
  (make-posn (node-x-pos nd) (node-y-pos nd)))

; Tests:
(define-test-suite node-to-center-tests-suite
  (check-equal? (node-to-center NODE-1) 
                (make-posn 200 10)
                "node-to-center ceter (200,10)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; node-to-sons : Node -> ListOf<Node>
;; RETURNS : The list of children nodes that a node contains.
;; Example : See test below.
;; STRATEGY : Structural decomposition on nd : Node.
(define (node-to-sons nd)
  (node-children nd))

; Tests:
(define-test-suite node-to-sons-tests-suite
  (check-equal? (node-to-sons NODE-1) 
                empty
                "node-to-sons node with no sons"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; node-to-selected? : Node -> Boolean
;; RETURNS : True iff the node is selected otherwise returns false
;; Example : See test below.
;; STRATEGY : Structural decomposition on nd : Node.
(define (node-to-selected? nd)
  (node-selected? nd))

;; Tests:
(define-test-suite node-to-selected?-tests-suite
  (check-equal? (node-to-selected? NODE-1)
                false
                "node-to-selected? unselected node"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Running the test suite
(run-tests world-to-scene-tests-suite)
(run-tests initial-world-test-suite)
(run-tests world-after-key-event-test-suite)
(run-tests world-after-mouse-event-tests-suite)
(run-tests world-to-roots-tests-suite)
(run-tests node-to-center-tests-suite)
(run-tests node-to-sons-tests-suite)
(run-tests node-to-selected?-tests-suite)
