#lang eopl

(require "./nenv.rkt")
(require "./parser.rkt")
(require "./translator.rkt")

(provide
 ; expressed Values
 num-val bool-val
 ; interpreter
 run)

; an expressed value is either a number or a boolean.
(define-datatype expval expval?
  (num-val
   (n number?))
  (bool-val
   (b boolean?))
  (proc-val (p proc?)))

(define init-nenv
  (extend-nenv
   (num-val 1)
   (extend-nenv
    (num-val 5)
    (extend-nenv
     (num-val 10)
     (empty-nenv)))))

; run : String -> ExpVal
; Page: 71
(define run
  (lambda (string)
    (value-of-program (translate (scan&parse string)) init-nenv)))


; value-of-program : Program -> ExpVal
; Page: 71
(define value-of-program
  (lambda (pgm nenv)
    (cases program pgm
      (a-program (exp1)
                 (value-of exp1 nenv)))))

; value-of : Exp * Env -> ExpVal
; Page: 71
(define value-of
  (lambda (exp nenv)
    (cases expression exp
      (const-exp (n)
                 (num-val n))
      (nameless-var-exp (n)
               (apply-nenv nenv n construct-proc-val))
      (diff-exp (exp1 exp2)
                (let ((val1 (value-of exp1 nenv))
                      (val2 (value-of exp2 nenv)))
                  (num-val
                   (- (expval->num val1)
                      (expval->num val2)))))
      (zero?-exp (exp1)
                 (let ((val1 (value-of exp1 nenv)))
                   (if (zero? (expval->num val1))
                       (bool-val #t)
                       (bool-val #f))))
      (if-exp (exp1 exp2 exp3)
              (let ((val1 (value-of exp1 nenv)))
                (if (expval->bool val1)
                    (value-of exp2 nenv)
                    (value-of exp3 nenv))))
      (nameless-let-exp (exp1 body)
                        (let ([val1 (value-of exp1 nenv)])
                          (value-of body (extend-nenv val1 nenv))))
      (nameless-letrec-exp (proc-body letrec-body)
                           (value-of letrec-body
                                         (extend-nenv-rec proc-body nenv)))
      (nameless-proc-exp (body)
                         (proc-val (procedure body nenv)))
      (call-exp (rator rand)
              (let ((proc (expval->proc (value-of rator nenv)))
                    (arg (value-of rand nenv)))
                (apply-procedure proc arg)))
      (else
       (eopl:error 'value-of "Invalid translated expression")))))

(define (construct-proc-val body saved-env)
  (proc-val (procedure body saved-env)))

; Procedure ADT

(define-datatype proc proc?
  [procedure
   (body expression?)
   (saved-env nenv?)])

(define (apply-procedure proc1 val)
  (cases proc proc1
    [procedure (body saved-env)
               (value-of body (extend-nenv val saved-env))]))

; Values
;
; ExpVal = Int + Bool + Proc
; DenVal = ExpVal

; extractors:

; expval->num : ExpVal -> Int
; Page: 70
(define (expval->num val)
  (cases expval val
    (num-val (n) n)
    (else (eopl:error 'expval->num "Not a number: ~s" val))))

; expval->bool : ExpVal -> Bool
; Page: 70
(define (expval->bool val)
  (cases expval val
    (bool-val (b) b)
    (else (eopl:error 'expval->bool "Not a boolean: ~s" val))))

(define (expval->proc val)
  (cases expval val
    (proc-val (p) p)
    (else (eopl:error 'expval->proc "Not a procedure: ~s" val))))

; A nice REPL for interactive use
(define read-eval-print
  (sllgen:make-rep-loop "-->" value-of-program
                        (sllgen:make-stream-parser scanner-spec grammar)))
