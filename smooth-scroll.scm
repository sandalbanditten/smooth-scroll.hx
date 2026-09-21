(require "src/animation.scm")
(require "src/scroll.scm")
(require "src/viewport.scm")

(provide half-page-up-smooth
         half-page-down-smooth
         page-up-smooth
         page-down-smooth
         align-view-top-smooth
         align-view-center-smooth
         align-view-bottom-smooth)

;;;; Page scrolling: replacements for C-d, C-u, PageUp and PageDown.

(define (scroll-page-smooth direction size)
  (animate-scroll size
                  (page-step direction)
                  (lambda () (and (eq? direction 'down) (at-end-of-document?)))))

(define (half-page-up-smooth)
  (scroll-page-smooth 'up (half-page-height)))

(define (half-page-down-smooth)
  (scroll-page-smooth 'down (half-page-height)))

(define (page-up-smooth)
  (scroll-page-smooth 'up (page-height)))

(define (page-down-smooth)
  (scroll-page-smooth 'down (page-height)))

;;;; View alignment: replacements for zt, zz and zb.

;; Scrolls the view - leaving the cursor on its line - until it sits on `target-row`, or
;; until Helix will not carry it any further. Scrolling the view down raises the cursor
;; up the screen, and scrolling up lowers it.
;;
;; `Editor::cursor` caches its answer until the next redraw, so the row is read once and
;; the distance to travel is counted out in steps rather than watched for.
(define (align-view-smooth target-row)
  (let ([row (cursor-view-row)])
    (when (and row (not (= row target-row)))
      (animate-scroll (abs (- row target-row))
                      (view-step (if (> row target-row) 'down 'up))
                      (lambda () #false)))))

;; `zt` stops at the scrolloff margin, so that row has to be measured up front. `zb` aims
;; for the bottom row and is stopped at the margin by Helix as the view scrolls, and `zz`
;; always reaches the centre.
(define (align-view-top-smooth)
  (align-view-smooth (measure-scrolloff-margin)))

(define (align-view-center-smooth)
  (align-view-smooth (center-view-row)))

(define (align-view-bottom-smooth)
  (align-view-smooth (bottom-view-row)))
