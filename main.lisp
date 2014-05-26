
(defun recostruct (word)
	(defparameter *word* word);слово

	(defparameter *subwords-set* (make-subwords-set *word* 2));Создать список всех подслов

	(defparameter *subwords-multiset* (make-subwords-multiset *subwords-set*));Создать мультимножество подслов

	(defparameter *node-set* (make-node-set *subwords-multiset*));Создать множество вершин

	(defparameter *arc-set* (make-arc-set *subwords-multiset* *node-set*));Создать множенство дуг

	(defparameter *matrix* (make-matrix *node-set* *arc-set*));Создать матрицу графа

	(defparameter *testmatrix* (clean-multipl *matrix* *matrix* *arc-set*));Создать матрицу возведенную в квадрат

	(defparameter *finalmatrix* (find-euliar *matrix* *arc-set* *subwords-set*));Создать матрицу возведенную в список подслов

	(defparameter *list-of-variants* (list-recons-words *finalmatrix* *arc-set*))
		*list-of-variants*);Создать список вариантов
	
