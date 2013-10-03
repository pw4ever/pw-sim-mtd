(asdf:defsystem #:pw-sim-mtd
  :serial t
  :description "MTD simulation"
  :version "0.1"
  :author "Wei Peng <pengw@umail.iu.edu>"
  :license "MIT"
  :depends-on (
	       :alexandria
	       :iterate

	       :cl-server-manager
	       :cl-utils-pw

	       :cl-store

	       :optima
	       :optima.ppcre
	       )
  :components (
	       (:file "package")
	       
	       (:module model
		:serial t
		:components (
			     (:file "model")
			     (:file "node-types")
			     ))

	       (:module actor
		:serial t
		:components (
			     (:module attacker
			      :serial t
			      :components (
					   (:file "attacker")
					   ))
			     (:module defender
			      :serial t
			      :components (
					   (:file "defender")
					   (:file "defender-static")
					   (:file "defender-mtd")
					   (:file "defender-mtd-risk-aware")
					   (:file "defender-mtd-rotate")
					   ))
			     (:module judge
			      :serial t
			      :components (
					   (:file "judge")
					   ))
			     ))

	       (:module sim
			:serial t
			:components (
				     (:file "util")
				     (:file "param")
				     (:file "defaults")
				     (:file "init")
				     (:file "sim")
				     ))
	       ))

