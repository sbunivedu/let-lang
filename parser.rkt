#lang eopl

#|
concrete syntax:
Program     ::= Expression
                [a-program (exp1)]
Expression  ::= Number
                [const-exp (num)]
            ::= - (Expression , Expression)
                [diff-exp (exp1 exp2)]
            ::= zero? (Expression)
                [zero?-exp (exp1)]
            ::= if Expression then Expression else Expression
                [if-exp (exp1 exp2 exp3)]
            ::= identifier
                [var-exp (var)]
            ::= let identifier = Expression in Expression
                [let-exp (var exp1 body)]
            ::= proc (Identifier) Expression
                [proc-exp (var body)]
            ::= (Expression Expression)
                [call-exp (ractor rand)]
|#

(provide
 ; AST
 program
 a-program
 expression
 expression?
 const-exp
 var-exp
 diff-exp
 zero?-exp
 if-exp
 let-exp
 proc-exp
 call-exp
 ; parser
 scan&parse)

(define scanner-spec
  '((number (digit (arbno digit)) number)
    (identifier (letter (arbno letter)) symbol)
    (ws ((arbno whitespace)) skip)))

(define grammar
  '((program (expression)
             a-program)
    (expression (number)
                const-exp)
    (expression (identifier)
                var-exp)
    (expression ("-" "(" expression "," expression ")")
                diff-exp)
    (expression ("zero?" "(" expression ")")
                zero?-exp)
    (expression ("if" expression "then" expression "else" expression)
                if-exp)
    (expression ("let" identifier "=" expression "in" expression)
                let-exp)
    (expression ("proc" "(" identifier ")" expression)
                proc-exp)
    (expression ("(" expression expression ")")
                call-exp)))


(sllgen:make-define-datatypes scanner-spec grammar)

(define scan&parse
  (sllgen:make-string-parser scanner-spec grammar))

#|
> (scan&parse "-(55, -(x,11))")
#(struct:a-program
  #(struct:diff-exp
    #(struct:const-exp 55)
    #(struct:diff-exp
      #(struct:var-exp x)
      #(struct:const-exp 11))))
|#
