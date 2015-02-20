;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require rackunit)
(require "extras.rkt")

(provide
  initial-robot
  robot-left 
  robot-right
  robot-forward
  robot-north? 
  robot-south? 
  robot-east? 
  robot-west?
  )

(define WIDTH 200)  
(define HEIGHT 400)
(define RADIUS 15)

;; facing is one of the 
;; -- "North"
;; -- "South"
;; -- "West"
;; -- "East"
;; facing-fn : Facing -> ??
;; define (facing-fn f)
;;  (cond
;;    [(string=? "North" f)...]
;;    [(string=? "South" f)...]
;;    [(string=? "West" f)...]
;;    [(string=? "East" f)...]))

(define-struct robot(x y facing))

;; A robot is a (make-robot Real Real String)
;; interp:
;; x is the x-coordinate of the center of the robot.
;; y is the y-coordinate of the center of the robot.
;; facing is the direction of the robot.

;;robot-fn : Robot -> ??
;;(define (robot-fn r)
;; (...
;;   (robot-x r)
;;   (robot-y r)
;;   (robot-facing r)))


;; initial-robot : Real Real-> Robot
;; GIVEN: a set of (x,y) coordinates
;; RETURNS: a robot with its center at those coordinates, facing north(up).
;; Examples:
;; (initial-robot 10 15) -> (make-robot 10 15 "North")

(define(initial-robot x y)
  (make-robot x y "North"))


;; robot-left : Robot -> Robot
;; robot-right : Robot -> Robot
;; GIVEN : A robot
;; RETURNS : A robot like the original, but turned 90 degrees either left or right.
;; STRATEGY : Structural Decomposition
;; Examples : 
;; (robot-left (make-robot 80 90 "South")) -> (make-robot 80 90 "East")
;; (robot-left (make-robot 190 120 "West")) -> (make-robot 190 120 "South")
;; (robot-right(make-robot 50 100 "North")) -> (make-robot 50 100 "East")
;; (robot-right(make-robot 50 40 "South")) -> (make-robot 50 40 "West")

(define (robot-left y)
  (cond
    [(string=? "North" (robot-facing y))(make-robot (robot-x y)(robot-y y) "West")]
    [(string=? "South" (robot-facing y))(make-robot (robot-x y)(robot-y y) "East")]
    [(string=? "West" (robot-facing y))(make-robot (robot-x y)(robot-y y) "South")]
    [(string=? "East" (robot-facing y))(make-robot (robot-x y)(robot-y y) "North")]))
  

(define (robot-right x)
  (cond
    [(string=? "North" (robot-facing x))(make-robot (robot-x x)(robot-y x) "East")]
    [(string=? "South" (robot-facing x))(make-robot (robot-x x)(robot-y x) "West")]
    [(string=? "West" (robot-facing x))(make-robot (robot-x x)(robot-y x) "North")]
    [(string=? "East" (robot-facing x))(make-robot (robot-x x)(robot-y x) "South")]))


;; robot-north? : Robot -> Boolean
;; robot-south? : Robot -> Boolean
;; robot-east? : Robot -> Boolean
;; robot-west? : Robot -> Boolean
;; GIVEN: a robot
;; RETURNS: whether the robot is facing in the specified direction.
;; STRATEGY: Structural Decomposition on robot
;; Examples :
;; (robot-north? (make-robot 40 50 "North") -> true
;; (robot-south? (make-robot 40 50 "North") -> false
;; (robot-east? (make-robot 40 50 "North")  -> false
;; (robot-west? (make-robot 40 50 "North")  -> false

(define (robot-north? r)
  (string=? (robot-facing r) "North"))

(define (robot-south? r) 
  (string=? (robot-facing r) "South"))

(define (robot-west? r) 
  (string=? (robot-facing r) "West"))

(define (robot-east? r) 
  (string=? (robot-facing r) "East"))

;; robot-forward : Robot PosInt -> Robot
;; GIVEN: A robot and a distance
;; RETURNS: A robot like the given one, but moved forward by the specified distance.
;; If moving forward the specified distance would cause the robot to move from being
;; entirely inside the room to being even partially outside the room,then the robot 
;; should stop at the wall.
;; STRATEGY : Structural Decomposition on Robot
;; Examples :
;; (robot-forward (make-robot -50 100 "East") 300)
;; (robot-forward (make-robot 50 -50 "South") 600)
;; (robot-forward (make-robot 250 200 "West") 500)
;; (robot-forward (make-robot 70 500 "North") 500)
;; (robot-forward (make-robot 50 100 "North") 50)
;; (robot-forward (make-robot 50 100 "West") 300)
;; (robot-forward (make-robot 50 100 "South") 400)
;; (robot-forward (make-robot 50 100 "East") 30)


(define (robot-forward robo x)
  (cond
  [(> (robot-x robo) (- WIDTH RADIUS))  (cond
                                [(robot-north? robo)(robot-position robo x)]
                                [(robot-south? robo)(robot-position robo x)]
                                [(robot-west? robo)(movement-when-robot-facing-west robo x)]
                                [(robot-east? robo)(robot-position robo x)])]
  [(< (robot-x robo) RADIUS)   (cond
                                [(robot-north? robo)(robot-position robo x)]
                                [(robot-south? robo)(robot-position robo x)]
                                [(robot-west? robo)(robot-position robo x)]
                                [(robot-east? robo)(movement-when-robot-facing-east robo x)])]

  [(> (robot-y robo) (- HEIGHT RADIUS))  (cond
                                [(robot-north? robo)(movement-when-robot-facing-north robo x)]
                                [(robot-south? robo)(robot-position robo x)]
                                [(robot-west? robo)(robot-position robo x)]
                                [(robot-east? robo)(robot-position robo x)])]

  [(< (robot-y robo) RADIUS)   (cond
                                [(robot-north? robo)(robot-position robo x)]
                                [(robot-south? robo)(movement-when-robot-facing-south robo x)]
                                [(robot-west? robo)(robot-position robo x)]
                                [(robot-east? robo)(robot-position robo x)])]
  [(check-if-inside robo)  (cond
                                [(robot-north? robo)(movement-when-robot-facing-north robo x)]
                                [(robot-south? robo)(movement-when-robot-facing-south robo x)]
                                [(robot-west? robo)(movement-when-robot-facing-west robo x)]
                                [(robot-east? robo)(movement-when-robot-facing-east robo x)])]))

;; robot-position : Robot Real -> Robot
;; GIVEN : A Robot and distance to be moved
;; RETURNS : A Robot in new position
;; STRATEGY : Structural Decomposition on robot
;; Examples :
;; (robot-position (make-robot 100 200 "North") 80) -> (make-robot 100 120 "North")
;; (robot-position (make-robot 200 -20 "West") 80) -> (make-robot 120 -20 "West")

(define (robot-position robo x)
  (cond
     [(robot-north? robo)(make-robot (robot-x robo) (- (robot-y robo) x) "North")]
     [(robot-south? robo)(make-robot (robot-x robo) (+ (robot-y robo) x) "South")]
     [(robot-west? robo)(make-robot (- (robot-x robo) x) (robot-y robo) "West")]
     [(robot-east? robo)(make-robot (+ (robot-x robo) x) (robot-y robo) "East")]))


;; check-if-inside :  Robot -> Boolean
;; GIVEN : a robot
;; RETURNS : true if robot is inside the given dimensions otherwise false
;; STRATEGY : Structural Decomposition on Robot
;; Examples :
;; (check-if-inside(make-robot 100 200 "South")) -> True

(define (check-if-inside robo)
  (and (< (robot-x robo) (- WIDTH (- RADIUS 1))) (> (robot-x robo) (- RADIUS 1)) (< (robot-y robo) (- HEIGHT (- RADIUS 1))) (> (robot-y robo) (- RADIUS 1))))
 

;; movement-when-robot-facing-west : Robot Real -> Robot
;; movement-when-robot-facing-east : Robot Real -> Robot
;; movement-when-robot-facing-north : Robot Real -> Robot
;; movement-when-robot-facing-south : Robot Real -> Robot
;; GIVEN : A robot and distance to be moved forward in the given direction
;; RETURNS : A robot which has moved the required distace within the limitations
;; STRATEGY : Structural Decomposition
;; Examples :
;; (movement-when-robot-facing-west (make-robot 300 400 "West") 100) -> (make-robot 200 400 "West")
;; (movement-when-robot-facing-east (make-robot 300 100 "East") 100) -> (make-robot 185 100 "East")
;; (movement-when-robot-facing-south (make-robot 100 200 "South") 300) -> (make-robot 100 385 "South")
;; (movement-when-robot-facing-north (make-robot 100 100 "North") 200) -> (make-robot 100 15 "North")

(define (movement-when-robot-facing-west robo x)
  (if (or (> (robot-y robo) (- HEIGHT (- RADIUS 1))) (< (robot-y robo) RADIUS ))
      (robot-position robo x)
      (check-room-limit-west robo x)))

(define (movement-when-robot-facing-east robo x)
  (if (or (> (robot-y robo) (- HEIGHT RADIUS)) (< (robot-y robo) RADIUS) )
      (robot-position robo x)
      (check-room-limit-east robo x)))

(define (movement-when-robot-facing-north robo x)
  (if (or (> (robot-x robo) (- WIDTH RADIUS)) (< (robot-x robo) RADIUS) )
      (robot-position robo x)
      (check-room-limit-north robo x)))

(define (movement-when-robot-facing-south robo x)
  (if (or (> (robot-x robo) (- WIDTH RADIUS)) (< (robot-x robo) RADIUS) )
      (robot-position robo x)
      (check-room-limit-south robo x)))


;; check-room-limit-west : Robot Real -> Robot
;; check-room-limit-east : Robot Real -> Robot
;; check-room-limit-south : Robot Real -> Robot
;; check-room-limit-north : Robot Real -> Robot
;; GIVEN :  A robot and Distance to be moved forward.
;; RETURNS : A robot which has moved to the final position 
;; within the given limitations of the room.
;; STRATEGY : Structural Decomposition on Robot
;; Examples : 
;;(check-room-limit-west (make-robot 40 70 "West") 60) -> (make-robot 15 70 "West")
;;(check-room-limit-south (make-robot 40 70 "South") 600) -> (make-robot 40 385 "South")

(define (check-room-limit-west robo x)
 (if (< (- (robot-x robo) x) RADIUS)
      (make-robot RADIUS (robot-y robo) "West")
      (make-robot (- (robot-x robo) x) (robot-y robo) "West")))

(define (check-room-limit-east robo x)
 (if (> (+ (robot-x robo) x) (- WIDTH RADIUS))
      (make-robot (- WIDTH RADIUS) (robot-y robo) "East")
      (make-robot (+ (robot-x robo) x) (robot-y robo) "East")))

(define (check-room-limit-north robo x)
 (if (> (- (robot-y robo) x) RADIUS)
      (make-robot (robot-x robo) (- (robot-y robo) x) "North")
      (make-robot (robot-x robo) RADIUS "North")))

(define (check-room-limit-south robo x)
 (if (< (+ (robot-y robo) x) (- HEIGHT RADIUS))
      (make-robot (robot-x robo) (+ (robot-y robo) x) "South")
      (make-robot (robot-x robo) (- HEIGHT RADIUS) "South")))


;Tests
(begin-for-test
  (check-equal? (initial-robot 10 15) (make-robot 10 15 "North"))
  (check-equal? (robot-left (make-robot 80 90 "South")) (make-robot 80 90 "East"))
  (check-equal? (robot-left (make-robot 80 90 "North")) (make-robot 80 90 "West"))
  (check-equal? (robot-left (make-robot 80 90 "East")) (make-robot 80 90 "North"))
  (check-equal? (robot-left (make-robot 190 120 "West")) (make-robot 190 120 "South"))
  (check-equal? (robot-right(make-robot 50 100 "North")) (make-robot 50 100 "East"))
  (check-equal? (robot-right(make-robot 50 40 "South")) (make-robot 50 40 "West"))
  (check-equal? (robot-right(make-robot 50 40 "West")) (make-robot 50 40 "North"))
  (check-equal? (robot-right(make-robot 150 140 "East")) (make-robot 150 140 "South"))
  (check-equal? (robot-north? (make-robot 40 50 "North")) true)
  (check-equal? (robot-south? (make-robot 40 50 "North")) false)
  (check-equal? (robot-east? (make-robot 40 50 "North")) false)
  (check-equal? (robot-west? (make-robot 40 50 "North")) false)
  (check-equal? (robot-forward (make-robot 50 -50 "South") 600) (make-robot 50 385 "South"))
  (check-equal? (robot-forward (make-robot 250 200 "West") 500) (make-robot 15 200 "West"))
  (check-equal? (robot-forward (make-robot 70 500 "North") 500) (make-robot 70 15 "North"))
  (check-equal? (robot-forward (make-robot 50 100 "North") 50) (make-robot 50 50 "North"))
  (check-equal? (robot-forward (make-robot 50 100 "West") 300) (make-robot 15 100 "West"))
  (check-equal? (robot-forward (make-robot 50 100 "South") 400) (make-robot 50 385 "South"))
  (check-equal? (robot-forward (make-robot 50 100 "East") 30) (make-robot 80 100 "East"))
  (check-equal? (robot-forward (make-robot -50 100 "East") 300) (make-robot 185 100 "East"))
  (check-equal? (robot-forward (make-robot -50 100 "South") 300) (make-robot -50 400 "South"))
  (check-equal? (robot-forward (make-robot -50 100 "West") 300) (make-robot -350 100 "West"))
  (check-equal? (robot-forward (make-robot -70 500 "North") 500) (make-robot -70 0 "North"))
  (check-equal? (robot-forward (make-robot 700 500 "South") 500) (make-robot 700 1000 "South"))
  (check-equal? (robot-forward (make-robot 200 500 "North") 500) (make-robot 200 0 "North"))
  (check-equal? (robot-forward (make-robot 70 500 "North") 500)  (make-robot 70 15 "North"))
  (check-equal? (robot-forward (make-robot 700 500 "East") 500) (make-robot 1200 500 "East"))                                      
  (check-equal? (robot-forward (make-robot 40 800 "South") 500) (make-robot 40 1300 "South"))
  (check-equal? (robot-forward (make-robot 50 400 "West") 500) (make-robot -450 400 "West"))
  (check-equal? (robot-forward (make-robot 80 600 "East") 500) (make-robot 580 600 "East"))
  (check-equal? (robot-forward (make-robot 70 -150 "North") 300) (make-robot 70 -450 "North"))
  (check-equal? (robot-forward (make-robot 80 -190 "East") 300) (make-robot 380 -190 "East"))
  (check-equal? (robot-forward (make-robot 50 -140 "West") 300) (make-robot -250 -140 "West"))
  (check-equal? (movement-when-robot-facing-west (make-robot 300 400 "West") 100) (make-robot 200 400 "West"))
  (check-equal? (movement-when-robot-facing-east (make-robot 300 100 "East") 100) (make-robot 185 100 "East")) 
  (check-equal? (movement-when-robot-facing-south (make-robot 100 200 "South") 300) (make-robot 100 385 "South"))
  (check-equal? (movement-when-robot-facing-north (make-robot 100 100 "North") 200) (make-robot 100 15 "North"))
  (check-equal? (robot-forward (make-robot 15 385 "North") 300)(make-robot 15 85 "North"))
  (check-equal? (robot-forward (make-robot 15 385 "South") 300)(make-robot 15 385 "South"))
  (check-equal? (robot-forward (make-robot 15 385 "West") 300)(make-robot 15 385 "West"))
  (check-equal? (robot-forward (make-robot 15 385 "East") 300)(make-robot 185 385 "East"))
  (check-equal? (robot-forward (make-robot 185 385 "North") 300)(make-robot 185 85 "North"))
  (check-equal? (robot-forward (make-robot 185 385 "South") 300)(make-robot 185 385 "South"))
  (check-equal? (robot-forward (make-robot 185 385 "East") 300)(make-robot 185 385 "East"))
  (check-equal? (robot-forward (make-robot 185 385 "West") 300)(make-robot 15 385 "West"))
  (check-equal? (robot-forward (make-robot 15 15 "North") 300)(make-robot 15 15 "North"))  
  (check-equal? (robot-forward (make-robot 15 15 "South") 300) (make-robot 15 315 "South"))
  (check-equal? (robot-forward (make-robot 15 15 "East") 300)(make-robot 185 15 "East"))
  (check-equal? (robot-forward (make-robot 15 15 "West") 300)(make-robot 15 15 "West"))
  (check-equal? (robot-forward (make-robot 185 15 "North") 300)(make-robot 185 15 "North"))
  (check-equal? (robot-forward (make-robot 185 15 "South") 300) (make-robot 185 315 "South"))
  (check-equal? (robot-forward (make-robot 185 15 "East") 300) (make-robot 185 15 "East"))
  (check-equal? (robot-forward (make-robot 185 15 "West") 300) (make-robot 15 15 "West"))
  (check-equal? (robot-forward (make-robot 200 500 "North") 70)(make-robot 200 430 "North"))
  (check-equal? (robot-forward (make-robot -20 50 "South") 30)(make-robot -20 80 "South"))
  (check-equal? (robot-forward (make-robot -50 -50 "East") 60)(make-robot 10 -50 "East"))
  (check-equal? (robot-forward (make-robot 185 15 "West") 30)(make-robot 155 15 "West"))
  (check-equal? (movement-when-robot-facing-north (make-robot 200 500 "North") 70)(make-robot 200 430 "North"))
  (check-equal?(movement-when-robot-facing-south (make-robot -20 50 "South") 30)(make-robot -20 80 "South")))