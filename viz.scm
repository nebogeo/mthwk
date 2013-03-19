(clear)
(osc-source "4445")


(define p (with-state
    (scale 2)
    (hint-wire)
    (build-pixels 512 512 #t)))

(define q (with-pixels-renderer p
        (clear-colour (vector 0 0 0))
        (hint-unlit)
        (colour (vector 1 1 1))
        (build-torus 0.2 2 10 20)))

(define (osc-drain)
    (when (osc-msg "/pos")
        (with-pixels-renderer p
        (with-primitive q
            (identity)
            (translate (vector 
            (* (osc 0) 40) 
            (* (osc 2) 28) 
            -10))
            (scale 5)))
        (osc-drain)))


(define (render)
    (osc-drain))
    
#;(with-state
    (hint-none)
    (hint-wire)
    (backfacecull 0)
    (scale 2)
    (build-cube))

(show-fps 1)

(every-frame (render))
 

