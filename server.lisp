(load "~/quicklisp/setup.lisp")
(load "clutils/listener.lisp")
(ql:quickload :yason)

(defun example-handler(req)
	(format nil "got paramter param1: ~A <br>" (tbnl:get-parameter "param1")))

(defparameter *lstnr* (make-instance 'utils:listener))

(utils:listener-add-handler *lstnr* "/examplepath/" #'example-handler)
(utils:listener-start *lstnr* 4242)


(yason:parse "{ \"a\" : \"b\" }")
