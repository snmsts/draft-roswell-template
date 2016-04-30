(asdf:defsystem :snmsts/draft-roswell-template
  :depends-on (:cl-mustache)
  :method :mustache
  :components ((:file "init")))
