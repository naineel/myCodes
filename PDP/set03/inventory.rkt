;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname inventory) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")))))
;; Given an inventoy of a book store which is a list of books.We can 
;; manipulate the inventory and handle orders which are a list of line items.
(require "extras.rkt")
(require rackunit)

(provide 
 inventory-potential-profit
 inventory-total-volume
 price-for-line-item
 fillable-now?
 days-til-fillable
 price-for-order
 inventory-after-order
 increase-prices
 make-book
 make-line-item
 reorder-present?
 make-empty-reorder
 make-reorder)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS

(define-struct book(isbn title author publisher unit-price unit-cost num 
                         reorderstatus cuft))
;; A Book is a 
;; make-book(Integer String String String NonNegInt NonNegInt NonNegInt reorder
;;                   Real)
;; isbn is the 8 digit unique isbn number of the book.
;; title is the title of the book.
;; author is the author of the book.
;; publisher is the publisher of the book.
;; unit-price is the price at which the book is sold given as USD*100.
;; unit cost is the cost of the book to the bookstore given as USD*100.
;; num is the number of copies on hand.
;; reorderstatus is the re-order status of the book.
;; cuft is the volume taken up by the book in cubic feet.

;; book-fn : Book -> ??
;; (define(book-fn b)
;;   (...(book-isbn b) (book-title b) (book-author b) (book-publisher b)
;;       (book-unit-price b) (book-unit-cost b) (book-num b) (book-reorder b)
;;       (book-cuft b)...))

;; An Inventory is either
;; -- empty
;; -- (cons Book Inventory)

;; inventory-fn : Inventory -> ??
;; (define (inventory-fn invent)
;;   (cond
;;     [(empty? invent) ...]
;;     [else (...
;;             (book-fn (first invent))
;;             (inventory-fn (rest invent)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct reorderstatus(days copies))

;; A ReorderStatus is a make-reorderstatus(NonNegInt NonNegInt)
;; Interpretation :
;; days is the number of days until the next shipment of books.
;; copies is the number of copies expected to arrive at that tim.
;; template :
;; reorderstatus-fn : ReorderStatus -> ??
;; (define (reorderstatus-fn r)
;;   (...(reorderstatus-days r) (reorderstatus-copies)...)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct lineitem(isbn num))
;; A LineItem is (make-lineitem Integer PosInt)
;; Interpretation:
;; isbn is the 8 digit unique identifier for books.
;; num is the quantity to be ordered.

;; Template:
;; lineitem-fn : LineItem -> ??
;; (define(lineitem-fn l)
;;   (...(lineitem-isbn l) (lineitem-num l)...))

;; An Order is either
;; -- empty
;; -- (cons LineItem Order)

;; order-fn : Order -> ??
;; (define (order-fn l)
;;   (cond
;;     [(empty? l) ...]
;;     [else (...
;;             (lineitem-fn (first l))
;;             (order-fn (rest l)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A MaybeInteger is one of:
;; -- Integer interp : any integer value
;; -- false interp : it is false

;; template:
;; maybeinteger-fn : MaybeInteger -> ??
;; (define (maybeinteger-fn mi)
;;   (cond
;;     [(integer? mi)...]
;;     [(false? mi)...]))
;;
;;; END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

(define Inventory
  (list
   (make-book 12345678 "HtDP/1" "Felleisen" "publication" 2000 1300 50 
              (make-reorderstatus 2 10) 0.5 )
   (make-book 65488765 "EOPL" "Wand" "MIT Press" 5000 2000 40 
              (make-reorderstatus 2 100) 0.9)
   (make-book 32154988 "Hamlet" "Shakespeare" "publication" 1055 500 60
              (make-reorderstatus 4 12) 7.8)
   (make-book 64978561 "Macbeth" "Shakespeare" "publication 2" 1200 1000 70
              (make-reorderstatus 3 50) 1.3)))

(define Order
  (list
   (make-lineitem 12345678 60)
   (make-lineitem 65488765 50)
   (make-lineitem 32154988 75)
   (make-lineitem 64978561 80)
   ))

(define Order2
  (list
   (make-lineitem 65488765 30)
   (make-lineitem 12345678 40)
   ))

(define Order1
  (list
   (make-lineitem 64378581 10)
   (make-lineitem 12345678 10)
   (make-lineitem 65488765 10)
   (make-lineitem 32154988 10)
   (make-lineitem 64978561 10)
   (make-lineitem 64978581 10)))

;;; END OF CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; inventory-potential-profit : Inventory ->  Integer
;; GIVEN: an inventory
;; RETURNS: the total profit, in USD*100, for all the items in stock (i.e., 
;; how much the bookstore would profit if it sold every book in the inventory)
;; STRATEGY : Structural Decomposition on invent : Inventory
;; Examples : See test cases below.
(define (inventory-potential-profit invent)
  (cond
    [(empty? invent) 0]
    [else (+ (book-profit (first invent))
             (inventory-potential-profit (rest invent)))]))

;; book-profit : Book -> Integer
;; GIVEN : A book
;; RETURNS : profit of the book
;; STRATEGY : Structural Decomposition on b : Book
;; Examples : See test cases below.
(define (book-profit b)
  (- (book-market-price b) (book-unit-cost b)))

;; book-market-price : Book -> Integer
;; GIVEN : A book
;; RETURNS : the unit price of the book
(define (book-market-price b)
  (book-unit-price b))

(begin-for-test
  (check-equal? (inventory-potential-profit Inventory)
                4455 "Check the potential profit of the inventory"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; inventory-total-volume : Inventory -> Real
;; RETURNS: the total volume needed to store all the books in stock.
;; STRATEGY : Structural decomposition on invent : Inventory.
;; Examples : See test cases below.
(define (inventory-total-volume invent)
  (cond
    [(empty? invent) 0]
    [else (+ (book-cuft (first invent))
             (inventory-total-volume (rest invent)))]))

(begin-for-test
  (check-equal? (inventory-total-volume Inventory) 10.5 "Check volume of
 each book"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; price-for-line-item : Inventory LineItem -> MaybeInteger
;; GIVEN: an inventory and a line item.
;; RETURNS: the price for that line item (the quantity times the unit
;; price for that item).  Returns false if that isbn does not exist in
;; the inventory.
;; STRATEGY : Structural decomposition on invent : Inventory.
;; Examples : See the tests below.
(define (price-for-line-item invent item)
  (cond
    [(empty? invent) false]
    [else (if (equal? (book-isbn(first invent)) (isbn-for-line-item item))
              (market-price-for-quantity (first invent) item)
              (price-for-line-item (rest invent) item))]))

;; market-price-for-quantity : Book LineItem -> PosInt
;; GIVEN : A book and a lineitem.
;; RETURNS : price for a certain quantity of books.
;; STRATEGY : Function composition.
;; Examples : See test case below.
(define (market-price-for-quantity book item)
  (* (book-market-price book) 
     (quantity-of-line-item item)))

;; isbn-for-line-item : LineItem -> Integer
;; GIVEN : A lineitem
;; RETURNS : the isbn number for the particular lineitem
(define (isbn-for-line-item item)
  (lineitem-isbn item))

;; quantity-of-line-item : LineItem -> Integer
;; GIVEN : A lineitem
;; RETURNS : the quantity for the particular lineitem
(define (quantity-of-line-item item)
  (lineitem-num item))

(begin-for-test
  (check-equal? (price-for-line-item Inventory (make-lineitem 64978561 100))
                120000 "Price for line item..Check item price and quantity")
  (check-equal? (price-for-line-item Inventory (make-lineitem 64958561 100)) 
                false "Price for line item Check if item ISBN is in
 the Inventory"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; fillable-now? : Order Inventory -> Boolean.
;; GIVEN: an order and an inventory
;; RETURNS: true iff there are enough copies of each book on hand to fill
;; the order.  If the order contains a book that is not in the inventory,
;; then the order is not fillable.
;; STRATEGY : Structural Decompositon on invent : Inventory
;; Examples : See test cases below.
(define (fillable-now? ord invent)
  (cond
    [(empty? ord) true]
    [else  (if (check-if-available (first ord) invent)
               (fillable-now? (rest ord) invent)
               false)]))

;; check-if-available : LineItem Inventory -> Boolean.
;; GIVEN: A lineitem and an inventory
;; RETURNS: true iff there are enough copies of each book on hand to fill
;; the order.  If the order contains a book that does not have enough copies
;; in the inventory,then the order is not fillable and returns false.
;; STRATEGY : Structural decomposition on invent : Inventory
;; Examples : see the test cases below.
(define (check-if-available lineitem invent)
  (cond
    [(empty? invent) false]
    [else(if (equal? (isbn-for-line-item lineitem) (book-isbn(first invent)))
             (check-book-quantity lineitem (first invent))
             (check-if-available lineitem (rest invent)))]))

;; check-book-quantity : LineItem Book -> Boolean.
;; GIVEN: A lineitem and a book
;; RETURNS: true iff the number of books in the inventory are greater than
;; the number of books in the order.
;; STRATEGY : Structural decomposition on book : Book
;; Examples : see the test cases below.
(define (check-book-quantity lineitem book)     
  (>= (- (book-num book) (quantity-of-line-item lineitem)) 0))

(begin-for-test
  (check-equal? (fillable-now? Order2 Inventory) true "Order should be 
 fillable check the order")
  (check-equal? (fillable-now? Order Inventory) false " fillable-now? 
 Check the order again")
  (check-equal? (fillable-now? Order empty) false " fillable-now? 
 inventory empty"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; days-til-fillable : Order Inventory -> MaybeInteger
;; GIVEN: an order and an inventory
;; RETURNS: the number of days until the order is fillable, assuming all
;; the shipments come in on time.  Returns false if there won't be enough
;; copies of some book, even after the next shipment of that book comes in.
;; STRATEGY : Structural decomposition on order : Order.
;; Examples: see test cases below.
(define (days-til-fillable order inventory)
  (cond
    [(empty? order) 0]
    [else (check-member (list (comparing-isbn (first order) inventory)
                              (days-til-fillable (rest order) inventory)))]))

;; comparing-isbn : Order Inventory -> MaybeInteger
;; GIVEN: an order and an inventory.
;; RETURNS : false if the ISBN does not exist in the inventory
;; and number of days if the ISBN exists in the inventory.
;; STRATEGY : Structural Decomposition on invent : Inventory.
;; Examples : See test cases below.
(define (comparing-isbn ord invent)
  (cond
    [(empty? invent) false]
    [else (if (equal? (line-item-for-isbn ord) (book-isbn (first invent)))
              (compare-number-of-days ord invent)
              (comparing-isbn ord (rest invent)))]))

;; compare-number-of-days : Order Inventory -> MaybeInteger
;; GIVEN : An order and an Inventory
;; RETURNS : 0 if the number of books in the order are less than the 
;; books in the inventory.
;; STRATEGY : Stuctural decomposition on invent : Inventory
;; Examples : See test cases below.
(define (compare-number-of-days ord invent)
  (if (<= (line-item-number ord) (book-num (first invent)))
      0
      (compare-with-reorder-status ord invent)))

;; compare-with-reorder-status : Order Inventory -> MaybeInteger
;; GIVEN : an order and an Inventory
;; RETURNS : false if inventory and the reordered books do not match the
;; required no of books
;; will return the number of days if the condition is fulfilled.
;; STRATEGY : Structural Decomposition on invent : Inventory
;; Examples : See test cases below.
(define (compare-with-reorder-status ord invent)
  (if (<= (line-item-number ord) 
          (+ (book-num (first invent))
             (get-number-of-copies(book-reorderstatus(first invent)))))
      (get-number-of-days(book-reorderstatus(first invent)))
      false))

;; line-item-number : Order -> Integer
;; GIVEN : An Order
;; RETURNS : quantity of books ordered
(define (line-item-number ord)
  (lineitem-num ord))

;; line-item-for-isbn : Order -> Integer
;; GIVEN : An Order
;; RETURN : ISBN number
(define (line-item-for-isbn ord)
  (lineitem-isbn ord))

;; get-number-of-copies : ReorderStatus -> Integer
;; GIVEN : reorderstatus
;; RETURN : number of copies 
(define (get-number-of-copies x)
  (reorderstatus-copies x))

;; get-number-of-days : ReorderStatus -> Integer
;; GIVEN : reorderstatus
;; RETURN : number of days
(define (get-number-of-days y)
  (reorderstatus-days y))

;; check-member : List -> MaybeInteger
;; GIVEN : A list.
;; RETURNS : If list contains false it will return false otherwise it will 
;; return the maximum value from the list.
;; STRATEGY : Function Composition.
;; Examples : See test cases below.
(define (check-member list)
  (if (member? false list)
      false
      (maximum-value list)))

;; maximum-value : List -> Integer
;; GIVEN : A list.
;; RETURNS : The maximum value in the list.
;; STRATEGY : Structural decomposition on list:List.
;; Examples : See test cases below.
(define(maximum-value list)
  (cond
    [(empty? list)0]
    [else (max (first list) (maximum-value (rest list)))]))

(begin-for-test
  (check-equal? (days-til-fillable Order Inventory) false "Order 
 cannot be completed check reorder status or order again")
  (check-equal?(days-til-fillable Order1 Inventory) false "Order
 cannot be completed check reorder status or order again"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; price-for-order : Inventory Order -> NonNegInt
;; GIVEN : An inventory and an order.
;; RETURNS: the total price for the given order, in USD*100.  The price does 
;; not depend on whether any particular line item is in stock.  Line items
;; for an ISBN that is not in the inventory count as 0.
;; STRATEGY : Strategy on order : Order
;; Examples : See test cases below.

(define (price-for-order inventory order)
  (cond
    [(empty? order) 0]
    [else (add-up-members (list (comparing-isbn-for (first order) inventory)
                                (price-for-order inventory (rest order))))]))

;; comparing-isbn-for : LineItem Inventory -> NonNegInt
;; GIVEN : A lineitem and an inventory.
;; RETURNS : the price of the total quantity of books if the ISBN 
;; number matches.
;; STRATEGY : Structural Decomposition on invent : Inventory.
;; Examples : See test cases below.
(define (comparing-isbn-for li invent)
  (cond
    [(empty? invent) 0]
    [else (if (equal? (line-item-for-isbn li) (book-isbn (first invent)))
              (price-for-isbn li (first invent))
              (comparing-isbn-for li (rest invent)))]))

;; price-for-isbn : LineItem Book -> PosInt
;; GIVEN : A lineitem and a Book.
;; RETURNS : Price of the particular book.
;; STRATEGY : Structural decomposition on ord : Order.
;; Examples : See test cases below.
(define (price-for-isbn li book)
  (* (book-market-price book) (lineitem-num li)))

;; add-up-members : List -> Integer
;; GIVEN : A list
;; RETURNS : Sum of all the members of the list.
;; STRATEGY : Structural Decomposition on list : List.
;; Examples : See test cases below.
(define(add-up-members list)
  (cond
    [(empty? list) 0]
    [else (+ (first list) (add-up-members (rest list)))]))

(begin-for-test
  (check-equal? (price-for-order Inventory Order1) 92550 
                "Check price of each item properly"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; inventory-after-order : Inventory Order -> Inventory.
;; GIVEN : an inventory and an order.
;; WHERE : the order is fillable now.
;; RETURNS : the inventory after the order has been filled.
;; STRATEGY : Structural decomposition on invent : Inventory.
;; Examples : See the test cases below.
(define (inventory-after-order invent order)
  (cond
    [(empty? invent) empty]
    [else (cons (comparing-isbn-for-inventory  order (first invent)) 
                (inventory-after-order (rest invent) order))]))

;; comparing-isbn-for-inventory : Order Book -> Book
;; GIVEN : An order and a Book
;; RETURNS : a Book with an updated quantity in the inventory
;; after the order.
;; STRATEGY : Structural decomposition on ord : Order
;; Examples : See the test cases below.
(define (comparing-isbn-for-inventory ord book)
  (cond
    [(empty? ord) book]
    [else (if (equal? (line-item-for-isbn (first ord)) (book-isbn book))
              (making-the-book ord book)
              (comparing-isbn-for-inventory (rest ord) book))]))

;; making-the-book : Order Book -> Book
;; GIVEN : An order and a Book
;; RETURNS : The book with the updated quantity after the order.
;; STRATEGY : Structural decomposition on book : Book.
;; Examples : See the test cases below.
(define (making-the-book ord book)
  (make-book (book-isbn book) (book-title book) (book-author book)
             (book-publisher book) (book-unit-price book) 
             (book-unit-cost book) (update-number (first ord) book) 
             (book-reorderstatus book) (book-cuft book)))

;; update-number : LineItem Book -> Integer 
;; GIVEN : A lineitem and a book.
;; RETURNS : Number of books after the order quantity is deducted.
;; STRATEGY : Structural decomposition on book : Book.
;; Examples : See the test cases below.
(define (update-number li book)
  (- (book-num book) (quantity-of-line-item li)))

(begin-for-test
  (check-equal? (inventory-after-order Inventory Order2)
                (list
                 (make-book 12345678 "HtDP/1" "Felleisen" "publication" 2000 
                            1300 10 (make-reorderstatus 2 10) 0.5)
                 (make-book 65488765 "EOPL" "Wand" "MIT Press" 5000 2000 10 
                            (make-reorderstatus 2 100) 0.9)
                 (make-book 32154988 "Hamlet" "Shakespeare" "publication" 
                            1055 500 60 (make-reorderstatus 4 12) 7.8)
                 (make-book 64978561 "Macbeth" "Shakespeare" "publication 2" 
                            1200 1000 70 (make-reorderstatus 3 50) 1.3)) 
                "Inventory after the order" ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; increase-prices : Inventory String Real -> Inventory
;; GIVEN: an inventory, a publisher, and a percentage of increase.
;; RETURNS: an inventory like the original, except that all items by that
;; publisher have their unit prices increased by the specified
;; percentage.
;; STRATEGY : Structural decomposition on inventory : Inventory.
;; Examples: see test case below.
(define (increase-prices inventory publish percent)
  (cond
    [(empty? inventory) empty]
    [else (cons (comparing-publisher publish (first inventory) percent) 
                (increase-prices (rest inventory) publish percent))]))

;; comparing-publisher : String Book Real -> Book
;; GIVEN : A book ,name of a publisher and the percentage increase of
;; the prices.
;; RETURNS : a book with the price updated by the percentage given for the 
;; specified publisher only.
;; STRATEGY : Structural decomposition on book : Book.
;; Examples : see the test case below.
(define (comparing-publisher publish book percent)
  (if (string=? publish (book-publisher book))
      (make-book (book-isbn book) (book-title book) 
                 (book-author book) (book-publisher book)
                 (update-price percent book) (book-unit-cost book)
                 (book-num book) (book-reorderstatus book) (book-cuft book))
      book))

;; update-price : Integer Book -> PosInt
;; GIVEN : A book and percentage increase.
;; RETURNS : the updated price of the particular book.
;; STRATEGY : Structural decomposition on book : Book.
;; Examples : See test case below.
(define (update-price percent book)
  (round (+ (book-unit-price book) (* percent 0.01 (book-unit-price book)))))


(begin-for-test
  (check-equal? (increase-prices Inventory "publication" 10)
                (list
                 (make-book 12345678 "HtDP/1" "Felleisen" "publication" 2200
                            1300 50 (make-reorderstatus 2 10) 0.5)
                 (make-book 65488765 "EOPL" "Wand" "MIT Press" 5000 2000 40 
                            (make-reorderstatus 2 100) 0.9)
                 (make-book 32154988 "Hamlet" "Shakespeare" "publication" 1160
                            500 60 (make-reorderstatus 4 12) 7.8)
                 (make-book 64978561 "Macbeth" "Shakespeare" "publication 2" 
                            1200 1000 70 (make-reorderstatus 3 50) 1.3)) 
                "Inventory with increased prices"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reorder-present? : ReorderStatus -> Boolean
;; RETURNS: true iff the given ReorderStatus shows a pending re-order.
;; STRATEGY : Structural decomposition on rs : ReorderStatus
;; Examples : See the test case below.
(define (reorder-present? rs)
  (and (> (reorderstatus-days rs) 0) (> (reorderstatus-copies rs) 0)))

(begin-for-test
  (check-equal? (reorder-present? (make-reorderstatus 50 50)) true "Check
 Reorder Status"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make-empty-reorder : Any -> ReorderStatus
;; Ignores its argument.
;; RETURNS: a ReorderStatus showing no pending re-order. 
;; STRATEGY : Function Composition.
;; Examples : see the test case below.
(define (make-empty-reorder x)
  (make-reorderstatus 0 0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make-reorder : PosInt PosInt -> ReorderStatus
;; GIVEN: number of days and number of copies.
;; RETURNS: a ReorderStatus with the given data.
;; STRATEGY : Function composition.
(define (make-reorder days copies)
  (make-reorderstatus days copies))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make-line-item : PosInt PosInt -> LineItem
;; GIVEN : ISBN number and number of books ordered.
;; RETURNS : A lineitem
;; STRATEGY : Function composition.
;; Examples : See test case below.
(define(make-line-item isbn num)
  (make-lineitem isbn num))

(begin-for-test
  (check-equal? (make-empty-reorder (make-empty-reorder 50))
                (make-reorderstatus 0 0) "Check Reorder Status")
  (check-equal? (make-reorder 2 30) (make-reorderstatus 2 30) 
                "Check reorder status")
  (check-equal? (make-line-item 12345678 50) (make-lineitem 12345678 50)))


