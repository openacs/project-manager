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

# set up context bar
set context [list]
set title "Project Manager Administration"

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]
set root_folder_id [content::folder::get_folder_from_package -package_id $package_id]

# set up links
set categories_link "/categories/cadmin/one-object?object_id=$package_id"
set categories_task_link "/categories/cadmin/one-object?object_id=$root_folder_id"
set parameters_link "/shared/parameters?package_id=$package_id&return_url=[site_node::get_package_url -package_key project-manager]admin/"
set update_projects_link "update-projects"

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege admin

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]


# ------------------------- END OF FILE ------------------------- #
