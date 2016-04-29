(defpackage :roswell.template
  (:use :cl))
(in-package :roswell.template)

(defparameter ros::*main*
  (lambda (template &rest r)
    (when r
      (render r))
    (ros:quit 0)))

(defun read-file (path)
  (with-open-file (s path :if-does-not-exist :error)
    (loop for o = (read s nil '+eof+)
          until (eq o '+eof+)
          collect o)))

(defvar *template-dir* (or #.*compile-file-pathname* *load-pathname*))

(defun render (argv)
  (handler-case
      (let* ((abs (make-pathname :defaults *template-dir* :name "template" :type "lisp"))
             (param (first (read-file abs)))
             (arg (arg-parse (getf param :arguments) (getf param :file) argv))
             (path (second arg)))
        (with-open-file (s path
                           :direction :output
                           :if-exists :supersede)
          (mustache:render (getf param :source) (first arg) s)))
    (file-error ()
      (format t "Template file ~a does not exist" "template"))))

(defun lispfy-args (list)
  (loop for i in list
        collect (if (ignore-errors
                     (and (eql (aref i 0) #\-)
                          (eql (aref i 1) #\-)))
                    (intern (string-upcase (subseq i 2)) :keyword) i)))

(defun lambda-list (string)
  (let* (*read-eval*
         (*readtable* (copy-readtable nil)))
    (read-from-string string)))

(defun arg-parse (string file args)
  (let ((lambda-list (lambda-list string))
        (args (lispfy-args args)))
    (handler-bind
        ((style-warning #'muffle-warning))
      (apply (eval `(lambda ,lambda-list
                      (list
                       (list
                        ,@(loop for i in lambda-list
                                when (and (symbolp i)
                                          (not (eql (aref (string i) 0) #\&)))
                                  collect (list 'cons (intern (string i) :keyword) i) 
                                when (listp i)
                                  collect (list 'cons (intern (string (first i)) :keyword)
                                                (first i))))
                       ,(read-from-string file))))
             args))))
