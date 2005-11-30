ad_page_contract {

    Page to get the project if one is missing for task creation

    @author jader@bread.com
    @creation-date 2003-10-06
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.
    @return projects A multirow containing the list of projects

    @param process_id The process we're using to create this task
} {

    {process_id:integer ""}
    {process_task_id:integer,multiple ""}
    {project_item_id ""}
    {return_url ""}
    {status_type "o"}
    {searchterm ""}
    {orderby ""}
    
} -properties {

    context_bar:onevalue
    title:onevalue
    choices:onevalue
    searchterm_copy:onevalue

} -validate {
} -errors {
}

# --------------------------------------------------------------- #

set user_id    [auth::require_login]
set package_id [ad_conn package_id]

permission::require_permission -object_id $package_id -privilege write

if {[empty_string_p $searchterm]} {
    unset searchterm
}

set hidden_vars [export_vars -form {process_id return_url process_task_id:multiple}]

if {[exists_and_not_null project_item_id]} {
    ad_returnredirect [export_vars -base task-add-edit {project_item_id process_id return_url process_task_id:multiple}]
}


# terminology
set Project_Term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term    [parameter::get -parameter "projectname" -default "project"]
set Task_Term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term       [parameter::get -parameter "taskname" -default "task"]

if {[empty_string_p $process_id]} {
    set title "Select a $project_term to assign this $task_term to"
} else {
    set title "Select a $project_term to assign this process to"
}

if {![exists_and_not_null searchterm]} {
    set searchterm_copy ""
    set searchterm_where_clause ""
} else {
    set searchterm_copy $searchterm
    set searchterm_where_clause "upper(p.title) like upper('%$searchterm%')"
}

if {[exists_and_not_null process_id]} {
    set context [list [list "processes" "Processes"] "Use"]
} else {
    set context [list [list "tasks" "Tasks"] "Select Project"]
}

# need to change this to show all the projects you're on by
# default, and then give you the option of selecting all projects
# as an option.

set root_folder [db_string get_root {}]

template::list::create \
    -name projects \
    -multirow projects \
    -key project_item_id \
    -elements {
        customer_name {
            label "Customer"
        }
        project_item_id {
            label "Project"
            link_url_col item_url
            display_template "@projects.project_name@"
        }
        description {
            label "Description"
            display_template "@projects.description_html;noquote@"
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        customer_name {
            label "Customer"
            where_clause {p.organization_id = :customer_id}
        }

        searchterm {
            label "Project Search term"
            where_clause $searchterm_where_clause
        }
 
       status_type {
            label "Status"
            values {{"Open" o} {"Closed" c}}
            where_clause {
                s.status_type = :status_type
            }
        }
        return_url {
            hide_p 1
        }
    } \
    -orderby {
        default_value customer_name,asc
        project_item_id {
            label "Project"
            orderby_desc "upper(p.title) desc"
            orderby_asc "upper(p.title) asc"
            default_direction asc
        }
        customer_name {
            label "Customer"
            orderby_desc "upper(o.name) desc, upper(p.title) desc"
            orderby_asc "upper(o.name) asc, upper(p.title) asc"
            default_direction asc
        }
    } \
    -orderby_name orderby \
    -html {
        width 100%
    }


db_multirow -extend { item_url description_html } projects select_a_project {
} {
    set item_url [export_vars -base "task-add-edit" {project_item_id process_id process_task_id:multiple return_url}]

    set richtext_list [list $description $mime_type]
    set description_html [template::util::richtext::get_property html_value $richtext_list]
}

