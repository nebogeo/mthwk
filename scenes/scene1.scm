(define (setup)
    (list 
        (let ((p (with-state 
                        (hint-unlit)
                        (hint-nozwrite)
                        (blend-mode 'src-alpha 'one)
                        (texture (load-texture "textures/particle.png")) 
                        (build-particles 500))))
            (with-primitive p
                (pdata-map! (lambda (s) 2) "s")
                (pdata-map! (lambda (c) (vector 1 1 1)) "c")
                (pdata-map! (lambda (p) (srndvec)) "p"))
            p)))

(define (update env pos)
    (with-primitive (list-ref env 0)
        (pdata-map! (lambda (s) (vmul s 0.99)) "s")
        (pdata-map! (lambda (p) 
                (let ((pp (vmul (vadd (vmul (vector (time) (time) 0) 2) p) 0.1)))
                (vadd (vmul (vector
                            (- (noise (vx pp) (vy pp)) 0.5)
                            (- (noise (+ 10 (vx pp)) (vy pp)) 0.5) 0) 1)
                    p))) "p")
        (for ((i (in-range 0 10)))
            (let ((new (random 500)))
                (pdata-set! "p" new (vadd (srndvec) pos))
                (pdata-set! "s" new 1)))))

;(osc-send "/eval" "s" (list (slurp "scenes/scene1.scm")))
