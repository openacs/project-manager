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

set title "[_ project-manager.lt_Edit_process_instance]"
set context [list [list "[_ project-manager.Processes]" processes ] [list "[_ project-manager.Process_instances]" "process-instances?process_id=$process_id"] $title]


