(define (setup)
    (build-list 100
        (lambda (i) 
            (let ((p (with-state
                (translate (vmul (srndvec) 10))
                (rotate (vector 0 0 (* (rndf) 90)))
                (if (odd? i) (scale (vector 50 1 1))
                             (scale (vector 1 50 1)))
                (build-cube))))
            (with-primitive p
                    (apply-transform))
            p))))

(define (update env pos)
    (for-each
        (lambda (i) 
            (with-primitive i 
                (identity)
 ;               (rotate (vector 0 0 (* 45 (sin (* 0.05 i (time))))))
                (translate (vmul pos (* i 0.1)))))
        env))


;(osc-send "/eval" "s" (list (slurp "scenes/scene5.scm")))
