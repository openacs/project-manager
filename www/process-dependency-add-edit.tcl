ad_page_contract {
    Form to add task dependencies

    @author jader@bread.com
    @creation-date 2003-08-06
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.
    @return task_term_lower Terminology to use for Task

    @param dependency_id The new ID for dependencies we create
    @param use_dependency The tasks for whom we want to create dependencies
} {
    {use_dependency:array ""}
    {use_dependency_list:multiple ""}
    process_id:integer
    dependency_id:integer,optional
    process_task_id:multiple,optional
    dependency_type:array,optional
    dependency_task_id:array,optional
    {project_item_id:integer ""}
} -properties {
    context_bar:onevalue
    title:onevalue
    task_term_lower:onevalue
}

# ---------------------------------------------------------------

set add_edit_definition ""

# turn the use_dependency

if {[llength [array get use_dependency]] > 0} {
    foreach {index value} [array get use_dependency] {
        lappend use_dependency_list $value
    }
}

# HACK because there isn't a facility for exporting multiple hidden
# form variables in ad_form

set process_task_id_pass $process_task_id
set process_task_id_pass [string map {"-" " "} $process_task_id_pass]
set process_task_id $process_task_id_pass

set use_dependency_list_pass $use_dependency_list
set use_dependency_list_pass [string map {"-" " "} $use_dependency_list_pass]
set use_dependency_list $use_dependency_list_pass

if {![exists_and_not_null use_dependency_list]} {
    pm::process::remove_dependency \
        -process_task_id $process_task_id

    ad_returnredirect "process-one?[export_url_vars process_id]"
    ad_script_abort
}

# terminology

set task_term [_ project-manager.Task]
set task_term_lower [_ project-manager.task]

# the unique identifier for this package

set package_id [ad_conn package_id]
set user_id [ad_maybe_redirect_for_registration]

# permissions

set title "[_ project-manager.lt_Add_task_term_lower_d_1]"
set context_bar [ad_context_bar [list "process-task-add-edit?[export_vars \
-url {{process_id process_task_id:multiple}}]" "#project-manager.Assignments#"] "New $task_term dependency"]

permission::require_permission -party_id $user_id -object_id $package_id -privilege create

set process_task_id_pass [string map {" " "-"} $process_task_id]
set use_dependency_list_pass [string map {" " "-"} $use_dependency_list]

ad_form -name add_edit -form {
    dependency_id:key(pm_process_task_dependency_seq)

    {process_task_id:text(hidden)
	{value $process_task_id_pass}
    }

    {use_dependency_list:text(hidden)
	{value $use_dependency_list_pass}
    }

    {process_id:text(hidden)
	{value $process_id}
    }
} -export {
} -on_submit {

    set user_id [ad_conn user_id]
    set peeraddr [ad_conn peeraddr]
} -new_data {

    # convert from our hack back to a list

    set process_task_id [string map {"-" " "} $process_task_id]

    pm::process::remove_dependency \
        -process_task_id $process_task_id

    # convert from our hack back to a list

    set use_dependency_list [string map {"-" " "} $use_dependency_list]

    foreach tr $use_dependency_list {

        set type_id $dependency_type($tr)
        
        set parent_tsk_id $dependency_task_id($tr)

	set tsk_revision_id $tr
        set tsk_id $tr

	pm::process::add_dependency \
            -process_task_id $tsk_id \
            -parent_task_id  $parent_tsk_id \
            -dependency_type_id $type_id
    }
} -edit_data {

    set process_task_id_pass $process_task_id
    set process_task_id_pass [string map {"-" " "} $process_task_id_pass]
    set process_task_id $process_task_id_pass

    pm::process::remove_dependency -process_task_id $process_task_id

    foreach tr $use_dependency_list {

	set type_id $dependency_type($tr)
        set parent_tsk_id $dependency_task_id($tr)
        set tsk_revision_id $tr
        set tsk_id [db_string get_task_id {}]

	pm::process::add_dependency \
            -process_task_id $tsk_id \
            -parent_task_id $parent_tsk_id \
            -dependency_type_id $type_id
    }
} -after_submit {

    ad_returnredirect -message "[_ project-manager.lt_Process_task_dependen]" [export_vars \
										   -base process-one \
										   -url {process_id}]
    ad_script_abort
}

# get dependency types

#set options {} #db_foreach get_dependency_types {} -column_array
#sdependencies {# lappend options "{\"$dependencies(description)\"
#s$dependencies(short_name)}" #}

# set up list of tasks that this task can be depend on

set dependency_keys {}

db_foreach get_dependency_tasks {} -column_array dependency_tasks {
    
    set dependency_options($dependency_tasks(task_title)) $dependency_tasks(task_id)

    lappend dependency_keys $dependency_tasks(task_title)}

# get the information on tasks from their task_id numbers

db_foreach dependency_query {} -column_array tasks {
    # set up the tasks that can be viewed. Takes out the current task

    set dependency_options_full {}
    foreach key $dependency_keys {
        if {![string equal $key $tasks(task_title)]} {
            lappend dependency_options_full [list $key $dependency_options($key)]
        }
    }

     append add_edit_definition "
        {task_id.$tasks(task_id):text(hidden)
            {value {$tasks(task_id)}}
        }

        {-section sec1 {legendtext {$tasks(task_title)}}}
        {task_title.$tasks(task_id):text(hidden)
            {label \"#project-manager.Subject_2#\"}
            {value {$tasks(task_title)}}
        }

        {description.$tasks(task_id):text(inform)
            {label \"#project-manager.Description_2#\"}
            {value {$tasks(description)}}
        }

        {dependency_type.$tasks(task_id):text(hidden)
            {value {finish_before_start}}
        }

        {dependency_task_id.$tasks(task_id):text(select)
            {label \"#project-manager.Dependency_1#\"}
            {options {$dependency_options_full}}
            {value {$tasks(parent_task_id)}}
            {help_text {$task_term the dependency is based on}}
        }
        "
    }

    ad_form -extend -name add_edit -form $add_edit_definition
