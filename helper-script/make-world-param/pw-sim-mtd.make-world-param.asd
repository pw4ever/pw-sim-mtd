(asdf:defsystem #:pw-sim-mtd.make-world-param
  :serial t
  :description "make world param"
  :author "Wei Peng <pengw@umail.iu.edu>"
  :license "MIT"
  :depends-on (#:alexandria
               #:cl-store
               #:cl-utils-pw
	       #:pw-sim-mtd)
  :components ((:file "package")
	       (:file "init")
               (:file "main")))

