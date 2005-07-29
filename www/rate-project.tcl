# packages/project-manager/www/rate-project

ad_page_contract {
    Creates the chunk to rate one project

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    project_id:integer,notnull
    project_item_id:integer,notnull
}

set title "Rate this Project"

set context [list [list "one?project_id=$project_id" "One Project"] $title]

set user_id [ad_conn user_id]

set users_list [pm::project::assignee_role_list -project_item_id $project_item_id]

set output_page ""
foreach user $users_list {
    set assignee_id [lindex $user 0]
    acs_user::get -user_id $assignee_id -array user_info
    set role [pm::role::name -role_id [lindex $user 1]]
    append output_page "<h3>Rate $user_info(first_names) $user_info(last_name) ($role):</h3>"    
    append output_page [ratings::dimension_form -dimensions_key_list "" -object_id $user_id -context_object_id $project_id]
    append output_page "<br><br>"
}

