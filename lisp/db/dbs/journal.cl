        (read-table *my-read-table*));---------------------------------------------------;   Contents Summary;---------------------------------------------------;;;;  Journals:;;;;      Journal structure type;---------------------------------------------------(define-structure-type journal    symbol          ;   unique atomic identifier    subject         ;   text header (string)    resources       ;   hmmm...    time            ;   time of engagement    date-due        ;   date    client          ;   person requesting journal    agent           ;   person performing journal    keywords        ;   keys for indexing db table    remarks         ;   text ...    index           ;   order in schedule    status          ;   Open, Pending, Closed (string)    date-open       ;   date    date-closed     ;   date    current-flag    ;   true if selected, else nil    db              ;   recursive db slot    (               ;; handlers:     ((id self)      (journal-symbol self))     ((pretty-print self port)      (MAPC #'       #'(LAMBDA (selector)           (cond ((NULL (selector self))                  nil)                 ((MEMBER selector (no-pp-fields self))                  nil)                 ((EQ  (selector-id selector) 'db)                  (format port "~%Db: ~15T")                  (print (selector self) port))                 ((EQ  (selector-id selector) 'remarks)                  (format port "~%Remarks:")                  (MAPC #'                    #'(LAMBDA (str)                        (format port "~%~A" str))                    (selector self)))                 (else                  (format port "~%~A: ~15T"                          (capitalize (selector-id selector)))                  (pretty-print (selector self) port))))       (stype-selectors journal-stype)))     ((inorder? self other)      (if (journal? other)          (let ((date1 (coerce-date (journal-date-due self)))                (date2 (coerce-date (journal-date-due other)))                (time1 (coerce-time (journal-time self)))                (time2 (coerce-time (journal-time other)))                (status1 (journal-status self))                (status2 (journal-status other)))            (or (date-before? date1 date2)                (and (date-equal? date1 date2)                     (or (time-before? time1 time2)                         (and (time-equal? time1 time2)                               (inorder? status1 status2))))))))     ((print-header self port . args)      (format port "~%~A ~A~A ~A ~10T~A ~21T~A~28T~A~A"          (case (CHAR *0*(journal-status self))            ((#\A #\O) #\space)            ((#\P) #\/)            (else  (CHAR *0*(journal-status self))))          (if (journal-current-flag self) "*" " ")          (if (db? (journal-db self)) "db" "  ")          (journal-index self)          (if (date? (journal-date-due self))              (print-header (journal-date-due self) nil)              "")          (if (time? (journal-time self))              (print-header (journal-time self) nil)              "")          (if (db? (journal-db self))              (format nil "~S: " (db-name (journal-db self)))              "")          (journal-subject self)))     ((print-hc self port . args)      (let ((indent (if args (car args) "")))        (format port "~%~A ~A ~6T~A ~21T~A~28T~A~A~A"                (case (CHAR *0*(journal-status self))                  ((#\A #\O) #\space)                  ((#\P) #\/)                  (else  (CHAR *0*(journal-status self))));;;          (if (journal-current-flag self) "*" " ")                (if (db? (journal-db self)) "db" "  ");;;          (journal-index self)                (if (date? (journal-date-due self))                    (print-header (journal-date-due self) nil)                    "")                (if (time? (journal-time self))                    (print-header (journal-time self) nil)                    "")                indent                (if (db? (journal-db self))                    (format nil "~S: " (db-name (journal-db self)))                    "")                (journal-subject self))        (if (db? (journal-db self))            (MAPC #'             #'(LAMBDA (item)               (print-hc item port (CONCATENATE 'STRING indent "  ")))             (db-all (journal-db self))))))     ((print self port)      (format port "#{Journal ~A Status: ~A}"        (object-hash self)        (journal-status self)))     ((input-prototype self slot-id)      (case slot-id       ((symbol)        #'(LAMBDA () (generate-symbol 'journal)))       ((status)        #'(LAMBDA () "Active"))       ((subject)       #'(LAMBDA () (prompted-string-input "Subject: ")))       ((date-open)     #'(LAMBDA () (current_date)))       ((date-due)      #'(LAMBDA () (current_date)))       ((keywords)      #'(LAMBDA () (prompted-list-input "Keywords: ")))       ((remarks)       #'(LAMBDA () (prompted-string-list-input "Remarks: ")))       (else            #'(LAMBDA () '()))))     ((update-prototype self slot-id)      (case slot-id       ((status)        #'(LAMBDA () (capitalize (prompted-string-input "Status: "))))       ((subject)       #'(LAMBDA () (prompted-string-input "Subject: ")))       ((resources)     #'(LAMBDA () (prompted-string-input "Resources: ")))       ((remarks)       #'(LAMBDA () (prompted-string-list-input "Remarks: ")))       ((date-open)     #'(LAMBDA () (prompted-date-input "Date-open: ")))       ((date-due)      #'(LAMBDA () (prompted-date-input "Date-due: ")))       ((time)          #'(LAMBDA () (prompted-time-input "Time: ")))       ((date-closed)   #'(LAMBDA () (prompted-date-input "Date-closed: ")))       ((client)        #'(LAMBDA () (prompted-string-input "Client: ")))       ((agent)         #'(LAMBDA () (prompted-string-input "Agent: ")))       ((keywords)      #'(LAMBDA () (prompted-list-input "Keywords: ")))       ((db)            #'(LAMBDA () (prompted-string-input "Db: ")))       (else            #'(LAMBDA () '()))))     ((no-pp-fields self)      (list journal-index journal-current-flag))     ((no-print-readable-fields self)      (list journal-index journal-current-flag))     ((table-index-fields self)      (list journal-keywords journal-subject journal-agent journal-client))    ))  ;;  END OF JOURNAL STRUCTURE DEFINITION;;  set all initial JOURNAL values to NIL(initialize-entire-structure journal-stype nil);;----------------------------------------------------------;;      Master Schedule of Journals;;----------------------------------------------------------(DEFVAR journal (make-db)) (SETF (db-data-file journal) "~/t/db/data/journal")(SETF (db-name journal) 'journal) (SETF (db-prompt journal) "JOURNAL> ")(SETF (db-struct journal) journal-stype)(SETF (db-print-file journal) "~/t/db/data/journal.print")(SETF (db-commands journal)        '((agent (agent))          (client (client))          (date-closed (date-closed closed))          (date-due (date-due due))          (date-open (date-open open))          (remarks (remarks text))          (resources (resources res))          (status (status st))          (subject (subject subj))          (time (time))          (keywords (keywords keys))          (db (db))          ))(init-db journal)