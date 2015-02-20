;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pretty) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))
(require "extras.rkt")
(require rackunit)

;; providing the functions
(provide expr-to-strings
         make-sum-exp
         sum-exp-exprs
         make-mult-exp
         mult-exp-exprs)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;DATA DEFINITIONS
;;
;; An Expr is one of
;; -- Integer
;; -- (make-sum-exp NELOExpr)
;; -- (make-mult-exp NELOExpr)

;; expr-fn : Expr -> ??
;;(define (expr-fn expr)
;;  (cond
;;   [(integer? expr) ... ]
;;   [(sum-exp? expr) (... (sum-exp-exprs))]
;;   [(mult-exp? expr) (... (mult-exp-exprs))]))

;; A LOExpr is one of
;; -- empty
;; -- (cons Expr LOExpr)

;; exprs-fn : LOExpr -> ??
;;(define (exprs-fn exprs)
;;  (cond
;;    [(empty? exprs)...]
;;    [else (... (first exprs)
;;               (exprs-fn (rest exprs))])) 

;; A NELOExpr is a non-empty LOExpr.
;; Tempate1:
;; neloexpr-fn : NELOExpr -> ??
;; (define (neloexpr-fn neloexpr)
;;   (... (exprs-fn (first neloexpr))
;;        (neloexpr-fn (rest neloexpr))))
;
;;Template2:
;; neloexpr-fn : NELOExpr -> ??
;;(define (neloexpr-fn neloexpr)
;;  (cond
;;    [(empty? (rest neloexpr)) (... (exprs-fn (first neloexpr)))]
;;    [else (... (exprs-fn (first neloexpr))
;;               (neloexpr-fn (rest neloexpr)))])

(define-struct sum-exp (exprs))
;; A sum-exp is a (make-sum-exp NELOExpr)
;; Interpretation:
;; exprs is a Non-Empty List of Expressions
;; Template:
;; sum-exp-fn : Sum-exp -> ??
;; (define (sum-exp-fn sexp)
;;   (... (sum-exp-exprs sexp)))

(define-struct mult-exp (exprs))
;; A Mult-exp is a (make-mult-exp NELOExpr)
;; Interpretation:
;; exprs is a Non-Empty List of Expressions
;; Template:
;; mult-exp-fn : Mult-exp -> ??
;; (define (mult-exp-fn mexp)
;;   (... (mult-exp-exprs mexp)))
;;
;; ListOfString is
;; -- empty
;; -- (cons String ListOfString)
;;
;; Template :
;; (define (los-fn s)
;;   (cond
;;     [(empty? s)...]
;;     [else ...(first lst)
;;              (los-fn (rest lst))]))
;;
;;;END OF DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS
(define hw-example-1 (make-sum-exp (list 22 333 44)))

(define hw-example-2 (make-sum-exp
                      (list
                       (make-mult-exp (list 22 3333 44))
                       (make-mult-exp
                        (list
                         (make-sum-exp (list 66 67 68))
                         (make-mult-exp (list 42 43))))
                       (make-mult-exp (list 77 88)))))
;; END OF CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; expr-to-strings : Exp NonNegInt -> ListOfStrings
;; GIVEN : An expression 
;; RETURNS : A representation of the expression as a sequence of lines, with
;; each line represented as a string of length not greater than the width.
;; Example : See test case below.
;; STRATEGY : Function composition
(define (expr-to-strings expr width)
  (final-output-list (create-the-full-list expr empty) width 
                     1 "" 0 0 empty))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create-the-full-list : Expr List -> ListOfString
;; GIVEN: An expression
;; WHERE : every expression is appended to the base-list
;; RETURNS: A list which will contain all the strings supposed to be in 
;; the final list.
;; Example : (create-the-full-list (make-sum-exp (list 22 333 44)) empty) ->
;; ("(+" "22" "333" "44" ")")
;; STRATEGY : Structural decomposition on expr : NELOExpr
(define (create-the-full-list expr base-lst)
  (cond
    [(integer? expr) (append (list (number->string expr)) base-lst)]
    [(sum-exp? expr) (append (list "(+") (making-full-list 
                                          (sum-exp-exprs expr) 
                                          base-lst) base-lst)]
    [(mult-exp? expr) (append (list "(*") (making-full-list 
                                           (mult-exp-exprs expr) 
                                           base-lst) base-lst)]))

;; making-full-list : ListOfString ListOfString -> ListOfString 
;; GIVEN : A main list over which this function recurses 
;; WHERE :
;; a base-list which gets each and every string appended onto it.   
;; RETURNS : The base list with close bracket appended to it
;; Example : (making-full-list (list 22 333 44) empty) -> ("22" "333" "44" ")")
;; STRATEGY : structural decomposition on lst : ListOfString
(define (making-full-list lst base-lst)
  (cond
    [(empty? lst) (append (list ")") base-lst)]
    [else (append (create-the-full-list (first lst) base-lst)
                  (making-full-list (rest lst) base-lst))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; final-output-list : List NonNegInt NonNegInt String NonNegInt NonNegInt 
;; ListOfString -> ListOfString
;; GIVEN : A list of strings, given width,maximum-depth.
;; WHERE : 
;; bracket-count is the count of the number of opening 
;; and closing brackets.
;; base-string is the string on which each string is appended temporarily.
;; depth gives the depth of the nesting level.
;; final-list is the list which gives the final list. 
;; RETURNS : final list which has the proper division of the string and spacing 
;; Example : (final-output-list '("(+" "22" "333" "44" ")") 
;; 50 1 "" 0 0 empty) -> ("(+ 22 333 44)")
;; (final-output-list '("(+" "22" "333" "44" ")") 10 1 "" 0 0 
;; empty) -> Not Enough room
;; STRATEGY : Function composition
(define (final-output-list lst width 
                           bracket-count base-string depth 
                           max-depth final-list)
  (if (compare-string-length-to-width (print-list lst bracket-count 
                                                  base-string width depth 
                                                  (calculate-maximum-depth 
                                                   lst depth max-depth)
                                                  final-list) width)
      (print-list lst bracket-count base-string width depth 
                  (calculate-maximum-depth lst depth max-depth) 
                  final-list)
      (check-for-error lst width bracket-count base-string depth 
                       (calculate-maximum-depth lst depth max-depth)
                       final-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; calculate-maximum-depth : listOfString NonNegInt NonNegInt -> NonNegInt
;; GIVEN : A list of Strings
;; WHERE : 
;; depth increases by 1 if an (+ or a (* is encountered
;; depth decreases by 1 if a ) is encountered.
;; max-depth is the maximum depth of nesting.
;; RETURNS : Maximum depth of the nesting.
;; Example : (calculate-maximum-depth "(+ )" 1 1) -> 1
;; STRATEGY : Structural decomposition on lst : ListOfString
(define (calculate-maximum-depth lst depth max-depth)
  (cond
    [(empty? lst) max-depth]
    [(string=? "(+" (first lst)) (calculate-maximum-depth (rest lst) 
                                                          (+ 1 depth) 
                                                          (larger-number 
                                                           (+ 1 depth) 
                                                           max-depth))]
    [(string=? "(*" (first lst)) (calculate-maximum-depth (rest lst) 
                                                          (+ 1 depth) 
                                                          (larger-number 
                                                           (+ 1 depth) 
                                                           max-depth))]
    [(string=? ")" (first lst)) (calculate-maximum-depth (rest lst) 
                                                         (- depth 1)
                                                         max-depth)]
    [else (calculate-maximum-depth (rest lst) depth max-depth)]))

;; larger-number : NonNegInt NonNegInt -> NonNegInt
;; GIVEN : Two integers
;; RETURNS : The larger number.
;; STRATEGY : Function composition.
;; Example : (larger-number 10 23) -> 23
(define (larger-number cur max)
  (if (> cur max)
      cur
      max))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check-for-error : ListOfString NonNegInt NonNegInt String NonNegInt NonNegInt
;; ListOfString -> ListOfString
;; GIVEN : A list of strings, given width,depth of the nesting level,
;; list which gives the final-output. 
;; WHERE : 
;; String length of list generated is more than width necessarily
;; bracket-count is the count of the number of opening 
;; and closing brackets. and is increased by 1 to check condition.
;; or if the condition fails that is there is enough room for the output. 
;; max-depth is increased by 1 to check the condition 
;; RETURNS : If condition is true then it will give an error that not enough 
;; room for the ouput else will give th output if possible 
;; Example : (check-for-error '("(+" "22" "333" "44" ")") 
;; 10 1 "" 0 1 empty) -> Not enough room
;; STRATEGY : Function composition
(define (check-for-error lst width bracket-count base-string depth max-depth
                         final-list)
  (if (> (+ 1 bracket-count) (+ 1 max-depth))
      (error "Not enough room")
      (final-output-list lst width (+ bracket-count 1) 
                         base-string depth
                         max-depth final-list)))

;; compare-string-length-to-width : ListOfString NonNegInt -> Boolean
;; GIVEN : List of strings and width
;; RETURNS : True iff the length of each string is less than width
;; Example : (compare-string-length-to-width ("(+ 22 333 44)") 50) -> #t
;; (compare-string-length-to-width ("(+ 22 333 44)") 10) -> #f
;; STRATEGY: HOFC
(define (compare-string-length-to-width lst width)
  (andmap
   (lambda (strng)
     (<= (string-length strng) width))
   lst))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; print-list : ListOfString NonNegInt String NonNegInt NonNegInt NonNegInt
;; ListOfString -> ListOfString
;; GIVEN : A list of all strings,
;; bracket-count is the count of the number of opening and closing brackets
;; base-string is the string on which the string is built temporarily
;; depth gives the depth of the current level
;; maximum depth of the nesting in the input.
;; final-list is the list which gives the final-output.
;; RETURNS : The final list of strings which has brackets and integers appended
;; Example : (print-list '("(+" "22" "333" "44" ")") 1 "" 20 1 1 empty) ->
;; ("   (+ 22 333 44)")
;; STRATEGY : Structural decomposition on lst : ListOfString

(define (print-list lst bracket-count base-string width depth max-depth 
                    final-list)
  (cond
    [(empty? lst) final-list]
    [(string=? "(+"  (first lst)) (appending-spaces-symbols "(+" (rest lst) 
                                                            bracket-count 
                                                            base-string
                                                            width
                                                            depth
                                                            max-depth
                                                            final-list)] 
    [(string=? "(*" (first lst)) (appending-spaces-symbols "(*" (rest lst) 
                                                           bracket-count 
                                                           base-string 
                                                           width
                                                           depth
                                                           max-depth
                                                           final-list)] 
    [(string=? ")" (first lst)) (check-bracket-depth-condition (rest lst) 
                                                               base-string 
                                                               bracket-count 
                                                               width
                                                               depth
                                                               max-depth
                                                               final-list)]
    [else (appending-the-integer lst bracket-count base-string
                                 width depth max-depth final-list)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; appending-spaces-symbols : String ListOfString NonNegInt String NonNegInt 
;; NonNegInt NonNegInt ListOfString -> ListOfString
;; GIVEN : The symbol to be appended, A list of all strings
;; bracket-count is the count of the number of opening and closing brackets
;; maximum depth of the nesting,
;; final list for output
;; WHERE :
;; base-string on which the string is built temporarily and here spacing is 
;; added to it depending on the nesting level.
;; depth gives the depth of the current level and depending on the nesting
;; spacing to be given is decided.

;; RETURNS : A List of strings with 
;; Example : (appending-spaces-symbols "(+" '("(+" "22" "333" "44" ")") 1 "" 0 
;; 20 1 empty) ->
;; ("                                                         (+ (+ 22 333 44)")
;; STRATEGY : Function composition

(define (appending-spaces-symbols sign lst bracket-count base-string width 
                                  depth max-depth final-list) 
  (if (string=? base-string "")
      (print-list lst 
                  bracket-count 
                  (string-append (add-spacing depth) sign)
                  width
                  (+ depth 1)
                  max-depth
                  final-list)
      (print-list lst 
                  bracket-count 
                  (string-append base-string " " sign)
                  width
                  (+ depth 1)
                  max-depth
                  final-list)))

;; add-spacing : NonNegInt -> String
;; GIVEN : Depth of the nested loop
;; RETURNS : String with spacing according to the depth.
;; Example : (add-spacing 1) -> "   "
;; STRATEGY : Function composition
(define (add-spacing depth)
  (make-string (* 3 depth) #\space))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check-bracket-depth-condition : ListOfString String NonNegInt NonNegInt 
;; ListOfString -> ListOfString
;; GIVEN : A List of strings ,Base string, Bracket-count gives the count 
;; of the opening and closing brackets,depth of the nesting
;; bracket-count 
;; WHERE : 
;; base-string is the string getting built and will be added as the final list
;; upon receiving the last closing bracket otherwise will continue if its not
;; the last closing bracket
;; depth gives depth of the nesting level and reduces by one if the closing
;; bracket occurs in the list.
;; final-list is the final output list which is output only if it is the last 
;; encountered closing bracket. 
;; RETURNS : The final list of strings for output
;; Example : (check-bracket-depth-condition '(")") "(+ (+ 22 333 44" 2 50 
;; 1 2 empty) -> ("(+ (+ 22 333 44))") 
;; STRATEGY : Function composition.
(define (check-bracket-depth-condition lst base-string bracket-count width 
                                       depth max-depth final-list)
  (if (check-condition lst bracket-count depth)
      (print-list lst 
                  bracket-count 
                  "" 
                  width
                  (- depth 1)
                  max-depth
                  (append final-list (list (string-append base-string ")"))))
      (print-list lst 
                  bracket-count 
                  (string-append base-string ")")
                  width
                  (- depth 1)
                  max-depth
                  final-list)))

;; check-condition : ListOfString NonNegInt NonNegInt ->  Boolean
;; GIVEN : A List of strings, bracket-count and depth of nesting
;; WHERE : bracket-count gives the count of the opening and closing brackets
;; depth gives depth of the nesting level.
;; RETURNS : True iff the list of strings is empty or if the bracket-count is 
;; greater than or equal to the depth and next string in the list of string is
;; not a closing bracket.
;; Example : (check-condition "" 1 2) -> true
;; STRATEGY : Function composition
(define (check-condition lst bracket-count depth)
  (or (empty? lst) (and (>= bracket-count depth) 
                        (not (string=? (get-first lst) ")")))))

;; get-first : ListOfString -> String
;; GIVEN : A List of strings
;; RETURNS : The first string
(define (get-first lst)
  (first lst))

;; get-first : ListOfString -> String
;; GIVEN : A List of strings
;; RETURNS : The string after the first string
(define (get-rest lst)
  (rest lst))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; appending-the-integer : ListOfString NonNegInt String NonNegInt NonNegInt 
;; ListOfString -> ListOfString
;; GIVEN : A list of all strings,
;; bracket-count is the count of the number of opening and closing brackets
;; base-string is the string on which the string is built temporarily
;; width is the given width
;; depth gives the depth of the current nesting level
;; maximum-depth is the maximum nesting level.
;; final-list is the list which gives the final-output.  
;; RETURNS : 
;; Examples : (appending-the-integer '("(+" "22" "333" "44" ")") 2 "" 
;; 50 1 1 empty) -> ("   (+" "   22" "   333" "   44)")
;; STRATEGY : Function composition
(define (appending-the-integer lst bracket-count base-string width depth 
                               max-depth final-list)
  (if (check-condition-for-integer (get-rest lst) bracket-count base-string 
                                   width depth max-depth final-list)
      (new-line lst bracket-count base-string 
                width depth max-depth final-list)
      (same-line lst bracket-count base-string 
                 width depth max-depth final-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; check-condition-for-integer : ListOfString NonNegInt String NonNegInt 
;; NonNegInt ListOfString -> Boolean
;; GIVEN : A list of all strings,
;; bracket-count is the count of the number of opening and closing brackets
;; base-string is the string on which the string is built temporarily
;; width is the given width
;; depth gives the depth of the nesting level
;; max-depth is the maximum depth of nesting.
;; final-list is the list which gives the final-output.   
;; RETURNS : True iff all conditions are fulfilled for an integer 
;; Examples : (check-condition-for-integer '("(+") 1 "" 50 1 1 empty) -> false
;; STRATEGY : Function composition 
(define (check-condition-for-integer lst bracket-count base-string width depth  
                                     max-depth final-list)  
  (and (condition-one bracket-count max-depth) (condition-two lst)
       (condition-three lst base-string width)))

;; condition-one : NonNegInt NonNegInt -> Boolean
;; GIVEN : Bracket-count and maximum-depth
;; RETURNS : True iff bracket count is greater than maximum depth.
;; Example : (condition-one 2 1) -> False
;; STRATEGY : Function composition.
(define (condition-one bracket-count max-depth)
  (> bracket-count max-depth))

;; condition-two : ListOfString
;; GIVEN : A list of string
;; RETURNS : True iff first element of the list is not a closing bracket.
;; Example : (condition-two '("(" "77")) -> True
;; STRATEGY : Function composition.
(define (condition-two lst)
  (not (string=? (get-first lst) ")")))

;; condition-three : ListOfString String NonNegInt -> Boolean
;; GIVEN : A list of strings, Current string, Width 
;; RETURNS : True iff the current string is empty or current string and 
;; the next string length is greater than the allowed width.
;; Example : (condition-three '("20") "" 20) -> True
;; STRATEGY : Function composition.
(define (condition-three lst base-string width)
  (or (check-to-append lst base-string width) 
      (check-empty base-string)))

;; check-to-append : ListOfString String NonNegInt -> Boolean 
;; GIVEN : A list of strings , current string and width to be put in
;; RETURNS : True iff String length of current string and string length 
;; of the rest of the string is greater than the width to be adjusted in.
;; Example : (check-to-append '("(+" "22" "333" "44" ")") "" 50) -> false
;; STRATEGY : Function composition.
(define (check-to-append lst base-string width)
  (> (+ (string-length base-string) 
        (string-length (appending-condition (get-rest lst) ""))) 
     width))

;; check-empty : String -> Boolean
;; GIVEN : A string
;; RETURNS : True iff the string is empty
;; Example : (check-empty "") -> True
;; STRATEGY : Function composition
(define (check-empty base-string)
  (string=? base-string ""))

;; appending-condition : ListOfSting String -> String
;; GIVEN : A List and a string.
;; RETURNS : A list where only the closing bracket is appended or the 
;; integer is appended..opening brackets are ignored
;; Example : (appending-condition "" "") -> ""
;; STRATEGY : Structural decomposition on lst : ListOfString
(define (appending-condition lst str)
  (cond
    [(empty? lst) str]
    [(string=? "(+" (first lst)) (appending-condition (rest lst) str)]
    [(string=? "(*" (first lst)) (appending-condition (rest lst) str)]
    [(string=? ")" (first lst)) 
     (appending-condition (rest lst) (string-append ")" str))]
    [else 
     (appending-condition (rest lst) (string-append (first lst) " " str))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; new-line : ListOfString NonNegInt String NonNegInt NonNegInt NonNegInt 
;; ListOfString -> ListOfString
;; GIVEN : A List of strings 
;; Bracket-count gives the count of the opening and closing brackets
;; base-string 
;; width is the given width
;; depth of the nesting,
;; maximum depth
;; WHERE : 
;; final-list is the final output list which either appends a closing bracket 
;; or appends the integer with a space. 
;; RETURNS : The final output with final-list updated here.
;; Examples :(new-line '("(+" "22" "333" "44" ")") 2 "" 50 1 1 empty) ->
;; ("   (+" "   22" "   333" "   44)")
;; STRATEGY : Function composition.
(define (new-line lst bracket-count base-string width depth max-depth 
                  final-list)
  (if (string=? base-string "")
      (print-list (get-rest lst) bracket-count "" width depth max-depth 
                  (append final-list (list (string-append (add-spacing depth) 
                                                          (get-first lst)))))
      (print-list (get-rest lst) bracket-count "" width depth max-depth 
                  (append final-list (list (string-append base-string " " 
                                                          (get-first lst)))))))

;; same-line : ListOfString NonNegInt String NonNegInt NonNegInt NonNegInt 
;; ListOfString -> ListOfString
;; GIVEN : A List of strings ,
;; Bracket-count gives the count of the opening and closing brackets
;; base-string is the temporary string built. 
;; width is the given width.
;; depth of the nesting,
;; max-depth gives the maximum depth of nesting
;; final-list is the final output list 
;; WHERE : 
;; base-string is updated with the appropriate spacing and the integer next in 
;; list.
;; RETURNS : The final list of strings for output on the same line.
;; Examples :(same-line '("(+" "22" "333" "44" ")") 2 "" 50 1 1 empty) ->
;; ("   (+ 22 333 44)")
;; STRATEGY : Function composition.
(define (same-line lst bracket-count base-string width depth max-depth 
                   final-list)
  (if (string=? base-string "")
      (print-list (get-rest lst) 
                  bracket-count 
                  (string-append (add-spacing depth) (get-first lst)) 
                  width
                  depth 
                  max-depth 
                  final-list)
      (print-list (get-rest lst) 
                  bracket-count 
                  (string-append base-string " " (get-first lst))
                  width
                  depth 
                  max-depth 
                  final-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Tests
(begin-for-test
  (check-equal? (expr-to-strings hw-example-2 15) 
                '("(+ (* 22" "      3333" "      44)" "   (* (+ 66" 
                             "         67" "         68)" "      (* 42" 
                             "         43))" "   (* 77 88))"))
  (check-equal? (expr-to-strings hw-example-2 20) '("(+ (* 22 3333 44)" 
                                                    "   (* (+ 66 67 68)" 
                                                    "      (* 42 43))" 
                                                    "   (* 77 88))"))    
  (check-equal? 
   (expr-to-strings hw-example-2 50) 
   '("(+ (* 22 3333 44)" "   (* (+ 66 67 68) (* 42 43))" "   (* 77 88))"))
  (check-error (expr-to-strings hw-example-2 10) "Not Enough room"))

