(asdf:defsystem #:pw-sim-mtd.review-history
  :serial t
  :description ""
  :author "Wei Peng <pengw@umail.iu.edu>"
  :license "MIT"
  :depends-on (#:alexandria
	       #:iterate

	       #:optima
	       #:optima.ppcre

               #:cl-utils-pw
	       #:pw-sim-mtd)
  :components ((:file "package")
	       (:file "param")
	       (:file "util")
	       (:file "init")
               (:file "main")))

