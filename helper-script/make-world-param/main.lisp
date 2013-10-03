(in-package #:pw-sim-mtd.make-world-param)

(defun make-world-param (world 
			 node
			 attacker attacker-budget
			 defender defender-asset)
  (cl-store:store
   `(
     (:make-network ,node
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
      (pw-sim-mtd::attacker ,attacker :budget ,attacker-budget)
      (pw-sim-mtd::defender-static ,defender :asset ,defender-asset)
      (pw-sim-mtd::defender-mtd-rotate ,defender :asset ,defender-asset :threshold 4)
      (pw-sim-mtd::defender-mtd-risk-aware ,defender :asset ,defender-asset)
      (pw-sim-mtd::judge 1)
      )
     )
   world
   )
  )

(defun run ()
  (make-world-param
   (cl-utils-pw.getopt:getopt :world)
   (read-from-string (cl-utils-pw.getopt:getopt :node))
   (read-from-string (cl-utils-pw.getopt:getopt :attacker))
   (read-from-string (cl-utils-pw.getopt:getopt :budget))
   (read-from-string (cl-utils-pw.getopt:getopt :defender))
   (read-from-string (cl-utils-pw.getopt:getopt :asset))
   )
  )
