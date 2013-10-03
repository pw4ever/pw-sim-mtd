(in-package :pw-sim-mtd)

;;; create the world

(defparameter *world* (make-hash-table))

(let ((part-type
	'((:hash-table
	   :network			; NETWORK of NODEs
	   :actors			; ACTORs act on NETWORK
	   )
	  (:list 
	   ))))
  (iter:iter
    (iter:for part :in (assoc-value part-type :hash-table))
    (setf (gethash part *world*) (make-hash-table)))
  (iter:iter
    (iter:for part :in (assoc-value part-type :list))
    (setf (gethash part *world*) nil))
  (setf (gethash :time *world*) 0))

(defun gettime ()
  (gethash :time *world*))

;;;  node

(defclass node ()
  (
   (name :accessor node-name :initarg :name)
   (neighbors :accessor node-neighbors :initarg :neighbors)
   (compromise-form :accessor node-compromise-form :initarg :compromise-form)
   (status :accessor node-status :initarg :status)
   (info :accessor node-info :initarg :info :initform (make-hash-table :test 'equal))
   )
  (:documentation "NODE can be ACTed on by ACTOR"))

(defgeneric make-node (node-class &rest initargs &key name &allow-other-keys)
  (:documentation "create a new node")
  (:method (node-class &rest initargs &key name &allow-other-keys)
    (setf (gethash name (gethash :network *world*))
	  (apply #'make-instance node-class initargs))))

(defun list-nodes (&optional (status t))
  "LIST NODES of STATUS; T for all"
  (iter:iter
    (iter:for (name node) :in-hashtable (gethash :network *world*))
    
    (when (or (eql status t)
	      (eql status (node-status (gethash name (gethash :network *world*)))))
      (iter:collect name))))

(defun find-node (name)
  (gethash name (gethash :network *world*)))

(defun destroy-node (name)
  (remhash name (gethash :network *world*)))

(defun destroy-all-nodes ()
  (iter:iter 
    (iter:for name :in (list-nodes))
    (destroy-node name)))

(defun change-node-status (name new-status)
  (change-class (find-node name) (symbolicate :node- new-status)))

(defmethod print-object ((node node) stream)
  (format stream "~&#<~A of class ~A>" (node-name node) (class-of node)))

;;; actor

(defclass actor ()
  (
   (name :accessor actor-name :initarg :name :type (or symbol string) :initform nil)
   )
  (:documentation "ACTOR can ACT on NODE"))

(defgeneric make-actor (actor-class &rest initargs &key name &allow-other-keys)
  (:documentation "create a new actor")
  (:method (actor-class &rest initargs &key name &allow-other-keys)
    (setf (gethash name (gethash :actors *world*))
	  (apply #'make-instance actor-class initargs))
    (initiate-actor (find-actor name))))

(defgeneric initiate-actor (actor &rest initargs &key &allow-other-keys)
  (:documentation "initiate a new actor"))

(defun list-actors (&optional (actor-class 'actor))
  (iter:iter
    (iter:for (name actor) :in-hashtable (gethash :actors *world*))
    (when (typep actor actor-class)
      (iter:collect name))))

(defun find-actor (name)
  (gethash name (gethash :actors *world*)))

(defun destroy-actor (name)
  (remhash name (gethash :actors *world*)))

(defun destroy-all-actors ()
  (iter:iter
    (iter:for name :in (list-actors))
    (destroy-actor name)))

(defgeneric act (actor targets)
  (:documentation "ACTOR ACT on TARGETS"))

(defgeneric select-targets (actor pool)
  (:documentation "ACTOR SELECT TARGETs from POOL"))

(defmethod print-object ((actor actor) stream)
  (format stream "~&#<~A of class ~A>" (actor-name actor) (class-of actor)))

;;; simulation evolution

(defun evolve ()
  (iter:iter
    (iter:for actor :in (sort (list-actors) #'string-lessp :key #'symbol-name))
    (let ((actor (find-actor actor)))
      (act actor (select-targets actor (list-nodes)))))
  (incf (gethash :time *world*)))


