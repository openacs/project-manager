ad_page_contract {

    Simple add/edit form for processs

    @author jader@bread.com
    @creation-date 2003-09-15
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.

} {

    process_id:integer,optional
    {one_line ""}
    {description ""}
    {number_of_tasks:integer ""}

} -properties {

    context_bar:onevalue
    title:onevalue

}


# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# terminology and parameters
set project_term    [_ project-manager.Project]
set project_term_lower  [_ project-manager.project]

if {[exists_and_not_null process_id]} {
    set title "[_ project-manager.Edit_a_Process]"
    set context_bar [ad_context_bar "[_ project-manager.Edit_Process]"]

    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege write
} else {
    set title "[_ project-manager.Add_a_Process]"
    set context_bar [ad_context_bar "[_ project-manager.New_Process]"]

    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege create
}


ad_form -name add_edit -form {
    process_id:key

    {one_line:text
        {label "[_ project-manager.Subject_1]"}
	{value $one_line}
        {html {size 40}}
    }

    {description:text(textarea),optional
	{label "[_ project-manager.Description]"}
	{value $description}
	{html { rows 5 cols 40 wrap soft}}}

    {number_of_tasks:text
        {label "[_ project-manager.Number_of_new_tasks]"}
	{value "1"}
        {html {size 5}}
    }

} -select_query_name process_query -on_submit {

    set party_id      [ad_conn user_id]
    set creation_date [db_string get_today { }]

} -new_data {
    set process_id [db_nextval pm_process_seq]

    db_dml new_process { *SQL* }

    ad_returnredirect -message "[_ project-manager.lt_Process_added_Now_add]" "process-task-add-edit?[export_vars -url {{number $number_of_tasks} process_id}]"
    ad_script_abort

} -edit_data {

    db_dml edit_process { *SQL* }

} -after_submit {

    ad_returnredirect -message "[_ project-manager.lt_Process_changes_saved]" "process-task-add-edit?[export_vars -url {{number $number_of_tasks} process_id}]"
    ad_script_abort
}


