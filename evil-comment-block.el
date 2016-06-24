;;; evil-comment-block.el --- Motions and text objects for comment blocks in Evil.

;; Copyright (c) 2016 Launay Gaby

;; Author: Launay Gaby <gaby.launay@gmail.com>
;; URL: http://github.com/muahah/evil-comment-block
;; Version: 1.0
;; Keywords: evil, vim-emulation
;; Package-Requires: ((evil "1.0.8"))

;; This file is NOT part of GNU Emacs.

;; The MIT License (MIT)

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;; This package provides motions and text objects for comment blocks in
;; Evil, the extensible vi layer. To activate it, add the following to your
;; .emacs:
;;
;;     (add-to-list 'load-path "path/to/evil-comment-block")
;;     (require 'evil-comment-block)
;;
;;     ;; bind evil-comment-block text objects
;;     (define-key evil-inner-text-objects-map "cb" 'evil-comment-block-inner-block)
;;     (define-key evil-outer-text-objects-map "cb" 'evil-comment-block-outer-block)
;;
;;     ;; bind evil-comment-block-comment-or-uncomment-block
;;     (evil-leader/set-key "cb" 'evil-comment-block-comment-or-uncomment-block)
;;
;; See README.md for more details.


(require 'evil)

(defgroup evil-comment-block nil
  "Motions and text objects for comment blocks in Evil."
  :group 'evil)

(defcustom evil-comment-block-comment-regexp
  (lambda ()
    (format "^\\s-*%s" comment-start))
  "Function returning the regexp matching the comment lines"
  :type '(sexp))

(defun evil-comment-block--get-block-region()
  (interactive)
  (save-excursion
    (let ((pos-init (progn (end-of-line) (point)))
	  (beg nil)
	  (end nil)
	  (comment-regexp evil-comment-block-comment-regexp))
      (end-of-line)
      ;; Check if i should comment or uncomment
      (if (re-search-backward comment-regexp (line-beginning-position) t)
	  ;;;; Uncomment block
	  (progn
	    ;; Get first commented line
	    (goto-char pos-init)
	    (while (re-search-backward comment-regexp (line-beginning-position) t)
	      (previous-line)
	      (end-of-line))
	    (next-line)
	    (setq beg (line-beginning-position))
	    ;; get last commented line
	    (goto-char pos-init)
	    (while (re-search-backward comment-regexp (line-beginning-position) t)
	      (next-line)
	      (end-of-line))
	    (previous-line)
	    (setq end (+ (line-end-position) 1))
	    ;; store result
	    (list beg end t))
	;;;; Comment block
	;; Get first commented line
	(goto-char pos-init)
	(while (not (re-search-backward comment-regexp (line-beginning-position) t))
	  (previous-line)
	  (end-of-line))
	(next-line)
	(setq beg (line-beginning-position))
	;; get last commented line
	(goto-char pos-init)
	(while (not (re-search-backward comment-regexp (line-beginning-position) t))
	  (next-line)
	  (end-of-line))
	(previous-line)
	(setq end (+ (line-end-position) 1))
	;; Store result
	(list beg end nil)))))

;;;###autoload (autoload 'evil-comment-block-inner-comment-block "evil-comment-block")
(evil-define-text-object evil-comment-block-inner-comment-block (count &optional beg end type)
  "Select inner delimited commented block."
    (let ((region (get-comment-uncomment-commented-block-region))
         (beg nil)
	 (end nil))
      (setq beg (pop region))
      (setq end (pop region))
      (evil-range beg end)))

;;;###autoload (autoload 'evil-comment-block-outer-comment-block "evil-comment-block")
(evil-define-text-object evil-comment-block-outer-comment-block (count &optional beg end type)
  "Select outer delimited commented block."
    (let ((region (get-comment-uncomment-commented-block-region))
         (beg nil)
	 (end nil))
      (setq beg (pop region))
      (setq end (pop region))
      (save-excursion
	(goto-char beg)
	(previous-line)
	(setq beg (line-beginning-position))
	(goto-char end)
	(setq end (+ (line-end-position) 1)))
      (evil-range beg end)))

;;;###autoload
(defun evil-comment-block-comment-or-uncomment-block ()
  (interactive)
  (let ((region (evil-comment-block--get-block-region))
	(beg nil)
	(end nil)
	(surround nil))
    (setq beg (pop region))
    (setq end (pop region))
    (setq surround (pop region))
    ;; check if comment block or surrounded block
      (end-of-line)
      (if surround
	  (uncomment-region beg end)
	(save-excursion
	  (goto-char beg)
	  (previous-line)
	  (setq beg (line-beginning-position))
	  (goto-char end)
	  (setq end (+ (line-end-position) 1)))
	(comment-region beg end)))))
(define-key evil-inner-text-objects-map "cb" 'evil-inner-comment-block)
(define-key evil-outer-text-objects-map "cb" 'evil-outer-comment-block)
(evil-leader/set-key "cb" 'comment-or-uncomment-block)

(provide 'evil-comment-block)
;;; evil-comment-block.el ends here
