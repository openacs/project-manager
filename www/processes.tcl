ad_page_contract {

    Main view page for projects.

    @author jader@bread.com, ncarroll@ee.usyd.edu.au
    @creation-date 2003-05-15
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return projects Multirow data set of projects.
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)

} -properties {

    context:onevalue
    processes:multirow
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
set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower [parameter::get -parameter "projectname" -default "project"]

# set up context bar
set context_bar [list "Processes"]

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# root CR folder
# set root_folder [db_string get_root "select pm_project__get_root_folder (:package_id, 'f')"]

# Processes, using list-builder ---------------------------------

template::list::create \
    -name processes \
    -multirow processes \
    -key item_id \
    -elements {
        one_line {
            label "Subject"
            display_template {
                <a href="process-one?process_id=@processes.process_id@">@processes.one_line@</a>
            }
        }
        description {
            label "Description"
        }
        instances {
            label "Times used"
            display_template {
                <a href="process-instances?process_id=@processes.process_id@">@processes.instances@</a>
            }
        }
        creation_date {
            label "Created"
        }
        delete {
            link_url_col delete_url
            display_template {
                <img src="/resources/acs-subsite/Delete16.gif" width="16" height="16" border="0">
            }
        }
    } \
    -main_class {
        narrow
    } \
    -actions {
        "Add process" "process-add-edit" "Add a process"
    } \
    -filters {
        orderby_process {}
    } \
    -orderby {
        one_line {orderby one_line}
        default_value one_line,desc
    } \
    -orderby_name orderby_project \
    -html {
        width 100%
    }


db_multirow -extend { delete_url creation_date } processes process_query {
} {
    set delete_url [export_vars -base "process-delete" {process_id}]
    set creation_date [lc_time_fmt $creation_date_ansi "%x"]
}


# ------------------------- END OF FILE ------------------------- #
