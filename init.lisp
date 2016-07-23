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

(defparameter *template-dir* (or #.*compile-file-pathname* *load-pathname*))

(defun render (argv &optional (template "template"))
  (let ((abs (make-pathname :defaults *template-dir* :name template :type "lisp")))
    (mapcar (lambda (param)
              (handler-case
                  (let* ((arg (arg-parse (getf param :arguments) (getf param :file) argv))
                         (path (second arg)))
                    (with-open-file (s (ensure-directories-exist path)
                                       :direction :output
                                       :if-exists :supersede)
                      (case (getf param :method) 
                        (:mustache (mustache:render (getf param :source) (first arg) s))
                        (t (format s "~A" (getf param :source)))))) ;; just copy
                (file-error ()
                  (format t "Template file ~a does not exist" "template"))))
            (read-file abs))))

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
