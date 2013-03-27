(clear)
(osc-source "4445")

(define test-mode #t)

(require mzlib/string)

;----------------------------------------------

(define (setup)
    (list 
        (with-state 
            (hint-unlit)
            (build-torus 0.1 2 10 10))))

(define (update env pos)
    (with-primitive (list-ref env 0)
        (identity)
        (translate pos)))

;----------------------------------------------

(define p (with-state
        (scale 2)
        (hint-wire)
        (build-pixels 1024 1024 #t)))

(define q (with-pixels-renderer p
        (clear-colour (vector 0 0 0))
        (build-locator)))

(define (osc-eval)
    (when (osc-msg "/eval")
        (eval-string (osc 0))
        (with-pixels-renderer p 
            (clear)
            (set! q (build-locator))            
            (set! env (setup))
            (every-frame (render)))
        (osc-eval)))

(define (osc-drain)
    (when (or test-mode (osc-msg "/pos"))
        (with-pixels-renderer p
            (with-primitive q
                (identity)
                (translate 
                    (if test-mode
                        (vadd (vector -30 15 0) 
                            (vector (* (mouse-x) 0.04) (* (mouse-y) -0.03) -10))
                        (vector (* (osc 0) 40) (* (osc 2) 28) -10)))
                (scale 5)))
        (when (not test-mode) (osc-drain))))

;------------------------------------------------

(define env     
    (with-pixels-renderer p
        (setup)))    

(define (render)
    (osc-eval)
    (osc-drain)
    (with-pixels-renderer p
        (update env (vtransform (vector 0 0 0) 
                (with-primitive q (get-transform))))))

#;(with-state
    (hint-none)
    (hint-wire)
    (backfacecull 0)
    (scale 2)
    (build-cube))

(show-fps 1)

(every-frame (render))


