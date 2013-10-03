(in-package :pw-sim-mtd)

(defclass defender-mtd-rotate (defender-mtd)
  (
   (threshold :accessor defender-mtd-rotate-threshold :initarg :threshold :initform 0
	      :documentation "eligible candidate should have shorter deployment history by at least THRESHOLD")
   )
  (:documentation "migrate to one of eligible candidate")
  )

(defmethod migrate ((defender defender-mtd-rotate) (asset node))
  (let* ((asset-name (node-name asset))
	 (selection asset-name)
	 (migration nil)
	 (risk (ensure-gethash asset-name
			       (defender-deployment-history defender)
			       0)))
    (when (> risk 0)
      (let* ((candidates (node-neighbors asset))
	     (candidate-risk (iter:iter
			       (iter:for candidate :in candidates)
			       (collect (cons candidate 
					      (ensure-gethash candidate
							      (defender-deployment-history defender)
							      0))))))
	;; find eligible candidates
	(setf candidate-risk (delete-if #'(lambda (c)
					    (optima:match c
					      ((cons _ cand-risk)
					       (>= cand-risk (- risk
								(defender-mtd-rotate-threshold defender)))))) 
					candidate-risk))
	(setf candidates (list* asset-name
				(iter:iter
				  (iter:for (cand . nil) :in candidate-risk)
				  (iter:collect cand))))
	;; random select migration target from eligible candidates
	(let ((sel (random-elt candidates)))
	  (setf selection sel)
	  (unless (eq sel asset-name)
	    (setf migration (cons asset-name sel))))))
    (values selection migration)))
