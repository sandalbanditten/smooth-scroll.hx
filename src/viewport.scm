(require "helix/components.scm")
(require "helix/editor.scm")

(provide view-height
         page-height
         half-page-height
         cursor-view-row
         top-view-row
         center-view-row
         bottom-view-row)

(define (focused-view-area)
  (or (editor-focused-buffer-area) (error "Unable to retrieve the focused view area")))

;; Rows of text in the viewport: the view without its statusline. Mirrors Helix's
;; `View::inner_height`.
(define (view-height)
  (- (area-height (focused-view-area)) 1))

;; A page scroll keeps one row of context from the previous screen.
(define (page-height)
  (- (view-height) 1))

(define (half-page-height)
  (ceiling (/ (page-height) 2)))

;; Row the primary cursor sits on within the viewport, or #false when it is off screen.
(define (cursor-view-row)
  (let ([position (car (current-cursor))])
    (and position (- (position-row position) (area-y (focused-view-area))))))

(define (top-view-row)
  0)

(define (center-view-row)
  (quotient (- (view-height) 1) 2))

(define (bottom-view-row)
  (- (view-height) 1))
