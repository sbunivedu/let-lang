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

This implementation uses SLLGEN (see Appendix B) as a front end to generate
abstract syntax trees, which can be described by `define-datatype` as follows.
For the given grammer, there will be one data type for each non-terminal.
For each nonterminal, there will be one variant for each production that
has the nonterminal as its left-hand side. Each variant will have one field
for each nonterminal, identifier, or number that appears in its right-hand
side.

```scheme
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
|#

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

## Implementation
The implmentation of LET is provided in several files - `env.rkt`, `parser.rkt`, and `interpreter.rkt`, which define procedures for the environment, the parser, and the interpreter respectively. Each file also has a corresponding unit test file (e.g. `env_test.rkt`). The `all.rkt` file has all source code in one place, which can be run
to test the following cases:
```scheme
> (run "42")
#(struct:num-val 42)
> (scan&parse "42")
#(struct:a-program #(struct:const-exp 42))
> (value-of-program (scan&parse "42"))
#(struct:num-val 42)
> (expval->num (value-of-program (scan&parse "42")))
42
> (run "
let x = 5
in -(x,3)")

#(struct:num-val 2)
> (run "
let z = 5
in let x=3
   in let y=-(x,1)
       in let x=4
          in -(z,-(x,y))")

#(struct:num-val 3)
> (run "
let x = 7
in let y = 2
   in let y = let x = -(x, 1)
              in -(x, y)
      in -(-(x, 8), y)")

#(struct:num-val -5)
> (run "
let x = 33
in let y = 22
   in if zero?(-(x, 11)) then -(y, 2) else -(y, 4)")

#(struct:num-val 18)
```