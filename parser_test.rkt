#lang racket

(require "./parser.rkt")
(require rackunit)

(check-equal?
 (scan&parse "1")
 (a-program (const-exp 1)))

(check-equal?
 (scan&parse "x")
 (a-program (var-exp 'x)))

(check-equal?
 (scan&parse "-(5, y)")
 (a-program (diff-exp (const-exp 5) (var-exp 'y))))

(check-equal?
 (scan&parse "zero?(z)")
 (a-program (zero?-exp (var-exp 'z))))

(check-equal?
 (scan&parse "if zero?(2) then 0 else 1")
 (a-program (if-exp (zero?-exp (const-exp 2))
                    (const-exp 0)
                    (const-exp 1))))

(check-equal?
 (scan&parse "let n=10 in -(n, 1)")
 (a-program (let-exp 'n (const-exp 10) (diff-exp (var-exp 'n) (const-exp 1)))))

(check-equal?
 (scan&parse "proc (x) -(x, 1)")
 (a-program (proc-exp 'x (diff-exp (var-exp 'x)
                                   (const-exp 1)))))

(check-equal?
 (scan&parse "(f x)")
 (a-program (call-exp (var-exp 'f)
                      (var-exp 'x))))
