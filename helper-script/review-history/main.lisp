(in-package #:pw-sim-mtd.review-history)

(defun review-history (&rest world-files)
  (format t "~&~{~(~A~)~^ ~}"
	  (list :node :attacker.budget :defender.init.asset
		      :time :defender.type :defender.survived.asset))
  (iter:iter
    (iter:for world-file :in world-files)
    (optima:match world-file
      ((optima.ppcre:ppcre "(\\d+)_(\\d+)_(\\d+)_(\\d+)_(\\d+)_(\\d+).world$"
	      node attacker attacker-budget defender defender-asset duration)
       ;(format t "~@{~S~^ ~}~%" world-file node attacker attacker-budget defender defender-asset duration)
       (pw-sim-mtd::load-world world-file)
       (iter:iter
	 (iter:for line :in (pw-sim-mtd::recover-history (read-from-string defender-asset)))
	 ;; each line: node attacker-budget defender-asset time defender-type defender-asset
	 (format t "~&~{~A~^ ~}" (append (list node attacker-budget defender-asset) line)))))))
