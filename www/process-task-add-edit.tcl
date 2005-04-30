ad_page_contract {

    Add/edit form for process tasks

    @author jader@bread.com
    @creation-date 2003-09-25
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.
    @return process_id The process we're adding/editing tasks for

    @return num used as a multirow datasource to iterate over the form elements

    @param process_id The process that we're adding or editing items for.
    @param number The number of Tasks to create

    @param process_task_id If we are editing tasks, this will be the value we receive
} {

    process_id:integer,notnull
    {number:integer "1"}
    {process_task_id:integer,multiple ""}

} -properties {

    context_bar:onevalue
    onevalue:multirow
    title:onevalue
    process_id:onevalue
    num:multirow
    use_uncertain_completion_times_p:onevalue

} -validate {
    number_is_in_range -requires {number:integer} {
        # todo: make 100 a parameter
        if {$number < 1 || $number > 100} {
            ad_complain
        }
    }
} -errors {
    number_is_in_range {Number must be between 1 and 100}
}

# --------------------------------------------------------------- #

# --------------------------
# terminology and parameters
# --------------------------

set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]
set use_day_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]

set DEFAULT_ORDERING_GAP 5

# --------------------------------------
# the unique identifier for this package
# --------------------------------------

set package_id [ad_conn package_id]
set user_id    [auth::require_login]

# ------------------------------------------------------------
# if process_task_id is set, then we are editing process tasks
# ------------------------------------------------------------

if {[exists_and_not_null process_task_id]} {

    set edit_p 1
    set title "Edit a process $task_term_lower"
    set context_bar [ad_context_bar [list "process-one?process_id=$process_id" "Process"] "Edit tasks"]
    permission::require_permission -party_id $user_id -object_id $package_id -privilege write

    set process_tasks [list]
    set i 1
    
    db_foreach get_process_tasks { } {
        set process_task_v($i)             $pti
        set one_line_v($i)                 $one_line
        set description_v($i)              $description
        set estimated_hours_work_v($i)     $estimated_hours_work
        set estimated_hours_work_min_v($i) $estimated_hours_work_min
        set estimated_hours_work_max_v($i) $estimated_hours_work_max
        set ordering_v($i)                 $ordering

        set estimated_days_work_v($i)     [pm::util::days_work \
                                                -hours_work $estimated_hours_work]
        set estimated_days_work_min_v($i) [pm::util::days_work \
                                                -hours_work $estimated_hours_work_min]
        set estimated_days_work_max_v($i) [pm::util::days_work \
                                                -hours_work $estimated_hours_work_max]
 
        if {[empty_string_p $ordering_v($i)]} {
            set ordering_v($i) [expr $i * $DEFAULT_ORDERING_GAP]
        }
       
        if {[exists_and_not_null dependency_type]} {
            set checked_v($i) "checked"
        } else {
            set checked_v($i) ""
        }
        
        lappend process_tasks $pti
        incr i
    }
    set number [llength $process_tasks]
} else {

    set edit_p 0
    set title "Add a process $task_term_lower"
    set context_bar [ad_context_bar [list "process-one?process_id=$process_id" "Process"] "Add tasks"]
    permission::require_permission -party_id $user_id -object_id $package_id -privilege create
    
    for {set i 1} {$i <= $number} {incr i} {
        set process_task_v($i)             ""
        set one_line_v($i)                 ""
        set description_v($i)              ""
        set estimated_hours_work_v($i)     ""
        set estimated_hours_work_min_v($i) ""
        set estimated_hours_work_max_v($i) ""
        set estimated_days_work_v($i)     ""
        set estimated_days_work_min_v($i) ""
        set estimated_days_work_max_v($i) ""
        set ordering_v($i)                 [expr $i * $DEFAULT_ORDERING_GAP]
        set checked_v($i)                  ""
    }
}


# set up assignees and roles

set roles_list_of_lists [pm::role::select_list_filter]

set assignee_list_of_lists [pm::util::subsite_assignees_list_of_lists]


template::multirow create num process_task_id one_line description work work_min work_max work_days work_days_min work_days_max ordering checked assignee_html

for {set i 1} {$i <= $number} {incr i} {

    if {[string is false $edit_p]} {
        set process_task_id_tmp [db_nextval pm_process_task_seq]
    } else {
        set process_task_id_tmp [lindex $process_task_id [expr $i-1]]

        # remember all the assignees for this task
        db_foreach assignee_query { 
            SELECT
            a.party_id,
            a.role_id
            FROM
            pm_process_task_assignment a
            WHERE
            a.process_task_id = :process_task_id_tmp
            ORDER BY
            a.role_id
        } {
            set assigned($process_task_id_tmp-$party_id-$role_id) 1
        }

    }

    # we set up the assignments by using this convention:
    # {process_task_id}-{party_id}-{role_id}

    set html "<table border=\"0\">"

    foreach role_list $roles_list_of_lists {
        
        set role_name [lindex $role_list 0]
        set role      [lindex $role_list 1]
        
        append html "
        <td align=\"left\" valign=\"top\"><p /><B><I>Assignee: $role_name</I></B><p />"
        
        foreach assignee_list $assignee_list_of_lists {
            set name [lindex $assignee_list 0]
            set person_id [lindex $assignee_list 1]
            
            if {[exists_and_not_null assigned($process_task_id_tmp-$person_id-$role)]} {
                set checked "checked"
            } else {
                set checked ""
            }
            
            append html "
            <input name=\"assignee\" value=\"$process_task_id_tmp-$person_id-$role\" type=\"checkbox\" $checked />$name
            <br />
        "
            
        }
        
        append html "</td>"

    }

    append html "</table>"

    template::multirow append num $process_task_id_tmp $one_line_v($i) $description_v($i) $estimated_hours_work_v($i) $estimated_hours_work_min_v($i) $estimated_hours_work_max_v($i) $estimated_days_work_v($i) $estimated_days_work_min_v($i) $estimated_days_work_max_v($i) $ordering_v($i) $checked_v($i) $html

}


