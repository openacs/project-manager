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



# terminology and other parameters
set task_term       [_ project-manager.Task]
set task_term_lower [_ project-manager.task]
set assignee_term   [parameter::get -parameter "AssigneeName" -default "Assignee"]
set watcher_term    [parameter::get -parameter "WatcherName" -default "Watcher"]
set project_term    [_ project-manager.Project]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

set use_days_p      [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
set urgency_threshold 8
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

# set link to comments

set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 $task_id "[pm::task::get_url $task_id]"]

set comments_link "<a href=\"[export_vars -base "comments/add" {{ object_id $task_id} {title "$task_info(task_title)"} {return_url [ad_return_url]} {type task} }]\">[_ project-manager.Add_comment]</a>"

set print_link "task-print?&task_id=$task_id&project_item_id=$task_info(project_item_id)"


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

set assignee_add_self_widget "Add myself as <form method=\"post\" action=\"task-assign-add\">[export_vars -form {{task_item_id $task_id} user_id return_url}][pm::role::task_select_list -select_name "role_id" -task_item_id $task_id -party_id $user_id]<input type=\"Submit\" value=\"OK\" /></form>"

# Only need a 'remove myself' link if you are already assigned
set assigned_p [pm::task::assigned_p -task_item_id $task_id -party_id $user_id]
if {$assigned_p} {
    set assignee_remove_self_url [export_vars -base task-assign-remove {{task_item_id $task_id} user_id return_url}]
}

# Set the link to the permissions page
set permissions_url "[site_node::closest_ancestor_package -package_key subsite]/permissions/one?[export_vars {{object_id $task_id}}]"

set nextyear_ansi [clock format [clock scan "+ 365 day"] -format "%Y-%m-%d"]
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

# ------------------
# Dynamic Attributes
# ------------------

set form_attributes [list]
foreach element [dtype::form::metadata::widgets_list -object_type pm_task -exclude_static_p 1 -dform $task_info(dform)] {
    lappend form_attributes [lindex $element 3]
}

dtype::get_object -object_id $task_revision_id -object_type pm_task -array dattr -exclude_static

multirow create dynamic_attributes name value
foreach attr [array names dattr] {
    if {[lsearch -exact $form_attributes $attr] > -1} {
	multirow append dynamic_attributes "[_ acs-translations.pm_task_$attr]" $dattr($attr)
    }
}


# People, using list-builder ---------------------------------

template::list::create \
    -name people \
    -multirow people \
    -key item_id \
    -elements {
        first_names {
            label {
                "[_ project-manager.Who]"
            }
            display_template {
                <if @people.is_lead_p@><i></if>@people.user_info@<if @people.is_lead_p@></i></if>
            }
        }
        role_id {
            label "[_ project-manager.Role]"
            display_template "@people.one_line@"
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        party_id {}
        task_id {}
        orderby_depend_to {}
        orderby_depend_from {}
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

ad_return_template

# ------------------------- END OF FILE ------------------------- #
