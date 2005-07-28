ad_page_contract {
    Main view page for one task.

    @author jader@bread.com
    @creation-date 2003-07-28
    @cvs-id $Id$

    @return task_term Term to use for Task
    @return task_term_lower Term to use for task
    @return assignee_term Term to use for assignee
    @return watcher_term Term to use for watcher

    @param task_id item_id for the task
    @param project_item_id the item_id for the project. Used for navigational links
    @param project_id the revision_id for the project. Used for navigational links
    @param context_bar value for context bar creation
    @param orderby_depend_to specifies how the dependencies will be sorted
    @param orderby_depend_from specifies how the dependencies will be sorted (for tasks that have dependencies on this task)
    @param logger_days The number of days back to view logged entries
} {
    task_id:integer,optional
    task_revision_id:integer,optional
    {orderby_depend_to:optional ""}
    {orderby_depend_from:optional ""}
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

# the unique identifier for this package
#set package_id  [ad_conn package_id]
#set package_url [ad_conn package_url]
#set user_id     [ad_conn user_id]


# permissions. Seemed to be superceded below and now again because of granular permissions work.
#permission::require_permission -object_id $task_id -privilege "read"

#set write_p  [permission::permission_p -object_id $task_id -privilege "write"]
#set create_p [permission::permission_p -object_id $task_id -privilege "create"]

# Master for the portlets
set portlet_master "/packages/project-manager/lib/portlet"

# terminology and other parameters
set task_term       [_ project-manager.Task]
set task_term_lower [_ project-manager.task]
set assignee_term   [parameter::get -parameter "AssigneeName" -default "Assignee"]
set watcher_term    [parameter::get -parameter "WatcherName" -default "Watcher"]
set project_term    [_ project-manager.Project]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]


set use_days_p      [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]

# the unique identifier for this package
set package_id  [ad_conn package_id]
set package_url [ad_conn package_url]
set user_id     [ad_maybe_redirect_for_registration]


# permissions. This is a general 'does the user have permission to even ask for this page to be run?'
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

# These values are now set by the query that extracts the task.
#set write_p  [permission::permission_p -object_id $package_id -privilege write]
#set create_p [permission::permission_p -object_id $package_id -privilege create]



# Task info ----------------------------------------------------------

db_1row task_query { } -column_array task_info

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
    set closed_message "[_ project-manager.--_Closed]"
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


# how to get back here
set return_url [ad_return_url]

set task_edit_url [export_vars -base task-add-edit {{task_item_id $task_id} return_url project_item_id}]

set logger_project [lindex [application_data_link::get_linked -from_object_id $task_info(project_item_id) -to_object_type logger_project] 0]

set logger_url [pm::util::logger_url]

if {[empty_string_p $logger_variable_id]} {
    set logger_variable_id [logger::project::get_primary_variable \
                                -project_id $logger_project]
}

set log_url [export_vars -base "${logger_url}log" -url {{project_id $logger_project} {pm_project_id $task_info(project_item_id)} {pm_task_id $task_id} return_url}]



set then_ansi [clock format [clock scan "-$logger_days days"] -format "%Y-%m-%d"]

set day_widget "[_ project-manager.Last] <input type=\"text\" name=\"logger_days\" value=\"$logger_days\" size=\"5\" /> [_ project-manager.Days]"

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


ad_return_template

# ------------------------- END OF FILE ------------------------- #
