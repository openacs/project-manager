ad_page_contract {

    Add/edit form for tasks

    Needs to handle the following cases:
    <ul>
    <li> Adding a new task or tasks</li>
    <li> Editing a task or tasks</li>
    <li> Using a process to add new tasks</li>
    </ul>

    @author jader@bread.com
    @creation-date 2003-07-28
    @cvs-id $Id$

    @return context Context bar
    @return title Page title.

    @param task_item_id list of tasks to edit, if there are any
    @project_item_id The project these tasks are assigned to.
    @param process_id The id for the process used, if any
    @param process_task_id The process task IDs if there is a process used.
    @param return_url 
    @param new_tasks if we are creating new tasks, how many to create
} {
    {task_item_id:integer,multiple ""}
    {project_item_id:integer ""}
    {process_id:integer ""}
    {process_task_id:integer,multiple ""}
    {return_url ""}
    {new_tasks "1"}
} -properties {

} -validate {
} -errors {
}


# --------------------------------------------------------------- 
# Set up
# --------------------------------------------------------------- 
set user_id       [auth::require_login]
set package_id    [ad_conn package_id]

# use hour units or day units
set use_day_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
set hours_day     [pm::util::hours_day]

if {[string is true $use_day_p]} {
    set work_units "days"
} else {
    set work_units "hrs"
}

# --------------------------------------------------------------- 
# terminology
# --------------------------------------------------------------- 
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set task_term       [parameter::get -parameter "TaskName" -default "Task"]
set task_term_lower [parameter::get -parameter "taskname" -default "task"]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

# -------------------------
# Set up flags to use later
# -------------------------

if {[exists_and_not_null task_item_id]} {
    set edit_p t
} else {
    set edit_p f
}

if {[exists_and_not_null process_id]} {
    set using_process_p t
} else {
    set using_process_p f
}

# --------------------------------------------------------------------
# if we are editing tasks, each task has its own project. We also want
# to look up all the old information to store it for later. We use
# this for comparison, to see what has changed.
# --------------------------------------------------------------------

if {[string is true $edit_p]} {

    # get old values
    pm::task::get \
        -tasks_item_id                  $task_item_id \
        -one_line_array                  task_one_line \
        -description_array               task_description \
        -description_mime_type_array     task_description_mime_type \
        -estimated_hours_work_array      task_estimated_hours_work \
        -estimated_hours_work_min_array  task_estimated_hours_work_min \
        -estimated_hours_work_max_array  task_estimated_hours_work_max \
        -dependency_array                task_dependency \
        -percent_complete_array          task_percent_complete \
        -end_date_day_array              task_end_date_day \
        -end_date_month_array            task_end_date_month \
        -end_date_year_array             task_end_date_year \
        -project_item_id_array           task_project_item_id \
        -priority_array                  task_priority

} elseif {[empty_string_p $project_item_id]} {
    
    ad_return_error "Project missing" "For new tasks, a project must be passed in"
    ad_script_abort
}

# --------------------------------------------------------------- 
# permissions and title setup, etc
# --------------------------------------------------------------- 

if {[string is true $edit_p]} { 

    set title "Edit a $task_term_lower"
    set context [list [list $return_url "Go back"] "Edit $task_term"]

    permission::require_permission \
        -party_id $user_id \
        -object_id $package_id \
        -privilege write

} else {

    set title "Add $task_term_lower"
    set context [list [list "one?item_id=$project_item_id" "One $project_term"] "New $task_term"]

    permission::require_permission \
        -party_id $user_id \
        -object_id $package_id \
        -privilege create

}

# -------------------------------------------------------------
# Start creating the multirow we'll use to create the interface
# -------------------------------------------------------------

template::multirow create \
    tasks \
    task_item_id \
    process_task_id \
    one_line \
    description \
    description_mime_type \
    work_hrs \
    work_min_hrs \
    work_max_hrs \
    work_days \
    work_min_days \
    work_max_days \
    percent_complete \
    end_date_html \
    depends \
    assignee_html \
    dependency_html \
    logger_variable_html \
    project_html \
    priority


if {[string is true $edit_p]} {

#    set today_html [pm::task::today_html \
 \#                      -month_target log_month \
   \#                    -day_target   log_day \
     \#                  -year_target  log_year]


    # -------
    # EDITING
    # -------

    set number 1
    set total_number [llength $task_item_id]



    set deps [list]
    foreach task $task_item_id {
        if {[lsearch $deps $task_dependency($task)] == -1 && \
                ![empty_string_p $task_dependency($task)]} {
            lappend deps $task_dependency($task)
        }
    }

    foreach task $task_item_id {

        set this_project $task_project_item_id($task)
        
        set project_options [pm::project::select_list_of_open \
                                 -selected $this_project]

        # find out the default logger variable for this project
        set logger_project [pm::project::get_logger_project \
                                -project_item_id $this_project]
        set logger_variable_id [logger::project::get_primary_variable \
                                    -project_id $logger_project]
	set today_date [db_string today "select to_date(sysdate,'YYYY-MM-DD')  from dual"]
        set today_html$task "<br><input type=\"text\" name=\"log_date\" value=\"$today_date\" id=\"sel2$task\" /> <input type='reset' value=' ... ' onclick=\"return showCalendar('sel2$task', 'y-m-d');\"> <b>y-m-d </b>"

       #set end_date_html [pm::task::date_html \
        \#                       -selected_day $task_end_date_day($task) \
          \#                     -selected_month $task_end_date_month($task) \
            \#                   -selected_year $task_end_date_year($task)] 

    set end_date_html "<br><input type=\"text\" name=\"date\" value=\"$task_end_date_year($task)-$task_end_date_month($task)-$task_end_date_day($task)\" id=sel1$task /> <input type='reset' value=' ... ' onclick=\"return showCalendar('sel1$task', 'y-m-d');\"> <b>y-m-d </b>"

        set assignee_html [pm::task::assignee_html \
                               -task_item_id $task \
                               -number $number]

        set dependency_options_full [pm::task::options_list_html \
                                         -edit_p $edit_p \
                                         -task_item_id $task \
                                         -project_item_id $this_project \
                                         -dependency_task_id $task_dependency($task) \
                                         -dependency_task_ids "$deps" \
                                         -number $total_number \
                                         -current_number $number]

        set variable_widget [logger::ui::variable_select_widget \
                                 -project_id $logger_project \
                                 -current_variable_id $logger_variable_id \
                                 -select_name logger_variable.$number]

        set project_html "$project_term:
                <select name=\"project_item_id.$number\">
                  $project_options
                </select>"

        set task_estimated_days_work($task) \
            [pm::util::days_work \
                 -hours_work $task_estimated_hours_work($task)]

        set task_estimated_days_work_min($task) \
            [pm::util::days_work \
                 -hours_work $task_estimated_hours_work_min($task)]

        set task_estimated_days_work_max($task) \
            [pm::util::days_work \
                 -hours_work $task_estimated_hours_work_max($task)]
        
        
        template::multirow append tasks \
            $task \
            "" \
            $task_one_line($task) \
            $task_description($task) \
            $task_description_mime_type($task) \
            $task_estimated_hours_work($task) \
            $task_estimated_hours_work_min($task) \
            $task_estimated_hours_work_max($task) \
            $task_estimated_days_work($task) \
            $task_estimated_days_work_min($task) \
            $task_estimated_days_work_max($task) \
            $task_percent_complete($task) \
            $end_date_html \
            $task_dependency($task) \
            $assignee_html \
            $dependency_options_full \
            $variable_widget \
            $project_html \
            $task_priority($task)
            
        incr number
    }


} elseif {[string is true $using_process_p]} {

    # -------------
    # USING PROCESS
    # -------------

    set process_name [pm::process::process_name \
                          -process_id $process_id]

    # get all the process task info
    pm::process::get \
        -process_id                      $process_id \
        -process_task_id                 $process_task_id \
        -one_line_array                  process_one_line \
        -description_array               process_description \
        -description_mime_type_array     process_description_mime_type \
        -estimated_hours_work_array      process_estimated_hours_work \
        -estimated_hours_work_min_array  process_estimated_hours_work_min \
        -estimated_hours_work_max_array  process_estimated_hours_work_max \
        -dependency_array                process_dependency \
        -tasks_list                      process_tasks

    # we now have an array (process_dependency) that contains all the
    # templates for where the dependencies should lie. However, the
    # user may not have selected all the process tasks to be
    # created. We also need to keep track of which new task
    # corresponds with which process task, so we can make sure the
    # default process
    set number 1
    foreach pt $process_tasks {
        set task_num($pt) $number
        incr number
    }
    foreach pt $process_tasks {
        if {[exists_and_not_null process_dependency($pt)]} {
            # keep track of which task the new task should by default
            # depend upon
            set task_parent_num($pt) $task_num($process_dependency($pt))
        } else {
            set task_parent_num($pt) ""
        }
    }

    set new_tasks [llength $process_tasks]

#    set end_date_html [pm::task::date_html]


     set end_date_html "<br><input type=\"text\" name=\"date\" value=\"$task_end_date_year($task)-$task_end_date_month($task)-$task_end_date_day($task)\" id=sel1$task_item_id /> <input type='reset' value=' ... ' onclick=\"return showCalendar('sel1$task_item_id', 'y-m-d');\"> <b>y-m-d </b>"
   

    set number 1
    set total_number [llength $process_tasks]

    foreach pt $process_tasks {

        set assignee_html [pm::task::assignee_html \
                               -number $number \
                               -process_task_id $pt]


        set dependency_options_full [pm::task::options_list_html \
                                         -edit_p $edit_p \
                                         -project_item_id $project_item_id \
                                         -depends_on_new $task_parent_num($pt) \
                                         -number $new_tasks \
                                         -current_number $number]

        set project_html "<input type=\"hidden\" name=\"project_item_id.$number\" value=\"$project_item_id\" />"

        set process_estimated_days_work($pt) \
            [pm::util::days_work \
                 -hours_work $process_estimated_hours_work($pt)]

        set process_estimated_days_work_min($pt) \
            [pm::util::days_work \
                 -hours_work $process_estimated_hours_work_min($pt)]

        set process_estimated_days_work_max($pt) \
            [pm::util::days_work \
                 -hours_work $process_estimated_hours_work_max($pt)]


        # make sure deps are working.

        template::multirow append tasks \
            "" \
            $process_task_id \
            $process_one_line($pt) \
            $process_description($pt) \
            $process_description_mime_type($pt) \
            $process_estimated_hours_work($pt) \
            $process_estimated_hours_work_min($pt) \
            $process_estimated_hours_work_max($pt) \
            $process_estimated_days_work($pt) \
            $process_estimated_days_work_min($pt) \
            $process_estimated_days_work_max($pt) \
            "0" \
            $end_date_html \
            $process_dependency($pt) \
            $assignee_html \
            $dependency_options_full \
            "" \
            $project_html

        incr number
    }

} else {

    # ---
    # NEW
    # ---

set today_date [db_string today "select to_date(sysdate,'YYYY-MM-DD') from dual"]
 #  set end_date_html [pm::task::date_html]

    for {set i 1} {$i <= $new_tasks} {incr i} {
    set end_date_html "<br><input type=\"text\" name=\"date\" value=\"$today_date\" id=\"sel1$i\" /> <input type='reset' value=' ... ' onclick=\"return showCalendar('sel1$i', 'y-m-d');\"> <b>y-m-d </b>"

        set assignee_html [pm::task::assignee_html \
                              -number $i]

        set dependency_options_full [pm::task::options_list_html \
                                         -edit_p $edit_p \
                                         -project_item_id $project_item_id \
                                         -number $new_tasks \
                                         -current_number $i]

        set project_html "<input type=\"hidden\" name=\"project_item_id.$i\" value=\"$project_item_id\" />"

        # sorry this isn't internationalized. The choice is to cludge
        # around dates, or to cludge around ad_forms poor support for
        # multiple dates. 

        template::multirow append tasks \
            "" \
            "" \
            "" \
            "" \
            "text/plain" \
            0 \
            0 \
            0 \
            0 \
            0 \
            0 \
            0 \
            $end_date_html \
            "" \
            $assignee_html \
            $dependency_options_full \
            "" \
            $project_html \
	    0

    }
}



set export_vars [export_vars -form {edit_p using_process_p return_url}]
