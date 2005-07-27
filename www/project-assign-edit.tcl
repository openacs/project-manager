#

ad_page_contract {
    
    Allows the user to edit the assignees for a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    @arch-tag: e7f97c50-b2de-4483-b0a6-daadd802965b
    @cvs-id $Id$
} {
    project_item_id:integer,notnull
    return_url:notnull
} -properties {
} -validate {
} -errors {
}

# The unique identifier for this package.
set package_id [ad_conn package_id]

# The id of the person logged in and browsing this page
set user_id [ad_maybe_redirect_for_registration]

# We want to assign people based on one or more categories. For this a
# new page should be made available to add users based on categories.
 
set project_assign_categories_url [export_vars -base project-assign-from-categories {project_item_id return_url}]

# permissions
permission::require_permission -party_id $user_id -object_id $project_item_id -privilege write

set project_name [pm::project::name -project_item_id $project_item_id]

set title "[_ project-manager.lt_Edit_project_assignee]"
set context [list [list "one?project_item_id=$project_item_id" "$project_name"] "[_ project-manager.Edit_assignees]"]

set project_task_assignee_url [export_vars -base project-assign-task-assignees {project_item_id return_url}]

set roles_list_of_lists [pm::role::select_list_filter]

db_foreach assignee_query {
    SELECT
    a.party_id,
    r.role_id
    FROM
    pm_project_assignment a,
    pm_roles r,
    persons p
    WHERE
    a.role_id = r.role_id and
    a.party_id = p.person_id and
    a.project_id = :project_item_id
    ORDER BY
    r.role_id,
    p.first_names,
    p.last_name

} {
    set assigned($party_id-$role_id) 1
}

set contact_id [application_data_link::get_linked -from_object_id $party_id -to_object_type "content_item"]

set assignee_list_of_lists [pm::util::subsite_assignees_list_of_lists]


set html "<form action=\"project-assign-edit-2\" method=\"post\"><table border=0 width=\"100\%\"><tr>"

foreach role_list $roles_list_of_lists {

    set role_name [lindex $role_list 0]
    set role      [lindex $role_list 1]

    append html "
      <td><p /><B><I>[_ project-manager.Assignee_1] $role_name</I></B><p />"

    foreach assignee_list $assignee_list_of_lists {
        set name [lindex $assignee_list 0]
        set person_id [lindex $assignee_list 1]

        if {[exists_and_not_null assigned($person_id-$role)]} {
            set checked "checked"
        } else {
            set checked ""
        }

        append html "
          <input name=\"assignee\" value=\"$person_id-$role\"
              type=\"checkbox\" $checked />$name
          <br />
        "

    }

    # Add the list of Employees from the customer as well if they are
    # not already in the list above.

    append html "</td>"

}

set export_vars [export_vars -form {project_item_id return_url}]

append html "<tr><td colspan=\"[llength $roles_list_of_lists]\" align=\"center\"><input type=\"Submit\" value=\"Save\"></td></tr></table>$export_vars</form>"
