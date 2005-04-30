# 

ad_page_contract {
    
    Processes the process instance changes
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-05
    @arch-tag: 6d8d980e-c28f-4333-874b-4e71c3803ffd
    @cvs-id $Id$
} {
    instance_id:integer,notnull
    my_name:notnull
    process_id:integer,notnull
} -properties {
} -validate {
} -errors {
}

set user_id     [ad_maybe_redirect_for_registration]
set package_id  [ad_conn package_id]

permission::require_permission \
    -party_id $user_id \
    -object_id $package_id \
    -privilege write

db_dml change_process_instance { }

ad_returnredirect -message "Saved change of process instance name" process-instances?process_id=$process_id
