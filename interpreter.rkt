#lang eopl

(require "./env.rkt")
(require "./parser.rkt")

(provide
 ; expressed Values
 num-val bool-val
 ; interpreter
 run)

(define init-env
  (lambda ()
    (extend-env
     'i (num-val 1)
     (extend-env
      'v (num-val 5)
      (extend-env
       'x (num-val 10)
       (empty-env))))))

; run : String -> ExpVal
; Page: 71
(define run
  (lambda (string)
    (value-of-program (scan&parse string))))

; value-of-program : Program -> ExpVal
; Page: 71
(define value-of-program
  (lambda (pgm)
    (cases program pgm
      (a-program (exp1)
                 (value-of exp1 (init-env))))))

; value-of : Exp * Env -> ExpVal
; Page: 71
(define value-of
  (lambda (exp env)
    (cases expression exp
      (const-exp (n)
                 (num-val n))
      (var-exp (var)
               (apply-env env var construct-proc-val))
      (diff-exp (exp1 exp2)
                (let ((val1 (value-of exp1 env))
                      (val2 (value-of exp2 env)))
                  (num-val
                   (- (expval->num val1)
                      (expval->num val2)))))
      (zero?-exp (exp1)
                 (let ((val1 (value-of exp1 env)))
                   (if (zero? (expval->num val1))
                       (bool-val #t)
                       (bool-val #f))))
      (if-exp (exp1 exp2 exp3)
              (let ((val1 (value-of exp1 env)))
                (if (expval->bool val1)
                    (value-of exp2 env)
                    (value-of exp3 env))))
      (let-exp (var exp1 body)
               (let ((val1 (value-of exp1 env)))
                 (value-of body (extend-env var val1 env))))
      (proc-exp (var body)
                (proc-val (procedure var body env)))
      (letrec-exp (proc-name bound-var proc-body letrec-body)
                (value-of letrec-body (extend-env-rec proc-name bound-var proc-body env)))
      (call-exp (rator rand)
              (let ((proc (expval->proc (value-of rator env)))
                    (arg (value-of rand env)))
                (apply-procedure proc arg))))))

(define (construct-proc-val var body saved-env)
  (proc-val (procedure var body saved-env)))

; Procedure ADT

(define-datatype proc proc?
  [procedure
   (var symbol?)
   (body expression?)
   (saved-env env?)])

(define (apply-procedure proc1 val)
  (cases proc proc1
    [procedure (var body saved-env)
               (value-of body (extend-env var val saved-env))]))

; Values
;
; ExpVal = Int + Bool + Proc
; DenVal = ExpVal

; an expressed value is either a number or a boolean.
(define-datatype expval expval?
  (num-val
   (n number?))
  (bool-val
   (b boolean?))
  (proc-val (p proc?)))

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
