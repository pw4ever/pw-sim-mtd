(in-package :pw-sim-mtd)

(defparameter *default-world-param*
  `(
    (:make-network 64
     :random-state ,(make-random-state t)
     :node-compromise-form-pool
     (
      (pw-sim-mtd::make-sigmoid-function 1 0 0.5 5)
      (pw-sim-mtd::make-sigmoid-function 0.85 0.15 1 2.5)
      (pw-sim-mtd::make-sigmoid-function 0.7 0.3 0.5 7.5)
      )		   
     )
    (:make-actors
     ;; order matters!!
     (attacker 1 :budget 8)
     (defender-static 2  :asset 32)
     (defender-mtd-rotate 2 :asset 32 :threshold 4)
     (defender-mtd-risk-aware 2 :asset 32)
     (judge 1)
     )
    ))

(defparameter *default-duration*
  50)
