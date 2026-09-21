(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/static.scm")
(require-builtin helix/core/text)

(require "utils.scm")
(require "viewport.scm")

(provide page-step
         view-step
         at-end-of-document?
         measure-scrolloff-margin)

(define (opposite direction)
  (if (eq? direction 'down) 'up 'down))

(define (scroll-view direction)
  (if (eq? direction 'down) (scroll_down) (scroll_up)))

(define (at-end-of-document?)
  (let* ([doc-id (editor->doc-id (editor-focus))]
         [rope (editor->text doc-id)]
         [cursor-pos (cursor-position)]
         [doc-length (rope-len-chars rope)])
    (>= cursor-pos (- doc-length 1))))

;;;; Page steps: the view and the cursor move together, so the cursor keeps its row.

(define (page-step direction)
  (match direction
    ['up (lambda ()
           (move_visual_line_up)
           (scroll_up))]
    ;; Near the top of the document the view has nowhere to go, and scrolling anyway
    ;; would make Helix drag the cursor along, so there only the cursor moves.
    ['down (lambda ()
             (when (>= (get-current-line-number) 6)
               (scroll_down))
             (move_visual_line_down))]
    [_ (error "Invalid scroll direction" direction)]))

;;;; View steps: only the view moves, so the cursor keeps its line and changes row.

;; Scrolls the view a single row. Helix will not scroll the cursor into its `scrolloff`
;; margin - it drags the cursor onto another line instead - so that is as far as the view
;; can go. When that happens the step rolls itself back and answers #false, leaving the
;; view where the built-in alignments settle.
;;
;; Asking Helix rather than reading `editor.scrolloff` is deliberate: reading a config
;; option makes Helix serialise its whole config, which panics on configs it cannot
;; serialise, such as a custom `[editor.statusline]` element.
(define (view-step direction)
  (lambda ()
    (let ([selection (current-selection-object)]
          [line (get-current-line-number)])
      (scroll-view direction)
      (or (= (get-current-line-number) line)
          (begin
            (scroll-view (opposite direction))
            (set-current-selection-object! selection)
            #false)))))

;; The row `zt` can reach, found by scrolling down until Helix pushes back.
;;
;; Helix can only push back by dragging the cursor onto a line further down, and on the
;; document's final line there is none - so the measurement borrows the line above, which
;; Helix will always protect. The view and the selection are put back before the frame is
;; drawn, so none of this is visible.
;;
;; `Editor::cursor` caches its answer until the next redraw, so the starting row is read
;; before anything moves and the borrowed line is then tracked by counting rows rather
;; than by asking again. Restoring the view exactly is what leaves that cached answer
;; correct for the caller.
(define (measure-scrolloff-margin)
  (let* ([row (cursor-view-row)]
         [selection (current-selection-object)]
         [step (view-step 'down)])
    (if (not row)
        (top-view-row)
        (begin
          (move_visual_line_up)
          (let loop ([scrolled 0])
            (if (and (< scrolled (view-height)) (step))
                (loop (+ scrolled 1))
                (begin
                  (repeat-while (lambda () (scroll-view 'up)) scrolled)
                  (set-current-selection-object! selection)
                  ;; the borrowed line starts one row above the cursor and is carried
                  ;; `scrolled` rows up the screen before Helix stops it
                  (max (top-view-row) (- (- row 1) scrolled)))))))))
