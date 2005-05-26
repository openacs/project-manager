ad_page_contract {

    Delete of process tasks

    @author jader@bread.com
    @creation-date 2003-10-08
    @cvs-id $Id$

} {
    process_id:integer
    process_task_id:multiple,verify
}

# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege write

db_dml delete_process_tasks { }

ad_returnredirect -message "Process task deleted" "process-one?[export_vars -url {process_id}]"
