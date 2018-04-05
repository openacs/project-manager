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

# Checking if the optional variables exist to know if we are going
# to send them in the include

if { [exists_and_not_null task_id] } {
    set exist_task_p 1
} else {
    set exist_task_p 0
}

if { [exists_and_not_null task_revision_id] } {
    set exist_task_rev_p 1
} else {
    set exist_task_rev_p 0
}

if { [exists_and_not_null orderby_people] } {
    set exist_order_by_p 1
} else {
    set exist_order_by_p 0
}

# Retrieving the value of the parameter to know which template we call
set template_src [parameter::get -parameter "TaskOne"]
# ------------------------- END OF FILE ------------------------- #
