(defvar test1   (MAKE-INSTANCE 'DIALOG    :WINDOW-TYPE    :DOCUMENT    :VIEW-POSITION    '(:TOP 60)    :VIEW-SIZE    #@(300 150)    :VIEW-FONT    '("Chicago" 12 :SRCOR :PLAIN)    :VIEW-SUBVIEWS    (LIST (MAKE-DIALOG-ITEM           'EDITABLE-TEXT-DIALOG-ITEM           #@(46 27)           #@(84 17)           "Mary"           #'(LAMBDA (ITEM)               ITEM               )           :VIEW-NICK-NAME           'NAME-ENTRY           :ALLOW-RETURNS           NIL)))  )(defun name-message ()  (let ((edit-item (view-named 'name-entry test1)))    (format t "Hello ~A!" (dialog-item-text edit-item))))