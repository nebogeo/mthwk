(define (setup)
    (build-list 100
        (lambda (i) 
            (let ((p (with-state
                            (colour (rndvec)) 
                            (hint-unlit)
                            (hint-wire)
                            (wire-colour 0)
                            (line-width 15)
                            (build-polygons 10 'triangle-strip))))
                (with-primitive p
                    (pdata-index-map! (lambda (i p)
                            (let ((i (* i 40)))
                                (vector (sin i) (cos i) 0))) "p")
                    p)))))

(define (update env pos)
    (for-each
        (lambda (i) 
            (with-primitive i (rotate (vector 0 0 0))))
        env)
    
    (with-primitive (list-ref env (random (length env)))
        (identity)
        (translate pos)
        (colour (rndvec))
        (rotate (vector 0 0 (* (rndf) 90)))    
        (scale (vector (* (rndf) 5) (* (rndf) 5) 1))
        ))


;(osc-send "/eval" "s" (list (slurp "scenes/scene4.scm")))
