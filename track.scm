

(require fluxus-018/freenect)

(define kinect (freenect-open 0))

(freenect-set-depth-mode 'raw)

(osc-destination "osc.udp://localhost:4445")

(define (make-cloud)
    (let ((p (build-particles 800)))
        (with-primitive p
            (hint-unlit)
            (hide 0)
            (pdata-map!
                (lambda (c)
                    (vector 1 1 0))
                "c")
            (pdata-map!
                (lambda (c)
                    0.01)
                "s")
            (pdata-map! 
                (lambda (p)
                    (let ((p (vmul (crndvec) 10)))
                        (vector
                            (vx p)
                            (* (vy p) 0.1)
                            (vz p))))
                "p"))
        p))

(define (update-cloud cloud)
    (define n 0)
    (with-freenect-device kinect
        (with-primitive cloud
            (for* ([x (in-range 0 640 20)]
                    [y (in-range 0 480 20)])
                (let ([pos (freenect-worldcoord-at x y)])
                    (pdata-set! "p" n pos)        
                    (pdata-set! "c" n (vector 1 0 0) #;(hsv->rgb (vector (* (vz pos) .1) .9 .6)))
                    (set! n (+ n 1)))))
        (freenect-update)))


(define (make-frame)
    (with-state
        (backfacecull 0)
        (hint-none)
        (wire-colour 1)
        (hint-wire)
        (build-cube)))

(define cali #f)


(define (update-frame frame cloud)
    (update-cloud cloud)
    
    (let ((tx (with-primitive frame (minverse (get-transform)))))
        (with-primitive cloud
            (pdata-map!
                (lambda (c p) 
                    (let ((px (vtransform p tx)))
                        (if (and (> (vx px) -0.5) (< (vx px) 0.5)
                                (> (vy px) -0.5) (< (vy px) 0.5)
                                (> (vz px) -0.5) (< (vz px) 0.5))
                            (if (< (vy px) 0)
                                (vector 0 1 1)
                                (vector 1 0 0))    
                            (vector 0.5 0.5 0.5))))
                "c" "p"))
        
        
        (let* ((r (with-primitive cloud (pdata-fold
                            (lambda (p c r)
                                (if (> (vx c) 0.5)
                                    (list (+ (car r) 1) (vadd (cadr r) p))
                                    r))
                            (list 0 (vector 0 0 0))
                            "p" "c")))
                (pos (cond (cali
                            (let ((t (inexact->exact (floor (fmod (time) 4)))))
                                (vtransform 
                                    (cond 
                                        ((eq? t 0) (vector 0.5 0 0.5)) 
                                        ((eq? t 1) (vector 0.5 0 -0.5)) 
                                        ((eq? t 2) (vector -0.5 0 -0.5)) 
                                        ((eq? t 3) (vector -0.5 0 0.5))) 
                                    (minverse tx)))) 
                        
                        (else (vdiv (cadr r) (if (zero? (car r)) 1 (car r)))))))
            (with-state
                (translate pos)
                (scale 0.1)
                (draw-cube))
            (let ((pp (vtransform pos tx)))
                ;       (display "sending")(newline)
                (osc-send "/pos" "fff" (list (vx pp) (vy pp) (vz pp)))))) 
    
    
    (with-primitive frame
        (cond
            ((key-pressed "q") (rotate (vector 1 0 0)))
            ((key-pressed "w") (rotate (vector -1 0 0)))
            ((key-pressed "a") (rotate (vector 0 1 0)))
            ((key-pressed "s") (rotate (vector 0 -1 0)))
            ((key-pressed "z") (rotate (vector 0 0 1)))
            ((key-pressed "x") (rotate (vector 0 0 -1)))
            
            ((key-pressed "e") (scale (vector 1.1 1.1 1.1)))
            ((key-pressed "r") (scale (vector 0.9 0.9 0.9)))
            ;            ((key-pressed "d") (scale (vector 1 1.1 1)))
            ;            ((key-pressed "f") (scale (vector 1 0.9 1)))
            ;            ((key-pressed "c") (scale (vector 1 1 1.1)))
            ;            ((key-pressed "v") (scale (vector 1 1 0.9)))
            
            ((key-pressed "t") (translate (vector 0.1 0 0)))
            ((key-pressed "y") (translate (vector -0.1 0 0)))
            ((key-pressed "g") (translate (vector 0 0.1 0)))
            ((key-pressed "h") (translate (vector 0 -0.1 0)))
            ((key-pressed "b") (translate (vector 0 0 0.1)))
            ((key-pressed "n") (translate (vector 0 0 -0.1)))
            
            )))

(clear)

(define (slurp fn)
    (define (_ f)
        (let ((l (read-line f)))
            (if (eof-object? l) ""
                (string-append l "\n" (_ f)))))
    (let* ((f (open-input-file fn))
            (r (_ f)))
        (close-input-port f)
        r))

;(osc-send "/eval" "s" (list (slurp "scenes/scene3.scm")))

(show-fps 1)
(define cloud (make-cloud))
(define frame (let ((p (with-state (scale 1) (make-frame))))
        (with-primitive p 
            (apply-transform)
            (rotate (vector -35 0 0))
            (translate (vector 0.5 -1.3 1.5))
            
            ) p))    

(every-frame (update-frame frame cloud))

















