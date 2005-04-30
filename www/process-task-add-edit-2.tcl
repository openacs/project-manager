ad_page_contract {

    Add/edit form for process tasks, page 2

    @author jader@bread.com
    @creation-date 2003-09-29
    @cvs-id $Id$

    @param process_id The process that we're adding or editing items for.
    @param task_title The titles of the tasks
    @param estimated_hours_work Estimated hours worked
    @param estimated_hours_work Estimated hours worked (min)
    @param estimated_hours_work Estimated hours worked (max)
    @param process_task_id the ID for each process
    @param use_dependency this task will depend on others

} {

    process_id:integer,notnull
    {task_title:array ""}
    {description:array ""}
    {estimated_hours_work:array ""}
    {estimated_hours_work_min:array ""}
    {estimated_hours_work_max:array ""}
    {estimated_days_work:array ""}
    {estimated_days_work_min:array ""}
    {estimated_days_work_max:array ""}
    {ordering:array ""}
    {assignee:multiple ""}
    process_task_id:integer,multiple
    {use_dependency:array ""}

} -validate {
    process_id_missing {
        if {![exists_and_not_null process_id]} {
            ad_complain
        }
    }
    task_title_too_long {
        foreach {index tt} [array get task_title] {
            if {[string length $tt] > 198} {
                ad_complain
            }
        }
    }
    description_too_long {
        foreach {index d} [array get description] {
            if {[string length $d] > 3998} {
                ad_complain
            }
        }
    }
    description_empty {
        foreach {index d} [array get description] {
            if {[empty_string_p $d]} {
                ad_complain
            }
        }
    }
    bad_estimated_hours_work_range {
        foreach {index wr} [array get estimated_hours_work] {
            if {$wr > 500 || $wr < 0} {
                ad_complain
            }
        }
    }
    process_task_id_missing {
        foreach ptid $process_task_id {
            if {![exists_and_not_null ptid]} {
                ad_complain
            }
        }
    }
} -errors {
    process_id_missing {I don't know which process these tasks are for!}
    task_title_too_long {A task subject is too long. It must be 198 characters or less}
    description_too_long {A description subject is too long. It must be 3998 characters or less}
    description_empty {The description may not be empty}
    bad_estimated_hours_work_range {The estimated hours must be between 0 and 499 hours}
    process_task_id_missing {I don't know which process task is being added or edited!}
}


set user_id    [ad_maybe_redirect_for_registration]
set package_id [ad_conn package_id]

permission::require_permission -party_id $user_id -object_id $package_id -privilege create

set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

set use_days_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
set hours_day     [pm::util::hours_day]

# ------------------------------------------------------------
# we need to determine if these tasks are new or being edited.
# we know this by checking if the numbers exist.
# we assume that if any of them exist, that we're editing.
# ------------------------------------------------------------

set edit_p [db_string editing_process_tasks_p { } -default "0"]


if {[string is false $edit_p]} {

    # -----------------------------
    # if we're adding process tasks
    # -----------------------------

    set index 0
    set array_index 0

    foreach ptid $process_task_id {

        set array_index [expr $index +1]
        
        # set up the values
        set task_id  [lindex $process_task_id $index]
        
        set one_line $task_title($array_index)
        set desc     $description($array_index)
        set order    $ordering($array_index)

        if {[string is true $use_days_p]} {
            if {[string is true $use_uncertain_completion_times_p]} {
                set work_min [expr $estimated_days_work_min($array_index) * $hours_day]
                set work_max [expr $estimated_days_work_max($array_index) * $hours_day]
                set work [expr .5 * [expr $work_max - $work_min] + $work_min]
            } else {
                set work     [expr $estimated_hours_work($array_index) * $hours_day]
                set work_min $work
                set work_max $work
            }
        } else {
            if {[string is true $use_uncertain_completion_times_p]} {
                set work_min $estimated_hours_work_min($array_index)
                set work_max $estimated_hours_work_max($array_index)
                set work [expr .5 * [expr $work_max - $work_min] + $work_min]
            } else {
                set work     $estimated_hours_work($array_index)
                set work_min $work
                set work_max $work
            }
        }
        
        db_dml new_task { *SQL* }
        incr index
    }
} else {

    # -----------------------------
    # if we're editing process tasks
    # -----------------------------

    # -----------------------------
    # if we're adding process tasks
    # -----------------------------

    set index 0
    set array_index 0

    foreach ptid $process_task_id {
        
        set array_index [expr $index +1]

        # set up the values
        set task_id  [lindex $process_task_id $index]
        
        set one_line $task_title($array_index)
        set desc     $description($array_index)
        set order    $ordering($array_index)
        
        if {[string is true $use_days_p]} {
            if {[string is true $use_uncertain_completion_times_p]} {
                set work_min [expr $estimated_days_work_min($array_index) * $hours_day]
                set work_max [expr $estimated_days_work_max($array_index) * $hours_day]
                set work [expr .5 * [expr $work_max - $work_min] + $work_min]
            } else {
                set work     [expr $estimated_hours_work($array_index) * $hours_day]
                set work_min $work
                set work_max $work
            }
        } else {
            if {[string is true $use_uncertain_completion_times_p]} {
                set work_min $estimated_hours_work_min($array_index)
                set work_max $estimated_hours_work_max($array_index)
                set work [expr .5 * [expr $work_max - $work_min] + $work_min]
            } else {
                set work     $estimated_hours_work($array_index)
                set work_min $work
                set work_max $work
            }
        }
        
        db_dml edit_task { *SQL* }
        incr index
    }
}


# remove assignments 
foreach ptid $process_task_id {

    pm::process::remove_assignees \
        -process_task_id $process_task_id

}

foreach ass $assignee {

    regexp {(.*)-(.*)-(.*)} $ass match process_task party_id role_id

    pm::process::assign \
        -process_task_id $process_task \
        -party_id $party_id \
        -role_id $role_id

}

if {[llength $process_task_id] > 1} {
    set task_tasks tasks
} else {
    set task_tasks task
}

if {[llength [array get use_dependency]] > 0} {
    set dep_msg "Now set up dependencies"
} else {
    set dep_msg ""
}

ad_returnredirect -message "Process $task_tasks saved. $dep_msg" "process-dependency-add-edit?[export_vars -url {process_task_id:multiple process_id use_dependency:array}]"

ad_script_abort
