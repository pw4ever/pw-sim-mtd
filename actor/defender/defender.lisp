(in-package :pw-sim-mtd)

(defclass defender (actor)
  (
   (asset :accessor defender-asset :initarg :asset :type (integer 0 *)
	  :initform 0
	  :documentation "how many nodes does the defender holds?")
   (select-init-assets-form :accessor defender-select-init-assets-form :initarg :select-init-assets-form
			    :initform '(lambda (nodes asset) (last (shuffle nodes) asset)))
   (assets :accessor defender-assets :initarg :assets
	   :initform nil
	   :documentation "which nodes are the assets?")
   (deployment-history :accessor defender-deployment-history :initform (make-hash-table)
		      :documentation "keyed on node names; deployment history")
   (migration-history :accessor defender-migration-history :initform nil
		      :documentation "one alist per timestamp")
   )
  )

(defmethod initiate-actor ((actor defender) &rest initargs &key pool &allow-other-keys)
  (if (defender-assets actor)
      (setf (defender-asset actor) (length (defender-assets actor)))
      (when (> (defender-asset actor) 0)
	(setf (defender-assets actor)
	      (funcall (eval (defender-select-init-assets-form actor)) 
		       (if pool pool (list-nodes)) (defender-asset actor)))))
  (when (next-method-p) (call-next-method)))

(defmethod select-targets ((actor defender) pool)
  (declare (ignore pool))
  (let ((targets (make-hash-table))
	(migration nil)
	(selection nil))
    (iter:iter
      (iter:for asset :in (defender-assets actor))
      (multiple-value-bind (sel mig) (migrate actor (find-node asset))
	(push sel selection)
	(when mig (push mig migration))))
    (when migration (push migration (defender-migration-history actor))) ; update migration history
    (iter:iter				; update deployment history
      (iter:for sel :in selection)
      (setf (gethash sel (defender-deployment-history actor))
	    (1+ (ensure-gethash sel (defender-deployment-history actor) 0))))
    (apply #'update-defender-assets actor selection) ; update defender assets !!! otherwise, inconsistency with judges' view 
    (iter:iter
      (iter:for judge :in (list-actors 'judge))
      (setf (gethash judge targets) (defender-assets actor)))
    targets))

(defgeneric migrate (defender asset)
  (:documentation "DEFENDER deicdes where to migrate ASSET")
  (:method ((defender defender) (asset node))
    "default: no migration"
    (values (node-name asset) nil)))

(defmethod update-defender-assets ((defender defender) &rest assets)
  (setf (defender-assets defender) assets)
  (setf (defender-asset defender) (length (defender-assets defender))))

(defmethod inform-defender-compromise ((defender defender) &rest compromised-nodes)
  (apply #'update-defender-assets defender (nset-difference (defender-assets defender) compromised-nodes)))

(defmethod act ((actor defender) targets)
  (iter:iter
    (iter:for judge :in (list-actors 'judge))
    (inform-judge (find-actor judge) actor (gethash judge targets))))

(defmethod print-object ((defender defender) stream)
  (when (next-method-p) (call-next-method))
  (format stream "#<ASSETS ~A>~&" (defender-assets defender)))
