ad_page_contract {

    Main admin view page

    @author jader@bread.com
    @creation-date 2003-09-10
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return projects Multirow data set of projects.
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)

} -properties {

    categories_link:onevalue
    context:onevalue
    projects:multirow
    write_p:onevalue
    create_p:onevalue
    admin_p:onevalue
    task_term:onevalue
    task_term_lower:onevalue
    project_term:onevalue
    project_term_lower:onevalue
    logger_link:onevalue
    logger_primary_link:onevalue
    logger_sync_link:onevalue
}

# --------------------------------------------------------------- #

set logger_URLs [parameter::get -parameter "LoggerURLsToKeepUpToDate" -default ""]
set logger_primary [parameter::get -parameter "LoggerPrimaryURL" -default ""]

# set up context bar
set context [list]
set title "Project Manager Administration"

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [auth::require_login]

# set up links
set categories_link "/categories/cadmin/one-object?object_id=$package_id"
set parameters_link "/shared/parameters?package_id=$package_id&return_url=[site_node::get_package_url -package_key project-manager]admin/"
set logger_link "logger"
set logger_primary_link "logger-primary"
set logger_sync_link "logger-sync"
set update_projects_link "update-projects"

if {[empty_string_p $logger_URLs]} {
    set logger_warning "<font color=\"red\">not set up</font>"
} else {
    set logger_warning "Currently integrated: <ul><li>[join $logger_URLs "<li>"]</ul>"
}

if {[empty_string_p $logger_primary]} {
    set logger_primary_warning "<font color=\"red\">not set up</font>"
} else {
    set logger_primary_warning "Currently selected: <ul><li>$logger_primary</ul>"
}

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege admin

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# root CR folder
set root_folder [db_string get_root "select pm_project__get_root_folder (:package_id, 'f')"]


# ------------------------- END OF FILE ------------------------- #
