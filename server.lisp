(load "~/quicklisp/setup.lisp")
(load "clutils/listener.lisp")
(load "reconstruct.lisp")
(load "main.lisp")

(ql:quickload :drakma)
(ql:quickload :yason)

(defun example-handler(req)
	(let* ((query_str (tbnl:get-parameter "query"))
			(query (yason:parse query_str))
			(word_length (gethash "word_length" query))
			(words (gethash "words" query))
			(result  (recostruct word_length words))
			(resp ""))
			
			(let ((s (make-string-output-stream)))
				(yason:encode result s)
				(setf resp (get-output-stream-string s)))
			
				resp))
	

(defparameter *lstnr* (make-instance 'utils:listener))

(utils:listener-add-handler *lstnr* "/examplepath/" #'example-handler)
(utils:listener-start *lstnr* 8080)

;(pprint (recostruct "aaabbabaaabbbaaabaaabbbaaa"))
;obj
;(setf (gethash "field" obj) value)