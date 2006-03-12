# packages/project-manager/www/send-mail.tcl

ad_page_contract {
    Use acs-mail-lite/lib/email chunk to send out going mail messages.
} {
    project_id:integer,notnull
    {party_ids:multiple ""}
}

# Get the project_item_id and the project_name
set project_item_id [pm::project::get_project_item_id -project_id $project_id]
set project_name [pm::project::name -project_item_id $project_item_id]

set title [_ project-manager.send_message_to]
set context [list [list "one?project_id=$project_id" $project_name] $title]

# Values to send to the include
set export_vars [list project_id]
set return_url "one?project_id=$project_id"


# First we get all users assigned to this project
set users_list [pm::project::assignee_role_list -project_item_id $project_item_id]

set options [list]

set party_ids [list]
foreach user $users_list {
    set user [lindex $user 0]
    if { ![empty_string_p [party::email -party_id $user]] } {
	lappend party_ids $user
    }
}

set employee_list [group::get_members -group_id [group::get_id -group_name "Employees"]]
foreach employee_id $employee_list {
    if {[lsearch -exact $party_ids $employee_id] == -1} {
	lappend party_ids $employee_id
    }
}

