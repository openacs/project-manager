# 

ad_library {
    
    Procs for processes.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-24
    @arch-tag: 29bef794-0109-464c-a5f9-99981628e379
    @cvs-id $Id$
}

namespace eval pm::process {}

ad_proc -public pm::process::delete {
    {-process_id:required}
} {
    Deletes a process and all process tasks
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-25
    
    @param process_id

    @return 
    
    @error 
} {

    db_dml delete_process { }
    
}


ad_proc -public pm::process::remove_assignees {
    {-process_task_id:required}
} {
    Removes all assignees from a process task. If process_task_id
    is a list, then removes from all of those task_ids
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-24
    
    @param process_task_id

    @return 
    
    @error 
} {

    if {[llength $process_task_id] > 1} {
        db_dml delete_assignments {}
    } else {
        db_dml delete_assignment {}
    }

    return
}


ad_proc -public pm::process::assign {
    {-process_task_id:required}
    {-party_id:required}
    {-role_id:required}
} {
    Assigns party_id to process_task_id under the role_id role
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-24
    
    @param process_task_id

    @param party_id

    @param role_id

    @return 
    
    @error 
} {

    db_dml add_assignment {}

    return
}


ad_proc -public pm::process::remove_dependency {
    {-process_task_id:required}
} {
    Removes all dependencies from a given task. If process_task_id
    is a list of tasks, then deletes all dependencies from all the tasks.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-24
    
    @param process_task_id

    @return 
    
    @error 
} {

    if {[llength $process_task_id] > 1} {
        db_dml delete_dependencies {}
    } else {
        db_dml delete_dependency {}    
    }

    return
}


ad_proc -public pm::process::add_dependency {
    {-process_task_id:required}
    {-parent_task_id:required}
    {-dependency_type_id:required}
} {
    Adds a dependency on parent_task_id for process_task_id
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-24
    
    @param process_task_id

    @param parent_task_id

    @param dependency_type_id

    @return 
    
    @error 
} {
    set dependency_id [db_nextval pm_task_dependency_seq]

    db_dml add_dependency {}

    return
}


ad_proc -public pm::process::get {
    {-process_id:required}
    {-process_task_id ""}
    {-one_line_array:required}
    {-description_array:required}
    {-description_mime_type_array:required}
    {-estimated_hours_work_array:required}
    {-estimated_hours_work_min_array:required}
    {-estimated_hours_work_max_array:required}
    {-dependency_array:required}
    {-tasks_list:required}
} {
    Sets a bunch of information in a set of arrays on all
    process tasks for a given process
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-23
    
    @param process_id

    @param one_line_array

    @param description_array

    @param estimated_hours_work_array

    @param estimated_hours_work_min_array

    @param estimated_hours_work_max_array

    @param dependency_array

    @param tasks_list

    @return 
    
    @error 
} {

    # set variables in calling environment, using names passed in
    upvar 1 $one_line_array                 one_line_arr
    upvar 1 $description_array              description_arr
    upvar 1 $description_mime_type_array    description_mime_type_arr
    upvar 1 $estimated_hours_work_array     estimated_hours_work_arr
    upvar 1 $estimated_hours_work_min_array estimated_hours_work_min_arr
    upvar 1 $estimated_hours_work_max_array estimated_hours_work_max_arr
    upvar 1 $dependency_array               dependency_arr
    upvar 1 $tasks_list                     process_tasks_l

    if {[exists_and_not_null process_task_id]} {
        set process_task_where_clause " and t.process_task_id in ([join $process_task_id ", "])"
    } else {
        set process_task_where_clause ""
    }

    db_foreach get_process_tasks { } {
        set one_line_arr($process_tid)                 $one_line
        set description_arr($process_tid)              $description
        set description_mime_type_arr($process_tid)    $description_mime_type
        set estimated_hours_work_arr($process_tid)     $estimated_hours_work
        set estimated_hours_work_min_arr($process_tid) $estimated_hours_work_min
        set estimated_hours_work_max_arr($process_tid) $estimated_hours_work_max
        set dependency_arr($process_tid)               $process_parent_task

        # make sure that we don't have empty values for estimated
        # hours work
        if {[empty_string_p $estimated_hours_work_arr($process_tid)]} {
            set estimated_hours_work_arr($process_tid) 0
        }
        if {[empty_string_p $estimated_hours_work_min_arr($process_tid)]} {
            set estimated_hours_work_min_arr($process_tid) 0
        }
        if {[empty_string_p $estimated_hours_work_max_arr($process_tid)]} {
            set estimated_hours_work_max_arr($process_tid) 0
        }


        lappend process_tasks_l $process_tid
    }
    
}


ad_proc -public pm::process::select_html {
} {
    Returns the option part of the 
    HTML for a select list of process options
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-14
    
    @return 
    
    @error 
} {

    set html "<option value=\"\">Select process</option>"

    db_foreach get_processes get_processes {
        append html "<option value=\"$process_id\">$process_name</option>\n"
    }

    return $html
}


ad_proc -public pm::process::task_assignee_role_list {
    {-process_task_id:required}
} {
    Returns a list of lists, with all assignees to a particular 
    process task. {{party_id role_id} {party_id role_id}}
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-15
    
    @param process_task_id

    @return 
    
    @error 
} {

    return [db_list_of_lists get_assignees_roles { }]

}


ad_proc -public pm::process::instantiate {
    {-process_id:required}
    {-project_item_id:required}
    {-name:required}
} {
    Returns a unique process instance id
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-15
    
    @return 
    
    @error 
} {

    set instance_id [db_nextval pm_process_instance_seq]

    db_dml add_instance { }

    return $instance_id
}


ad_proc -public pm::process::instances {
    {-project_item_id:required}
} {
    Returns a list of lists of form
    {{process_instance_id process_instance_name} { } ...}

    of processes in use by tasks in a particular project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-15
    
    @param project_item_id

    @return 
    
    @error 
} {

    return [db_list_of_lists get_process_instance { }]
    
}


ad_proc -public pm::process::instance_options {
    {-project_item_id:required}
    {-process_instance_id ""}
} {
    Returns the options portion of HTML for process instances
    associated with tasks in a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-15
    
    @param project_item_id

    @return 
    
    @error 
} {

    set instances [pm::process::instances -project_item_id $project_item_id]

    set html ""

    foreach inst $instances {
        set instance_id [lindex $inst 0]
        set name        [lindex $inst 1]

        if {[string equal $instance_id $process_instance_id]} {
            set sel "selected=\"selected\""
        } else {
            set sel ""
        }

        append html "<option $sel value=\"$instance_id\">$name (\#$instance_id)</option>"
    }

    return $html
}


ad_proc -public pm::process::url {
    {-process_instance_id:required}
    {-project_item_id:required}
    {-fully_qualified_p "t"}
} {
    Returns the URL for a process instance
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-15
    
    @param process_instance_id

    @return 
    
    @error 
} {

    return [pm::util::url -fully_qualified_p $fully_qualified_p][export_vars -base one {project_item_id {instance_id $process_instance_id}}]

}


ad_proc -public pm::process::email_alert {
    {-process_instance_id:required}
    {-project_item_id:required}
    {-new_p "t"}
} {
    Sends out an email notification when a process is instantiated.
    Gives the status of all tasks created.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-05
    
    @param process_instance_id

    @return 
    
    @error 
} {

    set task_term       \
        [parameter::get -parameter "Taskname" -default "Task"]
    set task_term_lower \
        [parameter::get -parameter "taskname" -default "task"]
    set use_uncertain_completion_times_p \
        [parameter::get -parameter "UseUncertainCompletionTimesP" -default "0"]

    set user_id [ad_conn user_id]

    db_1row get_from_address_and_more { }
    db_1row get_project_info { }

    set process_name [pm::process::name \
                          -process_instance_id $process_instance_id]

    set project_url [pm::project::url -project_item_id $project_item_id]
    set process_url [pm::process::url \
                         -process_instance_id $process_instance_id \
                         -project_item_id $project_item_id]

    if {[string is true $new_p]} {
        set subject_out "New: $process_name"
        set intro_text "$mod_username assigned you to a process."
    } else {
        set subject_out "Status update: $process_name"
        set notif_name [person::name -person_id $user_id]
        set intro_text "$notif_name sent this process status update."
    }
    
    
    set task_info [db_list_of_lists get_task_info { }]

    set task_list [list]
    foreach ti $task_info {
        lappend task_list [lindex $ti 0]
    }

    set assignees [db_list_of_lists get_assignees { }]

    # make a list of those who are assigned in some capacity
    set to_addresses [list]

    foreach ass $assignees {
        set to_address [lindex $ass 0]

        if {[lsearch $to_addresses $to_address] < 0} {
            lappend to_addresses $to_address
        }
    }

    # make the notification for each assignee
    foreach to_address $to_addresses {

        set notification_text "${intro_text}
<h3>Process overview</h3>
<table border=\"0\" bgcolor=\"#ddddff\">
  <tr>
    <td>Project:</td>
    <td><a href=\"${project_url}\">$project_name</a> (\#$project_item_id)</td>
  </tr>
  <tr>
    <td>Overview of process:</td>
    <td><a href=\"${process_url}\">$process_name</a></td>
  </tr>
</table>

<h3>$task_term and current status</h3>
<table border=\"0\" bgcolor=\"\#ddddff\" cellpadding=\"1\" cellspacing=\"1\">
  <th>$task_term name</th>
  <th>Slack time</th>
  <th>Lead</th>
  <th>Latest finish</th>"

        foreach ti $task_info {
            set task_item_id     [lindex $ti 0]
            set subject          [lindex $ti 1]
            set today_j          [lindex $ti 2]
            set earliest_start_j [lindex $ti 3]
            set latest_start_j   [lindex $ti 4]
            set latest_finish    [lindex $ti 5]
            set status_type      [lindex $ti 6]
            
            set slack_time [pm::task::slack_time \
                                -earliest_start_j $earliest_start_j \
                                -today_j $today_j \
                                -latest_start_j $latest_start_j]
            
            set pretty_latest_finish [lc_time_fmt $latest_finish "%x"]
            
            set lead_html ""
            
            # we highlight rows when the user is assigned to this task
            set assignee_involved_p f

            foreach ass $assignees {
                set to_addr    [lindex $ass 0]
                set role       [lindex $ass 1]
                set is_lead_p  [lindex $ass 2]
                set user_name  [lindex $ass 3]
                set my_task_id [lindex $ass 4]
                
                # ignore anything that isn't for this task
                if {[string equal $my_task_id $task_item_id]} {

                    if {[string is true $is_lead_p]} {
                        append lead_html "$user_name<br />"
                    }
                    
                    if {[string equal $to_addr $to_address]} {
                        set assignee_involved_p t
                    }
                }
            }

            if {[string equal $status_type "c"]} {
                append notification_text "<tr bgcolor=\"dddddd\">"
            } elseif {[string is true $assignee_involved_p]} {
                append notification_text "<tr bgcolor=\"ffdddd\">"
            } else {
                append notification_text "<tr>"
            }
            
            append notification_text "
  <td>$subject</td>
  <td>$slack_time</td>
  <td>$lead_html</td>
  <td>$pretty_latest_finish</td>
</tr>"
        }
        
        # build table of current status 
        append notification_text "</table> <p>If the row is in red, you are involved in this task. If it is in grey, then it has already been completed.</p>"
        
        pm::util::email \
            -to_addr $to_address \
            -from_addr $from_address \
            -subject $subject_out \
            -body $notification_text \
            -mime_type "text/html"
    }
    
}


ad_proc -public pm::process::name {
    {-process_instance_id:required}
} {
    Returns the name when given a process_instance_id
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-20
    
    @param process_instance_id

    @return 
    
    @error 
} {

    db_1row get_name { }

    return $process_name
}


ad_proc -public pm::process::process_name {
    {-process_id:required}
} {
    Returns the name when given a process_id
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-20
    
    @param process_id

    @return 
    
    @error 
} {

    db_1row get_name { }

    return $one_line
}


