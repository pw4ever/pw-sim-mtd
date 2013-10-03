(in-package :pw-sim-mtd)

(defmacro define-node-types (&rest types)
  `(progn
     ,@(iterate:iter
	 (iterate:for type :in types)
	 (iterate:for node-type := (symbolicate :node- type))
	 (iterate:collect
	     `(progn
		(defclass ,node-type (node)
		  ()
		  (:default-initargs :status ,type))
		(defmethod update-instance-for-different-class ((previous node) 
								(current ,node-type) 
								&rest initargs &key &allow-other-keys)
		  (setf (node-status current) ,type)))))))

(define-node-types :active :inactive)
