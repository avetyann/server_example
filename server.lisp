(load "~/quicklisp/setup.lisp")
(load "clutils/listener.lisp")
(load "reconstruct.lisp")
(load "main.lisp")

(ql:quickload :drakma)
(ql:quickload :yason)

(defun example-handler(req)
	(let ((word  (tbnl:get-parameter "word"))
			(resp "{ [ "))
		(format t "~%|~A|~%" word)
		(mapcar #'(lambda (str) (setf resp (format nil "~A \"~A\", " resp str)) ) (yason:encode (recostruct word)))
		(format nil "~A \"end\" ] }" resp )))
	
(defparameter *lstnr* (make-instance 'utils:listener))

(utils:listener-add-handler *lstnr* "/examplepath/" #'example-handler)
(utils:listener-start *lstnr* 4242)

;(pprint (recostruct "aaabbabaaabbbaaabaaabbbaaa"))

(yason:parse "{ \"a\" : \"b\" }")
