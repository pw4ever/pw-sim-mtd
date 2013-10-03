(in-package :pw-sim-mtd)

(defclass defender-static (defender)
  (
   )
  )

(defmethod migrate ((defender defender-static) (asset node))
  ;; default method of "no migration" suffices
  (when (next-method-p) (call-next-method)))
