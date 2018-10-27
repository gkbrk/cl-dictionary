(in-package :cl-user)

(require :ningle)
(require :clack)
(require :cl-who)
(require :datafly)
(require :sqlite)
(require :jose)

(defpackage :dict-app
  (:use :cl)
  (:use :cl-who)
  (:use :sxql)
  )

(in-package :dict-app)

(load "config")
(load "sql")
(load "helpers")
(load "layout")

(defvar *app* (make-instance 'ningle:<app>))

(route "/" :GET
       (with-template
           (:b "Latest entries")(:br)
           (loop for entry in (get-latest-entries)
                do (render-entry out entry))
           ))

(route "/login" :GET
       (with-template
           (:h3 "Login")
         (:form :method :post
                (:input :type :text :name :username :placeholder "Username")(:br)
                (:input :type :password :name :password :placeholder "Password")(:br)
                (:input :type :submit :value "Login")
                )
         ))

(route "/login" :POST
       (let* ((username (get-param :username params))
              (password (get-param :password params))
              (auth (check-auth username password)))
         (if auth
             (setf (gethash :user ningle:*session*) auth))
         (redirect "/")))

(route "/logout" :GET
       (remhash :user ningle:*session*)
       (redirect "/")
       nil)

(route "/register" :GET
       (with-template
           (:h3 "Register")
         (:form :method :post
                (:input :type :text :name :username :placeholder "Username")(:br)
                (:input :type :password :name :password :placeholder "Password")(:br)
                (:input :type :submit :value "Register"))))

(route "/register" :POST
       (let* ((username (get-param :username params))
              (password (get-param :password params))
              (user (make-dict-user :username username
                                    :password password)))
         (insert-user user)
         (setf (gethash :user ningle:*session*) user)
         (redirect "/")))

(route "/search" :GET
       (redirect (format nil "/view/~a" (get-param :q params)))
       nil
       )

(route "/view/:title" :GET
       (with-template
           (let* ((title (get-param :title params))
                  (postlink (format nil "/postentry/~a" title)))
             (htm
              (:h3 (str (format nil "Showing entries for ~a" title)))
              (:form :action postlink :method :post
                     (:textarea :name :content)(:br)
                     (:input :type :submit :value "Send"))
              (loop for entry in (get-entries-by-title title)
                 if (string= (dict-entry-title entry) title)
                 do (render-entry out entry))
              ))))

(route "/postentry/:title" :POST
       (require-auth
        (let* ((title (get-param :title params))
               (url (format nil "/view/~a" title))
               (content (get-param :content params)))
          (redirect url)
          (insert-entry (make-dict-entry :title title
                                         :content content))
          nil
          )))

(defvar *clack-app* nil)
(defun start-app ()
  (datafly:connect-toplevel :sqlite3 :database-name *db-path*)
  (setf *clack-app* (clack:clackup (lack.builder:builder :session *app*))))

(defun stop-app ()
  (clack:stop *clack-app*)
  )

(defun reload () (load "dictionary.lisp"))

;(start-app)
