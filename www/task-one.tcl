ad_page_contract {
    Main view page for one task.

    @author jader@bread.com
    @creation-date 2003-07-28
    @cvs-id $Id$

    @return task_term Term to use for Task
    @return task_term_lower Term to use for task
    @return assignee_term Term to use for assignee
    @return watcher_term Term to use for watcher
    @return dependency multirow that stores dependency information
    @return dependency2 multirow that stores dependency information for tasks that have dependencies on this particular task

    @param task_id item_id for the task
    @param project_item_id the item_id for the project. Used for navigational links
    @param project_id the revision_id for the project. Used for navigational links
    @param context_bar value for context bar creation
    @param orderby_dependency specifies how the dependencies will be sorted
    @param orderby_dependency2 specifies how the dependencies will be sorted (for tasks that have dependencies on this task)
    @param logger_days The number of days back to view logged entries
} {
    task_id:integer,optional
    task_revision_id:integer,optional
    orderby_dependency:optional
    orderby_dependency2:optional
    orderby_people:optional
    {logger_variable_id:integer ""}
    {logger_days:integer "180"}
} -properties {
    closed_message:onevalue
    notification_chunk:onevalue
    task_info:onerow
    project_item_id:onevalue
    project_id:onevalue
    context:onevalue
    write_p:onevalue
    create_p:onevalue
    dependency:multirow
    dependency2:multirow
    people:multirow
    task_term:onevalue
    task_term_lower:onevalue
    assignee_term:onevalue
    watcher_term:onevalue
    comments:onevalue
    comments_link:onevalue
    print_link:onevalue
    use_uncertain_completion_times_p:onevalue
} -validate {
    task_id_exists {
        if {![info exists task_id]} {
            set task_id [pm::task::get_item_id \
                             -task_id $task_revision_id]
            if {[string equal $task_id -1]} {
                ad_complain
            }
        }
    }
    revision_id_exists {
        if {![info exists task_revision_id]} {
            set task_revision_id [pm::task::get_revision_id \
                                      -task_item_id $task_id]
            if {[string equal $task_revision_id -1]} {
                ad_complain
            }
        }
    }
    logger_days_positive {
        if {$logger_days < 1} {
            set logger_days 1
        }
    }
} -errors {
    task_id_exists {That task does not exist}
    revision_id_exists {That task does not exist}
}


# --------------------------------------------------------------- #

# terminology and other parameters
set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]
set assignee_term   [parameter::get -parameter "AssigneeName" -default "Assignee"]
set watcher_term    [parameter::get -parameter "WatcherName" -default "Watcher"]
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

set use_days_p      [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
set urgency_threshold 8
# the unique identifier for this package
set package_id  [ad_conn package_id]
set package_url [ad_conn package_url]
set user_id     [ad_maybe_redirect_for_registration]


# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]



# Task info ----------------------------------------------------------

db_1row task_query { } -column_array task_info

# format the hours remaining section

set task_info(hours_remaining) \
    [pm::task::hours_remaining \
         -estimated_hours_work $task_info(estimated_hours_work) \
         -estimated_hours_work_min $task_info(estimated_hours_work_min) \
         -estimated_hours_work_max $task_info(estimated_hours_work_max) \
         -percent_complete $task_info(percent_complete)]

set task_info(days_remaining) \
    [pm::task::days_remaining \
         -estimated_hours_work $task_info(estimated_hours_work) \
         -estimated_hours_work_min $task_info(estimated_hours_work_min) \
         -estimated_hours_work_max $task_info(estimated_hours_work_max) \
         -percent_complete $task_info(percent_complete)]

# format the dates according to the local settings
set task_info(earliest_start)  [lc_time_fmt $task_info(earliest_start) "%x"]
set task_info(earliest_finish) [lc_time_fmt $task_info(earliest_finish) "%x"]
set task_info(latest_start)    [lc_time_fmt $task_info(latest_start) "%x"]
set task_info(latest_finish)   [lc_time_fmt $task_info(latest_finish) "%x"]
set task_info(end_date)        [lc_time_fmt $task_info(end_date) "%x"]

# we do this for the hours include portion
set project_item_id $task_info(project_item_id)

set context [list [list "one?project_item_id=$task_info(project_item_id)" "$task_info(project_name)"] "$task_info(task_title)"]


set richtext_list [list $task_info(description) $task_info(mime_type)]

set task_info(description) [template::util::richtext::get_property html_value $richtext_list]

if {[exists_and_not_null task_info(earliest_start_j)]} {
    set task_info(slack_time) [pm::task::slack_time \
                                   -earliest_start_j $task_info(earliest_start_j) \
                                   -today_j $task_info(today_j) \
                                   -latest_start_j $task_info(latest_start_j)]
}

if {$task_info(percent_complete) >= 100} {
    set closed_message "-- Closed"
} else {
    set closed_message ""
}


# if part of a process, offer link to process
if {![empty_string_p $task_info(process_instance)]} {
    set process_url [pm::process::url \
                         -process_instance_id $task_info(process_instance) \
                         -project_item_id     $task_info(project_item_id) \
                         -fully_qualified_p "f"]
    set process_name [pm::process::name \
                          -process_instance_id $task_info(process_instance)]
    set process_html "<a href=\"$process_url\">$process_name</a>"
} else {
    set process_html ""
}

# set link to comments

set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 $task_id "[pm::task::get_url $task_id]"]

set comments_link "<a href=\"[export_vars -base "comments/add" {{ object_id $task_id} {title "$task_info(task_title)"} {return_url [ad_return_url]} {type task} }]\">Add comment</a>"

set print_link "task-print?&task_id=$task_id&project_item_id=$task_info(project_item_id)"


# how to get back here
set return_url [ad_return_url]

set task_edit_url [export_vars -base task-add-edit {{task_item_id $task_id} return_url project_item_id}]

set logger_project [pm::project::get_logger_project \
                        -project_item_id $task_info(project_item_id)]

set logger_url [pm::util::logger_url]

if {[empty_string_p $logger_variable_id]} {
    set logger_variable_id [logger::project::get_primary_variable \
                                -project_id $logger_project]
}

set log_url [export_vars -base "${logger_url}log" {{return_url $return_url} {project_id $logger_project} {pm_project_id $task_info(project_item_id)} {pm_task_id $task_id}}]

set assignee_add_self_widget "Add myself as <form method=\"post\" action=\"task-assign-add\">[export_vars -form {{task_item_id $task_id} user_id return_url}][pm::role::task_select_list -select_name "role_id" -task_item_id $task_id -party_id $user_id]<input type=\"Submit\" value=\"OK\" /></form>"

# Only need a 'remove myself' link if you are already assigned
set assigned_p [pm::task::assigned_p -task_item_id $task_id -party_id $user_id]
if {$assigned_p} {
    set assignee_remove_self_url [export_vars -base task-assign-remove {{task_item_id $task_id} user_id return_url}]
}



set nextyear_ansi [clock format [clock scan "+ 365 day"] -format "%Y-%m-%d"]
set then_ansi [clock format [clock scan "-$logger_days days"] -format "%Y-%m-%d"]

set day_widget "Last <input type=\"text\" name=\"logger_days\" value=\"$logger_days\" size=\"5\" /> Days"

set variable_widget [logger::ui::variable_select_widget \
                         -project_id $logger_project \
                         -current_variable_id $logger_variable_id \
                         -select_name logger_variable_id]

set variable_exports [export_vars -form -entire_form -exclude {logger_variable_id logger_days }]


# ------------------
# Notifications info
# ------------------
set notification_chunk [notification::display::request_widget \
                            -type pm_task_notif \
                            -object_id $task_id \
                            -pretty_name "$task_info(task_title)" \
                            -url "[ad_conn url]?[ad_conn query]" \
                           ]


# Dependency info ------------------------------------------------

template::list::create \
    -name dependency \
    -multirow dependency \
    -key d_task_id \
    -elements {
        dependency_type {
            label "Type"
            display_template {
                <if @dependency.dependency_type@ eq start_before_start>
                <img border="0" src="resources/start_before_start.png">
                </if>
                <if @dependency.dependency_type@ eq start_before_finish>
                <img border="0" src="resources/start_before_finish.png">
                </if>
                <if @dependency.dependency_type@ eq finish_before_start>
                <img border="0" src="resources/finish_before_start.png">
                </if>
                <if @dependency.dependency_type@ eq finish_before_finish>
                <img border="0" src="resources/finish_before_finish.png">
                </if>
            }
        }
        d_task_id {
            label "Task"
            display_col task_title
            link_url_col item_url
            link_html { title "View this task" }
        }
        percent_complete {
            label "Status"
            display_template "@dependency.percent_complete@\%"
        }
        end_date {
            label "Deadline"
        }
    } \
    -orderby {
        percent_complete {orderby percent_complete}
        end_date {orderby end_date}
    } \
    -orderby_name orderby_dependency \
    -sub_class {
        narrow
    } \
    -filters {
        task_revision_id {}
        orderby_dependency2 {}
    } \
    -html {
        width 100%
    }

db_multirow -extend { item_url } dependency dependency_query {
} {
    set item_url [export_vars -base "task-one" -override {{task_id $parent_task_id}} { task_id $d_task_id }]
}

# Dependency info (dependency other task have on this task) ------

template::list::create \
    -name dependency2 \
    -multirow dependency2 \
    -key d_task_id \
    -elements {
        dependency_type {
            label "Type"
            display_template {
                <if @dependency2.dependency_type@ eq start_before_start>
                <img border="0" src="resources/start_before_start.png">
                </if>
                <if @dependency2.dependency_type@ eq start_before_finish>
                <img border="0" src="resources/start_before_finish.png">
                </if>
                <if @dependency2.dependency_type@ eq finish_before_start>
                <img border="0" src="resources/finish_before_start.png">
                </if>
                <if @dependency2.dependency_type@ eq finish_before_finish>
                <img border="0" src="resources/finish_before_finish.png">
                </if>
            }
        }
        d_task_id {
            label "Task"
            display_col task_title
            link_url_eval {task-one?task_id=$d_task_id}
            link_html { title "View this task" }
        }
        percent_complete {
            label "Status"
            display_template "@dependency2.percent_complete@\%"
        }
        end_date {
            label "Deadline"
        }
    } \
    -orderby {
        percent_complete {orderby percent_complete}
        end_date {orderby end_date}
    } \
    -orderby_name orderby_dependency2 \
    -sub_class {
        narrow
    } \
    -filters {
        task_revision_id {}
        orderby_dependency {}
    } \
    -html {
        width 100%
    }


db_multirow -extend { item_url } dependency2 dependency2_query {
} {

}

# People, using list-builder ---------------------------------

template::list::create \
    -name people \
    -multirow people \
    -key item_id \
    -elements {
        first_names {
            label {
                Who
            }
            display_template {
                <if @people.is_lead_p@><i></if>@people.user_info@<if @people.is_lead_p@></i></if>
            }
        }
        role_id {
            label "Role"
            display_template "@people.one_line@"
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        party_id {}
        task_id {}
        orderby_subproject {}
        orderby_versions {}
        orderby_tasks {}
    } \
    -orderby {
        default_value role_id,desc
        first_names {
            orderby_asc "first_names asc, last_name asc"
            orderby_desc "first_names desc, last_name desc"
            default_direction asc
        }
        role_id {
            orderby_asc "role_id asc, user_info asc"
            orderby_desc "role_id desc, user_info asc"
            default_direction asc
        }
        default_value role_id,asc
    } \
    -orderby_name orderby_people \
    -html {
        width 100%
    }

db_multirow people task_people_query { }

# Xrefs ------------------------------------------------

template::list::create \
    -name xrefs \
    -multirow xrefs \
    -key x_task_id \
    -elements {
        x_task_id {
            label "ID"
        }
        title {
            label "Task"
            link_url_col item_url
            link_html { title "View this task" }
        }
        slack_time {
            label "Slack"
        }
        earliest_start_pretty {
            label "ES"
        }
        earliest_finish_pretty {
            label "EF"
        }
        latest_start_pretty {
            label "LS"
        }
        latest_finish_pretty {
            label "LF"
            display_template {
                <b>@xrefs.latest_finish_pretty@</b>
            }
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        task_revision_id {}
        orderby_revision {}
        orderby_dependency {}
        orderby_dependency2 {}
    } \
    -html {
        width 100%
    }

db_multirow -extend { item_url earliest_start_pretty earliest_finish_pretty latest_start_pretty latest_finish_pretty slack_time } xrefs xrefs_query {
} {
    set item_url [export_vars -base "task-one" -override {{task_id $x_task_id}}]

    set earliest_start_pretty [lc_time_fmt $earliest_start "%x"]
    set earliest_finish_pretty [lc_time_fmt $earliest_finish "%x"]
    set latest_start_pretty [lc_time_fmt $latest_start "%x"]
    set latest_finish_pretty [lc_time_fmt $latest_finish "%x"]

    set slack_time [pm::task::slack_time \
                        -earliest_start_j $earliest_start_j \
                        -today_j $today_j \
                        -latest_start_j $latest_start_j]

}


ad_return_template

# ------------------------- END OF FILE ------------------------- #

