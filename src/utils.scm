(provide repeat-while)

;; Applies `f` up to `n` times, stopping early if it answers #false.
;; Answers whether all `n` applications ran.
(define (repeat-while f n)
  (let loop ([i n])
    (cond
      [(<= i 0) #true]
      [(f) (loop (- i 1))]
      [else #false])))
