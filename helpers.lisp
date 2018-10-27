(defun get-param (param params)
  "Get param from assoc"
  (cdr (assoc param params :test #'string=))
  )

(defun set-header (header content)
  (setf (getf (lack.response:response-headers ningle:*response*) header) content)
  )

(defun set-status-code (status-code)
  (setf (lack.response:response-status ningle:*response*) status-code)
  )

(defun redirect (url)
  (setf (getf (lack.response:response-headers ningle:*response*) :location) url)
  (setf (lack.response:response-status ningle:*response*) 302)
  nil
  )

(defmacro route (path method &body body)
  `(setf (ningle:route *app* ,path :method ,method)
         #'(lambda (params)
             ,@body
             ))
  )

(defun get-user ()
  (gethash :user ningle:*session*))

(defun check-auth (username password)
  (datafly:retrieve-one
   (select :*
           (from :User)
           (where (:and (:= :username username) (:= :password password))))
   :as 'dict-user))

(defmacro require-auth (&body body)
  `(if (get-user)
       (progn ,@body)
       (redirect "/login")))
