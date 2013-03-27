(define (setup)
    (build-list 100
        (lambda (i) 
            (with-state 
          ;      (hint-wire)
                (build-cube)))))

(define (update env pos)
    (for-each
        (lambda (i) 
            (with-primitive i (rotate (vector 2 0 1))))
        env)

    (with-primitive (list-ref env (random (length env)))
        (identity)
        (translate pos)
        (colour (rndvec))
        (rotate (vector 0 0 (* (rndf) 90)))    
        (scale (vector (* (rndf) 5) (* (rndf) 5) 1))
        ))


;(osc-send "/eval" "s" (list (slurp "scenes/scene3.scm")))
