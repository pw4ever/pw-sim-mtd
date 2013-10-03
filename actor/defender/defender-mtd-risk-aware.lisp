(in-package :pw-sim-mtd)

(defclass defender-mtd-risk-aware (defender-mtd)
  (
   )
  (:documentation "migrate based on estimated risk; refer to the paper")
  )

(defmethod migrate ((defender defender-mtd-risk-aware) (asset node))
  (let* ((asset-name (node-name asset))
	 (selection asset-name)
	 (migration nil)
	 (risk (funcall (eval (node-compromise-form asset))
			(ensure-gethash asset-name
					(defender-deployment-history defender)
					0))))
    (when (> risk 0)
      (let* ((candidates (node-neighbors asset))
	     (candidate-risk (iter:iter
			       (iter:for candidate :in candidates)
			       (collect (cons candidate 
					      (funcall (eval (node-compromise-form (find-node candidate))) 
						       (ensure-gethash candidate
								       (defender-deployment-history defender)
								       0)))))))
	;; find eligible candidates
	(setf candidate-risk (delete-if #'(lambda (c)
					    (optima:match c
					      ((cons _ cand-risk)
					       (>= cand-risk risk)))) 
					candidate-risk))
	(when candidate-risk
	  (let ((candidate-count (length candidate-risk))
		(candidates (iter:iter
			      (iter:for (cand . nil) :in candidate-risk)
			      (iter:collect cand)))
		(risk-sum (+ risk 
			     (iter:iter
			       (iter:for (nil . risk) :in candidate-risk)
			       (iter:summing risk))))
		(candidate-line nil) ; line up eligible candidates by their selection probability
		(start 0))
	    (iter:iter
	      (iter:for cand :in candidates)
	      (push (cons cand start) candidate-line)
	      (setf start (+ start 
			     (/ (- risk-sum (assoc-value candidate-risk cand))
				(* candidate-count
				   risk-sum)))))
	    ;; asset should assume the last position
	    (push (cons asset-name start) candidate-line) 
	    ;; order by ascending "start"
	    (reversef candidate-line)
	    ;; find the first number that is greater than a random number and select the corresponding candidate
	    (let ((sel (car (find (random 1.0) candidate-line :key #'cdr :test #'<=))))
	      ;; if falls to the last interval, choose the last one, i.e., the asset
	      (setf selection (if sel sel asset-name))	
	      ;; record migration
	      (unless (eq sel asset-name)
		(setf migration (cons asset-name sel))))))))
    (values selection migration)))
