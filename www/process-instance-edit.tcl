# 

ad_page_contract {
    
    Allows a user to edit a process instance name
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-05
    @arch-tag: c792123e-8a76-4b61-829f-932f176be045
    @cvs-id $Id$
} {
    instance_id:integer,notnull
} -properties {
} -validate {
} -errors {
}

db_1row get_instance { }

set title "Edit process instance"
set context [list [list "Processes" processes ] [list "Process instances" "process-instances?process_id=$process_id"] $title]


