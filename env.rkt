#lang racket

(provide
 ; build
 empty-env
 extend-env
 ; query
 apply-env)

; an example of a data type built without define-datatype
(define (empty-env)
  '())

(define (extend-env var val env)
  (cons (cons var val) env))

(define (apply-env env search-var)
  (if (null? env)
      (error 'apply-env "No binding for ~s" search-var)
      (let ([saved-var (caar env)])
        (if (symbol=? search-var saved-var)
            (cdar env)
            (apply-env (cdr env) search-var)))))
