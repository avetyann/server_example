;;;;Программа реконструкции слов по мультимножеству подслов
;;;;Нет проверок на адекватность ввода

;;;Библиотека для работы с JSON
(ql:quickload :yason)

;;;Функция возвращающая множество подслов длины n слов word образованное сдвигом 1
(defun make-subwords-set (word n)
	(if (< (length word) n)
		nil
		(let ((set nil))
			(do ((i 0 (+ i 1)))
				((> i (- (length word) n)))
				(push (subseq word i (+ i n)) set))
			set)))
			
;;;Функция, принимающая список подслов с повторениями и создающая хеш-таблицу, 
;;;где ключ -- подслово, а значение -- число повторений
(defun make-subwords-multiset (subwords-set)
	(let ((ht (make-hash-table :test #'equal)))
		(dolist (sbword subwords-set)
			(if (null (gethash sbword ht));Если данное подслово встречается впервые
				(setf (gethash sbword ht) 1)
				(setf (gethash sbword ht) (+ (gethash sbword ht) 1))))
		ht));возвращает правильную хеш-таблицу
	
;;;Функция, берущая префикс от слова
(defun prefix (word)
	(subseq word 0 (- (length word) 1)))
	
;;;Функция, берущая суффикс слова
(defun sufix (word)
	(subseq word 1 (length word)))
		
;;;Функция, принимающая мультимножество подслов (хеш-таблицу) и возвращающая
;;;хеш-таблицу вершин (суффиксов и префиксов подслов без повторений), ключ слово - значение номер
(defun make-node-set (subwords-multiset)
	(let ((node-set (make-hash-table :test #'equal)) (i 0));;;Создать хэш-таблицу для вершин
		(maphash #'(lambda (k v)
			 			(if (null (gethash (prefix k) node-set))
							(progn
								(setf (gethash (prefix k) node-set) i)
								(setf i (+ i 1))))
						(if (null (gethash (sufix k) node-set))
							(progn
								(setf (gethash (sufix k) node-set) i)
								(setf i (+ i 1)))))
					subwords-multiset)
		node-set))

;;;печатает структуру ребра
(defun print-arc (arc stream depth)
	(format stream "#<~A,~A,~A,~A>" (arc-start arc) (arc-end arc) (arc-rep arc) (arc-value arc)))
			
			
;;;Структура, реализующая ребра с полями: начало (номер), конец (номер), частота, подслово					
(defstruct (arc (:print-function print-arc))
	start
	end
	rep
	value)
	

	
	
;;;Функция, принимающая мультимножество подслов и хеш-таблицу вершин и возвращающая
;;;хеш-таблицу дуг (ключ номер(символ) - значение структура вершина)
(defun make-arc-set (subwords-multiset node-set)
	(let ((arc-set (make-hash-table :test #'equal)) (i 0))
		(maphash #'(lambda (k v)
						(setf (gethash i arc-set)
							  (make-arc :start (gethash (prefix k) node-set)
								  		:end (gethash (sufix k) node-set)
								  	  	:rep v
								  	  	:value k))
						(setf i (+ i 1)))
					subwords-multiset)
		arc-set))
					
;;;Функция, принимающая множества вершин и ребер и возвращающая матрицу графа
(defun make-matrix (node-set arc-set)
	(let ((matrix (make-array (list (hash-table-count node-set) 
									(hash-table-count node-set)) :initial-element nil)))
		(maphash #'(lambda (k v)
						(setf (aref matrix (arc-start v)
										   (arc-end v))
							  (cons (cons k nil) nil)))
					arc-set)
		matrix))


;;;Функция считающая число повторений вершины в картеже			
(defun check-path (path elem);path (asdd) elem (a)
		(let ((i 0))
			(mapcar #'(lambda (x)
						(if (equal x (car elem))
							(setf i (+ i 1)))) path)
		i))
		
;;;Получить число вершин с таким символическим именем ВСЕГО
(defun rep-numb (elem arc-set);elem (a)
	(arc-rep (gethash (car elem) arc-set)))	
		
		
;;;Функция умножает картеж на новое символьное имя учитывая правила
(defun elem-mult (path elem arc-set);path (asdf) elem (a)
	(if (not (or (null path) (null elem)))
		;(format t "nil");nil
		(if (<= (+ (check-path path elem) 1) (rep-numb elem arc-set))
			;(format t "nil");nil
			(append path elem))))
			

;;;Функция умножает две ячейки матрицы, вида ((aav)(sdf)) и ((а)), 
;;;друг на друга и записывает результат в какой-то список
(defun matrix-elem-mult (cell1 cell2 output arc-set);cell1 список cell2 элемент
	(progn
	(mapcar #'(lambda (x)
					(push (elem-mult x (car cell2) arc-set) output)) cell1)
	output))
					
					
;;;Функция перемножающая матрицы
(defun multipl-matrix (f-matrix s-matrix arc-set)
	(let ((new-matrix (make-array (list (array-dimension f-matrix 0) 
										(array-dimension f-matrix 1))
								  :initial-element nil)))
		(do ((i 0 (+ i 1)))
			((>= i (array-dimension new-matrix 0)))
			(do ((j 0 (+ j 1)))
				((>= j (array-dimension new-matrix 1)))
				(do ((k 0 (+ k 1)))
					((>= k (array-dimension new-matrix 1)))
					(setf (aref new-matrix i j) 
						  (matrix-elem-mult (aref f-matrix i k) 
									  		(aref s-matrix k j) 
									  		(aref new-matrix i j)
									  	  	arc-set)))))
	new-matrix))


;;;Функция очищающая матрицу от лишних нуллов	
(defun clean-matrix (matrix)
	(progn
		(do ((i 0 (+ i 1)))
			((>= i (array-dimension matrix 0)))
			(do ((j 0 (+ j 1)))
				((>= j (array-dimension matrix 1)))
				(if (not (null (aref matrix i j)))
						(setf (aref matrix i j) (remove nil (aref matrix i j))))))
		matrix))


;;;Функция перемножающая матрицу и возвращающая матрицу без лишних нуллов
(defun clean-multipl (f-matrix s-matrix arc-set)
	(clean-matrix (multipl-matrix f-matrix s-matrix arc-set)))
	
	
;;;Возвести в правильную степень
(defun find-euliar (matrix arc-set subwords-set)
	(let ((x matrix))
		(do ((i 1 (+ i 1)))
			((>= i (length subwords-set)))
			(setf x (clean-multipl x matrix arc-set)))
	x))


;;;Реконструировать слово
(defun reconstruct-word (arcs arc-set)
	(let ((str ""))
		(mapcar #'(lambda (x)
						(setf str (concatenate 'string str 
											   (subseq (arc-value 
												   			(gethash x arc-set)) 
														0 1)))) 
				   arcs)
		(setf str (concatenate 'string str (sufix 
								(arc-value 
									(gethash 
										(car (last arcs)) 
										arc-set)))))
	str)
	)


;;;Выписать все варианты реконструкции
(defun list-recons-words (matrix arc-set)
	(let ((words nil))
		(do ((i 0 (+ i 1)))
			((>= i (array-dimension matrix 0)))
			(do ((j 0 (+ j 1)))
				((>= j (array-dimension matrix 1)))
				(if (not (null (aref matrix i j)))
						(mapcar #'(lambda (x)
										(push (reconstruct-word x arc-set) words))
								(aref matrix i j)))))
		words))
		
;;;Превратить матрицу в список списков
(defun matrix-to-list (matrix)
	(let ((mat nil) (lst nil))
		(progn
			(do ((i 0 (+ i 1)))
				((>= i (array-dimension matrix 0)))
					(progn
					(do ((j 0 (+ j 1)))
						((>= j (array-dimension matrix 1)))
							(setf lst (cons (aref matrix i j) lst)))
					(setf lst (reverse lst))
					(setf mat (cons lst mat))
					(setf lst nil)))
			(setf mat (reverse mat)))
		mat))	
		
;;;Создать хеш-таблицу дуг для JSON
(defun make-arc-hash-json (arc-set)
	(let ((arc-set-json (make-hash-table :test #'equal)))
	(maphash #'(lambda (k v) 
					(setf (gethash (format nil "~A" k) arc-set-json) 
						  (list (arc-start v)
						  	 	(arc-end v)
								(arc-rep v) 
								(arc-value v)))) arc-set)
	arc-set-json))

;;;Формируем JSON ответ								
(defun make-response (node-set arc-set matrix finalmatrix list-of-variants)
	(let ((response (make-hash-table :test #'equal)))
		(setf (gethash "node-set" response) node-set)
		(setf (gethash "arc-set" response) arc-set)
		(setf (gethash "matrix" response) matrix)
		(setf (gethash "result-matrix" response) finalmatrix)
		(setf (gethash "list-of-variants" response) list-of-variants)
	response)
	)
					
		
																																																																																	
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					