(clear)
(osc-source "4445")



(define (render)
    (when (osc-msg "/pos")
        (with-state
            (translate (vector (osc 0) (osc 1) (osc 2)))
            (scale 0.1)
            (draw-cube))))


(with-state
    (hint-none)
    (hint-wire)
    (backfacecull 0)
    (scale 2)
    (build-cube))

(show-fps 1)

(every-frame (render))
 

