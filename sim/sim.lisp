(in-package #:pw-sim-mtd)

;(trace act)

(defun sim (&optional (duration *param-duration*))
  (iter:iter
    (iter:repeat duration)
    (evolve))
  (let ((output (cl-utils-pw.getopt:getopt :output)))
    (when output
      (save-world output))))

;(sim)
;(untrace act)

