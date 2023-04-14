# LET: A Simple Language

This example is from chapter 3 of EOPL3.

## Syntax
The concrete syntax for the LET language is as follows (`[]` denotes abstract syntax):
```
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
            ::= proc (identifier) Expression
                [proc-exp (var body)]
            ::= (Expression Expression)
                [call-exp (ractor rand)]
```

Example programs:
```
42

x

-(55, -(1,11))

let x = 5
in -(x,3)

let x = 33
in let y = 22
   in if zero?(-(x, 11)) then -(y, 2) else -(y, 4)

let z = 5
in let x = 3
   in let y = -(x,1) % here x = 3
      in let x = 4
         in -(z, -(x,y)) % here x = 4

let x = 7
in let y = 2
   in let y = let x = -(x,1)
              in -(x,y)
      in -(-(x,8), y)
```

## Syntax datatype

This implementation uses SLLGEN as a front end, which means that expressions will be represented by data types as follows:

```scheme
(define-datatype program program?
  (a-program
   (exp1 expression?)))

(define-datatype expression expression?
  (const-exp
   (num number?))
  (diff-exp
   (exp1 expression?)
   (exp2 expression?))
  (zero?-exp
   (exp1 expression?))
  (if-exp
   (exp1 expression?)
   (exp2 expression?)
   (exp3 expression?))
  (var-exp
   (var symbol?))
  (let-exp
   (var symbol?)
   (exp1 expression?)
   (exp2 expression?)))
```
