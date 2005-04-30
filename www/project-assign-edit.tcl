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
set user_id [auth::require_login]

set subsite_id [ad_conn subsite_id]

set user_group_id [application_group::group_id_from_package_id \
                       -package_id $subsite_id]


set project_name [pm::project::name -project_item_id $project_item_id]

set title "Edit project assignees"
set context [list [list "one?project_item_id=$project_item_id" "$project_name"] "Edit assignees"]

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

set assignee_list_of_lists [db_list_of_lists get_assignees {
    select distinct
    p.first_names || ' ' || p.last_name as name,
    p.person_id
    FROM
    persons p,
    acs_rels r,
    membership_rels mr
    WHERE
    r.object_id_one = :user_group_id and
    mr.rel_id = r.rel_id and
    p.person_id = r.object_id_two and
    member_state = 'approved'
    ORDER BY name
}]


set html "<form action=\"project-assign-edit-2\" method=\"post\"><table border=0 width=\"100\%\"><tr>"

foreach role_list $roles_list_of_lists {

    set role_name [lindex $role_list 0]
    set role      [lindex $role_list 1]

    append html "
      <td><p /><B><I>Assignee: $role_name</I></B><p />"

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

    append html "</td>"

}

set export_vars [export_vars -form {project_item_id return_url}]

append html "<tr><td colspan=\"[llength $roles_list_of_lists]\" align=\"center\"><input type=\"Submit\" value=\"Save\"></td></tr></table>$export_vars</form>"
