# --------------------------------------------------------------- 
# Set up
# --------------------------------------------------------------- 
set user_id       [ad_maybe_redirect_for_registration]
set package_id    [ad_conn package_id]

# use hour units or day units
set use_day_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
set hours_day     [pm::util::hours_day]

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]


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

    set open_p [pm::project::open_p -project_item_id $project_item_id]
    if {[string is false $open_p]} {
        set project_options [list [list [pm::project::name -project_item_id $project_item_id] $project_item_id]]
    } else {
	set project_options [pm::project::get_list_of_open -object_package_id $package_id]
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
        
if {[string is true $using_process_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {process_name:text,optional
		{label "[_ project-manager.Process_name]"}
		{html {size 25}}
	    }
	}
}

# Options for the description
        
# Where should we store the attached files in file storage
set desc_options [list editor xinha plugins OacsFs height 350px] 
set folder_id [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type "content_folder"] 0]
if {$folder_id ne ""} {
    lappend desc_options "folder_id"
    lappend desc_options "$folder_id"
}

ad_form -extend -name task_add_edit \
    -form {
        {task_title:text
            {label "[_ project-manager.Task_name]"}
            {html {size 40}}
        }
        
        {description:richtext(richtext),optional
            {label "[_ project-manager.Task_description]"}
	    {options $desc_options}
	    {html {rows 20 cols 80 wrap soft}}
	}
        
    }
        
if {[exists_and_not_null task_id]} {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
	category::ad_form::add_widgets \
	    -container_object_id $package_id \
	    -categorized_object_id $task_id \
	    -form_name task_add_edit
    }

} else {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
	category::ad_form::add_widgets \
	    -container_object_id $package_id \
	    -form_name task_add_edit
    }
}

dtype::form::add_elements -dform $dform -prefix pm -object_type pm_task -object_id [value_if_exists task_id] -form task_add_edit -exclude_static -cr_widget none

if {[string is true $edit_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {-section "sec1" {legendtext "[_ project-manager.Comment]"}}
	    {comment:richtext(richtext),optional
		{label "[_ project-manager.Comment]"}
		{options $desc_options}		
		{html {rows 20 cols 80 wrap soft}}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {comment:text(hidden)}
	}
}

if {!$use_uncertain_completion_times_p} {
    ad_form -extend -name task_add_edit \
	-form {
	    {-section "sec2" {legendtext "[_ project-manager.Work_required]"}}
	    {estimated_hours_work:float
		{label " "}
		{html {size 5}}
		{after_html $work_units}
	    }
	}
} elseif {[string is true $use_day_p]} {
    ad_form -extend -name task_add_edit \
	-form {
	    {-section "sec2" {legendtext "[_ project-manager.Work_required]"}}
	    {estimated_days_work_min:float
		{label "[_ project-manager.Min]"}
		{html {size 5}}
		{after_html $work_units}
	    }
        
	    {estimated_days_work_max:float
		{label "[_ project-manager.Max]"}
		{html {size 5}}
		{after_html $work_units}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {-section "sec2" {legendtext "[_ project-manager.Work_required]"}}
	    {estimated_hours_work_min:float
		{label "[_ project-manager.Min]"}
		{html {size 5}}
		{after_html $work_units}
	    }
        
	    {estimated_hours_work_max:float
		{label "[_ project-manager.Max]"}
		{html {size 5}}
		{after_html $work_units}
	    }
	}
}

ad_form -extend -name task_add_edit \
    -form {
        {task_end_date:text(text),optional
            {label "[_ project-manager.Deadline]"}
	    {html {id sel1}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
        }
    }

#------------------------
# Check if the task will be handled on daily basis or will request hours and minutes
#------------------------

if { $daily_p } {
    ad_form -extend -name task_add_edit \
	-form {
	    {task_end_time:text(hidden)
		{value ""}
	    }
	}
} else {
    ad_form -extend -name task_add_edit \
	-form {
	    {task_end_time:date,optional
		{label "[_ project-manager.Deadline_Time]"}
		{value {[template::util::date::now]}}
		{format {[lc_get formbuilder_time_format]}} 
	    }
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

# Logger information
set logger_project [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]
set logger_variable_id [logger::project::get_primary_variable -project_id $logger_project]
logger::variable::get -variable_id $logger_variable_id -array logger_variable

ad_form -extend -name task_add_edit \
    -form {
	{-section "sec3" {legendtext "[_ project-manager.Log_entry]"}}
	{hours:text,optional
	    {label $logger_variable(name)}
	    {html {size 4}}
	    {after_html $logger_variable(unit)}
	}

	{logger_variable_id:text(hidden)
	}

	{log_date:text(text),optional
	    {label "[_ logger.Date]"}
	    {html {id sel2}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel2', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
	}
        
	{log:text,optional
	    {label "[_ logger.Description]"}
	    {html {size 30}}
	    {help_text "[_ project-manager.lt_You_can_optionally_lo]"}
	}
    }

set roles_list [pm::role::select_list_filter]
set assignee_role_list [pm::project::assignee_role_list -project_item_id $project_item_id]
set project_assignee_role_list $assignee_role_list

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


set assign_group_p [parameter::get -parameter "AssignGroupP" -default 0]

# if the task assignee list is empty, use the assignee_role_list
if {![string eq $task_assignee_list ""]} {
    set assignee_role_list $task_assignee_list
}

foreach one_assignee $assignee_role_list {
    set person_id [lindex $one_assignee 0]

    if { $assign_group_p } {
        # We are going to show all asignees including groups
        if { [catch {set assignee_name [person::name -person_id $person_id] } err] } {
            # person::name give us an error so its probably a group so we get
            # the title
            set assignee_name [group::title -group_id $person_id] 
        }
    } else {
        if { [catch {set assignee_name [person::name -person_id $person_id] } err] } {
            # person::name give us an error so its probably a group, here we don't want
            # to show any group so we just continue the multirow
            continue
        }
    }
    lappend assignee_options [list $assignee_name $person_id]
    lappend assignee_ids $person_id
}

foreach assignee_one $project_assignee_role_list {
    set person_id [lindex $assignee_one 0]
    if {[lsearch $assignee_ids $person_id]<0} {
	lappend assignee_options [list [person::name -person_id $person_id] $person_id]
    }
}

foreach role_list $roles_list {
    set role_name [lindex $role_list 0]
    set role      [lindex $role_list 1]

    set assignees [list]
    foreach one_assignee $assignee_role_list {
	set person_id [lindex $one_assignee 0]
	set person_role [lindex $one_assignee 1]
	if {[lsearch $task_assignee_list [list $person_id $role]] >= 0 || $role == $person_role} {
	    lappend assignees $person_id
	}
    }

    ad_form -extend -name task_add_edit \
	-form [list \
		   [list assignee.$role\:text(checkbox),optional,multiple \
			[list label $role_name] \
			[list options $assignee_options] \
			[list values $assignees] \
		       ] ]
}

ad_form -extend -name task_add_edit -new_request {
    set send_email_p t
    set task_title ""
    set description  [template::util::richtext::create "" "text/html"]
    set comment  [template::util::richtext::create "" "text/html"]
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

    set description [template::util::richtext::create $description_content $description_mime_type]
    set comment [template::util::richtext::create "" ""]

    set task_end_time [template::util::date::from_ansi $task_end_date [lc_get frombuilder_time_format]]
    set task_end_date [lindex $task_end_date 0]

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

    set description_content [template::util::richtext::get_property content $description]
    set description_format [template::util::richtext::get_property format $description]
    set comment_content [template::util::richtext::get_property content $comment]
    set comment_format [template::util::richtext::get_property format $comment]

    set task_end_date_list [split $end_date(date) "-"]
    append task_end_date_list " [lrange $task_end_time 3 5]"
    
    if {$task_end_date_list eq ""} {
	set end_date_sql "NULL"
    } else {
	set end_date(date) $task_end_date_list 
	set end_date_sql [pm::util::datenvl -value $end_date(date) -value_if_null "null" -value_if_not_null "to_timestamp('$end_date(date)','YYYY MM DD HH24 MI SS')"]
    }

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

    if {[string is true $use_uncertain_completion_times_p]} {
	if {$estimated_hours_work_min > $estimated_hours_work_max} {
	    set temp $estimated_hours_work_max
	    set estimated_hours_work_max $estimated_hours_work_min
	    set estimated_hours_work_min $temp
	}
	set estimated_hours_work [expr .5 * ($estimated_hours_work_max - $estimated_hours_work_min) + $estimated_hours_work_min]
    } else {
	set estimated_hours_work_min $estimated_hours_work
	set estimated_hours_work_max $estimated_hours_work
    }

    set category_ids [category::ad_form::get_categories -container_object_id $package_id]

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
			 -defaults [list title $task_title description $description_content mime_type $description_format context_id $project_item_id parent_id $project_item_id object_type pm_task] \
			 -default_fields {percent_complete {end_date $end_date_sql} estimated_hours_work estimated_hours_work_min estimated_hours_work_max priority dform} \
			 -exclude_static]

	set task_item_id [db_string get_item_id {}]

	db_dml new_task {}

	# Store the categories
	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $task_id $category_ids
	}

	if {$percent_complete >= 100} {
	    pm::task::close -task_item_id $task_item_id
	}

	# ----------------
	# add in assignees
	# ----------------

	if {[array exists assignee]} {
	    foreach role [array names assignee] {
		foreach person_id $assignee($role) {
		    # We do not want to update the assignment
		    # This allows the trick that a LEAD assignment will not be 
		    # overwritten by a player / watcher one, as the role is lower
		    pm::task::assign \
			-task_item_id $task_item_id \
			-party_id     $person_id \
			-role_id      $role \
			-no_update
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
			 -defaults [list title $task_title description $description_content mime_type $description_format context_id $project_item_id parent_id $project_item_id object_type pm_task] \
			 -default_fields {percent_complete {end_date $end_date_sql} estimated_hours_work estimated_hours_work_min estimated_hours_work_max priority dform} \
			 -exclude_static]

	db_dml update_task {}
	db_dml update_parent_id {}

	# Store the categories
	if {[exists_and_not_null category_ids]} {
	    category::map_object -object_id $task_id $category_ids
	}

	set actual_hours_worked [pm::task::update_hours -task_item_id $task_item_id]
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

	callback pm::task_edit -package_id $package_id -task_id $task_item_id
    }
} -after_submit {
    set number 1
    set comments(1) $comment_content
    set comments_mime_type(1) $comment_format

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

