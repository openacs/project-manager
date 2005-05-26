#

ad_page_contract {
    
    Processes the add or edit
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-13
    @arch-tag: 8de16306-6d59-419a-a0ef-dae06dc5e69e
    @cvs-id $Id$
} {
    {project_item_id:array ""}
    {process_id:integer ""}
    {process_name ""}
    {task_item_id:array ""}
    {number:integer,multiple ""}
    {comments:html,array ""}
    {comments_mime_type:array ""}
    {task_title:array ""}
    {description:html,array ""}
    {description_mime_type:array ""}
    {estimated_hours_work:array ""}
    {estimated_hours_work_min:array ""}
    {estimated_hours_work_max:array ""}
    {estimated_days_work:array ""}
    {estimated_days_work_min:array ""}
    {estimated_days_work_max:array ""}
    {process_task_id:integer,multiple ""}
    {percent_complete:array ""}
    {dependency:array ""}
    {assignee:multiple ""}
    {use_dependency:array ""}
    {edit_p "f"}
    {using_process_p "f"}
    {end_date_month:multiple ""}
    {end_date_day:multiple ""}
    {end_date_year:multiple ""}
    return_url:optional
    {send_email_p "t"}
    {hours:array ""}
    {log_month:multiple ""}
    {log_day:multiple ""}
    {log_year:multiple ""}
    {log_date:multiple ""}
    {log:array ""}
    {logger_variable:array ""}
    {date:multiple ""}
    {priority:array ""}
} -properties {
} -validate {
} -errors {
}

# --------------------------------------------------------------- 
# Set up
# --------------------------------------------------------------- 
set user_id       [ad_maybe_redirect_for_registration]
set package_id    [ad_conn package_id]
set peeraddr      [ad_conn peeraddr]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

set hours_day [pm::util::hours_day]
set use_days_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]

foreach i $number {

    set date_$i [split [lindex $date [expr $i-1]] "-"]
    set end_date_${i}(day)    [lindex [set date_$i] 2]
    set end_date_${i}(month)  [lindex [set date_$i] 1]
    set end_date_${i}(year)   [lindex [set date_$i] 0]
    set end_date_${i}(format) ""

    ad_page_contract_filter_proc_date end_date_$i end_date_$i


    set log_date_$i [split [lindex $log_date [expr $i-1]] "-"]
    
    set log_date_${i}_day    [lindex [set log_date_$i] 2]
    set log_date_${i}_month  [lindex [set log_date_$i] 1]
    set log_date_${i}_year   [lindex [set log_date_$i] 0]
    set log_date_${i}_format ""


    ad_page_contract_filter_proc_date log_date_$i log_date_$i

    if {[string is true $use_days_p]} {

        # set the hours work
        if {[string is true $use_uncertain_completion_times_p]} {

            set estimated_hours_work_min($i) \
                [expr $estimated_days_work_min($i) * $hours_day]
            set estimated_hours_work_max($i) \
                [expr $estimated_days_work_max($i) * $hours_day]

        } else {

            set estimated_hours_work($i) \
                [expr $estimated_days_work($i) * $hours_day]

        }
    }
}



if {[string is true $edit_p]} {

    # -------
    # EDITING
    # -------


        # -----------------------------------------------------
        # find out information about the task before we edit it
        # -----------------------------------------------------

    set tasks_item_id [list]
    foreach num $number {
        lappend tasks_item_id $task_item_id($num)
    }

    foreach task $tasks_item_id {
        pm::task::clear_client_properties \
            -task_item_id $task
    }

    pm::task::get \
        -tasks_item_id                  $tasks_item_id \
        -one_line_array                  old_one_line \
        -description_array               old_description \
        -description_mime_type_array     old_description_mime_type \
        -estimated_hours_work_array      old_estimated_hours_work \
        -estimated_hours_work_min_array  old_estimated_hours_work_min \
        -estimated_hours_work_max_array  old_estimated_hours_work_max \
        -dependency_array                old_dependency \
        -percent_complete_array          old_percent_complete \
        -end_date_day_array              old_end_date_day \
        -end_date_month_array            old_end_date_month \
        -end_date_year_array             old_end_date_year \
        -project_item_id_array           old_project_item_id \
        -priority_array                  old_priority \
        -set_client_properties_p         t
    foreach num $number {

        # --------------------------
        # figure out estimated hours
        # --------------------------

        if {[string is true $use_uncertain_completion_times_p]} {
            set estimated_hours_work($num) \
                [expr .5 * \
                     ($estimated_hours_work_max($num) - \
                          $estimated_hours_work_min($num)) + \
                     $estimated_hours_work_min($num)]
        } else {
            set estimated_hours_work_min($num) $estimated_hours_work($num)
            set estimated_hours_work_max($num) $estimated_hours_work($num)
        }

        # -------------------------------------
        # Log hours and other variables to task
        # -------------------------------------

        set logger_project [pm::project::get_logger_project \
                                -project_item_id $project_item_id($num)]

       
        if {[exists_and_not_null hours($num)]} {

            pm::project::log_hours \
                -logger_project_id $logger_project \
                -variable_id $logger_variable($num) \
                -value $hours($num) \
                -description $log($num) \
                -task_item_id $task_item_id($num) \
                -project_item_id $project_item_id($num) \
                -update_status_p f \
                -party_id $user_id \
                -timestamp_ansi [set log_date_${num}]
        }

        # ---------
        # edit task
        # ---------

        permission::require_permission -party_id $user_id -object_id $task_item_id($num) -privilege write


        set dead_line "[set end_date_${num}(year)]-[set end_date_${num}(month)]-[set end_date_${num}(day)]"
        set task_revision \
            [pm::task::edit \
                 -task_item_id             $task_item_id($num) \
                 -project_item_id          $project_item_id($num) \
                 -title                    $task_title($num) \
                 -description              $description($num) \
                 -mime_type                $description_mime_type($num) \
                 -end_date                 [set end_date_${num}(date)] \
                 -percent_complete         $percent_complete($num) \
                 -estimated_hours_work     $estimated_hours_work($num) \
                 -estimated_hours_work_min $estimated_hours_work_min($num) \
                 -estimated_hours_work_max $estimated_hours_work_max($num) \
                 -update_user              $user_id \
                 -update_ip                $peeraddr \
                 -package_id               $package_id \
		 -priority                 $priority($num)
                ]

        # --------------------------
        # remove all old assignments
        # --------------------------
        pm::task::assign_remove_everyone \
            -task_item_id $task_item_id($num)

        # -----------------------
        # remove all dependencies
        # -----------------------
        pm::task::dependency_delete_all \
            -task_item_id $task_item_id($num)

    }

    # -----------------------
    # add back in assignments
    # -----------------------

    foreach ass $assignee {
        regexp {(\d+)-(\d+)-(\d+)} $ass match num person role

        set task $task_item_id($num)

        pm::task::assign \
            -task_item_id $task \
            -party_id     $person \
            -role_id      $role
    }

    # -----------------------
    # add in the dependencies
    # -----------------------
    foreach num $number {
        if {[exists_and_not_null dependency($num)]} {
            pm::task::dependency_add \
                -task_item_id $task_item_id($num) \
                -parent_id $dependency($num) \
                -dependency_type finish_before_start \
                -project_item_id $project_item_id($num)
        }
    }

} else {

    # -----------------------------------
    # USING PROCESS OR CREATING NEW TASKS
    # -----------------------------------

    if {[string is true $using_process_p]} {

        set process_instance_id [pm::process::instantiate \
                                     -process_id $process_id \
                                     -project_item_id $project_item_id([lindex $number 0]) \
                                     -name $process_name]
    } else {
        set process_instance_id ""
    }

    foreach num $number {

        # --------------------------
        # figure out estimated hours
        # --------------------------

        if {[string is true $use_uncertain_completion_times_p]} {
            set estimated_hours_work($num) \
                [expr .5 * \
                     ($estimated_hours_work_max($num) - \
                          $estimated_hours_work_min($num)) + \
                     $estimated_hours_work_min($num)]
        } else {
            set estimated_hours_work_min($num) $estimated_hours_work($num)
            set estimated_hours_work_max($num) $estimated_hours_work($num)
        }

        # -----------
        # create task
        # -----------

        permission::require_permission -party_id $user_id -object_id $project_item_id($num) -privilege create

        set task_item \
            [pm::task::new \
                 -project_id               $project_item_id($num) \
                 -title                    $task_title($num) \
                 -description              $description($num) \
                 -mime_type                $description_mime_type($num) \
                 -end_date                 [set end_date_${num}(date)]\
                 -percent_complete         $percent_complete($num) \
                 -estimated_hours_work     $estimated_hours_work($num) \
                 -estimated_hours_work_min $estimated_hours_work_min($num) \
                 -estimated_hours_work_max $estimated_hours_work_max($num) \
                 -process_instance_id      $process_instance_id \
                 -creation_user            $user_id \
                 -creation_ip              $peeraddr \
                 -package_id               $package_id \
		 -priority                 $priority($num)
                ]

        set task_item_id($num) $task_item
    }

    # ----------------
    # add in assignees
    # ----------------

    foreach ass $assignee {
        regexp {(\d+)-(\d+)-(\d+)} $ass match num person role

        set task $task_item_id($num)

        pm::task::assign \
            -task_item_id $task \
            -party_id     $person \
            -role_id      $role
    }

    # -------------------
    # add in dependencies
    # -------------------
    foreach num $number {

        # if there is a numXX as the dependency, then we are relying
        # on new tasks that had not been created yet. So we match them
        # up with the new tasks we've just created.
        if {[regexp {num(.*)} $dependency($num) match parent]} {
            set dependency($num) $task_item_id($parent)
        }

        if {[exists_and_not_null dependency($num)]} {

            pm::task::dependency_add \
                -task_item_id    $task_item_id($num) \
                -parent_id       $dependency($num) \
                -dependency_type  finish_before_start \
                -project_item_id $project_item_id($num)
        }
    }

}

# --------------------------------------------------------------------
# Internet Explorer sucks. It really really does. Due to length limits
# on URLs for IE, we have to pass these variables through
# ad_set_client_property.
# --------------------------------------------------------------------

foreach num $number {
    ad_set_client_property -persistent f -- \
        project-manager \
        project_item_id($num) \
        $project_item_id($num)

    ad_set_client_property -persistent f -- \
        project-manager \
        task_item_id($num) \
        $task_item_id($num)
    
}

# We're done!

ad_returnredirect \
    [export_vars -base task-add-edit-3 \
         { \
               number:multiple \
               using_process_p \
               process_instance_id \
               edit_p \
               comments:array \
               comments_mime_type:array \
               send_email_p \
               return_url}]

