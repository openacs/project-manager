ad_page_contract {

    Main view page for tasks.

    @author jader@bread.com
    @creation-date 2003-12-03
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return tasks Multirow data set of tasks
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)

    @param mine_p is used to make the default be the user, but
    still allow people to view everyone.

} {
    orderby:optional
    party_id:optional
    {searchterm ""}
    {mine_p "t"}
    {status_id ""}
    role_id:optional
} -properties {
    task_term:onevalue
    context:onevalue
    tasks:multirow
    hidden_vars:onevalue
}

# if someone clicks on a party, then we want to see those tasks.
if {[exists_and_not_null party_id]} {
    set mine_p "f"
}

# --------------------------------------------------------------- #

# terminology and parameters
set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower [parameter::get -parameter "projectname" -default "project"]

set use_days_p      [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]

set exporting_vars { status_id party_id orderby mine_p }
set hidden_vars [export_vars -form $exporting_vars]
# how to get back here
set return_url [ad_return_url -qualified]
set logger_url [pm::util::logger_url]

# set up context bar
set context [list "Tasks"]

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [auth::require_login]

# if mine_p is true, show only my tasks
if {[string equal $mine_p t]} {
    set party_id $user_id
}

# status defaults to open
if {![exists_and_not_null status_id]} {
    set status_id [pm::task::default_status_open]
}

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# Tasks, using list-builder ---------------------------------

if {![empty_string_p $searchterm]} {

    # if we're searching, we disregard who we were searching for.
    if {[info exists party_id]} {
        unset party_id
    }
    set mine_p "f"

    if {[regexp {([0-9]+)} $searchterm match query_digits]} {
        set search_term_where " (upper(t.title) like upper('%$searchterm%')
 or t.item_id = :query_digits) "
    } else {
        set search_term_where " upper(t.title) like upper('%$searchterm%')"
    }
} else {
    set search_term_where ""
}


set default_orderby [pm::task::default_orderby]

if {[exists_and_not_null orderby]} {
    pm::task::default_orderby \
        -set $orderby
}


set elements {
    task_number {
        label "\#"
        link_url_col item_url
        link_html { title "View this project version" }
        display_template {<a href="@tasks.item_url@">@tasks.task_item_id@</a>}
    } 
    title {
        label "Subject"
    } 
    slack_time {
        label "Slack"
        display_template "<if @tasks.slack_time@ gt 1>@tasks.slack_time@</if><else><font color=\"red\">@tasks.slack_time@</font></else>"
    } 
    role {
        label "Role"
    }
    latest_start_pretty {
        label "Latest Start"
    } 
    latest_finish_pretty {
        label "Latest Finish"
        display_template {
            <b>@tasks.latest_finish_pretty@</b>
        }
    } 
}

if {[string is true $use_days_p]} {
    append elements {
        days_remaining {
            label "Days work"
            html {
                align right
            }
        } 
    }
} else {
    append elements {
        hours_remaining {
            label "Hours remaining"
            html {
                align right
            }
        } 
    }
}

append elements {
    project_item_id {
        label "Project"
        display_col project_name
        link_url_eval {[export_vars -base one {project_item_id $tasks(project_item_id)}]}
    } 
    log_url {
        label "Log"
        display_template {<a href="@tasks.log_url@">L</a>}
    } 
    percent_complete {
        display_template "<group column=\"task_item_id\"></group>"
    }
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -key task_item_id \
    -elements $elements \
    -actions [list "Add task" [export_vars -base task-select-project {return_url}] "Add a task"] \
    -bulk_actions {
        "Log hours" "log-bulk" "Log hours for several tasks"
        "Edit tasks" "task-add-edit" "Edit multiple tasks"
    } \
    -bulk_action_export_vars {
        {return_url}
    } \
    -sub_class {
        narrow
    } \
    -filters {
        searchterm {
            label "Search"
            where_clause {$search_term_where}
        }
        role_id {
            label "Roles"
            values {[pm::role::select_list_filter]}
            where_clause {
                ta.role_id = :role_id
            }
        }
        party_id {
            label "People"
            values {[pm::task::assignee_filter_select -status_id $status_id]}
            where_clause {
                ta.party_id = :party_id
            }
        }
        status_id {
            label "Status"
            values {[db_list_of_lists get_status_values "select description, status_id from pm_task_status order by status_type desc, description"]}
            where_clause {ts.status = :status_id}
        }
        mine_p {
            label "Show others' tasks"
        }
    } \
    -orderby {
        default_value $default_orderby
        task_number {
            label "Task \#"
            orderby_desc "ts.task_number desc, p.first_names, p.last_name"
            orderby_asc "ts.task_number asc, p.first_names, p.last_name"
            default_direction asc
        }
        title {
            label "Subject"
            orderby_desc "t.title desc, ts.task_id, p.first_names, p.last_name"
            orderby_asc "t.title asc, ts.task_id, p.first_names, p.last_name"
            default_direction asc
        }
        full_name {
            label "Who"
            orderby_desc "p.first_names desc,p.last_name desc, ts.task_id"
            orderby_asc "p.first_names, p.last_name, ts.task_id"
            default_direction asc
        }
        description {
            label "Description"
            orderby_desc "t.description desc, ts.task_id, p.first_names, p.last_name"
            orderby_asc "t.description, ts.task_id, p.first_names, p.last_name"
            default_direction asc
        }
        slack_time {
            label "Slack"
            orderby_desc "(latest_start - earliest_start) desc, ts.task_id, p.first_names, p.last_name"
            orderby_asc "(latest_start - earliest_start), ts.task_id, p.first_names, p.last_name"
            default_direction asc
        }
        latest_start_pretty {
            label "Latest start"
            orderby_desc "t.latest_start desc, ts.task_id, p.first_names, p.last_name"
            orderby_asc "t.latest_start, ts.task_id, p.first_names, p.last_name"
            default_direction asc
        }
        latest_finish_pretty {
            label "Latest finish"
            orderby_desc "t.latest_finish desc, ts.task_id, p.first_names, p.last_name"
            orderby_asc "t.latest_finish, ts.task_id, p.first_names, p.last_name"
            default_direction asc
        }
    } \
    -orderby_name orderby \
    -html {
        width 100%
    }




db_multirow -extend { item_url latest_start_pretty latest_finish_pretty slack_time log_url hours_remaining days_remaining} tasks tasks {
} {
    set item_url [export_vars -base "task-one" {{task_id $task_item_id}}]

    set log_url [export_vars -base "${logger_url}log" {{project_id $logger_project} {pm_task_id $task_item_id} {pm_project_id $project_item_id} {return_url $return_url}}]

    set latest_start_pretty [lc_time_fmt $latest_start "%x"]
    set latest_finish_pretty [lc_time_fmt $latest_finish "%x"]

    if {[exists_and_not_null earliest_start_j]} {
        set slack_time [pm::task::slack_time \
                            -earliest_start_j $earliest_start_j \
                            -today_j $today_j \
                            -latest_start_j $latest_start_j]
    } else {
        set slack_time "n/a"
    }

    set hours_remaining \
        [pm::task::hours_remaining \
             -estimated_hours_work $estimated_hours_work \
             -estimated_hours_work_min $estimated_hours_work_min \
             -estimated_hours_work_max $estimated_hours_work_max \
             -percent_complete $percent_complete]

    set days_remaining \
        [pm::task::days_remaining \
             -estimated_hours_work $estimated_hours_work \
             -estimated_hours_work_min $estimated_hours_work_min \
             -estimated_hours_work_max $estimated_hours_work_max \
             -percent_complete $percent_complete]

}


# ------------------------- END OF FILE ------------------------- #
