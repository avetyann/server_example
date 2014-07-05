
(defun recostruct (word_length words) ;;;;;; !!!!!!!!!!
	;(defparameter *word* word);слово

	;(defparameter *subwords-set* (make-subwords-set words word_length));Создать список всех подслов
    
	(defparameter *subwords-multiset* (make-subwords-multiset words));Создать мультимножество подслов

	(defparameter *node-set* (make-node-set *subwords-multiset*));Создать множество вершин

	(defparameter *arc-set* (make-arc-set *subwords-multiset* *node-set*));Создать множенство дуг
		
	(defparameter *arc-set-json* (make-arc-hash-json *arc-set*));Создать хеш-таблицу дуг для JSON

	(defparameter *matrix* (make-matrix *node-set* *arc-set*));Создать матрицу графа

	(defparameter *testmatrix* (clean-multipl *matrix* *matrix* *arc-set*));Создать матрицу возведенную в квадрат

	(defparameter *finalmatrix* (find-euliar *matrix* *arc-set* words));Создать матрицу возведенную в список подслов
		
	(defparameter *matrix-json* (matrix-to-list *matrix*));JSON matrix 1
		
	(defparameter *finalmatrix-json* (matrix-to-list *finalmatrix*));JSON matrix 2
	
	(defparameter *list-of-variants* (list-recons-words *finalmatrix* *arc-set*)); СОЗДАТЬ ВАРИАНТЫ РЕКОНСТРУКЦИИ
		
	(defparameter *response* (make-response *node-set* *arc-set-json* *matrix-json* *finalmatrix-json* *list-of-variants*));формирует JSON ответ
	
		*response*);Создать список вариантов