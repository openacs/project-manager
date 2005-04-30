ad_page_contract {

    Confirm delete of process tasks

    @author jader@bread.com
    @creation-date 2003-10-08
    @cvs-id $Id$

    @return task_term_lower What to call tasks
    @return context_bar Context bar.
    @return title Page title.

} {

    process_id:integer,optional
    process_task_id:integer,multiple,notnull

} -properties {
    
    hidden_vars:onevalue
    task_term_lower:onevalue
    context_bar:onevalue
    title:onevalue

}

# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# terminology
set task_term_lower [parameter::get -parameter "taskname" -default "task"]

set title "Delete process $task_term_lower"
set context_bar [ad_context_bar "Delete process $task_term_lower"]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege write

set hidden_vars [export_vars -form {process_task_id:multiple,sign process_id}]
