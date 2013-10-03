(in-package #:pw-sim-mtd.make-world-param)

;;; declare and parse command-line options

(defun getopt ()
  (apply #'cl-utils-pw.getopt:declare-getopt-options
	 '(
	   (:world . :required)
	   (:node . :required)
	   (:attacker . :required)
	   (:budget . :required)
	   (:defender . :required)
	   (:asset . :required)
	   (:help . :none)
	   ))

  #+sbcl
  (cl-utils-pw.getopt:parse-getopt-options
   sb-ext:*posix-argv*)

;;; process command-line options
  
;;; * help?

  (when (cl-utils-pw.getopt:getopt :help)
    #+sbcl
    (progn
      (format t "~&~A ~A~%" (first sb-ext:*posix-argv*) (cl-utils-pw.getopt:help))
      (sb-ext:exit)
      )))

