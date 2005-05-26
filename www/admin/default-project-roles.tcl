ad_page_contract {

    page to view project roles

    @author jader@bread.com
    @creation-date 2003-09-10
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return roles Multirow data set of project roles
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)
} {
    {orderby_r ""}
} -properties {

    context_bar:onevalue
    projects:multirow
    write_p:onevalue
    create_p:onevalue
    admin_p:onevalue
    task_term:onevalue
    task_term_lower:onevalue
    project_term:onevalue
    project_term_lower:onevalue
}

# --------------------------------------------------------------- #

# terminology
set task_term       [_ project-manager.Task]
set task_term_lower [_ project-manager.task]
set project_term    [_ project-manager.Project]
set project_term_lower [_ project-manager.project]

# set up context bar
set context_bar [ad_context_bar "View $project_term_lower roles"]

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# root CR folder
set root_folder [db_string get_root "select pm_project__get_root_folder (:package_id, 'f')"]

# Project roles, using list-builder ---------------------------------

template::list::create \
    -name roles \
    -multirow roles \
    -key role_id \
    -elements {
        role_id {
            label "[_ project-manager.Role_ID]"
            link_url_col item_url
            link_html { title "[_ project-manager.Edit_this_role]" }
        }
        party_id {
            label "[_ project-manager.Party_ID]"
        }
    } \
    -filters {
        orderby_r {}
    } \
    -orderby {
        role_id {orderby role_id}
        party_id {orderby party_id}
        default_value role_id,asc
    } \
    -orderby_name orderby_r \
    -html {
        width 100%
    }


db_multirow -extend { item_url } roles default_project_roles_query {
} {
    set item_url [export_vars -base "default-project-role-add-edit" -override {{project_item_id}} {project_item_id}]
}


# ------------------------- END OF FILE ------------------------- #
