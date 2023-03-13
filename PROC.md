# PROC: A Language with Procedures

This language is based on the LET language from chapter 3 of EOPL3.
The concrete syntax of LET has been expanded with the last two production
rules as follows:

## Concrete Syntax
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
            ::= proc (Identifier) Expression
                [proc-exp (var body)]
            ::= (Expression Expression)
                [call-exp (ractor rand)]
```

## Representating Procedures

Procedures in PROC are represented using a data structure representation
as follows:
```scheme
; Proc ADT
; proc? : SchemeVal -> Bool
; procedure : Var x Exp x Env -> ExpVal

(define-datatype proc proc?
  [procedure
   (var symbol?)
   (body expression?)
   (saved-env env?)])

; observer
; apply-procedure : Proc x ExpVal -> ExpVal
(define (apply-procedure proc1 val)
  (cases proc proc1
    [procedure (var body saved-env)
               (value-of body (extend-env var val saved-env))]))
```
These data structures are often called closures, because they
are self-contained: they contain everything the procedure needs
in order to be applied. We sometimes say the procedure is closed
over or closed in its creation environment.

When `apply-procedure` is invoked, the lexical rule tells us that
when a procedure is applied, its body is evaluated in an environment
that binds the formal parameter of the procedure to the argument of
the call. Furthermore any other variables must have the same values
they had at **procedure-creation** time. This is why our data structure
representation of a procedure includes `saved-env` as a field.
The `saved-env` refers to the environment in which the procedure
definition expression is evaluated; this evironment should contain
all variables visible to the procedure during creation time.

## Implementation

The `parser.rkt` has the updated grammer with the rules about
procedures:
```scheme
...
    (expression ("proc" "(" identifier ")" expression)
                proc-exp)
    (expression ("(" expression expression ")")
                call-exp)
...
```
These two rules will generate `define-datatype` for `proc-exp`
and `call-exp`, which will be used by the generated parser to
represent procedure definitions and procedure calls in the
concrete syntax in abstract syntax trees.

The `value-of` procedure in `interpreter.rkt` is expanded to evaluate
procedure definitions and procedure alls in abstract syntax trees:
```scheme
...
      (proc-exp (var body)
                (proc-val (procedure var body env)))
      (call-exp (rator rand)
              (let ((proc (expval->proc (value-of rator env)))
                    (arg (value-of rand env)))
                (apply-procedure proc arg))))))
...
```
You can download a copy of the "proc" branch of this repository, load `interpreter.rkt` and run the following test cases:
```scheme
> (run "
let f = proc (x) -(x, 11)
in (f (f 77))
")
#(struct:num-val 55)
> (run "
(proc (f) (f (f 77))
 proc (x) -(x, 11))
")
#(struct:num-val 55)
> (run "
let x = 200
in let f = proc (z) -(z, x)
   in let x = 100
      in let g = proc (z) -(z, x)
         in -((f 1), (g 1))
")
#(struct:num-val -100)
> (list-the-datatypes)
((define-datatype program program? (a-program (a-program18 expression?)))
 (define-datatype
  expression
  expression?
  (const-exp (const-exp19 number?))
  (var-exp (var-exp20 symbol?))
  (diff-exp (diff-exp21 expression?) (diff-exp22 expression?))
  (zero?-exp (zero?-exp23 expression?))
  (if-exp (if-exp24 expression?) (if-exp25 expression?) (if-exp26 expression?))
  (let-exp (let-exp27 symbol?) (let-exp28 expression?) (let-exp29 expression?))
  (proc-exp (proc-exp30 symbol?) (proc-exp31 expression?))
  (call-exp (call-exp32 expression?) (call-exp33 expression?))))
```