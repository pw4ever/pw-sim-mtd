(in-package :pw-sim-mtd)

(defclass attacker (actor)
  (
   (budget :accessor attacker-budget :initarg :budget :type (interger 0 *)
	   :initform 0
	   :documentation "how many nodes can the attacker attack at one epoch")
   )
  (:documentation "attacker"))

(defmethod initiate-actor ((actor attacker) &rest initargs &key &allow-other-keys))

(defmethod act ((actor attacker) targets)
  (iter:iter
    (iter:for judge :in (list-actors 'judge))
    (inform-judge (find-actor judge) actor (gethash judge targets))))

(defmethod select-targets ((actor attacker) pool)
  (let ((targets (make-hash-table)))
    (iter:iter
      (iter:for judge :in (list-actors 'judge))
      (setf (gethash judge targets)	; per judge target
	    (last (shuffle pool) (attacker-budget actor))))
    targets))
