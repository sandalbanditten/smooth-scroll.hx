(require "helix/misc.scm")

(require "utils.scm")

(provide animate-scroll)

;; Identifies the scroll currently being animated. Starting a new one bumps this, which
;; makes any animation still in flight abandon its remaining frames.
(define *active-scroll-id* 0)

(define (claim-scroll-id)
  (set! *active-scroll-id* (modulo (+ *active-scroll-id* 1) 1000))
  *active-scroll-id*)

;; Longer scrolls are drawn in bigger, more frequent steps, so that scrolling a page and
;; scrolling a few rows take a comparable time to play out.
(define (frame-delay size)
  (cond
    [(>= size 50) 1]
    [(>= size 40) 2]
    [(>= size 30) 3]
    [(>= size 20) 4]
    [(>= size 10) 5]
    [else 10]))

(define (rows-per-frame size)
  (ceiling (/ size 20)))

;; Scrolls `size` rows by applying `scroll-one-row` a few at a time, pausing between
;; frames so the movement is drawn as an animation. Stops early once `finished?` holds,
;; once `scroll-one-row` answers #false, or once another scroll has been started.
(define (animate-scroll size scroll-one-row finished?)
  (let ([scroll-id (claim-scroll-id)]
        [rows (rows-per-frame size)]
        [delay-ms (frame-delay size)])
    (let loop ([remaining size])
      (when (and (> remaining 0) (not (finished?)))
        (when (repeat-while scroll-one-row (min rows remaining))
          (enqueue-thread-local-callback-with-delay delay-ms
                                                    (lambda ()
                                                      (when (= scroll-id *active-scroll-id*)
                                                        (loop (- remaining rows))))))))))
