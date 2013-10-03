(in-package #:pw-sim-mtd)

;;; world

(defun create-world (world-param)
  (iter:iter
    (iter:for (func . param) :in world-param)
    (apply (symbol-function (symbolicate func)) param)))

(defun save-world (place)
  (cl-store:store *world* place))

(defun load-world (place)
  (setf *world* (cl-store:restore place)))

;;; network

(defun make-network (&optional n &key node-compromise-form-pool random-state (density 0.5) make-node-initargs)
  (declare (type (float 0 1) density))
  "make a network of N node; if N is NIL, use existing *NETWORK*"
  (when n
    (iter:iter 
      (iter:for i :from 1 :to n)
      (apply #'make-node 'node 
	     :name (make-keyword (symbolicate :node- (format nil "~A" i)))
	     :compromise-form (random-elt node-compromise-form-pool)
	     (mapcar #'(lambda (x)
		       (optima:match x
			 ((cons :eval body) (apply #'eval body))
			 ((cons :compile body) (apply #'compile nil body))
			 (x x)))
		   make-node-initargs))))
  ;; construct neighbors
  (let* ((*random-state* (if random-state random-state *random-state*))
	 (nodes (list-nodes))
	 (max-unidir-neighbor-length (ceiling (* (length nodes) density))))
    (iter:iter				; randomly connect nodes
      (iter:for node :in nodes)
      (let ((other-nodes (remove node nodes)))
	(setf (node-neighbors (find-node node))
	      (last
	       (cl-utils-pw.util:random-select-from-list other-nodes
							 :destructive t)
	       max-unidir-neighbor-length))))
    (iter:iter				; make connections bidirectional
      (iter:for node :in nodes)
      (iter:iter
	(iter:for neighbor :in (node-neighbors (find-node node)))
	(let ((neighbor (find-node neighbor)))
	  (setf (node-neighbors neighbor) (adjoin node (node-neighbors neighbor))))))))

(defun list-network ()
  "list nodes and their neighbors; each (NODE . NEIGHBOR-LIST)"
  (iter:iter
    (iter:for node :in (list-nodes))
    (iter:collect (cons node (node-neighbors (find-node node))))))

;;; actors

(defun make-actors (&rest args)
  (iter:iter
    (iter:for (actor-class n . initargs) :in-sequence args :with-index index)
    (iter:iter
      (iter:for i :from 1 :to n)
      (apply #'make-actor
	     (find-class actor-class)
	     :name (make-keyword 
		    (symbolicate :actor-
				 (format nil 
					 "~A-~A-~A" 
					 index actor-class i)))
	     initargs))))

;;; node compromise function

(defun make-sigmoid-function (&optional K A B M)
  "generalized logistic function as defined in https://en.wikipedia.org/wiki/Generalised_logistic_function"
  #'(lambda (time)
      (+ A (/ (- K A)
	      (1+ (exp (* (- B)
			  (- time M))))))))

(defun review-history ()
  (values
   (iter:iter
     (iter:for judge :in (list-actors 'judge))
     (iter:collect (find-actor judge)))
   (iter:iter
     (iter:for defender :in (list-actors 'defender))
     (iter:collect (find-actor defender)))))
