(in-package :pw-sim-mtd)

(defclass judge (actor)
  (
   (information :accessor judge-information :initform (make-hash-table))
   (history :accessor judge-history :initform (make-hash-table))
   )
  )

(defgeneric inform-judge (judge actor action)
  (:method ((judge judge) (actor actor) action)
    (setf (gethash (actor-name actor) (judge-information judge)) action)))

(defmethod initiate-actor ((actor judge) &rest initargs &key &allow-other-keys))

(defmethod act ((actor judge) targets)
  (declare (ignore targets))
  ;; carry out the judgment based on information
  (let ((compromised nil)
	(node-info (make-hash-table :test 'equal)))
    (iter:iter
      (iter:for attacker :in (list-actors 'attacker))
      (iter:iter
	(iter:for defender :in (list-actors 'defender))
	(let ((common (intersection (ensure-gethash attacker (judge-information actor) nil)
				    (ensure-gethash defender (judge-information actor) nil))))
	  (iter:iter
	    (iter:for node :in common)
	    (let ((node (find-node node)))
	      ;; (node-info node) is keyed on defender
	      (setf (gethash defender (node-info node))
		    (1+ (ensure-gethash defender (node-info node) 0)))
	      ;; similarly, (gethash :node-info (gethash :time judge-history))
	      ;; is keyed on (defender . node)
	      (setf (gethash (cons defender (node-name node)) node-info)
		    (gethash defender (node-info node)))
	      (when (< (random 1.0)
		       (funcall (eval (node-compromise-form node)) 
				(gethash defender (node-info node))))
		;; compromised!
		(inform-defender-compromise (find-actor defender) (node-name node))
		(pushnew (cons defender (node-name node)) compromised)))))))
    ;; record the history
    (let ((time (gettime))
	  (judge-history (judge-history actor)))
      (setf (gethash time judge-history) (make-hash-table))
      (setf (gethash :compromised (gethash time judge-history)) compromised)
      (setf (gethash :node-info (gethash time judge-history)) node-info)))

  ;; clear information for receiving future one
  (clrhash (judge-information actor)))

(defmethod select-targets ((actor judge) pool)
  (declare (ignore pool)))

(defmethod print-object ((judge judge) stream)
  (when (next-method-p) (call-next-method))
  (labels ((rec-hash-table-alist (elt)
	     (if (hash-table-p elt)
		 (iter:iter
		   (iter:for i :in 
			     (sort (hash-table-keys elt)
			      #'(lambda (a b) (ignore-errors (< a b)))))
		   (iter:collect (cons i
				       (rec-hash-table-alist (gethash i elt)))))
		 elt)))
    (format stream
	    "~&#<HISTORY~%~A~&>"
	    (rec-hash-table-alist (judge-history judge)))))
