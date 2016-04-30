(:arguments "(_file &optional (name _file) &key (datetime (get-universal-time)))"
 :file "(make-pathname :defaults (merge-pathnames _file) :type \"ros\")"
 :attr #o755
 :encoding nil
 :method :mustache
 :source "#!/bin/sh
#|-*- mode:lisp -*-|#
#| <Put a one-line description here>
exec ros -Q -- $0 \"$@\"
|#
;;; vim: set ft=lisp lisp:
;; created {{datetime}}
(defpackage :ros.script.{{name}}.{{datetime}}
  (:use :cl))
(in-package :ros.script.{{name}}.{{datetime}})
(defun main (&rest argv)
  (declare (ignorable argv)))

")
