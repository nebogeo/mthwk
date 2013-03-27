(define (setup)
    (list 
        (let ((p (with-state 
                        (hint-unlit)
                        (hint-nozwrite)
                        (hint-wire)
                        (blend-mode 'src-alpha 'one)
                        (build-ribbon 100))))
            (with-primitive p
                (pdata-index-map! (lambda (i w) (+ 0.5 (sin (* i 0.1)))) "w")
                (pdata-map! (lambda (c) (vector 1 1 1)) "c")
                (pdata-map! (lambda (p) (srndvec)) "p"))
            p)))

(define (update env pos)
    (with-primitive (list-ref env 0)
        (pdata-index-map! (lambda (i p)
                (if (zero? i) 
                    p
                    (vadd (vmul (pdata-ref "p" (- i 1)) 0.5) (vmul p 0.5)))) "p")
        (pdata-set! "p" 0 pos)
        ))

;(osc-send "/eval" "s" (list (slurp "scenes/scene2.scm")))
