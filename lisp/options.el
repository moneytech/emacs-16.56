;; Edit Options command for Emacs.
;; Copyright (C) 1985 Richard M. Stallman.

;; This file is part of GNU Emacs.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but without any warranty.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; document "GNU Emacs copying permission notice".   An exact copy
;; of the document is supposed to have been given to you along with
;; GNU Emacs so that you can know how you may redistribute it all.
;; It should be in a file named COPYING.  Among other things, the
;; copyright notice and this notice must be preserved on all copies.


(defun list-options ()
  "Display a list of Emacs user options, with values and documentation."
  (interactive)
  (save-excursion
    (set-buffer (get-buffer-create "*List Options*"))
    (Edit-options-mode))
  (with-output-to-temp-buffer "*List Options*"
    (let (vars)
      (mapatoms 'list-options-1)
      (setq vars (sort vars 'string-lessp))
      (while vars
	(let ((sym (car vars)))
	  (princ ";; ")
	  (prin1 sym)
	  (princ ":\n\t")
	  (prin1 (symbol-value sym))
	  (terpri)
	  (princ (substitute-command-keys (get sym 'variable-documentation)))
	  (princ "\n;;\n"))
	(setq vars (cdr vars))))))

(defun list-options-1 (sym)
  (let ((vdoc (get sym 'variable-documentation)))
    (and vdoc (> (length vdoc) 0) (= (aref vdoc 0) ?*)
	 (setq vars (cons sym vars)))))

(defun edit-options ()
  "Edit a list of Emacs user option values.
Selects a buffer containing such a list,
in which there are commands to set the option values.
Type \\[descibe-mode] in that buffer for a list of commands."
  (interactive)
  (list-options)
  (pop-to-buffer "*List Options*"))

(defvar Edit-options-mode-map nil "")

(defun Edit-options-mode ()
  "Major mode for editing Emacs user option settings.
Special commands are:
s -- set variable dot points at.  New value read using minibuffer.
x -- toggle variable, t -> nil, nil -> t.
1 -- set variable to t.
0 -- set variable to nil.
Each variable description is a paragraph.
For convenience, the characters p and n move back and forward by paragraphs."
  (kill-all-local-variables)
  (set-syntax-table lisp-mode-syntax-table)
  (if Edit-options-mode-map
      nil
    (setq Edit-options-mode-map (make-keymap))
    (define-key Edit-options-mode-map "s" 'Edit-options-set)
    (define-key Edit-options-mode-map "x" 'Edit-options-toggle)
    (define-key Edit-options-mode-map "1" 'Edit-options-t)
    (define-key Edit-options-mode-map "0" 'Edit-options-nil)
    (define-key Edit-options-mode-map "p" 'backward-paragraph)
    (define-key Edit-options-mode-map " " 'forward-paragraph)
    (define-key Edit-options-mode-map "n" 'forward-paragraph))
  (use-local-map Edit-options-mode-map)
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate "[^ -]")
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^\t")
  (setq truncate-lines t)
  (setq major-mode 'Edit-options-mode)
  (setq mode-name "Options"))

(defun Edit-options-set () (interactive)
  (Edit-options-modify
   '(lambda (var) (eval-minibuffer (concat "New " (symbol-name var) ": ")))))

(defun Edit-options-toggle () (interactive)
  (Edit-options-modify '(lambda (var) (not (symbol-value var)))))

(defun Edit-options-t () (interactive)
  (Edit-options-modify '(lambda (var) t)))

(defun Edit-options-nil () (interactive)
  (Edit-options-modify '(lambda (var) nil)))

(defun Edit-options-modify (modfun)
  (save-excursion
   (let (var pos)
     (re-search-backward "^;; ")
     (forward-char 3)
     (setq pos (dot))
     (save-restriction
      (narrow-to-region pos (progn (end-of-line) (1- (dot))))
      (goto-char pos)
      (setq var (read (current-buffer))))
     (goto-char pos)
     (forward-line 1)
     (forward-char 1)
     (save-excursion
      (set var (funcall modfun var)))
     (kill-sexp 1)
     (prin1 (symbol-value var) (current-buffer)))))

