ad_library {

    Project Manager Projects Library
    
    Procedures that deal with tasks

    @creation-date 2003-12-18
    @author Jade Rubick <jader@bread.com>
    @cvs-id $Id$

}

namespace eval pm::task {}


ad_proc -public pm::task::name {
    {-task_item_id:required}
} {
    Returns the name of the task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-25
    
    @param task_item_id

    @return 
    
    @error -1
} {
    return [db_string get_name { } -default "-1"]
}


ad_proc -public pm::task::options_list {
    {-edit_p "f"}
    -project_item_id
    {-task_item_id ""}
    {-dependency_task_ids ""}
    {-number "0"}
    {-current_number "0"}
} {
    Returns a list of lists suitable for use in a select list for 
    ad_form. Contains a list of possible tasks that this task can
    depend upon, or selected. These tasks are limited to just the
    one project.

    <p />

    There is one special case that we handle: if you are creating new
    tasks (not editing), you can have them depend on each other. 
    So if you create two tasks at the same time, you may want task 
    2 to depend on task 1. Instead of a task_item_id, we then 
    specify a value of this form:

    <blockquote>
    numX
    </blockquote>
    
    where X represents the number of the new task, ranging from 1
    to n.

    <p />

    To be more efficient when creating multiple tasks at the same 
    time, we should cache the database calls.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-13
    
    @param edit_p Is this for a task being edited? Or a new task?

    @param project_item_id The project we're finding tasks from

    @param task_item_id The task ID. This is used because we do not 
    want a task to depend on itself, so it is excluded from the list.

    @param dependency_task_ids For edited tasks, the current task_ids
    that it depends on. Used because sometimes it can be closed, and
    it wouldn't otherwise appear on the list. This is a list.

    @param number When the list is returned, it includes entries for 
    number new tasks, in the numX format described in these docs.

    @param current_number The current number. Used for new tasks. It
    prevents allowing dependencies on the task being created.

    @return 
    
    @error 
} {

    # get tasks this task can depend on 

    if {[exists_and_not_null dependency_task_ids]} {
        
        set union_clause "
     UNION
      SELECT
        r.item_id, 
        r.title as task_title        
        FROM
        pm_tasks_revisionsx r, 
        cr_items i,
        pm_tasks_active t
        WHERE
        r.parent_id = :project_item_id and
        r.revision_id = i.live_revision and
        i.item_id = t.task_id
        and t.task_id in ([join $dependency_task_ids ","])"
    } else {
        set union_clause ""
    }

    set keys [list]

    db_foreach get_dependency_tasks { } {
        set options($task_title) $item_id
        lappend keys $task_title
    } 

    set keys [lsort $keys]


    set dependency_options_full "{\"--None--\" \"\"} "

    if {[string is true $edit_p]} {
        # Do nothing
    } else {

        # now set up dependency options

        for {set j 1} {$j <= $number} {incr j} {
            if {![string equal $current_number $j]} {
                append dependency_options_full "{\"New Task \#$j\" \"num$j\"} "
            }
        }
    }

    # for editing tasks, we skip ourselves (because depending on
    # ourselves just sometimes isn't an option)

    if {[string is true $edit_p]} {
        foreach key $keys {

            # make sure we're not dependent on ourselves

            if {![string equal $task_item_id $options($key)]} {
                # check for case when there is a quote in the name of
                # a task. We have to filter this out, or we get an error.
                append dependency_options_full "{{$key} $options($key)} "
            }
        }
    } else {
        foreach key $keys {

            # check for case when there is a quote in the name of
            # a task. We have to filter this out, or we get an error.
            append dependency_options_full "{{$key} $options($key)} "
        }
    }


    return $dependency_options_full
}


ad_proc -public pm::task::options_list_html {
    {-edit_p "f"}
    -project_item_id
    {-task_item_id ""}
    {-dependency_task_id ""}
    {-dependency_task_ids ""}
    {-number "0"}
    {-depends_on_new ""}
    {-current_number "0"}
} {
    Returns a list of options suiteable for HTML.
    Contains a list of possible tasks that this task can
    depend upon, or selected. These tasks are limited to just the
    one project.

    <p />

    There is one special case that we handle: if you are creating new
    tasks (not editing), you can have them depend on each other. 
    So if you create two tasks at the same time, you may want task 
    2 to depend on task 1. Instead of a task_item_id, we then 
    specify a value of this form:

    <blockquote>
    numX
    </blockquote>
    
    where X represents the number of the new task, ranging from 1
    to n.

    <p />

    To be more efficient when creating multiple tasks at the same 
    time, we should cache the database calls.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-13
    
    @param edit_p Is this for a task being edited? Or a new task?

    @param project_item_id The project we're finding tasks from

    @param task_item_id The task ID. This is used because we do not 
    want a task to depend on itself, so it is excluded from the list.

    @param dependency_task_ids For edited tasks, the current task_ids
    that it depends on. Used because sometimes it can be closed, and
    it wouldn't otherwise appear on the list. This is a list.

    @param dependency_task_id For edited tasks, the current task that
    it depends on, used for setting the default option in HTML.

    @param number When the list is returned, it includes entries for 
    number new tasks, in the numX format described in these docs.

    @param depends_on_new When you're using a process, you want the 
    dependency to be on other new tasks. The format for this should
    be num1 num2, etc.. So we make the default if this parameter is set.

    @param current_number The current number. Used for new tasks. It
    prevents allowing dependencies on the task being created.

    @return 
    
    @error 
} {

    # get tasks this task can depend on 

    if {[exists_and_not_null dependency_task_ids]} {
       
        set union_clause "
     UNION
      SELECT
        r.item_id, 
        r.title as task_title        
	FROM
        pm_tasks_revisionsx r, 
        cr_items i,
        pm_tasks_active t
        WHERE
        r.parent_id = :project_item_id and
        r.revision_id = i.live_revision and
        i.item_id = t.task_id
        and t.task_id in ([join $dependency_task_ids ","])"
    } else {
        set union_clause ""
    }

    set keys [list]

    db_foreach get_dependency_tasks { } {
        set options($task_title) $item_id
        lappend keys $task_title
    } 

    set keys [lsort $keys]

    # ---------------------------------------------------------------
    # Start setting up the output.
    # These are for new tasks, the already created tasks are added to
    # the list later.
    # ---------------------------------------------------------------

    set dependency_options_full "<option value=\"\">--None--</option> "

    if {[string is false $edit_p]} {

        # now set up dependency options

        for {set j 1} {$j <= $number} {incr j} {

            if {[string equal $depends_on_new $j]} {
                set selected "selected=\"selected\" "
            } else {
                set selected ""
            }

            if {![string equal $current_number $j]} {
                append dependency_options_full "<option ${selected}value=\"num$j\">New Task \#$j</option> "
            }
        }
    }

    # -------------------------------------------------
    # Now add the tasks that are already in the project
    # -------------------------------------------------


    if {[string is true $edit_p]} {
        foreach key $keys {

            # for editing tasks, we skip ourselves (because depending on
            # ourselves just sometimes isn't an option)
            if {![string equal $task_item_id $options($key)]} {

                if {[string equal $options($key) $dependency_task_id]} {
                    set selected "selected=\"selected\" "
                } else {
                    set selected ""
                }

                # check for case when there is a quote in the name of
                # a task. We have to filter this out, or we get an
                # error. -- not sure what this comment is for -- JR
                

                append dependency_options_full "<option ${selected}value=\"$options($key)\">$key</option> "
            }
        }
    } else {

        foreach key $keys {
            
            # check for case when there is a quote in the name of a
            # task. We have to filter this out, or we get an error. --
            # not sure what this comment is for -- JR

            append dependency_options_full "<option value=\"$options($key)\">$key</option> "
        }
    }


    return $dependency_options_full
}


ad_proc -public pm::task::dependency_delete_all {
    -task_item_id:required

} {
    Deletes all the dependencies of a task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-23
    
    @param task_item_id The task we wish to remove the dependencies from.

    @return 
    
    @error 
} {
    db_dml delete_deps { }

    return 1
}


ad_proc -public pm::task::dependency_add {
    -task_item_id:required
    -parent_id:required
    -dependency_type:required
    -project_item_id:required
} {

    Adds a dependency to a task, checking for loops in the process

    <p />

    We make the assumption that the following is true: 

    <ul>
    <li>no loop is created if you depend on a task already present</li>
    <li>therefore, if you add a task without creating a loop in the 
    newly created tasks, you are safe.</li>
    </ul>

    We check that the new items don't depend on each other by
    following them if they loop more than the number of tasks in the
    project, then we have a loop

    <p />
    The way we check for a loop is to follow the dependencies
    until we get to a task that has already been created.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-23
    
    @param task_item_id The task that is trying to create a 
    dependency. Of course this means that the task has already been
    created. 

    @param parent_id The task that we would like to create a 
    dependency on. (item_id for task, of course)

    @param dependency_type Type of dependency, from pm_dependency_types

    @param project_item_id The project's item_id. All dependencies are
    created within this project

    @return 
    
    @error 
} {

    set project_tasks [db_list get_tasks { }]

    # we do not allow tasks to depend on items outside of their
    # project. So if it's not in the list of tasks for that project,
    # we reject it

    if {[lsearch $project_tasks $parent_id] < 0} {
        set loop_limit 0
        set valid_p FALSE
    } else {
        set loop_limit [llength $project_tasks]
    }

    if {$loop_limit > 0} {

        set dep_list [list]
        db_foreach get_dependencies { } {
            lappend dep_list d-$dep_task-$dep_task_parent
        }

        # are there any loops?
        lappend dep_list d-$task_item_id-$parent_id

        foreach ti $project_tasks {
            set task_state($ti) 0
        }
        nsv_array set task_node_status [array get task_state]


        set valid_p [pm::task::verify_no_loops \
                         -current_task $task_item_id \
                         -dependency_list $dep_list]

    }

    if {[string is true $valid_p]} {
        # after it passes
        set dependency_id [db_nextval pm_task_dependency_seq]
        
        db_dml insert_dep { }
        
    } else {
        ns_log Notice "Task dependency for $task_item_id on $parent_id was not added due to looping or being outside of the current project"
    }
    
}


ad_proc -private pm::task::verify_no_loops {
    {-current_task:required}
    {-dependency_list:required}
} {
    Based on the dag_dfs algorithm at http://wiki.tcl.tk/3716

    <p />

    Determines if adding in the additional dependency would create
    an cyclical graph or not
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-25
    
    @param project_task_list

    @param current_task 

    @param dependency_list a list of dependencies, each of the form
    d-n1-n2 where n1 is the child and n2 is the parent. The initial
    call to this function should include the proposed addition in 
    this list.

    @return TRUE if no loops, FALSE if the proposed additon would add loops 
    
    @error 
} {

    set return_val ""

    array set task_state [nsv_array get task_node_status]

    set task_state($current_task) 1

    nsv_array set task_node_status [array get task_state]

    foreach arc $dependency_list {
        regexp {d-(.*)-(.*)} $arc match child parent

        # only walk to dependencies from the current task
        if {[string equal $child $current_task]} {

            set tNode $parent

            array set task_state [nsv_array get task_node_status]

            # this should only happen if dependencies span projects
            # they shouldn't, but I check anyway.
            if {![info exists task_state($tNode)]} {
                set used 0
            } else {
                set used $task_state($tNode)
            }

            if {[string equal $used 1]} {
                return FALSE
            }

            set return_val [pm::task::verify_no_loops \
                                -current_task $parent \
                                -dependency_list $dependency_list
                            ]

            if {[string equal $return_val FALSE]} {
                return FALSE
            }
        }

    }

    array set task_state [nsv_array get task_node_status]

    set task_state($current_task) 2

    nsv_array set task_node_status [array get task_state]

    return TRUE
}



ad_proc -public pm::task::get_item_id {
    -task_id:required
} {
    Returns the task_item_id (item_id) when given the task_id (revision_id)
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-19
    
    @param task_id The revision item

    @return task_item_id
    
    @error Returns -1 if there is no such task
} {
    set return_val [db_string get_item_id { } -default "-1"]

    return $return_val
}



ad_proc -public pm::task::get_revision_id {
    -task_item_id:required
} {
    Returns task_id (revision_id) when given the task_item_id (item_id)
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-19
    
    @param task_item_id The revision item

    @return task_item_id
    
    @error If there is no such task item, then returns -1
} {
    set return_val [db_string get_revision_id { } -default "-1"]

    return $return_val
}



ad_proc -public pm::task::current_status {
    -task_item_id:required
} {
    Returns the current status value for open tasks
} {
    set return_val [db_string get_current_status { }]

    return $return_val
}


ad_proc -public pm::task::open_p {
    -task_item_id:required
} {
    Returns 1 if the task is open, 0 otherwise
} {
    set return_val [db_string open_p { }]

    return $return_val
}


ad_proc -public pm::task::default_status_open {} {
    Returns the default status value for open tasks
} {
    set return_val [db_string get_default_status_open { }]

    return $return_val
}


ad_proc -public pm::task::default_status_closed {} {
    Returns the default status value for closed tasks
} {
    set return_val [db_string get_default_status_closed { }]

    return $return_val
}



ad_proc -public pm::task::edit {
    -task_item_id:required
    -project_item_id:required
    -title:required
    -description:required
    {-mime_type "text/plain"}
    {-comment ""}
    {-comment_type "text/plain"}
    -end_date:required
    -percent_complete:required
    -estimated_hours_work:required
    -estimated_hours_work_min:required
    -estimated_hours_work_max:required
    {-dform "implicit"}
    -update_user:required
    -update_ip:required
    -package_id:required
    {-priority "0"}
    -no_callback:boolean
} {
    
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-23
    
    @param task_item_id

    @param project_item_id

    @param title

    @param description

    @param comment The comment to send out by email if the task
    is closed. Otherwise, it is NOT sent out.

    @param mime_type

    @param end_date

    @param percent_complete

    @param estimated_hours_work

    @param estimated_hours_work_min

    @param estimated_hours_work_max

    @param update_user The user updating the task

    @param update_ip The IP address of the request

    @param package_id

    @return new revision_id for the task
    
    @error 
} {
    # simple sanity check for min and max estimated hours
    if {$estimated_hours_work_min > $estimated_hours_work_max} {
        set temp $estimated_hours_work_max
        set estimated_hours_work_max $estimated_hours_work_min
        set estimated_hours_work_min $temp
    }

    if {$percent_complete >= 100} {
        set status_id [pm::task::default_status_closed]
    } elseif {$percent_complete < 100} {
        set status_id [pm::task::default_status_open]
    }

    set actual_hours_worked [pm::task::update_hours -task_item_id $task_item_id]

    set return_val [db_exec_plsql new_task_revision { *SQL }]

    if {!$no_callback_p} {
	callback pm::task_edit -package_id $package_id -task_id $task_item_id
    }

    return $return_val
}



ad_proc -public pm::task::new {
    -project_id:required
    {-task_id ""}
    {-title "Subject missing"}
    {-description ""}
    {-mime_type "text/plain"}
    {-end_date ""}
    {-percent_complete "0"}
    {-estimated_hours_work "0"}
    {-estimated_hours_work_min "0"}
    {-estimated_hours_work_max "0"}
    {-creation_date ""}
    {-status_id ""}
    {-process_instance_id ""}
    {-dform "implicit"}
    -creation_user:required
    -creation_ip:required
    -package_id:required
    {-priority "0"}
    -no_callback:boolean
} {
    Creates a new task. 

    @param process_instance_id If a process was used to create the
    task, then it is linked in to that process instance, so we can
    things like display only tasks that are a part of a process.

    @author Jade Rubick (jader@bread.com)
    @creation-date who knows?

    @return new task_item_id
    
    @error

} {
    if {[empty_string_p $task_id]} {
	set task_id [db_nextval acs_object_id_seq]
    }

    if {![exists_and_not_null status_id]} {
        set status_id [pm::task::default_status_open]
    }

    if {$estimated_hours_work_min > $estimated_hours_work_max} {
        set temp $estimated_hours_work_max
        set estimated_hours_work_max $estimated_hours_work_min
        set estimated_hours_work_min $temp
    }

    set task_revision [db_exec_plsql new_task_item { *SQL }]
    set task_item_id  [pm::task::get_item_id \
                           -task_id $task_revision]

    if {$percent_complete >= 100} {
        pm::task::close -task_item_id $task_item_id
    }

    if {!$no_callback_p} {
	callback pm::task_new -package_id $package_id -task_id $task_item_id
    }

    return $task_item_id
}



ad_proc -public pm::task::delete {
    -task_item_id:required
    -no_callback:boolean
} {
    Marks a task deleted
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-10
    
    @param task_item_id

    @return 1, no matter once
    
    @error No error thrown if there is no such task.
} {
    if {!$no_callback_p} {
	callback pm::task_delete -package_id [ad_conn package_id] -task_id $task_item_id
    }

    db_dml mark_delete "update pm_tasks set deleted_p = 't' where task_id = :task_item_id"
    
    if {[parameter::get -parameter UseDayInsteadOfHour -default f]} {
	pm::project::compute_status [pm::task::project_item_id -task_item_id $task_item_id]
    } else {
	pm::project::compute_status_mins [pm::task::project_item_id -task_item_id $task_item_id]
    }

    return 1
}


ad_proc -public pm::task::project_item_id {
    -task_item_id:required
} {
    Returns the project item id for a given task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-16
    
    @param task_item_id

    @return -1 if there is an error.
    
    @error 
} {
    return [db_string get_project_id "select parent_id from cr_items where item_id = :task_item_id" -default -1]
}



ad_proc -public pm::task::get_url {
    object_id
} {
    
    set package_id [db_string pm_package_id "select package_id from cr_folders cf, cr_items ci1, cr_items ci2 where cf.folder_id = ci1.parent_id and ci1.item_id = ci2.parent_id and ci2.item_id = :object_id" -default 0]
    
    if {$package_id == 0} {
        
        set url [site_node_closest_ancestor_package_url -package_key "project-manager"]
    } else {
        set url "[ad_url]"
        append url [site_node::get_url_from_object_id -object_id $package_id]
    }

    set package_url "${url}task-one?task_id=$object_id"

    return $package_url

}



ad_proc -public pm::task::process_reply {
    reply_id
} {
    # return successful_p = "f"
    return "f"
}



ad_proc -public pm::task::slack_time {
    -earliest_start_j:required
    -today_j:required
    -latest_start_j:required
} {
    Return the amount of slack time
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-20
    
    @param earliest_start_j Earliest start date, Julian

    @param today_j today's date, in Julian

    @param latest_start_j Latest start date, in Julian

    @return Slack days
    
    @error 
} {
    if { \
             [exists_and_not_null earliest_start_j] && \
             [exists_and_not_null latest_start_j]} {

        if {$earliest_start_j < $today_j} {
            set slack_time "[expr $latest_start_j - $today_j] [_ project-manager.days]"
        } else {
            set slack_time "[expr $latest_start_j - $earliest_start_j] [_ project-manager.days]"
        }

    } else {
        set slack_time "n/a"
    }

}



ad_proc -private pm::task::update_hours {
    {-task_item_id ""}
    {-task_revision_id ""}
    {-update_tasks_p "t"}
} {
    The pm_tasks_revisions table contains a denormalized cache of the
    total number of hours logged to it. Updates the cache from the 
    hours logged in logger
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-04
    
    @param task_item_id

    @param task_revision_id

    @param update_tasks_p If t, updates the current pm_tasks_revision
    table in the database. 

    @return total logged hours
    
    @error if neither task_item_id or task_revision_id is defined,
    returns -1
} {
    if { \
             ![info exists task_item_id] && \
             ![info exists task_revision_id]} {

        ns_log Error "Illegal parameters in pm::task::update_hours"
        return -1
    }

    if { \
             [exists_and_not_null task_item_id] && \
             ![exists_and_not_null task_revision_id]} {

        set task_revision_id [pm::task::get_revision_id \
                                  -task_item_id $task_item_id]
    }

    if { \
             ![exists_and_not_null task_item_id] && \
             [exists_and_not_null task_revision_id]} {

        set task_item_id [pm::task::get_item_id \
                             -task_id $task_revision_id]
    }

    set variable_id [logger::variable::get_default_variable_id]

    set total_logged_hours [db_string total_hours "
        select sum(le.value)
	from logger_entries le
	where entry_id in (select object_id_two
			   from acs_rels
			   where object_id_one = :task_item_id
			   and rel_type = 'application_data_link')
	and le.variable_id = :variable_id
    " -default "0"]

    if {[string is true $update_tasks_p]} {

        db_dml update_current_task {
        UPDATE
        pm_tasks_revisions
        SET 
        actual_hours_worked = :total_logged_hours
        WHERE 
        task_revision_id = :task_revision_id
        }
    }

    return $total_logged_hours

}


ad_proc -public pm::task::link {
    -task_item_id_1:required
    -task_item_id_2:required
} {
    Links two tasks together
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-10
    
    @param task_item_id_1

    @param task_item_id_2

    @return 
    
    @error 
} {

    if {[string equal $task_item_id_1 $task_item_id_2]} {
        # do nothing
        ns_log Notice "Project-manager: Cannot link a task to itself!"
    } elseif {$task_item_id_1 < $task_item_id_2} {
        db_dml link_tasks "
        INSERT INTO 
        pm_task_xref 
        (task_id_1, task_id_2)
        VALUES
        (:task_item_id_1, :task_item_id_2)"
    } else {
        db_dml link_tasks "
        INSERT INTO 
        pm_task_xref 
        (task_id_1, task_id_2)
        VALUES
        (:task_item_id_2, :task_item_id_1)"
    }
    
}


ad_proc -public pm::task::assign_remove_everyone {
    -task_item_id:required
} {
    Removes all assignments for a task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-09
    
    @param task_item_id

    @return 
    
    @error 
} {
    
    db_dml remove_assignment { }
    
    # Flush the cache that remembers which roles to offer the current user in the 'assign role to myself' listbox
    util_memoize_flush [list pm::role::task_select_list_filter_not_cached -task_item_id $task_item_id -party_id [ad_conn user_id]]
}


ad_proc -public pm::task::unassign {
    -task_item_id:required
    -party_id:required
} {
    Removes an assignment for a task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-11-18
    
    @param task_item_id

    @param party_id

    @return 
    
    @error 
} {
    db_dml remove_assignment { }
    
    # Flush the cache that remembers which roles to offer the current user in the 'assign role to myself' listbox
    if {[ad_conn user_id] == $party_id} {
        util_memoize_flush [list pm::role::task_select_list_filter_not_cached -task_item_id $task_item_id -party_id $party_id]
    }
}


ad_proc -public pm::task::assign {
    -task_item_id:required
    -party_id:required
    {-role_id ""}
} {
    Assigns party_id to task_item_id
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-05
    
    @param task_item_id

    @param party_id

    @param role_id the role under which the person is assigned

    @return
    
    @error 
} {
    if {![exists_and_not_null role_id]} {
        set role_id [pm::role::default]
    }

    db_transaction {
        # make sure we avoid case when that assignment has already
        # been made.
        db_dml delete_assignment {
           delete from
           pm_task_assignment
           where
           task_id  = :task_item_id and
           party_id = :party_id
        }

        db_dml add_assignment {
           insert into pm_task_assignment
           (task_id,
            role_id,
            party_id) 
           values
           (:task_item_id,
            :role_id,
            :party_id)
         }
    }

    # Flush the cache that remembers which roles to offer the current user in the 'assign role to myself' listbox
    if {[ad_conn user_id] == $party_id} {
        util_memoize_flush [list pm::role::task_select_list_filter_not_cached -task_item_id $task_item_id -party_id $party_id]
    }
}


ad_proc -public pm::task::assigned_p {
    -task_item_id:required
    -party_id:required
} {
    Returns 1 if assigned, 0 if not
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-11-18
    
    @param task_item_id

    @param party_id

    @return 
    
    @error 
} {
    return [db_string assigned_p { } -default 0]
}


ad_proc -public pm::task::open {
    {-task_item_id:required}
} {
    Opens a task.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-22
    
    @param task_item_id

    @return 
    
    @error 
} {
    set status_code [pm::task::default_status_open]

    db_dml update_status { }
}

ad_proc -public pm::task::close {
    {-task_item_id:required}
    -no_callback:boolean
} {
    Closes a task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-22
    
    @param task_item_id

    @return 
    
    @error 
} {
    set status_code [pm::task::default_status_closed]

    db_dml update_status { }

    if {!$no_callback_p} {
	callback pm::task_close -package_id [ad_conn package_id] -task_id $task_item_id
    }
}



ad_proc -public pm::task::email_status {} {

    set send_email_p [parameter::get_from_package_key -package_key "project-manager" -parameter SendDailyEmail -default "0"]

    if {[string is false $send_email_p]} {
        ns_log Notice "Parameter SendDailyEmail for project manager says skip email today"
        return
    }

    # also don't send reminders on weekends.

    set today_j [db_string get_today "select to_char(current_timestamp,'J')"]
    if {![pm::project::is_workday_p $today_j]} {
        return
    }

    set parties [list]

    # what if the person assigned is no longer a part of the subsite?
    # right now, we still email them.

    db_foreach get_all_open_tasks {
        SELECT
        ts.task_id,
        ts.task_id as item_id,
        ts.task_number,
        t.task_revision_id,
        t.title,
        to_char(t.earliest_start,'J') as earliest_start_j,
        to_char(current_timestamp,'J') as today_j,
        to_char(t.latest_start,'J') as latest_start_j,
        to_char(t.latest_start,'YYYY-MM-DD HH24:MI') as latest_start,
        to_char(t.latest_finish,'YYYY-MM-DD HH24:MI') as latest_finish,
        t.percent_complete,
        t.estimated_hours_work,
        t.estimated_hours_work_min,
        t.estimated_hours_work_max,
        case when t.actual_hours_worked is null then 0
                else t.actual_hours_worked end as actual_hours_worked,
        to_char(t.earliest_start,'YYYY-MM-DD HH24:MI') as earliest_start,
        to_char(t.earliest_finish,'YYYY-MM-DD HH24:MI') as earliest_finish,
        to_char(t.latest_start,'YYYY-MM-DD HH24:MI') as latest_start,
        to_char(t.latest_finish,'YYYY-MM-DD HH24:MI') as latest_finish,
        p.first_names || ' ' || p.last_name as full_name,
        p.party_id,
        (select one_line from pm_roles r where ta.role_id = r.role_id) as role
        FROM
        pm_tasks_active ts, 
        pm_tasks_revisionsx t, 
        pm_task_assignment ta,
        acs_users_all p,
        cr_items i,
        pm_task_status s
        WHERE
        ts.task_id    = t.item_id and
        i.item_id     = t.item_id and
        t.task_revision_id = i.live_revision and
        ts.status     = s.status_id and
        s.status_type = 'o' and
        t.item_id     = ta.task_id and
        ta.party_id   = p.party_id
        ORDER BY
        t.latest_start asc
    } {
        set earliest_start_pretty [lc_time_fmt $earliest_start "%x"]
        set earliest_finish_pretty [lc_time_fmt $earliest_finish "%x"]
        set latest_start_pretty [lc_time_fmt $latest_start "%x"]
        set latest_finish_pretty [lc_time_fmt $latest_finish "%x"]
        
        if {[exists_and_not_null earliest_start_j]} {
            set slack_time [pm::task::slack_time \
                                -earliest_start_j $earliest_start_j \
                                -today_j $today_j \
                                -latest_start_j $latest_start_j]
            
        }
        
        if {[lsearch $parties $party_id] == -1} {
            lappend parties $party_id
        }
        
        lappend task_list($party_id) $task_id
        set titles_arr($task_id) $title
        set ls_arr($task_id)     $latest_start_pretty
        set lf_arr($task_id)     $latest_finish_pretty
        set slack_arr($task_id)  $slack_time
        set roles($task_id-$party_id) $role
        
        # how many tasks does this person have?
        if {[info exists task_count($party_id)]} {
            incr task_count($party_id)
        } else {
            set task_count($party_id) 1
        }
    }
    
    # transitions are < this value
    set OVERDUE_THRESHOLD 0
    set PRESSING_THRESHOLD 7
    set LONGTERM_THRESHOLD 90

    foreach party $parties {

        set subject "Daily Task status report"
        set address [db_string get_email "select email from parties where party_id = :party" -default "jade-errors@bread.com"]

        set overdue [list]
        set pressing [list]
        set longterm [list]

        foreach task $task_list($party) {

            set url [pm::task::get_url $task]

            if {$slack_arr($task) < $OVERDUE_THRESHOLD} {
                set which_pile overdue
            } elseif {$slack_arr($task) < $PRESSING_THRESHOLD} {
                set which_pile pressing
            } elseif {$slack_arr($task) < $LONGTERM_THRESHOLD} {
                set which_pile longterm
            } else {
                set which_pile ""
            }

            if {![empty_string_p $which_pile]} {

                lappend $which_pile "
<tr><td>\#$task</td><td><a href=\"$url\">$titles_arr($task)</a></td><td>$roles($task-$party)</td><td>$ls_arr($task)</td><td>$lf_arr($task)</td><td>$slack_arr($task)</td>"

            }

        }

        set overdue_title "<h3>[_ project-manager.Overdue_Tasks]</h3>"

        set overdue_description "[_ project-manager.lt_consult_with_people_a]"

        set pressing_title "<h3>[_ project-manager.Pressing_Tasks]</h3>"

        set pressing_description "[_ project-manager.lt_you_need_to_start_wor]"

        set longterm_title "<h3>[_ project-manager.Long_Term_Tasks]</h3>"

        set longterm_description "[_ project-manager.lt_look_over_these_to_pl]"

        # okay, let's now set up the email body

        set description "
<p>[_ project-manager.lt_This_is_a_daily_remin]</p>

$overdue_title

<hr />

$overdue_description

<table border=\"0\" bgcolor=\"#ddddff\">
<tr>
  <th>[_ project-manager.Task] \#</th>
  <th>[_ project-manager.Subject_1]</th>
  <th>[_ project-manager.Role]</th>
  <th>[_ project-manager.Latest_start]</th>
  <th>[_ project-manager.Latest_finish]</th>
  <th>[_ project-manager.Slack_1]</th>
</tr>
"

        foreach overdue_item $overdue {
            append description $overdue_item
        }

        append description "
</table>

$pressing_title

<hr />

$pressing_description

<table border=\"0\" bgcolor=\"#ddddff\">
<tr>
  <th>[_ project-manager.Task] \#</th>
  <th>[_ project-manager.Subject_1]</th>
  <th>[_ project-manager.Role]</th>
  <th>[_ project-manager.Latest_start]</th>
  <th>[_ project-manager.Latest_finish]</th>
  <th>[_ project-manager.Slack_1]</th>
</tr>
"

        foreach pressing_item $pressing {
            append description $pressing_item
        }

        append description "
</table>

$longterm_title

$longterm_description

<table border=\"0\" bgcolor=\"#ddddff\">
<tr>
  <th>[_ project-manager.Task] \#</th>
  <th>[_ project-manager.Subject_1]</th>
  <th>[_ project-manager.Role]</th>
  <th>[_ project-manager.Latest_start]</th>
  <th>[_ project-manager.Latest_finish]</th>
  <th>[_ project-manager.Slack_1]</th>
</tr>
"

        foreach longterm_item $longterm {
            append description $longterm_item
        }

        append description "</table>"

        pm::util::email \
            -to_addr  $address \
            -from_addr $address \
            -subject $subject \
            -body $description \
            -mime_type "text/html"
    }

    # consider also sending out emails to people who have created
    # tickets that are not assigned to anyone

}



ad_proc -private pm::task::email_status_init {
} {
    Schedules the daily emailings 
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-14
    
    @return 
    
    @error 
} {
    ns_log Notice "Scheduling daily email notifications for project manager to 5:00 am"
    ad_schedule_proc -thread t -debug t -schedule_proc ns_schedule_daily "5 0" pm::task::email_status
}



ad_proc -public pm::task::email_alert {
    -task_item_id:required
    {-edit_p "t"}
    {-comment ""}
    {-comment_mime_type "text/plain"}
    {-extra_description ""}
} {
    Sends out an email notification when changes have been made to a task

    <p />

    If any of the following are missing, fills in from the database:
    subject, work, work_min, work_max, project_name, earliest_start,
    earliest_finish, latest_start, latest_finish
     
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-03
    
    @param task_item_id

    @param edit_p Is this an edited task, or a new one? t for edited,
    f otherwise.
    
    @param extra_description Additional email content to send. In text format.

    @return 
    
    @error 
} {

    set task_term       \
        [parameter::get -parameter "Taskname" -default "Task"]
    set task_term_lower \
        [_ project-manager.task]
    set use_uncertain_completion_times_p \
        [parameter::get -parameter "UseUncertainCompletionTimesP" -default "0"]

    set user_id [ad_conn user_id]

    db_1row get_from_address_and_more { }

    db_1row get_task_info { }

    if {[string is true $edit_p]} {

        # ----
        # EDIT
        # ----

        set subject_out "[_ project-manager.lt_Edited_task_term_task]"
        set intro_text "[_ project-manager.lt_mod_username_edited_t]"


    } else {

        # ---
        # NEW
        # ---

        set subject_out "[_ project-manager.lt_New_task_term_task_it]"
        set intro_text "[_ project-manager.lt_mod_username_assigned]"

    }

    
    if {[empty_string_p $comment]} {
        set comment_text ""
    } else {
        set comment_text "<h3>[_ project-manager.Comment]</h3>$comment<p />"
    }

    set url [pm::task::get_url $task_item_id]
    
    set description [ad_html_text_convert -from $description_mime_type -to "text/html" -- $description]

    set extra_description [ad_html_text_convert -from "text/plain" -to "text/html" -- $extra_description]

    set description_out "$description $extra_description"

    set assignees [db_list_of_lists get_assignees { }]

    if {[exists_and_not_null $process_instance]} {

        set process_url [pm::process::url \
                             -process_instance_id $process_instance \
                             -project_item_id $project_item_id]

        set process_description [pm::process::name \
                                     -process_instance_id $process_instance]

        set process_html "
<h3>Process</h3>
<table border=\"0\" bgcolor=\"\#ddddff\">
  <tr>
    <td><a href=\"$process_url\">$process_description</a></td>
  </tr>
</table>
"
    } else {
        set process_html ""
    }

    foreach ass $assignees {

        set to_address [lindex $ass 0]
        set role       [lindex $ass 1]
        set is_lead_p  [lindex $ass 2]

        set notification_text "${intro_text}${comment_text}
<h3>[_ project-manager.Task_overview]</h3>
<table border=\"0\" bgcolor=\"#ddddff\">
  <tr>
    <td>[_ project-manager.Subject]</td>
    <td><a href=\"${url}\">$subject</a> (\#$task_item_id)</td>
  </tr>
  <tr>
    <td>[_ project-manager.Project]</td>
    <td>$project_name</td>
  </tr>
  <tr>
    <td>[_ project-manager.Your_role]</td>
    <td>$role</td>
  </tr>
</table>

$process_html
<h3>[_ project-manager.Description]</h3>
<table border=\"0\" bgcolor=\"\#ddddff\">
  <tr>
    <td>$description_out</td>
  </tr>
</table>

<h3>[_ project-manager.Dates_1]</h3>
<table border=\"0\" bgcolor=\"#ddddff\">
  <tr>
    <td>[_ project-manager.Latest_start_1]</td>
    <td>$latest_start</td>
  </tr>
  <tr>
    <td>[_ project-manager.Latest_finish]</td>
    <td><i>$latest_finish</i></td>
  </tr>
</table>"

        pm::util::email \
            -to_addr  $to_address \
            -from_addr $from_address \
            -subject $subject_out \
            -body $notification_text \
            -mime_type "text/html"
    }
}


ad_proc -public pm::task::update_percent {
    -task_item_id:required
    -percent_complete:required
} {
    Updates the task's percent complete. Called from logger to
    update the percentage complete.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-24
    
    @param task_item_id

    @param percent_complete

    @return 
    
    @error 
} {

    db_dml update_percent {
        UPDATE
        pm_tasks_revisions
        SET
        percent_complete = :percent_complete
        WHERE
        task_revision_id = (select 
                            live_revision 
                            from 
                            cr_items
                            where
                            item_id = :task_item_id)
    }

    if {$percent_complete >= 100} {
        
        pm::task::close -task_item_id $task_item_id
        
    } else {
        
        pm::task::open -task_item_id $task_item_id
        
    }
    
}


ad_proc -public pm::task::hours_remaining {
    -estimated_hours_work:required
    -estimated_hours_work_min:required
    -estimated_hours_work_max:required
    -percent_complete:required
} {
    Displays the estimated hours work remaining in a consistent format
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-02
    
    @param hours_work

    @param hours_work_min

    @param hours_work_max

    @param percent_complete

    @return 
    
    @error 
} {
    set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

    if {[string equal $percent_complete 100]} {
        return 0
    }

    if {[string equal $percent_complete 0]} {
        return [pm::task::estimated_hours_work \
                    -estimated_hours_work $estimated_hours_work \
                    -estimated_hours_work_min $estimated_hours_work_min \
                    -estimated_hours_work_max $estimated_hours_work_max]
    }

    if {[string is true $use_uncertain_completion_times_p]} {

        set display_value1 [expr round($estimated_hours_work_min * [expr 100 - $percent_complete] / double(100))]
        set display_value2 [expr round($estimated_hours_work_max * [expr 100 - $percent_complete] / double(100))]

        if {[string equal $display_value1 $display_value2]} {
            set display_value "$display_value1"
        } else {
            set display_value "$display_value1 - $display_value2"
        }
    } else {
        set display_value [expr round($estimated_hours_work * [expr 100 - $percent_complete] / double(100))]
    }

    return $display_value
}


ad_proc -public pm::task::days_remaining {
    -estimated_hours_work:required
    -estimated_hours_work_min:required
    -estimated_hours_work_max:required
    -percent_complete:required
} {
    Displays the estimated days work remaining in a consistent format
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-11-24
    
    @param hours_work

    @param hours_work_min

    @param hours_work_max

    @param percent_complete

    @return 
    
    @error 
} {
    set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]
    set hours_day [pm::util::hours_day]

    if {[string equal $percent_complete 100]} {
        return 0
    }

    if {[string equal $percent_complete 0]} {
        return [pm::task::estimated_days_work \
                    -estimated_hours_work $estimated_hours_work \
                    -estimated_hours_work_min $estimated_hours_work_min \
                    -estimated_hours_work_max $estimated_hours_work_max]
    }

    if {[string is true $use_uncertain_completion_times_p]} {

        set display_value1 [expr $estimated_hours_work_min * $hours_day * [expr 100 - $percent_complete] / double(100)]
        set display_value1 [pm::util::trim_number -number $display_value1]
        set display_value2 [expr $estimated_hours_work_max * $hours_day * [expr 100 - $percent_complete] / double(100)]
        set display_value2 [pm::util::trim_number -number $display_value2]
        # set display_value2 [expr round($estimated_hours_work_max * [expr 100 - $percent_complete] / double(100))]

        if {[string equal $display_value1 $display_value2]} {
            set display_value "$display_value1"
        } else {
            set display_value "$display_value1 - $display_value2"
        }
    } else {
        set display_value [expr $estimated_hours_work * [expr 100 - $percent_complete] / double(100)]
        set display_value [pm::util::trim_number -number $display_value]
    }

    return $display_value
}


ad_proc -public pm::task::estimated_hours_work {
    -estimated_hours_work:required
    -estimated_hours_work_min:required
    -estimated_hours_work_max:required
} {
    Displays the total estimated hours work in a consistent format
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-02
    
    @param estimated_hours_work

    @param estimated_hours_work_min

    @param estimated_hours_work_max

    @return 
    
    @error 
} {
    set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

    if {[string equal $use_uncertain_completion_times_p 1]} {
        if {[string equal $estimated_hours_work_min $estimated_hours_work_max]} {
            set display_value "$estimated_hours_work_min"
        } else {
            set display_value "$estimated_hours_work_min - $estimated_hours_work_max"
        }
    } else {
        set display_value "$estimated_hours_work"
    }
    
    return $display_value
}


ad_proc -public pm::task::estimated_days_work {
    -estimated_hours_work:required
    -estimated_hours_work_min:required
    -estimated_hours_work_max:required
} {
    Displays the total estimated days work in a consistent format
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-02
    
    @param estimated_hours_work

    @param estimated_hours_work_min

    @param estimated_hours_work_max

    @return 
    
    @error 
} {
    set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]

    if {[string equal $use_uncertain_completion_times_p 1]} {
        if {[string equal $estimated_hours_work_min $estimated_hours_work_max]} {
            set display_value [pm::util::days_work -hours_work $estimated_hours_work_min -pretty_p t]
        } else {
            set v1 [pm::util::days_work -hours_work $estimated_hours_work_min -pretty_p t]
            set v2 [pm::util::days_work -hours_work $estimated_hours_work_max -pretty_p t]

            if {[string equal $v1 $v2]} {
                set display_value $v1
            } else {
                set display_value "$v1 - $v2"
            }
        }
    } else {
        set display_value [pm::util::days_work -hours_work $estimated_hours_work -pretty_p t]
    }
    
    return $display_value
}


ad_proc -public pm::task::assignee_email_list {
    -task_item_id:required
} {
    Returns a list of assignee email addresses
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-10
    
    @param task_item_id

    @return 
    
    @error 
} {
    
    return [db_list get_addresses {
        SELECT
        p.email
        FROM 
        parties p,
        pm_task_assignment a
        WHERE
        a.task_id = :task_item_id and
        a.party_id = p.party_id
    }]
    
}


ad_proc -public pm::task::assignee_filter_select {
    {-status_id:required}
} {
    Returns a list of lists, people who are assigned tasks with a 
    status of status_id. Used in the list-builder filters for
    the tasks list page. Cached 5 minutes.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param status_id

    @return 
    
    @error 
} {
    return [util_memoize [list pm::task::assignee_filter_select_helper -status_id $status_id] 1]
}


ad_proc -private pm::task::assignee_filter_select_helper {
    {-status_id:required}
} {
    Returns a list of lists, people who are assigned tasks with a 
    status of status_id. Used in the list-builder filters for
    the tasks list page. Cached 5 minutes.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param status_id

    @return 
    
    @error 
} {
    return [db_list_of_lists get_people "
                SELECT
                distinct(first_names || ' ' || last_name) as fullname, 
                u.person_id 
                FROM
                persons u, 
                pm_task_assignment a,
                pm_tasks_active ts
                WHERE 
                u.person_id = a.party_id and
                ts.task_id = a.task_id and
                ts.status = :status_id
                ORDER BY
                fullname"]
}

ad_proc -public pm::task::assignee_html {
    {-number:required}
    {-process_task_id ""}
    {-task_item_id ""}
    {-project_item_id ""}
} {
    Assignee HTML for new tasks
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-13
    
    @return 
    
    @error 
} {

    # ------------------------------
    # cache these to speed it all up

    set roles_list_of_lists    [pm::role::select_list_filter]
    set assignee_list_of_lists [pm::util::subsite_assignees_list_of_lists]


    # Get assignments for when using processes
    if {[exists_and_not_null process_task_id]} {

        # PROCESS

        set task_assignee_list_of_lists \
            [pm::process::task_assignee_role_list \
                 -process_task_id $process_task_id]

    } elseif {[exists_and_not_null task_item_id]} {

        # EDITING (retrieve the assignees)

        set task_assignee_list_of_lists \
            [pm::task::assignee_role_list \
                 -task_item_id $task_item_id]

    } else {

        # NEW (set the assigness to the default assignees of the project)
	
        set task_assignee_list_of_lists \
	    [pm::project::assignee_role_list \
		 -project_item_id $project_item_id]
    }

    # Get assignments for when editing

            
    set html "<table border=\"0\">"

    foreach role_list $roles_list_of_lists {
        
        set role_name [lindex $role_list 0]
        set role      [lindex $role_list 1]
        
        append html "
        <td align=\"left\" valign=\"top\"><p /><B><I>$role_name</I></B><p />"
        
        foreach assignee_list $assignee_list_of_lists {
            set name      [lindex $assignee_list 0]
            set person_id [lindex $assignee_list 1]

            if {[lsearch $task_assignee_list_of_lists [list $person_id $role]] >= 0} {

                append html "
                <input name=\"assignee\" value=\"$number-$person_id-$role\" type=\"checkbox\" checked=\"checked\" /><span class=\"selected\">$name</span>
                <br />"

            } else {

                append html "
                <input name=\"assignee\" value=\"$number-$person_id-$role\" type=\"checkbox\" />$name
                <br />"
            }
                        
        }
        
        append html "</td>"

    }

    append html "</table>"

    return $html
}


ad_proc -public pm::task::get {
    {-tasks_item_id:required}
    {-one_line_array:required}
    {-description_array:required}
    {-description_mime_type_array:required}
    {-estimated_hours_work_array:required}
    {-estimated_hours_work_min_array:required}
    {-estimated_hours_work_max_array:required}
    {-dependency_array:required}
    {-percent_complete_array:required}
    {-end_date_day_array:required}
    {-end_date_month_array:required}
    {-end_date_year_array:required}
    {-project_item_id_array:required}
    {-set_client_properties_p "f"}
    {-priority_array:required}
} {
    Stuff information about tasks into several arrays
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-14
    
    @param tasks_item_id a list of tasks to retrieve and stuff in
    arrays

    @param one_line_array stuff one_line info in 
    one_line_array(task_item_id)

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
    upvar 1 $percent_complete_array         percent_complete_arr
    upvar 1 $end_date_day_array             end_date_day_arr
    upvar 1 $end_date_month_array           end_date_month_arr
    upvar 1 $end_date_year_array            end_date_year_arr
    upvar 1 $project_item_id_array          project_item_id_arr
    upvar 1 $priority_array                 priority_arr

    set task_where_clause " and i.item_id in ([join $tasks_item_id ", "])"

    db_foreach get_tasks { } {
        set one_line_arr($tid)                 $one_line
        set description_arr($tid)              $description
        set description_mime_type_arr($tid)    $description_mime_type
        set estimated_hours_work_arr($tid)     $estimated_hours_work
        set estimated_hours_work_min_arr($tid) $estimated_hours_work_min
        set estimated_hours_work_max_arr($tid) $estimated_hours_work_max
        set dependency_arr($tid)               $parent_task_id
        set percent_complete_arr($tid)         $percent_complete
        set end_date_day_arr($tid)             $end_date_day
        set end_date_month_arr($tid)           $end_date_month
        set end_date_year_arr($tid)            $end_date_year
        set project_item_id_arr($tid)          $project
	set priority_arr($tid)                 $priority

        # make sure that we don't have empty values for estimated
        # hours work
        if {[empty_string_p $estimated_hours_work_arr($tid)]} {
            set estimated_hours_work_arr($tid) 0
        }
        if {[empty_string_p $estimated_hours_work_min_arr($tid)]} {
            set estimated_hours_work_min_arr($tid) 0
        }
        if {[empty_string_p $estimated_hours_work_max_arr($tid)]} {
            set estimated_hours_work_max_arr($tid) 0
        }

        if {[string is true $set_client_properties_p]} {
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_one_line($tid) \
                $one_line
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_description($tid) \
                $description
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_description_mime_type($tid) \
                $description_mime_type
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_estimated_hours_work($tid) \
                $estimated_hours_work
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_estimated_hours_work_min($tid) \
                $estimated_hours_work_min
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_estimated_hours_work_max($tid) \
                $estimated_hours_work_max
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_dependency($tid) \
                $parent_task_id
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_percent_complete($tid) \
                $percent_complete
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_end_date_day($tid) \
                $end_date_day
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_end_date_month($tid) \
                $end_date_month
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_end_date_year($tid) \
                $end_date_year
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_project_item_id($tid) \
                $project
            
            ad_set_client_property -persistent f -- \
                project-manager \
                old_assignees($tid) \
                [pm::task::get_assignee_names \
                     -task_item_id $tid]

        }


    }
    
}


ad_proc -public pm::task::date_html {
    {-selected_month ""}
    {-selected_day   ""}
    {-selected_year  ""}
    {-show_help_p    "t"}
    {-month_target   "end_date_month"}
    {-day_target     "end_date_day"}
    {-year_target    "end_date_year"}

} {
    Returns HTML for the date widget in the task-add-edit page

    Since the calendar widget Javascript has been put in, this may
    need to be updated.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-15
    
    @return 
    
    @error 
} {
    for {set i 1} {$i <= 12} {incr i} {

        # numbers are in the form of 01 - 12
        if {$i < 10} {
            set j "0$i"
        } else {
            set j $i
        }
        set selected_[set j] ""
    }
    set selected_[set selected_month] "selected=\"selected\""

    set return_val "
        <table border=\"0\" cellpadding=\"0\" cellspacing=\"2\">
          <tr>
            <td nowrap=\"nowrap\">
              <select name=\"$month_target\" >
                <option value=\"\">--</option>
                <option $selected_01 value=\"1\">January</option>
                <option $selected_02 value=\"2\">February</option>
                <option $selected_03 value=\"3\">March</option>
                <option $selected_04 value=\"4\">April</option>
                <option $selected_05 value=\"5\">May</option>
                <option $selected_06 value=\"6\">June</option>
                <option $selected_07 value=\"7\">July</option>
                <option $selected_08 value=\"8\">August</option>
                <option $selected_09 value=\"9\">September</option>
                <option $selected_10 value=\"10\">October</option>
                <option $selected_11 value=\"11\">November</option>
                <option $selected_12 value=\"12\">December</option>
              </select>&nbsp;</td>
            <td nowrap=\"nowrap\">
              <input type=\"text\" name=\"$day_target\" size=\"2\" value=\"$selected_day\" />
            </td>
            <td nowrap=\"nowrap\"><input type=\"text\" name=\"$year_target\" size=\"4\" maxlength=\"4\" value=\"$selected_year\" />
            </td>
          </tr>"

    if {[string is true $show_help_p]} {
        append return_val "
          <tr>
            <td nowrap=\"nowrap\" align=\"center\">
              <font size=\"-2\">Month</font>
            </td>
            <td nowrap=\"nowrap\" align=\"center\">
              <font size=\"-2\">Day</font>
            </td>
            <td nowrap=\"nowrap\" align=\"center\">
              <font size=\"-2\">Year</font>
            </td>
          </tr>"
    }

    append return_val "</table>"

    return $return_val
}


ad_proc -public pm::task::get_assignee_names {
    {-task_item_id:required}
} {
    Returns a list of assignees to a task (first name + last name)
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-20
    
    @param task_item_id

    @return 
    
    @error 
} {

    return [db_list get_assignees { }]

}


ad_proc -public pm::task::assignee_role_list {
    {-task_item_id:required}
} {
    Returns a list of lists, with all assignees to a particular 
    task. {{party_id role_id} {party_id role_id}}

    Todo: dependency changes, deadline changes
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-18
    
    @param task_item_id

    @return 
    
    @error 
} {

    return [db_list_of_lists get_assignees_roles { }]

}


ad_proc -public pm::task::what_changed {
    {-comments_array:required}
    {-comments_mime_type_array:required}
    {-task_item_id_array:required}
    {-number:required}
} {
    Compares how a task was and how it currently is, and
    adds to the comments array a list of changes. Uses properties
    last set in the task::get proc.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-20
    
    @param comments_array

    @param comments_mime_type_array

    @param task_item_id_array an array of task_item_ids, with keys
    based on number

    @param number the keys to the task_item_id array, a list of integers

    @return 
    
    @error 
} {

    # we will append the changes to these arrays and convert them to
    # text/html format
    upvar 1 $comments_array             comments_arr
    upvar 1 $comments_mime_type_array   comments_mime_type_arr
    upvar 1 $task_item_id_array         task_item_id

    set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]
    set use_days_p     [parameter::get -parameter "UseDayInsteadOfHour" -default "t"]
    set hours_day [pm::util::hours_day]


    # get the new task values
    set tasks_item_id [list]
    foreach num $number {
        lappend tasks_item_id $task_item_id($num)
    }

    pm::task::get \
        -tasks_item_id                  $tasks_item_id \
        -one_line_array                  one_line_array \
        -description_array               description_array \
        -description_mime_type_array     description_mime_type_array \
        -estimated_hours_work_array      estimated_hours_work_array \
        -estimated_hours_work_min_array  estimated_hours_work_min_array \
        -estimated_hours_work_max_array  estimated_hours_work_max_array \
        -dependency_array                dependency_array \
        -percent_complete_array          percent_complete_array \
        -end_date_day_array              end_date_day_array \
        -end_date_month_array            end_date_month_array \
        -end_date_year_array             end_date_year_array \
        -project_item_id_array           project_item_id_array \
	-priority_array                  priority_array

    
    foreach num $number {

        set changes [list]

        set tid  $task_item_id($num)

        set old [ad_get_client_property -- project-manager old_percent_complete($tid)]

        set new $percent_complete_array($tid)

        if {![string equal $old $new]} {

            if {$new >= 100 && $old < 100} {

                lappend changes "<b>Closing task</b>"

            } elseif {$new < 100 && $old >= 100} {

                lappend changes "<b>Reopening task</b>"

            } else {
                lappend changes "Percent complete changed <i>from</i> $old%<i>to</i> $new%"
            }

        }
        

        set old_end_date_day [ad_get_client_property -- project-manager old_end_date_day($tid)]
        set old_end_date_month [ad_get_client_property -- project-manager old_end_date_month($tid)]
        set old_end_date_year [ad_get_client_property -- project-manager old_end_date_year($tid)]

        # end date
        if { \
                 ![string equal $old_end_date_day $end_date_day_array($tid)] || \
                 ![string equal $old_end_date_month $end_date_month_array($tid)] || \
                 ![string equal $old_end_date_year $end_date_year_array($tid)]} {

            # internationalize the dates
            set iso_date_old "$old_end_date_year-$old_end_date_month-$old_end_date_day 00:00:00"
            set iso_date_new "$end_date_year_array($tid)-$end_date_month_array($tid)-$end_date_day_array($tid) 00:00:00"

            if {[string equal $iso_date_old "-- 00:00:00"]} {
                set date_old "[_ project-manager.no_hard_deadline]"
            } else {
                set date_old [lc_time_fmt $iso_date_old "%x"]
            }

            if {[string equal $iso_date_new "-- 00:00:00"]} {
                set date_new "[_ project-manager.no_hard_deadline]"
            } else {
                set date_new [lc_time_fmt $iso_date_new "%x"]
            }

            lappend changes "[_ project-manager.lt_Hard_deadline_changed]"
        }

        set old_one_line [ad_get_client_property -- project-manager old_one_line($tid)]

        # one_line
        if {![string equal $old_one_line $one_line_array($tid)]} {
            lappend changes "Subject changed <i>from</i> $old_one_line  <i>to</i> $one_line_array($tid)"
        }

        set old_description [ad_get_client_property -- project-manager old_description($tid)]
        set old_description_mime_type [ad_get_client_property -- project-manager old_description_mime_type($tid)]

        # description
        if { \
                 ![string equal $old_description $description_array($tid)] || \
                 ![string equal $old_description_mime_type $description_mime_type_array($tid)]} {

            set richtext_list [list $old_description $old_description_mime_type]
            set old_description_html [template::util::richtext::get_property html_value $richtext_list]
            set richtext_list [list $description_array($tid) $description_mime_type_array($tid)]
            set new_description_html [template::util::richtext::get_property html_value $richtext_list]

            lappend changes "[_ project-manager.Description_changed]"
        }

        set old_estimated_hours_work [ad_get_client_property -- project-manager old_estimated_hours_work($tid)]
        set old_estimated_hours_work_min [ad_get_client_property -- project-manager old_estimated_hours_work_min($tid)]
        set old_estimated_hours_work_max [ad_get_client_property -- project-manager old_estimated_hours_work_max($tid)]

        # estimated_hours_work or days work
        if {[string is true $use_days_p]} {
            if {[string is true $use_uncertain_completion_times_p]} {
                
                set old [pm::util::days_work -hours_work $old_estimated_hours_work_min]
                set new [pm::util::days_work -hours_work $estimated_hours_work_min_array($tid)]

                if {![string equal $old $new]} {
                    lappend changes "[_ project-manager.lt_Work_estimate_min_cha]"
                }
                
                set old [pm::util::days_work -hours_work $old_estimated_hours_work_max]
                set new [pm::util::days_work -hours_work $estimated_hours_work_max_array($tid)]
                if {![string equal $old $new]} {
                    lappend changes "[_ project-manager.lt_Work_estimate_max_cha]"
                }

            } else {

                set old [pm::util::days_work -hours_work $old_estimated_hours_work]
                set new [pm::util::days_work -hours_work $estimated_hours_work_array($tid)]

                if {![string equal $old $new]} {
                    lappend changes "[_ project-manager.lt_Work_estimate_changed]"
                }
                
            }

        } else {

            # estimated_hours_work - hours
            if {[string is true $use_uncertain_completion_times_p]} {
                
                if {![string equal $old_estimated_hours_work_min $estimated_hours_work_min_array($tid)]} {
		    set new_estimated_hours_work_min $estimated_hours_work_min_array($tid)
                    lappend changes "[_ project-manager.lt_Work_estimate_min_cha_1]"
                }
                
                if {![string equal $old_estimated_hours_work_max $estimated_hours_work_max_array($tid)]} {
		    set new_estimated_hours_work_max $estimated_hours_work_max_array($tid)
                    lappend changes "[_ project-manager.lt_Work_estimate_max_cha_1]"
                }
            } else {
                
                if {![string equal $old_estimated_hours_work $estimated_hours_work_array($tid)]} {
		    set new_estimated_hours_work $estimated_hours_work_array($tid)
                    lappend changes "[_ project-manager.lt_Work_estimate_changed_1]"
                }
                
            }
        }

        set old_assignees [ad_get_client_property -- \
                               project-manager \
                               old_assignees($tid)]

        set new_assignees [pm::task::get_assignee_names \
                               -task_item_id $task_item_id($num)]

        # check for assignees that have been added

        foreach new $new_assignees {
            if { [lsearch $old_assignees $new] == -1} {
                lappend changes "[_ project-manager.Added_new]"
            }
        }

        # check for assignees that have been removed
        foreach old $old_assignees {
            if { [lsearch $new_assignees $old] == -1} {
                lappend changes "[_ project-manager.Removed_old]"
            }
        }

        set old_project_item_id [ad_get_client_property -- project-manager old_project_item_id($tid)]

        # project

        if {![string equal $old_project_item_id $project_item_id_array($tid)]} {

            set old [pm::project::name -project_item_id $old_project_item_id]

            lappend changes "[_ project-manager.lt_Project_changed_ifrom]"

        }

        set old_dependency [ad_get_client_property -- project-manager old_dependency($tid)]

        # dependency
        if {![string equal $old_dependency $dependency_array($tid)]} {

            if {[empty_string_p $old_dependency]} {
                set old "[_ project-manager.Nothing]"
            } else {
                set old [pm::task::name \
                             -task_item_id $old_dependency]
            }

            if {[empty_string_p $dependency_array($tid)]} {
                set new "[_ project-manager.Nothing]" 
            } else {
                set new [pm::task::name \
                             -task_item_id $dependency_array($tid)]
            }

            lappend changes "[_ project-manager.lt_Dependency_changed_if]"
        }


        # convert comments to richtext
        set richtext_list [list $comments_arr($num) $comments_mime_type_arr($num)]
        set comment_html [template::util::richtext::get_property html_value $richtext_list]


        # add in changes

        if {[llength $changes] > 0} {
            append comment_html "<ul><li>[join $changes "<li>"]</ul>"

            set comments_arr($num)           $comment_html
            set comments_mime_type_arr($num) "text/html"
        }
        
    }

    
}


ad_proc -public pm::task::clear_client_properties {
    {-task_item_id:required}
} {
    Clears all the client properties for a given task_item_id
    
    @author  (ibr@test)
    @creation-date 2004-11-03
    
    @param task_item_id

    @return 
    
    @error 
} {

    ad_set_client_property -persistent f -- \
        project-manager \
        old_one_line($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_description($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_description_mime_type($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_estimated_hours_work($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_estimated_hours_work_min($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_estimated_hours_work_max($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_dependency($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_percent_complete($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_end_date_day($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_end_date_month($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_end_date_year($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_project_item_id($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_assignees($task_item_id) \
        ""

    ad_set_client_property -persistent f -- \
        project-manager \
        old_assignees($task_item_id) \
        ""

}


ad_proc -public pm::task::default_orderby {
    {-set ""}
} {
    Returns the default order by (set by ad_set_client_property)
    
    @author  (jader@bread.com)
    @creation-date 2004-11-04
    
    @param if set is set, then set the default_orderby

    @return 
    
    @error 
} {
    if {[empty_string_p $set]} {
        
        set default_orderby "end_date,asc"
        
        set return_val [ad_get_client_property \
                            -default $default_orderby \
                            -- \
                            project-manager \
                            task-index-orderby]
        
        return $return_val

    } else {

        ad_set_client_property -- project-manager task-index-orderby $set
        return $set

    }
}


ad_proc -public pm::task::today_html {
    {-show_help_p "f"}
    {-month_target   "end_date_month"}
    {-day_target     "end_date_day"}
    {-year_target    "end_date_year"}

} {
    Returns today in an html form widget
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-18
    
    @return 
    
    @error 
} {

    set today_day   [clock format [clock scan today] -format "%d"]
    set today_month [clock format [clock scan today] -format "%m"]
    set today_year  [clock format [clock scan today] -format "%Y"]

    set return_val [pm::task::date_html \
                        -selected_month $today_month \
                        -selected_day   $today_day \
                        -selected_year  $today_year \
                        -show_help_p    $show_help_p \
                        -month_target   $month_target \
                        -day_target     $day_target \
                        -year_target    $year_target]

    return $return_val
}
