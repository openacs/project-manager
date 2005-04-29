# /project-manager/www/admin/update-projects.tcl

ad_page_contract {
    page which updates the status of all projects and tasks

    @author jader@bread.com
    @cvs-id $Id$
    @creation-date 11/24/03
} {
}

ns_log Debug "---------------------------------------------------"
ns_log Debug "Project manager: Updating all projects"

# make sure user is administrator
set user_id [ad_conn user_id]

permission::require_permission -party_id $user_id -object_id $user_id -privilege admin

set context_id [ad_conn package_id]
set peeraddr [ad_conn peeraddr]

ns_write "<html><title>Updating projects and tasks</title><body>

Starting...<p />"


set projects_list [db_list get_projects "select item_id from cr_items where content_type = 'pm_project'"]

foreach project $projects_list {
    pm::project::compute_status $project
    ns_write ". "
}


ns_log Notice "done with project update page (finally!)"


ns_write "
<a href=index>back to admin page</a></html>"

