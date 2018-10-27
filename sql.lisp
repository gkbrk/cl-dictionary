(defstruct dict-entry
  id
  title
  content
  timestamp)

(defstruct dict-user
  id
  username
  password)

(defun get-entries-by-title (title)
  (datafly:retrieve-all
   (select :*
           (from :Entry)
           (where (:= :title title))
           (order-by (:asc :id)))
   :as 'dict-entry))

(defun get-latest-entries ()
  (datafly:retrieve-all
   (select :*
           (from :Entry)
           (limit 10)
           (order-by (:desc :id)))
   :as 'dict-entry))

(defun create-db ()
  (delete-file *db-path*)
  (let ((db (sqlite:connect *db-path*)))
    (sqlite:execute-non-query
     db "create table Entry(ID integer primary key, Title text not null, Content text not null)")
    (sqlite:execute-non-query
     db "create table User(ID integer primary key, Username text not null, Password text not null)")
    (sqlite:disconnect db))
  (datafly:connect-toplevel :sqlite3 :database-name *db-path*)
  (create-test-data))

(defun insert-entry (entry)
  (datafly:execute
   (insert-into :Entry
                (set= :title (dict-entry-title entry)
                      :content (dict-entry-content entry)))))

(defun insert-user (user)
  (datafly:execute
   (insert-into :User
                (set= :username (dict-user-username user)
                      :password (dict-user-password user)))))

(defun create-test-data ()
  (insert-entry (make-dict-entry :title :potato
                                 :content "Potatoes are the best"))
  (insert-entry (make-dict-entry :title :tomato
                                 :content "Tomatoes are better"))
  (insert-user (make-dict-user :username "test"
                               :password "4321"))
  )
