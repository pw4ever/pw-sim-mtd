(in-package #:pw-sim-mtd)

;;; declare and parse command-line options

(defun getopt ()
  (apply #'cl-utils-pw.getopt:declare-getopt-options
	 '(
	   (:random-state . :optional)
	   (:world . :optional)
	   (:world-param . :optional)
	   (:console . :none)
	   (:repl . :none)
	   (:duration . :optional)
	   (:output . :optional)
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
      (format t "~&recognized options: ~A~%" (first sb-ext:*posix-argv*) (cl-utils-pw.getopt:help))
      (sb-ext:exit)
      ))

  ;; need to initialize random number generator

  (setf *random-state*
	(let ((random-state (cl-utils-pw.getopt:getopt :random-state)))
	  (if (and random-state (not (eql random-state t)) (probe-file random-state))
	      (cl-store:restore random-state)
	      (make-random-state t))))

  ;; * duration

  (setf *param-duration* 
	(let ((duration (cl-utils-pw.getopt:getopt :duration)))
	  (if duration
	      (read-from-string duration)
	      *default-duration*)))

  ;; * load or create the world?

  (let ((world (cl-utils-pw.getopt:getopt :world)))
    (if (and world (probe-file world))
	(load-world world)
	(let ((world-param (cl-utils-pw.getopt:getopt :world-param)))
	  (create-world
	   (if (and world-param (probe-file world-param))
	       (cl-store:restore world-param)
	       *default-world-param*)))))

  ;; * launch console?

  (when (cl-utils-pw.getopt:getopt :console)
    (cl-server-manager:launch-system-with-defaults nil :console)
    (format t "console ports: ~A~%" 
	    (cl-server-manager:list-ports :name :console)))

  ;; * launch repl?

  (when (cl-utils-pw.getopt:getopt :repl)
    (cl-server-manager:launch-system-with-defaults t))

  )



