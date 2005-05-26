ad_page_contract {

    page to view workgroups

    @author jader@bread.com
    @creation-date 2003-09-10
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return tasks Multirow data set of task roles
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)
} {
    {orderby_r ""}
} -properties {

    context_bar:onevalue
    workgroup:multirow
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
set context_bar [ad_context_bar "[_ project-manager.lt_View_project_term_low_1]"]

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

# Project workgroups, using list-builder ---------------------------------

template::list::create \
    -name workgroup \
    -multirow workgroup \
    -key role_id \
    -elements {
        workgroup_id {
            label "[_ project-manager.Workgroup_ID]"
            link_url_col item_url
            link_html { title "[_ project-manager.Edit_this_role]" }
        }
        one_line {
            label "[_ project-manager.One_line_description]"
        }
        description {
            label "[_ project-manager.Description]"
        }
        sort_order {
            label "[_ project-manager.Sort_order]"
        }
    } \
    -filters {
        orderby_r {}
    } \
    -orderby {
        one_line {orderby one_line}
        sort_order {orderby sort_order}
        default_value sort_order,asc
    } \
    -orderby_name orderby_r \
    -html {
        width 100%
    }


db_multirow -extend { item_url } workgroup wg_query {
} {
    set item_url [export_vars -base "ask-role-add-edit" -override {{project_item_id}} {project_item_id}]
}


# ------------------------- END OF FILE ------------------------- #
