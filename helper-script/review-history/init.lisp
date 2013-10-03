(in-package #:pw-sim-mtd.review-history)

;;; declare and parse command-line options

(defun getopt ()
  (apply #'cl-utils-pw.getopt:declare-getopt-options
	 '(
	   (:help . :none)
	   ))

  #+sbcl
  (cl-utils-pw.getopt:parse-getopt-options
   sb-ext:*posix-argv*)

  ;; process command-line options
  
  ;; * help?

  (when (cl-utils-pw.getopt:getopt :help)
    #+sbcl
    (progn
      (format t "~&recognized options: ~A~%" (cl-utils-pw.getopt:help))
      (sb-ext:exit)
      ))

  ;; command-line parameters are world file name
  #+sbcl
  (setf *world-file-list* (rest sb-ext:*posix-argv*))
  )

