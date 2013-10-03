(in-package #:pw-sim-mtd.review-history)

(in-package #:pw-sim-mtd)

(defun recover-history (defender-init-asset)
  (let (
	(history (make-hash-table))	; key on defender; each contain compromised event (time . nodes)
	(timeline nil)			; record the timeline
	)
    (iter:iter
      (iter:for defender :in (list-actors 'defender))
      (setf (gethash defender history) (make-hash-table)))
    (iter:iter
      (iter:for judge :in (list-actors 'judge))
      (let* ((judge (find-actor judge))
	     (judge-history (judge-history judge)))
	(iter:iter
	  (iter:for time :in (sort (hash-table-keys judge-history) #'<))
	  (push time timeline)
	  (let ((now (gethash time judge-history)))
	    (iter:iter
	      (iter:for (defender . node) :in (gethash :compromised now))
	      ;; won't double count node compromise event by multiple attackers
	      (pushnew node (gethash time (gethash defender history))))))))
    (nreversef timeline)
    (iter:iter
      :history
      (iter:for (defender events) :in-hashtable history)
      (iter:iter
	(iter:with defender-asset = defender-init-asset)
	(iter:for time :in timeline)
	(setf defender-asset (- defender-asset
				(length (gethash time (gethash defender history)))))
	(iter:in :history (iter:collect
			      ;; each line: time defender-type defender-asset 
			      (list
			       time
			       (typecase (find-actor defender)
				 (defender-static :|static|)
				 (defender-mtd-rotate :|rotate|)
				 (defender-mtd-risk-aware :|risk-aware|))
			       defender-asset)))))))

(in-package #:pw-sim-mtd.review-history)
