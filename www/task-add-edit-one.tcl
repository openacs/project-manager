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
} {
    task_item_id:integer,optional
    {dform:optional "implicit"}
    {project_item_id:integer ""}
    {process_id:integer ""}
    {process_task_id:integer,multiple ""}
    {return_url ""}
    {assignee:array,multiple,optional}
}


# --------------------------------------------------------------- 
# Set up
# --------------------------------------------------------------- 
set user_id       [ad_maybe_redirect_for_registration]
set package_id    [ad_conn package_id]

# use hour units or day units
set use_day_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
set hours_day     [pm::util::hours_day]
set root_folder_id [content::folder::get_folder_from_package -package_id $package_id]

if {[string is true $use_day_p]} {
    set work_units "[_ project-manager.days]"
} else {
    set work_units "[_ project-manager.hrs]"
}

# --------------------------------------------------------------- 
# terminology
# --------------------------------------------------------------- 
set project_term    [_ project-manager.Project]
set task_term       [_ project-manager.Task]
set task_term_lower [_ project-manager.task]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

# -------------------------
# Set up flags to use later
# -------------------------

if {[exists_and_not_null task_item_id] || ![ad_form_new_p -key task_id]} {
    set edit_p t
    db_1row task_data {}
    set logger_project [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]
    set logger_variable_id [logger::project::get_primary_variable -project_id $logger_project]
    logger::variable::get -variable_id $logger_variable_id -array logger_variable

    set open_p [pm::project::open_p -project_item_id $project_item_id]
    if {[string is false $open_p]} {
        set project_options [list [list [pm::project::name -project_item_id $project_item_id] $project_item_id]]
    } else {
	set project_options [pm::project::get_list_of_open]
    }
    db_1row get_dynamic_form {}
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

if {![string is true $edit_p] &&[empty_string_p $project_item_id]} {
    
    ad_return_error "[_ project-manager.Project_missing]" "[_ project-manager.lt_For_new_tasks_a_proje]"
    ad_script_abort
}

# --------------------------------------------------------------- 
# permissions and title setup, etc
# --------------------------------------------------------------- 

if {[string is true $edit_p]} {

    set title "[_ project-manager.lt_Edit_a_task_term_lowe]"
    set context [list [list $return_url "[_ project-manager.Go_back]"] "[_ project-manager.Edit_task_term]"]

} else {

    set title "[_ project-manager.Add_task_term_lower]"
    set context [list [list [export_vars -base one {project_item_id}] "[pm::project::name -project_item_id $project_item_id]"] "[_ project-manager.New_task_term]"]

    permission::require_permission -party_id $user_id -object_id $project_item_id -privilege create

}

# -------------------------------------------------------------
# Start creating the multirow we'll use to create the interface
# -------------------------------------------------------------

set boolean_options [list [list "[_ project-manager.Yes]" t] [list "[_ project-manager.No]" f]]
set format_options [list [list "[_ project-manager.Enhanced_Text]" "text/enhanced"] [list "[_ project-manager.Plain_Text]" "text/plain"] [list "[_ project-manager.Fixed-width_Text]" "text/fixed-width"] [list "[_ project-manager.HTML]" "text/html"]]
set percent_options [list [list "[_ project-manager.Open]" 0] [list "[_ project-manager.Closed]" 100]]
set dependency_options [pm::task::options_list \
			    -edit_p $edit_p \
			    -project_item_id $project_item_id \
			    -number 1 \
			    -current_number 1]

set send_email_p t

ad_form -name task_add_edit -export {task_item_id} \
    -form {
        task_id:key
        
        {edit_p:text(hidden)}
        {dform:text(hidden)}
        {using_process_p:text(hidden)}
        {return_url:text(hidden),optional}
        {process_task_id:text(hidden),optional}

        {send_email_p:text(select)
            {label "[_ project-manager.lt_Send_email_to_assigne]"}
            {options $boolean_options}
        }
    }
        
if {[string is true $using_process_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {process_name:text,optional
		{label "[_ project-manager.Process_name]"}
		{html {size 25}}
	    }
	}
}
        
ad_form -extend -name task_add_edit \
    -form {
        {task_title:text
            {label "[_ project-manager.Task_name]"}
            {html {size 40}}
        }
        
        {description:text(textarea),optional
            {label "[_ project-manager.Description_1]"}
            {html { rows 14 cols 40 wrap soft}}
	}
        
        {description_mime_type:text(select),optional
            {label "[_ project-manager.Format]"}
            {options $format_options}
        }
    }
        
if {[string is true $edit_p]} {
    if {![empty_string_p [category_tree::get_mapped_trees $root_folder_id]]} {
        ad_form -extend -name task_add_edit -form {
            {category_ids:integer(category),multiple {label "[_ project-manager.Categories]"}
                {html {size 7}} {value {$task_id $root_folder_id}}
            }
        }
    }
} else {
    if {![empty_string_p [category_tree::get_mapped_trees $root_folder_id]]} {
        ad_form -extend -name task_add_edit -form {
            {category_ids:integer(category),multiple,optional {label "[_ project-manager.Categories]"}
                {html {size 7}} {value {{} $root_folder_id}}
            }
        }
    }
}

dtype::form::add_elements -dform $dform -prefix pm -object_type pm_task -object_id [value_if_exists task_id] -form task_add_edit -exclude_static -cr_widget none

if {[string is true $edit_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {comment:text(textarea),optional
		{label "[_ project-manager.Description_1]"}
		{html { rows 7 cols 40 wrap soft}}
		{section "[_ project-manager.Comment]"}
	    }
        
	    {comment_mime_type:text(select),optional
		{label "[_ project-manager.Format]"}
		{options $format_options}
		{section "[_ project-manager.Comment]"}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {comment:text(hidden)
		{value ""}
	    }

	    {comment_mime_type:text(hidden)
		{value "text/plain"}
	    }
	}
}

if {!$use_uncertain_completion_times_p} {
    ad_form -extend -name task_add_edit \
	-form {
	    {estimated_hours_work:text
		{label " "}
		{html {size 5}}
		{after_html $work_units}
		{section "[_ project-manager.Work_required]"}
	    }
	}
} elseif {[string is true $use_day_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {estimated_days_work_min:text
		{label "[_ project-manager.Min]"}
		{html {size 5}}
		{after_html $work_units}
		{section "[_ project-manager.Work_required]"}
	    }
        
	    {estimated_days_work_max:text
		{label "[_ project-manager.Max]"}
		{html {size 5}}
		{after_html $work_units}
		{section "[_ project-manager.Work_required]"}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {estimated_hours_work_min:text
		{label "[_ project-manager.Min]"}
		{html {size 5}}
		{after_html $work_units}
		{section "[_ project-manager.Work_required]"}
	    }
        
	    {estimated_hours_work_max:text
		{label "[_ project-manager.Max]"}
		{html {size 5}}
		{after_html $work_units}
		{section "[_ project-manager.Work_required]"}
	    }
	}
}

ad_form -extend -name task_add_edit \
    -form {
        {task_end_date:text(text),optional
            {label "[_ project-manager.lt_Deadline_task]"}
	    {html {id sel1}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
        }
    }

if {[string is true $edit_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {project_item_id:text(select),optional
		{label $project_term}
		{options $project_options}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {project_item_id:text(hidden)}
	}
}
        
ad_form -extend -name task_add_edit \
    -form {
        {dependency:text(select),optional
            {label "[_ project-manager.Dependency]"}
            {options $dependency_options}
        }
        
        {priority:text,optional
            {label "[_ project-manager.Priority]"}
            {html {size 4}}
	    {help_text "[_ project-manager.lt_Enter_a_number_for_or]"}
        }
    }
        
if {[string is true $edit_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {percent_complete:text,optional
		{label "[_ project-manager.Status]"}
		{html {size 4}}
		{help_text "[_ project-manager.lt_Enter_100_to_close_th_1]"}
	    }

	    {hours:text,optional
		{label $logger_variable(name)}
		{html {size 4}}
		{section "[_ project-manager.Log_entry]"}
		{after_html $logger_variable(unit)}
	    }
        
	    {logger_variable_id:text(hidden)
		{section "[_ project-manager.Log_entry]"}
	    }

	    {log_date:text(text),optional
		{label "[_ project-manager.Date_1]"}
		{html {id sel2}}
		{after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel2', 'y-m-d');\"> \[<b>y-m-d </b>\]
		}}
		{section "[_ project-manager.Log_entry]"}
	    }
        
	    {log:text,optional
		{label "[_ project-manager.Description_1]"}
		{html {size 30}}
		{help_text "[_ project-manager.lt_You_can_optionally_lo]"}
		{section "[_ project-manager.Log_entry]"}
	    }
	}
} elseif {[string is true $using_process_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {percent_complete:text(select),optional
		{label "[_ project-manager.Status]"}
		{options $percent_options}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {percent_complete:text(hidden)}
	}
}

set roles_list [pm::role::select_list_filter]
set assignee_options [pm::util::subsite_assignees_list_of_lists]

# Get assignments for when using processes
if {[string is true $using_process_p]} {
    # PROCESS
    set task_assignee_list [pm::process::task_assignee_role_list -process_task_id $process_task_id]
} elseif {[string is true $edit_p]} {
    # EDITING
    set task_assignee_list [pm::task::assignee_role_list -task_item_id $task_item_id]
} else {
    # NEW
    set task_assignee_list [list]
}

foreach role_list $roles_list {
    set role_name [lindex $role_list 0]
    set role      [lindex $role_list 1]

    set assignees [list]
    foreach one_assignee $assignee_options {
	set name      [lindex $one_assignee 0]
	set person_id [lindex $one_assignee 1]
	
	if {[lsearch $task_assignee_list [list $person_id $role]] >= 0} {
	    lappend assignees $person_id
	}
    }

    ad_form -extend -name task_add_edit \
	-form [list \
		   [list assignee.$role\:text(checkbox),optional,multiple \
			[list label $role_name] \
			[list options $assignee_options] \
			[list section "[_ project-manager.Assignees]"] \
			[list values $assignees] \
		       ] ]
}

ad_form -extend -name task_add_edit -new_request {
    set send_email_p t
    set task_title ""
    set description ""
    set description_mime_type "text/plain"
    set estimated_hours_work 0
    set estimated_hours_work_min 0
    set estimated_hours_work_max 0
    set estimated_days_work_min 0
    set estimated_days_work_max 0
    set percent_complete 0
    set task_end_date [db_string today {}]
    set dependency ""
    set priority 0
} -edit_request {
    db_1row get_task_data {}

    set hours_day [pm::util::hours_day]
    set estimated_days_work_min [expr $estimated_hours_work_min / $hours_day]
    set estimated_days_work_max [expr $estimated_hours_work_max / $hours_day]

    set log_date [db_string today {}]
} -validate {
} -on_submit {
    set hours_day [pm::util::hours_day]
    set status_id [pm::task::default_status_open]

    set end_date_split [split $task_end_date "-"]
    set end_date(day)    [lindex [set end_date_split] 2]
    set end_date(month)  [lindex [set end_date_split] 1]
    set end_date(year)   [lindex [set end_date_split] 0]
    set end_date(format) ""
    ad_page_contract_filter_proc_date end_date end_date
    set end_date_sql [pm::util::datenvl -value $end_date(date) -value_if_null "null" -value_if_not_null "to_timestamp('$end_date(date)','YYYY-MM-DD')"]

    if {[info exists log_date]} {
	set log_date_split [split $log_date "-"]
	set log_date_array(day)    [lindex [set log_date_split] 2]
	set log_date_array(month)  [lindex [set log_date_split] 1]
	set log_date_array(year)   [lindex [set log_date_split] 0]
	set log_date_array(format) ""
	ad_page_contract_filter_proc_date log_date_array log_date_array
    }

    if {[string is true $use_day_p]} {
        # set the hours work
        if {[string is true $use_uncertain_completion_times_p]} {
            set estimated_hours_work_min \
                [expr $estimated_days_work_min * $hours_day]
            set estimated_hours_work_max \
                [expr $estimated_days_work_max * $hours_day]
        } else {
            set estimated_hours_work \
                [expr $estimated_days_work * $hours_day]
        }
    }

    if {$estimated_hours_work_min > $estimated_hours_work_max} {
        set temp $estimated_hours_work_max
        set estimated_hours_work_max $estimated_hours_work_min
        set estimated_hours_work_min $temp
    }

    if {[string is true $use_uncertain_completion_times_p]} {
	set estimated_hours_work [expr .5 * ($estimated_hours_work_max - $estimated_hours_work_min) + $estimated_hours_work_min]
    } else {
	set estimated_hours_work_min $estimated_hours_work
	set estimated_hours_work_max $estimated_hours_work
    }

} -new_data {
    db_transaction {

	# -----------------------------------
	# USING PROCESS OR CREATING NEW TASKS
	# -----------------------------------

	if {[string is true $using_process_p]} {
	    set process_instance_id [pm::process::instantiate \
					 -process_id $process_id \
					 -project_item_id $project_item_id \
					 -name $process_name]
	} else {
	    set process_instance_id ""
	}

        # -----------
        # create task
        # -----------

        permission::require_permission -party_id $user_id -object_id $project_item_id -privilege create

	set task_id [dtype::form::process \
			 -dform $dform \
			 -prefix pm \
			 -object_type pm_task \
			 -object_id $task_id \
			 -form task_add_edit \
			 -cr_widget none \
			 -defaults [list title $task_title description $description mime_type $description_mime_type context_id $project_item_id parent_id $project_item_id object_type pm_task] \
			 -default_fields {percent_complete {end_date $end_date_sql} estimated_hours_work estimated_hours_work_min estimated_hours_work_max priority dform} \
			 -exclude_static]

	set task_item_id [db_string get_item_id {}]

	db_dml new_task {}

	if {$percent_complete >= 100} {
	    pm::task::close -task_item_id $task_item_id
	}

	# ----------------
	# add in assignees
	# ----------------

	if {[array exists assignee]} {
	    foreach role [array names assignee] {
		foreach person_id $assignee($role) {
		    pm::task::assign \
			-task_item_id $task_item_id \
			-party_id     $person_id \
			-role_id      $role
		}
	    }
	}

	# -------------------
	# add in dependencies
	# -------------------

        # if there is a numXX as the dependency, then we are relying
        # on new tasks that had not been created yet. So we match them
        # up with the new tasks we've just created.
        if {[regexp {num(.*)} $dependency match parent]} {
            set dependency $task_item_id($parent)
        }

        if {[exists_and_not_null dependency]} {
            pm::task::dependency_add \
                -task_item_id    $task_item_id \
                -parent_id       $dependency \
                -dependency_type  finish_before_start \
                -project_item_id $project_item_id
        }

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $task_id $category_ids
	}

	callback pm::task_new -package_id $package_id -task_id $task_item_id
    }
} -edit_data {
    db_transaction {

        pm::task::clear_client_properties \
            -task_item_id $task_item_id

        # -------------------------------------
        # Log hours and other variables to task
        # -------------------------------------

	set logger_project [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]
       
        if {[exists_and_not_null hours]} {

            pm::project::log_hours \
                -logger_project_id $logger_project \
                -variable_id $logger_variable_id \
                -value $hours \
                -description $log \
                -task_item_id $task_item_id \
                -project_item_id $project_item_id \
                -update_status_p f \
                -party_id $user_id \
                -timestamp_ansi $log_date_array(date)
        }

        # ---------
        # edit task
        # ---------

        permission::require_permission -party_id $user_id -object_id $task_item_id -privilege write

	set task_id [dtype::form::process \
			 -dform $dform \
			 -prefix pm \
			 -object_type pm_task \
			 -object_id $task_id \
			 -form task_add_edit \
			 -cr_widget none \
			 -defaults [list title $task_title description $description mime_type $description_mime_type context_id $project_item_id parent_id $project_item_id object_type pm_task] \
			 -default_fields {percent_complete {end_date $end_date_sql} estimated_hours_work estimated_hours_work_min estimated_hours_work_max priority dform} \
			 -exclude_static]

	db_dml update_task {}

	if {$percent_complete >= 100} {
	    pm::task::close -task_item_id $task_item_id
	}

        # --------------------------
        # remove all old assignments
        # --------------------------
        pm::task::assign_remove_everyone \
            -task_item_id $task_item_id

        # -----------------------
        # remove all dependencies
        # -----------------------
        pm::task::dependency_delete_all \
            -task_item_id $task_item_id


	# ----------------
	# add in assignees
	# ----------------

	if {[array exists assignee]} {
	    foreach role [array names assignee] {
		foreach person_id $assignee($role) {
		    pm::task::assign \
			-task_item_id $task_item_id \
			-party_id     $person_id \
			-role_id      $role
		}
	    }
	}

	# -----------------------
	# add in the dependencies
	# -----------------------

        if {[exists_and_not_null dependency]} {
            pm::task::dependency_add \
                -task_item_id $task_item_id \
                -parent_id $dependency \
                -dependency_type finish_before_start \
                -project_item_id $project_item_id
        }

	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $task_id $category_ids
	}

	callback pm::task_edit -package_id $package_id -task_id $task_item_id
    }
} -after_submit {
    set number 1
    set comments(1) $comment
    set comments_mime_type(1) $comment_mime_type

    ad_set_client_property -persistent f -- \
        project-manager \
        project_item_id(1) \
        $project_item_id

    ad_set_client_property -persistent f -- \
        project-manager \
        task_item_id(1) \
        $task_item_id

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

    ad_script_abort
}

ad_return_template
