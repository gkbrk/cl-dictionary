(defvar *css* "
body {
    background-color: lightgray;
}

.entry {
    margin: 1em;
    padding: 0.5em;
}

nav a {
    margin-right: 0.5em;
}

a {
    color: black;
}
")

(defmacro with-template (&body body)
  `(with-html-output-to-string (out)
     (:html
      (:head
       (:title (str *title*))
       (:style (str *css*)))
      (:body
       (:a :href *base* (:h1 (str *title*)))
       (:form :action "/search"
              (:input :type :text :name :q :placeholder "What are you looking for?"))
       (nav out)
       (:hr)
       ,@body
       (:hr)
       (:p (str *copyright*))))))

(defun nav (out)
  (with-html-output (out)
    (:nav
     (if (not (get-user))
         (htm
          (:a :href "/login" "Login")
          (:a :href "/register" "Sign up"))
         (htm
          (:p "Welcome, " (:b (str (dict-user-username (get-user)))) "!")
          (:a :href "/logout" "Log out")))
     )))

(defun render-entry (out entry)
  (with-html-output (out)
    (:div
     :class "entry"
     :style "border: 1px solid black;"
     (:a :href (format nil "/view/~a" (dict-entry-title entry))
         (:h3 :class "title"
              (str (escape-string (dict-entry-title entry)))))
     (:p (str (escape-string (dict-entry-content entry))))
     )))
