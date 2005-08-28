ad_library {

    Project Manager Projects Library
    
    Procedures that deal with projects

    @creation-date 2003-08-25
    @author Jade Rubick <jader@bread.com>
    @cvs-id $Id$

}

namespace eval pm::project {}


ad_proc -public pm::project::get_project_id {
    -project_item_id:required
} {
    Returns the live project_id when give the project_item_id

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-19
    
    @param project_item_id The item_id for the project

    @return project_id
    
    @error 
} {
    set return_val [db_string get_project_id { }]

    return $return_val
}



ad_proc -public pm::project::get_project_item_id {
    -project_id:required
} {
    Returns the item_id for a project when given the project_id 
    (a revision id)     

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-19
    
    @param project_id

    @return project_item_id
    
    @error 
} {
    set return_val [db_string get_project_item { }]

    return $return_val
}



ad_proc -public pm::project::default_status_open {} {
    Returns the default status value for open projects
} {
    set return_val [db_string get_default_status_open { }]

    return $return_val
}



ad_proc -public pm::project::default_status_closed {} {
    Returns the default status value for closed projects
} {
    set return_val [db_string get_default_status_closed { }]

    return $return_val
}



ad_proc -private pm::project::log_hours {
    {-entry_id ""}
    -logger_project_id:required
    -variable_id:required
    -value:required
    {-timestamp_ansi ""}
    {-description ""}
    {-task_item_id ""}
    {-project_item_id ""}
    {-update_status_p "t"}
    {-party_id ""}
} {
    Adds a logger entry to a project. If task_item_id is passed 
    in, also links it up with that task, and updates the task
    hours.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-05

    @see logger::entry::new
    @see pm::project::compute_status
    
    @param entry_id If passed in, determines the entry_id for the 
    newly logged entry

    @param logger_project_id

    @param variable_id

    @param value

    @param timestamp_ansi Timestamp in ANSI format YYYY-MM-DD

    @param description

    @param task_item_id

    @param project_item_id If the task_item_id is passed in, the 
    project_item_id needs to be passed in as well

    @param update_status_p If t, then updates the database for the
    task and project so that the denormalized values are updated.
    This can be set to f when editing a task, because these things
    are done later anyway.

    @param party_id If set, the party that creates the new logger
    entry. If not set, defaults to ad_conn user_id

    @return 0 if there no task it is logged against, otherwise returns
    the total number of hours logged to that task
    
    @error returns -1 if there is an error in pm::task::update_hours
    If a task_id is passed in, essentially passes along any errors 
    from pm::task::update_hours
} {
    set returnval 0

    # get a new entry_id if it's not passed in (like it would be from
    # a page that was using ad_form)
    if {[empty_string_p $entry_id]} {
        set entry_id [db_nextval acs_object_id_seq]
    }

    if {[exists_and_not_null party_id]} {
        set creation_user $party_id
    } else {
        set creation_user [ad_conn user_id]
    }

    if {[empty_string_p $timestamp_ansi]} {
        set timestamp_ansi [clock format [clock seconds] -format "%Y-%m-%d"]
    }

    # add in the new entry
    logger::entry::new \
	-entry_id $entry_id \
        -project_id $logger_project_id \
	-project_item_id $project_item_id \
        -variable_id $variable_id \
        -value $value \
        -time_stamp $timestamp_ansi \
        -description $description \
        -party_id $creation_user

    
    # if we have a pm_task_id, then we need to note that this
    # entry is logged to a particular task.

    logger::project::get -project_id $logger_project_id -array project_array
    logger::variable::get -variable_id [logger::project::get_primary_variable -project_id $logger_project_id] -array variable_array

    if {[exists_and_not_null task_item_id]} {
	application_data_link::new -this_object_id $task_item_id -target_object_id $entry_id
        
        set returnval [pm::task::update_hours \
                           -task_item_id $task_item_id \
                           -update_tasks_p $update_status_p]

        if {[string is true $update_status_p]} {
            pm::project::compute_status  $project_item_id
        }

	set log_title "$project_array(name)\: [pm::task::name -task_item_id $task_item_id]: logged $value $variable_array(unit)"

        pm::util::general_comment_add \
            -object_id $task_item_id \
            -title $log_title \
            -comment $description \
            -mime_type "text/html" \
            -user_id [ad_conn user_id] \
            -peeraddr [ad_conn peeraddr] \
            -type "task" \
            -send_email_p t

        pm::task::update_hours \
            -task_item_id $task_item_id \
            -update_tasks_p t

    } else {

	set log_title "$project_array(name)\: [pm::project::name -project_item_id $project_item_id]: logged $value $variable_array(unit)"

        pm::util::general_comment_add \
            -object_id $project_item_id \
            -title $log_title \
            -comment $description \
            -mime_type "text/html" \
            -user_id [ad_conn user_id] \
            -peeraddr [ad_conn peeraddr] \
            -type "project" \
            -send_email_p t
    }

    return $returnval
}



ad_proc -public pm::project::new {
    -project_name:required
    {-project_code ""}
    {-parent_id ""}
    {-goal ""}
    {-description ""}
    {-mime_type "text/plain"}
    {-planned_start_date ""}
    {-planned_end_date ""}
    {-actual_start_date ""}
    {-actual_end_date ""}
    {-ongoing_p "f"}
    -status_id:required
    -organization_id:required
    {-dform "implicit"}
    {-creation_date ""}
    -creation_user:required
    -creation_ip:required
    -package_id:required
    -no_callback:boolean
} {
    Creates a new project

    @author Jade Rubick (jader@bread.com)
    
    @param project_name

    @error 
} {

    # if the project is ongoing, there is no end date
    # we set it to null to signify that. Technically, this
    # is bad data model design -- we should just get rid of
    # ongoing_p
    if {[string equal $ongoing_p t]} {
        set actual_end_date ""
        set planned_end_date ""
    }

    # create a project manager project
    set project_revision [db_exec_plsql new_project_item { *SQL }]

    set project_item_id [pm::project::get_project_item_id \
                             -project_id $project_revision]

    set project_role [pm::role::default]

    pm::project::assign \
        -project_item_id $project_item_id \
        -role_id $project_role \
        -party_id $creation_user \
        -send_email_p "f"

    # Set the parent_id to the package_id if this is not a subproject.
    # Otherwise permission inheritance won't work.
    # Update the context_id
    if {[empty_string_p $parent_id]} {
	set parent_id $package_id
    }

    db_dml update_context_id "update acs_objects set context_id = :parent_id where object_id = :project_item_id"

    if {!$no_callback_p} {
	callback pm::project_new -package_id $package_id -project_id $project_item_id -data [list organization_id $organization_id]
    }

    return $project_revision
}


ad_proc -public pm::project::delete {
    -project_item_id:required
    -no_callback:boolean
} {
    Stub for project deletion
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-03
    
    @param project_item_id

    @return 
    
    @error 
} {
    if {!$no_callback_p} {
	callback pm::project_delete -package_id [ad_conn package_id] -project_id $project_item_id
    }
}


ad_proc -public pm::project::edit {
    -project_item_id:required
    -project_name:required
    {-project_code ""}
    {-parent_id ""}
    {-goal ""}
    {-description ""}
    {-planned_start_date ""}
    {-planned_end_date ""}
    {-actual_start_date ""}
    {-actual_end_date ""}
    {-ongoing_p "f"}
    -status_id:required
    -organization_id:required
    {-dform "implicit"}
    {-creation_date ""}
    -creation_user:required
    -creation_ip:required
    -package_id:required
    -no_callback:boolean
} {
    Stub for project edit
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-03
    
    @param project_item_id

    @param project_name

    @return 
    
    @error 
} {
    set returnval [db_exec_plsql update_project "
	select pm_project__new_project_revision (
		:project_item_id,
		:project_name,
		:project_code,
                :parent_id,
		:goal,
		:description,
		to_timestamp(:planned_start_date,'YYYY MM DD HH24 MI SS'),
		to_timestamp(:planned_end_date,'YYYY MM DD HH24 MI SS'),
		null,
		null,
                null,
		:ongoing_p,
                :status_id,
                :organization_id,
                :dform,
		now(),
		:creation_user,
		:creation_ip,
		:package_id
	);
     "]

    if {!$no_callback_p} {
	callback pm::project_edit -package_id $package_id -project_id $project_item_id
    }

    return $returnval
}


ad_proc -public pm::project::get {
    -project_item_id:required
    -array:required
} {
    Stub for get function
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-03-03
    
    @param project_item_id

    @param array

    @return values for this project identified by project_item_id, in 
    an array named array
    
    @error 
} {
    
}


ad_proc -private pm::project::latest_start {
    {-end_date_j:required}
    {-hours_to_complete:required}
    {-hours_day:required}
} {
    Returns the latest_start date. This is equal to the
    latest finish date minus the amount of time it will
    take to accomplish the job. Also takes into
    account weekdays. 
    <p />
    Someday, it should disregard holidays!
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-20
    
    @param end_date_j 

    @param hours_to_complete Estimated number of hours it will take 
    to complete this task

    @param hours_day Number of hours in a day

    @return the latest start date, as a Julian number
    
    @error 
} {
    

    set t_end_date    $end_date_j
    set t_today       $t_end_date

    while {![is_workday_p $t_today]} {
        set t_today [expr $t_today - 1]
    }
    set t_total_hours $hours_to_complete
            
    while {$t_total_hours > $hours_day} {

        set t_today [expr $t_today - 1]
        
        # if it is a holiday, don't subtract from total time
        
        if {[is_workday_p $t_today]} {
            set t_total_hours [expr $t_total_hours - $hours_day]
        }
        
    }
            
    return  $t_today

}


ad_proc -private pm::project::earliest_finish {
    earliest_start_j
    hours_to_complete
    hours_day
} {

    # set earliest_finish($task_item) [expr $earliest_start($task_item) + [expr $activity_time($task_item) / double($hours_day)]]

    # we now set the earliest finish. This is equal to the
    # earliest start plus the amount of time it will
    # take to accomplish the job. We need to disregard holidays!

    set t_start_date    $earliest_start_j
    set t_today         $t_start_date

    while {![is_workday_p $t_today]} {
        set t_today [expr $t_today + 1]
    }
    set t_total_hours $hours_to_complete
            
    while {$t_total_hours > $hours_day} {

        set t_today [expr $t_today + 1]
        
        # if it is a holiday, don't subtract from total time
        
        if {[is_workday_p $t_today]} {
            set t_total_hours [expr $t_total_hours - $hours_day]
        }
        
    }
            
    return  $t_today

}


ad_proc -private pm::project::my_earliest_start {
    earliest_start_j
    hours_to_complete
    hours_day
} {
    Computing the earliest start requires getting a max of all the possible
    candidates. This returns the value for one candidate
} {
    # set my_earliest_start [expr [expr $activity_time($dependent_item) / double($hours_day)] + $earliest_start($dependent_item)]

    set t_start_date    $earliest_start_j
    set t_today         $t_start_date

    while {![is_workday_p $t_today]} {
        set t_today [expr $t_today + 1]
    }

    set t_total_hours $hours_to_complete
            
    while {$t_total_hours > $hours_day} {

        set t_today [expr $t_today + 1]
        
        # if it is a holiday, don't subtract from total time
        
        if {[is_workday_p $t_today]} {
            set t_total_hours [expr $t_total_hours - $hours_day]
        }
        
    }
            
    return  $t_today

}


ad_proc -private pm::project::my_latest_finish {
    latest_start_j
    hours_to_complete
    hours_day
} {
    Computing the latest
} {
    # set temp [expr $min_latest_start + [expr $activity_time($task_item) / double($hours_day)]]

    if {[empty_string_p $latest_start_j]} {
        return ""
    }

    set t_start_date    $latest_start_j
    set t_today         $t_start_date

    while {![is_workday_p $t_today]} {
        set t_today [expr $t_today + 1]
    }

    set t_total_hours $hours_to_complete
            
    while {$t_total_hours > $hours_day} {

        set t_today [expr $t_today + 1]
        
        # if it is a holiday, don't subtract from total time
        
        if {[is_workday_p $t_today]} {
            set t_total_hours [expr $t_total_hours - $hours_day]
        }
        
    }
            
    return  $t_today

}


ad_proc -private pm::project::julian_to_day_of_week {
    julian_date
} {
    Computes the day of the week. 0=Sunday
    Initially, I used Tcl's clock command, but it doesn't accept dates
    larger than 2038, so I had to do this myself.
} {
    set date [dt_julian_to_ansi $julian_date] 
    regexp {([0-9]*)-([0-9]*)-([0-9]*)} $date match year month day
    regexp {0(.)} $month match month extra
    regexp {0(.)} $day match day extra
    set alpha [expr [expr 14 - $month] / 12]
    set y [expr $year - $alpha]
    set m [expr $month + [expr 12 * $alpha] - 2]
    set day_of_week_pre_mod [expr $day + $y + [expr $y / 4] - [expr $y / 100] + [expr $y / 400] + [expr 31 * $m / 12]]
    set day_of_week [expr $day_of_week_pre_mod % 7]  
    return $day_of_week
}



ad_proc -private pm::project::is_workday_p {
    date_j
} {

    Figures out whether or not a given date is a workday or not.
    Assumes Saturday and Sunday are not workdays

} {

    # need to add in a table of holidays

    set day_of_week [julian_to_day_of_week $date_j]

    if {[string equal $day_of_week 6] || [string equal $day_of_week 0]} {
        return 0
    } else {
        return 1
    }
}



ad_proc -public pm::project::compute_status {project_item_id} {

    Looks at tasks and subprojects, and computes the current status of a project. 
    <p />
    
    These are the items we'd like to compute

    <pre>
    PROJECTS:
    estimated_completion_date       timestamptz,
    earliest_completion_date        timestamptz,
    latest_completion_date          timestamptz,
    actual_hours_completed          numeric,
    estimated_hours_total           numeric
    TASKS:
    earliest start(i)  = max(activity_time(i-1) + earliest_start(i-1))
    earliest_finish(i) = earliest_start(i) + activity_time(i)
    latest_start(i)    = min(latest_start(i+1) - activity_time(i)
    latest_finish(i)   = latest_start(i) + activity_time(i)
    </pre>

    (i-1 means an item that this task depends on)

    <p />

    These algorithms are explained at:
    http://mscmga.ms.ic.ac.uk/jeb/or/netaon.html <p />

    Tasks in ongoing projects are given null completion dates, 
    unless they already have deadlines.

    <p />

    The statistics are computed based on:
    <p />

    Project statistics are based on that project + subproject statistics
    <p />

    That means if a project has a subproject, then the tasks for
    both of those projects are put together in one list, and computed
    together.

    <p />

    So for a project with no subprojects, the values are computed 
    for the tasks in that project

    <p />
    For a project with subprojects, the statistics are based on the 
    tasks of both of those projects.

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-02-19
    
    @param project_item_id The item_id for the project

    @return a list of task_item_ids of all tasks under  a project, plus all subproject tasks. This is done so that the function can be recursive
    
    @error No error codes

} {
    
    # Before hacking on this, you might want to look at:
    # http://www.joelonsoftware.com/articles/fog0000000069.html

    # the first thing that should be done on this code is that it
    # should be broken out to a number of utility procs. 

    set debug 0

    # TODO:
    # 
    # -------------------------------------------------------------------------
    # to improve this in the future, be more intelligent about what is updated.
    # i.e., this procedure updates everything, which is necessary sometimes,
    # but not if you only edit one task.
    #
    # I added in an optimization to only save when something has
    # changed -- JR
    # -------------------------------------------------------------------------
    # Add in resource limits. (it's not realistic that 300 tasks can be done in
    # one day)
    # -------------------------------------------------------------------------
    # Use dependency types -- currently they're all treated like finish_to_start
    # -------------------------------------------------------------------------


    # note if you want to understand the algorithms in this function, you
    # should look at:
    # http://mscmga.ms.ic.ac.uk/jeb/or/netaon.html

    if {[string is true $debug]} {
        ns_log Notice "-----------------------------------------"
    }

    # --------------------------------------------------------------------
    # for now, hardcode in a day is 8 hours. Later, we want to set this by
    # person. 
    # --------------------------------------------------------------------
    set hours_day [pm::util::hours_day]


    # -------------------------
    # get subprojects and tasks
    # -------------------------
    set task_list            [list]
    set task_list_project    [list]

    foreach sub_item [db_list_of_lists select_project_children { }] {
        set my_id   [lindex $sub_item 0]
        set my_type [lindex $sub_item 1]

        if {[string equal $my_type "pm_project"]} {

            # ---------------------------------------------
            # gets all tasks that are a part of subprojects
            # ---------------------------------------------
            set project_return [pm::project::compute_status $my_id]
            set task_list_project [concat $task_list_project $project_return]

        } elseif {[string equal $my_type "pm_task"]} {
            lappend task_list    $my_id
        }
    }

    set task_list [concat $task_list $task_list_project]

    if {[string is true $debug]} {
        ns_log Notice "Tasks in this project (task_list): $task_list"
    }

    # -------------------------
    # no tasks for this project
    # -------------------------
    if {[llength $task_list] == 0} {
        return [list]
    }

    # --------------------------------------------------------------
    # we now have list of tasks that includes all subprojects' tasks
    # --------------------------------------------------------------
    
    # returns actual_hours_completed, estimated_hours_total, and
    # today_j (julian date for today)
    db_1row tasks_group_query { }

    if {[string is true $debug]} {
        ns_log notice "Today's date (julian format): $today_j"
    }

    # --------------------------------------------------------------
    # Set up activity_time for all tasks
    # Also set up deadlines for tasks that have hard-coded deadlines
    # --------------------------------------------------------------

    if {[string is true $debug]} {
        ns_log notice "Going through tasks and saving their values"
    }

    db_foreach tasks_query { } {

        # We now save information about all the tasks, so that we can
        # save on database hits later. Specifically, what we'll do is
        # we won't need to save changes if the earliest_start,
        # earliest finish, latest_start and latest_finish all haven't
        # changed at all. We also save whether the task is open (o) or
        # closed(c).

        set old_ES_j($my_iid) $old_earliest_start_j
        set old_EF_j($my_iid) $old_earliest_finish_j
        set old_LS_j($my_iid) $old_latest_start_j
        set old_LF_j($my_iid) $old_latest_finish_j
        set task_percent_complete($my_iid) $my_percent_complete

        set activity_time($my_iid) [expr [expr $to_work * [expr 100 - $my_percent_complete] / 100]]

        if {[exists_and_not_null task_deadline_j]} {

            if {[string is true $debug]} {
                ns_log notice "$my_iid has a deadline (julian: $task_deadline_j)"
            }

            set latest_finish($my_iid) $task_deadline_j
	    
            set latest_start($my_iid) [pm::project::latest_start \
                                           -end_date_j $task_deadline_j \
                                           -hours_to_complete $activity_time($my_iid) \
                                           -hours_day $hours_day]
            
        }
    }

    # --------------------------------------------------------------------
    # We need to keep track of all the dependencies so we can meaningfully
    # compute deadlines, earliest start times, etc..
    # --------------------------------------------------------------------

    db_foreach dependency_query { } {

        # task_item_id depends on parent_task_id
        lappend depends($task_item_id)     $parent_task_id

        # parent_task_id is dependent on task_item_id
        lappend dependent($parent_task_id) $task_item_id

        set dependency_types($task_item_id-$parent_task_id) $dependency_type

            if {[string is true $debug]} {
                ns_log Notice "dependency (id: $dependency_id) task: $task_item_id parent: $parent_task_id type: $dependency_type"
            }
    }


    # --------------------------------------------------------------
    # need to get some info on this project, so that we can base the
    # task information off of them
    # --------------------------------------------------------------

    # gives up end_date_j, start_date_j, and ongoing_p
    # if ongoing_p is t, then end_date_j should be null
    db_1row project_info { }

    if {[string is true $ongoing_p] && ![empty_string_p $end_date_j]} {
        ns_log Error "Project cannot be ongoing and have a non-null end-date. Setting end date to blank"
        set end_date_j ""
    }
    

    # --------------------------------------------------------------
    # task_list contains all the tasks
    # a subset of those do not depend on any other tasks
    # --------------------------------------------------------------

    # ----------------------------------------------------------------------
    # we want to go through and fill in all the values for earliest start.
    # the brain-dead, brute force way of doing this, would be go through the
    # task_list length(task_list) times, and each time, compute the values
    # for each item that depends on one of those tasks. This is extremely
    # inefficient.
    # ----------------------------------------------------------------------
    # Instead, we create two lists, one is of tasks we just added 
    # earliest_start values for, the next is a new list of ones we're going to
    # add earliest_start values for. We call these lists 
    # present_tasks and future_tasks
    # ----------------------------------------------------------------------

    set present_tasks [list]
    set future_tasks  [list]

    # -----------------------------------------------------
    # make a list of tasks that don't depend on other tasks
    # -----------------------------------------------------
    # while we're at it, save earliest_start and earliest_finish
    # info for these items
    # -----------------------------------------------------

    foreach task_item $task_list {

        if {![info exists depends($task_item)]} {

            set earliest_start($task_item) $start_date_j
            set earliest_finish($task_item) [earliest_finish $earliest_start($task_item) $activity_time($task_item) $hours_day]

            lappend present_tasks $task_item

            if {[string is true $debug]} {
                ns_log Notice "preliminary earliest_start($task_item): $earliest_start($task_item)"
            }
        }
    }

    # -------------------------------
    # stop if we have no dependencies
    # -------------------------------
    if {[llength $present_tasks] == 0} {

        if {[string is true $debug]} {
            ns_log Notice "No tasks with dependencies"
        }

        return [list]
    }

    if {[string is true $debug]} {
        ns_log Notice "present_tasks: $present_tasks"
    }

    # ------------------------------------------------------
    # figure out the earliest start and finish times
    # ------------------------------------------------------

    while {[llength $present_tasks] > 0} {

        set future_tasks [list]

        foreach task_item $present_tasks {

            if {[string is true $debug]} {
                ns_log Notice "-this task_item: $task_item"
            }

            # -----------------------------------------------------
            # some tasks may already have earliest_start filled in
            # the first run of tasks, for example, had their values
            # filled in earlier
            # -----------------------------------------------------

            if {![exists_and_not_null earliest_start($task_item)]} {

                if {[string is true $debug]} {
                    ns_log Notice " !info exists for $task_item"
                }

                # ---------------------------------------------
                # set the earliest_start for this task = 
                # max(activity_time(i-1) + earliest_start(i-1))
                #
                # (i-1 means an item that this task depends on)
                # ---------------------------------------------

                set max_earliest_start 0

                # testing if this fixes the bug
                if {![exists_and_not_null depends($task_item)]} {
                    set depends($task_item) [list]
                }

                foreach dependent_item $depends($task_item) {

                    set my_earliest_start [my_earliest_start $earliest_start($dependent_item) $activity_time($dependent_item) $hours_day]

                    if {$my_earliest_start > $max_earliest_start} {
                        set max_earliest_start $my_earliest_start
                    }
                }

                set earliest_start($task_item) $max_earliest_start

                set earliest_finish($task_item) [earliest_finish $max_earliest_start $activity_time($task_item) $hours_day]

                if {[string is true $debug]} {
                    ns_log Notice \
                        " earliest_start ($task_item): $earliest_start($task_item)"
                    ns_log Notice \
                        " earliest_finish($task_item): $earliest_finish($task_item)"
                }

            }

            # -------------------------------
            # add to list of tasks to process
            # -------------------------------

            if {[info exists dependent($task_item)]} {
                set future_tasks [concat $future_tasks $dependent($task_item)]
            }
        }

        if {[string is true $debug]} {
            ns_log Notice "future tasks: $future_tasks"
        }

        set present_tasks $future_tasks
    }

    # ----------------------------------------------
    # set up earliest date project will be completed
    # ----------------------------------------------

    set max_earliest_finish $today_j

    foreach task_item $task_list {

        if {[string is true $debug] && [exists_and_not_null earliest_finish($task_item)]} {
            ns_log Notice "* EF: ($task_item): $earliest_finish($task_item)"
        }
        
        if {[exists_and_not_null earliest_finish($task_item)] && $max_earliest_finish < $earliest_finish($task_item)} {
            set max_earliest_finish $earliest_finish($task_item)
        }

    }


    # -----------------------------------------------------------------
    # Now compute latest_start and latest_finish dates.
    # Note the latest_finish dates may be set to an arbitrary deadline.
    # Also note that it is possible for a project to be ongoing.
    # In that case, the latest_start and latest_finish dates should
    # be set to null, unless there is a hard deadline (end_date).
    # -----------------------------------------------------------------
    # If these represent the dependency hierarchy:
    #               2155
    #             /  |   \
    #         2161  2173  2179
    #          |           |
    #         2167        2195
    # ----------------------------------------------------------------------
    # we want to go through and fill in all the values for latest start
    # and latest_finish.
    # the brain-dead, brute force way of doing this, would be go through the
    # task_list length(task_list) times, and each time, compute the values
    # for each item that depends on one of those tasks. This is extremely
    # inefficient.
    # ----------------------------------------------------------------------
    # Instead, we create two lists, one is of tasks we just added 
    # latest_finish values for, the next is a new list of ones we're going to
    # add latest_finish values for. We call these lists 
    # present_tasks and future_tasks
    # ----------------------------------------------------------------------
    # Here's a description of the algorithm.
    # 1. The algorithm starts with those tasks that don't have other 
    # tasks depending on them. 
    # 
    # So in the example above, we'll start with 
    #   present_tasks: 2167 2173 2195
    #   future tasks: 
    #
    # 2. While we make the present_tasks list, we store latest_start
    # and latest_finish information for each of those tasks. If the
    # project is ongoing, then we also keep track of tasks that have
    # no latest_start or latest_finish. We keep this in the
    # ongoing_task(task_id) array. If is exists, then we know that
    # that task is an ongoing task, so no deadline will exist for it.
    #
    # 3. Stop if we don't have any dependencies
    # 
    # 4. Then we get into a loop.
    #    While there are present_tasks:
    #      Create the future_tasks list
    #      For each present task:
    #        If the task has a dependent task:
    #          Go through these dependent tasks:
    #            If the dependent task is ongoing don't defer
    #            If the dependent task doesn't have LS set,
    #             then defer, and add to future_tasks list
    #            Otherwise set the LS value for that task
    #          If there are no deferals, get the minimum LS of
    #          dependents, set LF 
    #        Add the dependent tasks to the future_tasks
    #      Set present_tasks equal to future_tasks, clear future_tasks

    # ----------------------------------------------------------------------
    # The biggest problem with this algorithm is that you can have items at 
    # two different levels in the hierarchy. 
    # 
    # if you trace through this algorithm, you'll see that we'll get to 2155
    # before 2161's values have been set, which can cause an error. The 
    # solution we arrive at is to defer to the future_tasks list any item
    # that causes an error. That should work.

    set present_tasks [list]
    set future_tasks  [list]

    # -----------------------------------------------------
    # make a list of tasks that don't have tasks depend on them
    # -----------------------------------------------------
    # while we're at it, save latest_start and latest_finish
    # info for these items
    # -----------------------------------------------------

    if {[string is true $debug]} {
        ns_log Notice "Starting foreach task-item $task_list"
    }

    foreach task_item $task_list {

        if {![info exists dependent($task_item)]} {

            if {[string is true $debug]} {
                ns_log Notice " !info exists dependent($task_item)"
            }

            # we check this because some tasks already have
            # hard deadlines set. 
            if {[info exists latest_finish($task_item)]} {

                # if the project needs to be completed before the
                # actual hard deadline, then the project deadline 
                # has precedence. However, sometimes the project is
                # ongoing, so we have to make sure that there actually
                # is an end_date_j

                # commented out: we need to trust the user. If they
                # set the deadline outside the project deadline,
                # that's their business
                
                #if {![empty_string_p $end_date_j]} {
                #    if {$end_date_j < $latest_finish($task_item)} {
                #        set latest_finish($task_item) $end_date_j
                #    }
                #}

                # we also set the latest_start date

                if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                    set activity_time($task_item) 0
                    ns_log Notice "setting activity_time($task_item) 0"
                }

                set late_start_temp \
                    [latest_start \
                         -end_date_j $latest_finish($task_item) \
                         -hours_to_complete $activity_time($task_item) \
                         -hours_day $hours_day]
                
                if {$late_start_temp < $latest_start($task_item)} {
                    set latest_start($task_item) $late_start_temp
                }

            } else {

                # this section is for items that have no solid
                # deadline, but also have no items dependent on them

                # we either set the latest start and finish of the item or
                # we specify that the task is an ongoing task
                if {[empty_string_p $end_date_j]} {
                    set ongoing_task($task_item) true

                    if {[string is true $debug]} {
                        ns_log Notice "NSDBAHNITD: end_date_j was empty ti:$task_item"
                    }
                } else {
                    set latest_finish($task_item) $end_date_j

                    if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                        set activity_time($task_item) 0
                        ns_log Notice "setting activity_time($task_item) 0 (location 2)"
                    }

                    set latest_start($task_item) \
                        [latest_start \
                             -end_date_j $latest_finish($task_item) \
                             -hours_to_complete $activity_time($task_item) \
                             -hours_day $hours_day]
                    
                }
            }
            lappend present_tasks $task_item

            if {[string is true $debug] && [exists_and_not_null latest_start($task_item)]} {
                ns_log Notice "preliminary latest_start($task_item): $latest_start($task_item)"
            }

            if {[string is true $debug] && [exists_and_not_null latest_finish($task_item)]} {
                ns_log Notice "preliminary latest_finish($task_item): $latest_finish($task_item)"
            }



        } else {
            if {[string is true $debug]} {
                ns_log Notice " info exists dependent($task_item)"
            }
        }
    }


    # -------------------------------
    # stop if we have no dependencies
    # -------------------------------
    if {[llength $present_tasks] == 0} {
        if {[string is true $debug]} {
            ns_log Notice "No tasks with dependencies"
        }
        return [list]
    }

    if {[string is true $debug]} {
        ns_log Notice "LATEST present_tasks: $present_tasks"
    }

    # ------------------------------------------------------
    # figure out the latest start and finish times
    # ------------------------------------------------------

    while {[llength $present_tasks] > 0} {

        set future_tasks [list]

        foreach task_item $present_tasks {

            if {[string is true $debug]} {
                ns_log Notice "this task_item: $task_item"
            }

            # -----------------------------------------------------
            # some tasks may already have latest_start filled in.
            # the first run of tasks, for example, had their values
            # filled in earlier
            # -----------------------------------------------------

            if {[info exists dependent($task_item)]} {

                if {[string is true $debug]} {
                    ns_log Notice " info exists for dependent($task_item)"
                }

                # ---------------------------------------------
                # set the latest_start for this task = 
                # min(latest_start(i+1) - activity_time(i))
                #
                # (i+1 means an item that depends on this task)
                # (i means this task)
                # ---------------------------------------------

                # we set this to the end date, and then move it forward
                # as we find dependent items that have earlier
                # latest_start dates. The problem is that the
                # end_date_j is empty when there is no deadline.
                # So we need to remember that min_latest_start can
                # be an empty value

                set min_latest_start $end_date_j
                
                if {[string is true $debug]} {
                    ns_log Notice " min_latest_start:  $end_date_j"
                }

                foreach dependent_item $dependent($task_item) {

                    if {[string is true $debug]} {
                        ns_log Notice " dependent_item: $dependent_item"
                    }
                                    
                    if {[exists_and_not_null ongoing_task($dependent_item)]} {
                        set defer_p f
                        set my_latest_start ""

                        if {[string is true $debug]} {
                            ns_log Notice " ongoing_task, no defer"
                        }
                        
                    } elseif {![exists_and_not_null latest_start($dependent_item)]} {
                        # we defer the task if the dependent item has no
                        # latest_start date set 

                        if {[info exists defer_count($task_item)]} {
                            incr defer_count($task_item)
                        } else {
                            set defer_count($task_item) 1
                        }

                        # we use a magic number here.
                        # basically, we don't want to defer the
                        # item forever. Ideally, this should
                        # be cleaned up better. Defering is necessary
                        # given this algorithm, but there are
                        # times when you don't want to defer.
                        # This is hackish, and I'm embarrased, but on
                        # a deadline. :(
                        if {$defer_count($task_item) > 5} {
                            set defer_p f

                                if {[string is true $debug]} {
                                    ns_log Notice " no defer because defer count exceeded"
                                }
                        } else {
                            lappend future_tasks $task_item

                            if {[string is true $debug]} {
                                ns_log Notice " defer"
                            }

                            set defer_p t
                        }
                        


                    } else {
                        
                        # the dependent item has a deadline
                        
                        if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                            set activity_time($task_item) 0
                            ns_log Notice "setting activity_time($task_item) 0 (location 3)"
                        }

                        set my_latest_start \
                            [latest_start \
                                 -end_date_j $latest_start($dependent_item) \
                                 -hours_to_complete $activity_time($task_item) \
                                 -hours_day $hours_day]
                        
                        if {[string is true $debug]} {
                            ns_log Notice " my_latest_start: $my_latest_start"
                        }

                        # we also only want to move forward the latest_start
                        # date if the dependent item is not already completed!

                        if {$task_percent_complete($dependent_item) < 100} {
                            if {[exists_and_not_null min_latest_start]} {
                                if {$my_latest_start < $min_latest_start} {
                                    set min_latest_start $my_latest_start
                                }
                            } else {
                                set min_latest_start $my_latest_start
                            }
                        }
                        
                        set defer_p f
                    }
                    
                }
                
                if {[string equal $defer_p f]} {
                    
                    # we check that latest_start doesn't already exist
                    # which it might for hard-deadlines

                    # we have to be fairly careful here. We want to
                    # set the latest_start date to the minimum
                    # latest_start, but only when min_latest_start
                    # actually has a value

                    if {[exists_and_not_null latest_start($task_item)]} {

                        if {[exists_and_not_null min_latest_start]} {
                        
                            if {$min_latest_start < $latest_start($task_item)} {
                                set latest_start($task_item) $min_latest_start
                            }
                            
                        } else {

                            if {[string is true $debug]} {
                                ns_log notice " setting latest start date (ignoring min_latest_start"
                            }

                            if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                                set activity_time($task_item) 0
                                ns_log Notice "setting activity_time($task_item) 0 (location 4)"
                            }


                            set latest_start($task_item) \
                                [latest_start \
                                     -end_date_j $latest_finish($task_item) \
                                     -hours_to_complete $activity_time($task_item) \
                                     -hours_day $hours_day]

                        }
                    } else {

                        # so this task has no hard deadline.
                        # We now set the value to the minimum of the
                        # dependent tasks. Note that if the dependent
                        # tasks all have no hard deadlines, and the
                        # project is ongoing, then the value will be
                        # set to ""

                        set latest_start($task_item) $min_latest_start
                    }

                    if {[string is true $debug]} {
                        ns_log Notice " min_latest_start: $min_latest_start"
                    }

                    # we now set the latest finish. Ongoing tasks set
                    # the latest finish to empty (sometimes)
                    if {[empty_string_p $latest_start($task_item)]} {
                        set temp_lf ""
                    } else {
                        set temp_lf [my_latest_finish $min_latest_start $activity_time($task_item) $hours_day]
                    }

                    # if there is already a hard deadline for this
                    # task, then we check whether temp_lf is earlier,
                    # and set it to temp_lf if so
                    
                    if {[string is true $debug]} {
                        ns_log Notice " temp_lf: $temp_lf"
                    }

                    if {[empty_string_p $temp_lf]} {
                        
                        # if the task is ongoing, we clear the
                        # latest_finish. Otherwise, we leave the
                        # latest_finish as it is.
                        
                        if {[exists_and_not_null ongoing_task($task_item)] && [string is true $ongoing_task($task_item)]} {
                            set latest_finish($task_item) ""
                        }

                    } else {
                        if {[exists_and_not_null latest_finish($task_item)]} {
                            if {$temp_lf < $latest_finish($task_item)} {
                                set latest_finish($task_item) $temp_lf
                            }
                        } else {
                            set latest_finish($task_item) $temp_lf
                        }
                    }
                    
                    if {[string is true $debug]} {
                        if {[exists_and_not_null latest_start($task_item)]} {
                            ns_log Notice \
                                " latest_start ($task_item): $latest_start($task_item)"
                        }
                        if {[exists_and_not_null latest_finish($task_item)]} {
                            ns_log Notice \
                                " latest_finish($task_item): $latest_finish($task_item)"
                        }
                    }

                } else {
                    if {[string is true $debug]} {
                        ns_log Notice "Deferring $task_item"
                    }
                }
            }    

            # -------------------------------
            # add to list of tasks to process
            # -------------------------------

            if {[info exists depends($task_item)]} {
                set future_tasks [concat $future_tasks $depends($task_item)]
            }
        }

        if {[string is true $debug]} {
            ns_log Notice "future tasks: $future_tasks"
        }

        set present_tasks $future_tasks
    }

    # ----------------------------------------------
    # set up latest start date for project
    # ----------------------------------------------

    if {[empty_string_p $end_date_j]} {
        set min_latest_start ""
        set max_earliest_finish ""
    } else {
        set min_latest_start $end_date_j
        
        foreach task_item $task_list {

            if {[string is true $debug]} {
                ns_log Notice "* LS ($task_item): $latest_start($task_item)"
            }

            if {[exists_and_not_null earliest_finish($task_item)] && $min_latest_start > $latest_start($task_item)} {
                set max_earliest_finish $earliest_finish($task_item)
            }
        }

        set max_earliest_finish "J[expr floor([set max_earliest_finish])]"
        set min_latest_start    "J[expr floor([set min_latest_start])]"
    }

    
    # estimated_finish_date
    # latest_finish 

    db_dml update_project { }

    # now we go through and save all the values for the tasks!
    # this is very inefficient and stupid

    foreach task_item $task_list {

        if {[exists_and_not_null earliest_start($task_item)]} {
            set es "J[expr ceil( [set earliest_start($task_item)])]"
        } else {
            set es ""
        }

        if {[exists_and_not_null earliest_finish($task_item)]} {
            set ef "J[expr ceil( [set earliest_finish($task_item)])]"
        } else {
            set ef ""
        }

        if {[exists_and_not_null latest_start($task_item)]} {
            set ls "J[expr floor([set latest_start($task_item)])]"
        } else {
            set ls ""
        }

        if {[exists_and_not_null latest_finish($task_item)]} {
            set lf "J[expr floor($latest_finish($task_item))]"
        } else {
            set lf ""
        }

        # Only update the task if something has actually
        # changed. Hopefully this should help speed things up.
        
        if { \
                 [string equal $es $old_ES_j($task_item)] && \
                 [string equal $ef $old_EF_j($task_item)] && \
                 [string equal $ls $old_LS_j($task_item)] && \
                 [string equal $lf $old_LF_j($task_item)]} {
            # do nothing
        } else {
            db_dml update_task { }
        }
        

    }


    if {[string is true $debug]} {
        ns_log Notice "*******************"
    }

    return $task_list

}




ad_proc -public pm::project::compute_parent_status {project_item_id} {

    When a project is updated, or a task updated within a project, we need to 
    update all the projects higher in the hierarchy.

    This may need to be fixed to add back in subproject support.
} {
    set package_id [pm::util::package_id]

    # ns_log Notice "computing parents for $project_item_id and package_id: $package_id"


    set my_item_id $project_item_id
    set parent_id [db_string get_parent_id {}]
    set last_item_id $my_item_id

    # trace up the hierarchy until we get one below the root

    set root_folder [db_exec_plsql get_root_folder { }]

    while {$parent_id != $root_folder && $parent_id != "-1"} {
        set parent_id [db_string get_parent_id {} -default "-1"]
        set last_item_id $my_item_id
        set my_item_id $parent_id
    }

    # ns_log Notice "root: $root_folder , last_item_id $last_item_id"

    set return_code [pm::project::compute_status $last_item_id]

    return $return_code
}



ad_proc -public pm::project::get_project {
    -logger_project:required
} {
    Returns the project_item_id when given the logger project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-28
    
    @param logger_project

    @return project_item_id
    
    @error 
} {
    set project_id [application_data_link::get_linked -from_object_id $logger_project -to_object_type "pm_project"]
    if {[empty_string_p $project_id]} {
	return "no project"
    } else {
	return $project_id    
    }
}


ad_proc -public pm::project::get_list_of_open {
    {-object_package_id ""}
} {
    Returns a list of lists, of all open project ids and their names.
    If object_package_id is provided then it returns all open projects
    with the same object_package_id value.

    We should util_memoize this. It will dramatically improve the
    speed of the task edits.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-05-13
    
    @return list of lists, with project id and name
    
    @error 
} {
    set extra_query ""
    if { ![empty_string_p $object_package_id] } {
	set extra_query "p.object_package_id = :object_package_id and"
    }
    set return_val [db_list_of_lists get_vals " "]
    
    return $return_val
}


ad_proc -public pm::project::select_list_of_open {
    {-selected ""}
} {
    Returns a select list of all open project ids and their names
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-13
    
    @return html for select list of open projects
    
    @error 
} {
    # is the selected project closed?
    set open_p [pm::project::open_p -project_item_id $selected]

    if {[string is false $open_p]} {
        set name [pm::project::name -project_item_id $selected]
        set html "<option value=\"$selected\">$name</option>"
    } else {
        set html ""
    }

    set list_of_lists [pm::project::get_list_of_open]

    foreach lol $list_of_lists {
        set name [lindex $lol 0]
        set id   [lindex $lol 1]

        if {[string equal $id $selected]} {
            set sel "selected=\"selected\""
        } else {
            set sel ""
        }

        append html "<option $sel value=\"$id\">$name</option>\n"
    }

    return $html
}


ad_proc -public pm::project::close {
    {-project_item_id:required}
    -no_callback:boolean
} {
    Closes a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-02
    
    @param project_item_id

    @return 
    
    @error 
} {

    set closed_id [pm::status::default_closed]
    
    db_dml update_status {
        UPDATE
        pm_projects
        SET 
        status_id = :closed_id
        WHERE
        project_id in (select live_revision from cr_items where item_id = :project_item_id)
    }

    if {!$no_callback_p} {
	callback pm::project_close -package_id [ad_conn package_id] -project_id $project_item_id
    }
}


ad_proc -public pm::project::open_p {
    {-project_item_id:required}
} {
    Returns true if the project is open
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-03
    
    @param project_item_id

    @return 1 if open, 0 if closed
    
    @error 
} {
    set return_val [db_string get_open_or_closed {
        SELECT
        case when status_type = 'c' then 0 else 1 end
        FROM
        pm_projectsx p,
        cr_items i,
        pm_project_status s
        WHERE
        i.item_id = p.item_id and
        i.live_revision = p.revision_id and
        p.status_id = s.status_id and
        p.item_id = :project_item_id
    } -default "0"]

    return $return_val
}


ad_proc -public pm::project::get_status_description {
    {-project_item_id:required}
} {
    get the project status description
} {
    return [db_string project_status {} -default ""]
}


ad_proc -public pm::project::assign {
    {-project_item_id:required}
    {-role_id:required}
    {-party_id:required}
    {-send_email_p "t"}
} {
    Assigns a user to a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param project_item_id

    @param role_id 

    @param party_id

    @return 
    
    @error 
} {

    db_dml insert_assignment {
        insert into pm_project_assignment
        (project_id, role_id, party_id)
        VALUES
        (:project_item_id, :role_id, :party_id)
        }
        
    # Flush the cache that remembers which roles to offer the current user in the 'assign role to myself' listbox
    util_memoize_flush [list pm::role::project_select_list_filter_not_cached -project_item_id $project_item_id -party_id $party_id]

    if {[string is true $send_email_p]} {

        set project_name [pm::project::name \
                              -project_item_id $project_item_id]
        
        set project_url [pm::project::url \
                             -project_item_id $project_item_id]
        
        set to_addr [cc_email_from_party $party_id]
        set from_addr [cc_email_from_party [ad_conn user_id]]
        set role [pm::role::name -role_id $role_id]

        set subject "[_ project-manager.lt_Assigned_to_project_p]"
        
        set content "<table bgcolor=\"\#ddffdd\"><tr><td>[_ project-manager.lt_You_have_been_assigne]</td></tr></table>"


        pm::util::email \
            -to_addr $to_addr \
            -from_addr $from_addr \
            -subject $subject \
            -body $content \
            -mime_type "text/html"
    }

    return
}


ad_proc -public pm::project::unassign {
    {-project_item_id:required}
    {-party_id:required}
} {
    Removes a user from a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param project_item_id

    @param party_id

    @return 
    
    @error 
} {

    db_dml remove_assignment {
        DELETE FROM
        pm_project_assignment 
        WHERE
        project_id = :project_item_id and
        party_id   = :party_id
    }

    # Flush the cache that remembers which roles to offer the current user in the 'assign role to myself' listbox
    if {[ad_conn user_id == $party_id]} {
        util_memoize_flush [list pm::role::project_select_list_filter_not_cached -project_item_id $project_item_id -party_id $party_id]
    }

    return
}


ad_proc -public pm::project::assign_remove_everyone {
    {-project_item_id:required}
} {
    Removes all users from a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param project_item_id

    @return party_ids of all users removed from the project
    
    @error 
} {

    set current_assignees [db_list get_assignees {
        SELECT
        party_id
        FROM
        pm_project_assignment
        WHERE
        project_id = :project_item_id
    }]

    db_dml remove_assignment {
        DELETE FROM
        pm_project_assignment 
        WHERE
        project_id = :project_item_id
    }

    # Flush the cache that remembers which roles to offer the current user in the 'assign role to myself' listbox
    util_memoize_flush [list pm::role::project_select_list_filter_not_cached -project_item_id $project_item_id -party_id [ad_conn user_id]]
    return $current_assignees
}

ad_proc -public pm::project::assignee_role_list {
    {-project_item_id:required}
} {
    Returns a list of lists, with all assignees to a particular 
    project. {{party_id role_id} {party_id role_id}}

    @author Malte Sussdorff (openacs@sussdorff.de)
    @creation-date 2005-05-14
    
    @param project_item_id

    @return 
    
    @error 
} {

    return [db_list_of_lists get_assignees_roles { }]

}

ad_proc -public pm::project::assignee_filter_select {
    {-status_id ""}
} {
    Returns a list of lists, people who are assigned to projects with a 
    status of status_id. Used in the list-builder filters for
    the projects list page. Cached 10 minutes.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param status_id

    @return 
    
    @error 
} {
    return [util_memoize [list pm::project::assignee_filter_select_helper -status_id $status_id] 600]
}


ad_proc -private pm::project::assignee_filter_select_helper {
    {-status_id ""}
} {
    Returns a list of lists, people who are assigned projects with a 
    status of status_id. Used in the list-builder filters for
    the projects list page. Cached 5 minutes.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    
    @param status_id

    @return 
    
    @error 
} {

    if {[exists_and_not_null status_id]} {
	set status_clause "p.status_id = :status_id and"
    } else {
	set status_clause ""
    }

    return [db_list_of_lists get_people "
SELECT
        distinct(first_names || ' ' || last_name) as fullname, 
        u.person_id 
        FROM
        persons u, 
        pm_project_assignment a,
        pm_projects p, 
        cr_items i
        WHERE 
        u.person_id = a.party_id and
        i.item_id = a.project_id and
	$status_clause
        i.live_revision = p.project_id
        ORDER BY
        fullname
    "]
}


ad_proc -public pm::project::assignee_email_list {
    -project_item_id:required
} {
    Returns a list of assignee email addresses

    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-30
    
    @param project_item_id

    @return 
    
    @error 
} {

    return [db_list get_addresses {
        SELECT
        p.email
        FROM 
        parties p,
        pm_project_assignment a
        WHERE
        a.project_id = :project_item_id and
        a.party_id = p.party_id
    }]

}


ad_proc -public pm::project::assigned_p {
    -project_item_id:required
    -party_id:required
} {
    Returns 1 if user has been assigned to a project

    @author Richard Hamilton (ricky.hamilton@btopenworld.com)
    @creation-date 2004-12-17
    
    @param project_item_id
    
    @param party_id

    @return
    
    @error 
} {

    return [db_0or1row assigned_p {
        SELECT
        party_id
        FROM
        pm_project_assignment
        WHERE
        project_id = :project_item_id and
        party_id = :party_id
        LIMIT 1
    }]

}


ad_proc -public pm::project::name {
    -project_item_id
    -project_id
} {
    Returns the name for a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-01
    
    @param project_item_id

    @return 
    
    @error 
} {

    if {[exists_and_not_null project_item_id]} {
        return [db_string get_name {
            SELECT
            title
            FROM
            cr_revisions p,
            cr_items i
            WHERE
            i.live_revision = p.revision_id
            and i.item_id = :project_item_id
        } -default ""]
    } else {
        return [db_string get_name {
            SELECT
            title
            FROM
            pm_projectsx
            WHERE
            project_id = :project_id
        } -default ""]
    }
}        
    

ad_proc -public pm::project::url {
    -project_item_id:required
} {
    Returns the URL for a project, when given the project_item_id
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-07-01
    
    @param project_item_id

    @return 
    
    @error 
} {

    return "[ad_url][ad_conn package_url]one?project_item_id=$project_item_id"
    
}


ad_proc -public pm::project::one_default_orderby {
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
        
        set default_orderby "latest_start,asc"
        
        set return_val [ad_get_client_property \
                            -default $default_orderby \
                            -- \
                            project-manager \
                            project-one-orderby]
        
        return $return_val

    } else {

        ad_set_client_property -- project-manager project-one-orderby $set
        return $set

    }
}


ad_proc -public pm::project::index_default_orderby {
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
        
        set default_orderby "project_name,asc"
        
        set return_val [ad_get_client_property \
                            -default $default_orderby \
                            -- \
                            project-manager \
                            project-index-orderby]
        
        return $return_val

    } else {
	
        ad_set_client_property -- project-manager project-index-orderby $set
        return $set
	
    }
}



ad_proc -public pm::project::compute_status_mins {
    project_item_id
} {
    Compute status of project according to mins on the dates.
} {
    set debug 0
    set hours_day [pm::util::hours_day]
    
    
    # -------------------------
    # get subprojects and tasks
    # -------------------------
    set task_list            [list]
    set task_list_project    [list]
    
    foreach sub_item [db_list_of_lists select_project_children { }] {
        set my_id   [lindex $sub_item 0]
        set my_type [lindex $sub_item 1]

        if {[string equal $my_type "pm_project"]} {

            # ---------------------------------------------
            # gets all tasks that are a part of subprojects
            # ---------------------------------------------
            set project_return [pm::project::compute_status $my_id]
            set task_list_project [concat $task_list_project $project_return]

        } elseif {[string equal $my_type "pm_task"]} {
            lappend task_list    $my_id
        }
    }

    set task_list [concat $task_list $task_list_project]

    if {[string is true $debug]} {
        ns_log Notice "Tasks in this project (task_list): $task_list"
    }
    
    # -------------------------
    # no tasks for this project
    # -------------------------
    if {[llength $task_list] == 0} {
        return [list]
    }
    
    # --------------------------------------------------------------
    # we now have list of tasks that includes all subprojects' tasks
    # --------------------------------------------------------------
    
    # returns actual_hours_completed, estimated_hours_total, and
    # today (julian date for today)
    db_1row tasks_group_query { }
    
    if {[string is true $debug]} {
        ns_log notice "Today's date (julian format): $today"
    }
    
    # --------------------------------------------------------------
    # Set up activity_time for all tasks
    # Also set up deadlines for tasks that have hard-coded deadlines
    # --------------------------------------------------------------
    
    if {[string is true $debug]} {
        ns_log notice "Going through tasks and saving their values"
    }
    
    db_foreach tasks_query { } {
	
        # We now save information about all the tasks, so that we can
        # save on database hits later. Specifically, what we'll do is
        # we won't need to save changes if the earliest_start,
        # earliest finish, latest_start and latest_finish all haven't
        # changed at all. We also save whether the task is open (o) or
        # closed(c).
	
        set old_ES($my_iid) $old_earliest_start
        set old_EF($my_iid) $old_earliest_finish
        set old_LS($my_iid) $old_latest_start
        set old_LF($my_iid) $old_latest_finish
        set task_percent_complete($my_iid) $my_percent_complete
	
        set activity_time($my_iid) [expr [expr $to_work * [expr 100 - $my_percent_complete] / 100]]
	
        if {[exists_and_not_null task_deadline]} {
	    
            if {[string is true $debug]} {
                ns_log notice "$my_iid has a deadline (julian: $task_deadline)"
            }
	    
	    set latest_finish($my_iid) $task_deadline
	    set hours_to_complete $activity_time($my_iid) 
	    
	    set date [lindex [split $task_deadline " "] 0]
	    set hours [lindex [split [lindex [split $task_deadline " "] 1] :] 0]
	    set mins  [lindex [split [lindex [split $task_deadline " "] 1] :] 1]
	    set mins [expr ($hours*60) + $mins]
	    
	    set date_j [dt_ansi_to_julian_single_arg $date]
	    set today_j $date_j
	    set mins_to_complete [expr $hours_to_complete * 60]
	    set t_total_mins $mins_to_complete 
	    
	    
	    
	    while { $mins_to_complete > [expr $hours_day * 60]} {
		
		set  [expr $today_j - 1]
		
		# if it is a holiday, don't subtract from total time
		
		if {[is_workday_p $t_today]} {
		    set t_total_mins [expr $t_total_mins - [expr $hours_day * 60]]
		}
		
	    }
	    
	    set t_mins [expr $mins - $t_total_mins]
	    set hours [expr round ($t_mins/60)]
	    set t_mins [expr round($t_mins) % 60]
            set latest_start($my_iid) "[dt_julian_to_ansi $date_j] $hours:$t_mins"
            
        }
    }
    
    # --------------------------------------------------------------------
    # We need to keep track of all the dependencies so we can meaningfully
    # compute deadlines, earliest start times, etc..
    # --------------------------------------------------------------------
    
    db_foreach dependency_query { } {
	
        # task_item_id depends on parent_task_id
        lappend depends($task_item_id) $parent_task_id
	
        # parent_task_id is dependent on task_item_id
        lappend dependent($parent_task_id) $task_item_id
	
        set dependency_types($task_item_id-$parent_task_id) $dependency_type
	
	if {[string is true $debug]} {
	    ns_log Notice "dependency (id: $dependency_id) task: $task_item_id parent: $parent_task_id type: $dependency_type"
	}
    }
    
    
    # --------------------------------------------------------------
    # need to get some info on this project, so that we can base the
    # task information off of them
    # --------------------------------------------------------------
    
    # gives up end_date, start_date, and ongoing_p
    # if ongoing_p is t, then end_date should be null
    db_1row project_info { }
    
    if {[string is true $ongoing_p] && ![empty_string_p $end_date]} {
        ns_log Error "Project cannot be ongoing and have a non-null end-date. Setting end date to blank"
        set end_date ""
    }
    
    
    # --------------------------------------------------------------
    # task_list contains all the tasks
    # a subset of those do not depend on any other tasks
    # --------------------------------------------------------------
    
    # ----------------------------------------------------------------------
    # we want to go through and fill in all the values for earliest start.
    # the brain-dead, brute force way of doing this, would be go through the
    # task_list length(task_list) times, and each time, compute the values
    # for each item that depends on one of those tasks. This is extremely
    # inefficient.
    # ----------------------------------------------------------------------
    # Instead, we create two lists, one is of tasks we just added 
    # earliest_start values for, the next is a new list of ones we're going to
    # add earliest_start values for. We call these lists 
    # present_tasks and future_tasks
    # ----------------------------------------------------------------------

    set present_tasks [list]
    set future_tasks  [list]

    # -----------------------------------------------------
    # make a list of tasks that don't depend on other tasks
    # -----------------------------------------------------
    # while we're at it, save earliest_start and earliest_finish
    # info for these items
    # -----------------------------------------------------

    foreach task_item $task_list {

        if {![info exists depends($task_item)]} {

            set earliest_start($task_item) $start_date
	    
	    set date [lindex [split $earliest_start($task_item) " "] 0]
	    set hours [lindex [split [lindex [split $earliest_start($task_item) " "] 1] :] 0]
	    set mins  [lindex [split [lindex [split $earliest_start($task_item) " "] 1] :] 1]
	    set mins [expr ($hours*60) + $mins]
	    
	    set date_j [dt_ansi_to_julian_single_arg $date]
	    set today_j $date_j
	    set mins_to_complete [expr $activity_time($task_item) * 60]
	    set t_total_mins $mins_to_complete 
	    
	    
	    while { $mins_to_complete > [expr $hours_day * 60]} {
		
		set today_j [expr $today_j + 1]
		
		# if it is a holiday, don't subtract from total time
		
		if {[is_workday_p $today_j]} {
		    set t_total_mins [expr $t_total_mins + [expr $hours_day * 60]]

	    
		}
		
	    }
	    
	    set t_mins [expr $mins + $t_total_mins]
	    if { $t_mins > 60 } {
		set hours [expr round ($t_mins/60)]
	    } else {
		set hours 0
	    }
	    set t_mins [expr round($t_mins) % 60]
            set earliest_finish($task_item) "[dt_julian_to_ansi $date_j] $hours:$t_mins"

            lappend present_tasks $task_item

            if {[string is true $debug]} {
                ns_log Notice "preliminary earliest_start($task_item): $earliest_start($task_item)"
            }
        }
    }

    # -------------------------------
    # stop if we have no dependencies
    # -------------------------------
    if {[llength $present_tasks] == 0} {

        if {[string is true $debug]} {
            ns_log Notice "No tasks with dependencies"
        }

        return [list]
    }

    if {[string is true $debug]} {
        ns_log Notice "present_tasks: $present_tasks"
    }

    # ------------------------------------------------------
    # figure out the earliest start and finish times
    # ------------------------------------------------------

    while {[llength $present_tasks] > 0} {

        set future_tasks [list]

        foreach task_item $present_tasks {

            if {[string is true $debug]} {
                ns_log Notice "-this task_item: $task_item"
            }

            # -----------------------------------------------------
            # some tasks may already have earliest_start filled in
            # the first run of tasks, for example, had their values
            # filled in earlier
            # -----------------------------------------------------

            if {![exists_and_not_null earliest_start($task_item)]} {

                if {[string is true $debug]} {
                    ns_log Notice " !info exists for $task_item"
                }

                # ---------------------------------------------
                # set the earliest_start for this task = 
                # max(activity_time(i-1) + earliest_start(i-1))
                #
                # (i-1 means an item that this task depends on)
                # ---------------------------------------------

                set max_earliest_start 0

                # testing if this fixes the bug
                if {![exists_and_not_null depends($task_item)]} {
                    set depends($task_item) [list]
                }

                foreach dependent_item $depends($task_item) {

                    set my_earliest_start [my_earliest_start $earliest_start($dependent_item) $activity_time($dependent_item) $hours_day]

                    if {$my_earliest_start > $max_earliest_start} {
                        set max_earliest_start $my_earliest_start
                    }
                }

                set earliest_start($task_item) $max_earliest_start

                set earliest_finish($task_item) [earliest_finish $max_earliest_start $activity_time($task_item) $hours_day]

                if {[string is true $debug]} {
                    ns_log Notice \
                        " earliest_start ($task_item): $earliest_start($task_item)"
                    ns_log Notice \
                        " earliest_finish($task_item): $earliest_finish($task_item)"
                }

            }

            # -------------------------------
            # add to list of tasks to process
            # -------------------------------

            if {[info exists dependent($task_item)]} {
                set future_tasks [concat $future_tasks $dependent($task_item)]
            }
        }

        if {[string is true $debug]} {
            ns_log Notice "future tasks: $future_tasks"
        }

        set present_tasks $future_tasks
    }

    # ----------------------------------------------
    # set up earliest date project will be completed
    # ----------------------------------------------

    set max_earliest_finish $today

    foreach task_item $task_list {

        if {[string is true $debug] && [exists_and_not_null earliest_finish($task_item)]} {
            ns_log Notice "* EF: ($task_item): $earliest_finish($task_item)"
        }
        
        if {[exists_and_not_null earliest_finish($task_item)] && $max_earliest_finish < $earliest_finish($task_item)} {
            set max_earliest_finish $earliest_finish($task_item)
        }

    }


    # -----------------------------------------------------------------
    # Now compute latest_start and latest_finish dates.
    # Note the latest_finish dates may be set to an arbitrary deadline.
    # Also note that it is possible for a project to be ongoing.
    # In that case, the latest_start and latest_finish dates should
    # be set to null, unless there is a hard deadline (end_date).
    # -----------------------------------------------------------------
    # If these represent the dependency hierarchy:
    #               2155
    #             /  |   \
    #         2161  2173  2179
    #          |           |
    #         2167        2195
    # ----------------------------------------------------------------------
    # we want to go through and fill in all the values for latest start
    # and latest_finish.
    # the brain-dead, brute force way of doing this, would be go through the
    # task_list length(task_list) times, and each time, compute the values
    # for each item that depends on one of those tasks. This is extremely
    # inefficient.
    # ----------------------------------------------------------------------
    # Instead, we create two lists, one is of tasks we just added 
    # latest_finish values for, the next is a new list of ones we're going to
    # add latest_finish values for. We call these lists 
    # present_tasks and future_tasks
    # ----------------------------------------------------------------------
    # Here's a description of the algorithm.
    # 1. The algorithm starts with those tasks that don't have other 
    # tasks depending on them. 
    # 
    # So in the example above, we'll start with 
    #   present_tasks: 2167 2173 2195
    #   future tasks: 
    #
    # 2. While we make the present_tasks list, we store latest_start
    # and latest_finish information for each of those tasks. If the
    # project is ongoing, then we also keep track of tasks that have
    # no latest_start or latest_finish. We keep this in the
    # ongoing_task(task_id) array. If is exists, then we know that
    # that task is an ongoing task, so no deadline will exist for it.
    #
    # 3. Stop if we don't have any dependencies
    # 
    # 4. Then we get into a loop.
    #    While there are present_tasks:
    #      Create the future_tasks list
    #      For each present task:
    #        If the task has a dependent task:
    #          Go through these dependent tasks:
    #            If the dependent task is ongoing don't defer
    #            If the dependent task doesn't have LS set,
    #             then defer, and add to future_tasks list
    #            Otherwise set the LS value for that task
    #          If there are no deferals, get the minimum LS of
    #          dependents, set LF 
    #        Add the dependent tasks to the future_tasks
    #      Set present_tasks equal to future_tasks, clear future_tasks

    # ----------------------------------------------------------------------
    # The biggest problem with this algorithm is that you can have items at 
    # two different levels in the hierarchy. 
    # 
    # if you trace through this algorithm, you'll see that we'll get to 2155
    # before 2161's values have been set, which can cause an error. The 
    # solution we arrive at is to defer to the future_tasks list any item
    # that causes an error. That should work.

    set present_tasks [list]
    set future_tasks  [list]

    # -----------------------------------------------------
    # make a list of tasks that don't have tasks depend on them
    # -----------------------------------------------------
    # while we're at it, save latest_start and latest_finish
    # info for these items
    # -----------------------------------------------------

    if {[string is true $debug]} {
        ns_log Notice "Starting foreach task-item $task_list"
    }

    foreach task_item $task_list {
	
        if {![info exists dependent($task_item)]} {
	    
            if {[string is true $debug]} {
                ns_log Notice " !info exists dependent($task_item)"
            }
	    
            # we check this because some tasks already have
            # hard deadlines set. 
            if {[info exists latest_finish($task_item)]} {

                # if the project needs to be completed before the
                # actual hard deadline, then the project deadline 
                # has precedence. However, sometimes the project is
                # ongoing, so we have to make sure that there actually
                # is an end_date

                # commented out: we need to trust the user. If they
                # set the deadline outside the project deadline,
                # that's their business
                
                #if {![empty_string_p $end_date]} {
                #    if {$end_date < $latest_finish($task_item)} {
                #        set latest_finish($task_item) $end_date
                #    }
                #}

                # we also set the latest_start date

                if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                    set activity_time($task_item) 0
                    ns_log Notice "setting activity_time($task_item) 0"
                }
		
		
		set hours_to_complete $activity_time($task_item) 
		
		set date [lindex [split $latest_finish($task_item) " "] 0]
		set hours [lindex [split [lindex [split $latest_finish($task_item) " "] 1] :] 0]
		set mins  [lindex [split [lindex [split $latest_finish($task_item) " "] 1] :] 1]
		set mins [expr ($hours*60) + $mins]
		
		set date_j [dt_ansi_to_julian_single_arg $date]
		set today_j $date_j
		set mins_to_complete [expr $hours_to_complete * 60]
		set t_total_mins $mins_to_complete 
		
		
		
		while { $mins_to_complete > [expr $hours_day * 60]} {
		
		    set  [expr $today_j - 1]
		    
		    # if it is a holiday, don't subtract from total time
		    
		    if {[is_workday_p $t_today]} {
			set t_total_mins [expr $t_total_mins - [expr $hours_day * 60]]
		    }
		    
		}
		
		set t_mins [expr $mins - $t_total_mins]
		set hours [expr round ($t_mins/60)]
		set t_mins [expr round($t_mins) % 60]
		set late_start_temp "[dt_julian_to_ansi $date_j] $hours:$t_mins"
                
                if {$late_start_temp < $latest_start($task_item)} {
                    set latest_start($task_item) $late_start_temp
                }

            } else {

                # this section is for items that have no solid
                # deadline, but also have no items dependent on them

                # we either set the latest start and finish of the item or
                # we specify that the task is an ongoing task
                if {[empty_string_p $end_date]} {
                    set ongoing_task($task_item) true

                    if {[string is true $debug]} {
                        ns_log Notice "NSDBAHNITD: end_date was empty ti:$task_item"
                    }
                } else {
                    set latest_finish($task_item) $end_date

                    if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                        set activity_time($task_item) 0
                        ns_log Notice "setting activity_time($task_item) 0 (location 2)"
                    }

                    set latest_start($task_item) \
                        [latest_start \
                             -end_date $latest_finish($task_item) \
                             -hours_to_complete $activity_time($task_item) \
                             -hours_day $hours_day]
                    
                }
            }
            lappend present_tasks $task_item

            if {[string is true $debug] && [exists_and_not_null latest_start($task_item)]} {
                ns_log Notice "preliminary latest_start($task_item): $latest_start($task_item)"
            }

            if {[string is true $debug] && [exists_and_not_null latest_finish($task_item)]} {
                ns_log Notice "preliminary latest_finish($task_item): $latest_finish($task_item)"
            }



        } else {
            if {[string is true $debug]} {
                ns_log Notice " info exists dependent($task_item)"
            }
        }
    }


    # -------------------------------
    # stop if we have no dependencies
    # -------------------------------
    if {[llength $present_tasks] == 0} {
        if {[string is true $debug]} {
            ns_log Notice "No tasks with dependencies"
        }
        return [list]
    }

    if {[string is true $debug]} {
        ns_log Notice "LATEST present_tasks: $present_tasks"
    }

    # ------------------------------------------------------
    # figure out the latest start and finish times
    # ------------------------------------------------------

    while {[llength $present_tasks] > 0} {

        set future_tasks [list]

        foreach task_item $present_tasks {

            if {[string is true $debug]} {
                ns_log Notice "this task_item: $task_item"
            }

            # -----------------------------------------------------
            # some tasks may already have latest_start filled in.
            # the first run of tasks, for example, had their values
            # filled in earlier
            # -----------------------------------------------------

            if {[info exists dependent($task_item)]} {

                if {[string is true $debug]} {
                    ns_log Notice " info exists for dependent($task_item)"
                }

                # ---------------------------------------------
                # set the latest_start for this task = 
                # min(latest_start(i+1) - activity_time(i))
                #
                # (i+1 means an item that depends on this task)
                # (i means this task)
                # ---------------------------------------------

                # we set this to the end date, and then move it forward
                # as we find dependent items that have earlier
                # latest_start dates. The problem is that the
                # end_date is empty when there is no deadline.
                # So we need to remember that min_latest_start can
                # be an empty value

                set min_latest_start $end_date
                
                if {[string is true $debug]} {
                    ns_log Notice " min_latest_start:  $end_date"
                }

                foreach dependent_item $dependent($task_item) {

                    if {[string is true $debug]} {
                        ns_log Notice " dependent_item: $dependent_item"
                    }
                                    
                    if {[exists_and_not_null ongoing_task($dependent_item)]} {
                        set defer_p f
                        set my_latest_start ""

                        if {[string is true $debug]} {
                            ns_log Notice " ongoing_task, no defer"
                        }
                        
                    } elseif {![exists_and_not_null latest_start($dependent_item)]} {
                        # we defer the task if the dependent item has no
                        # latest_start date set 

                        if {[info exists defer_count($task_item)]} {
                            incr defer_count($task_item)
                        } else {
                            set defer_count($task_item) 1
                        }

                        # we use a magic number here.
                        # basically, we don't want to defer the
                        # item forever. Ideally, this should
                        # be cleaned up better. Defering is necessary
                        # given this algorithm, but there are
                        # times when you don't want to defer.
                        # This is hackish, and I'm embarrased, but on
                        # a deadline. :(
                        if {$defer_count($task_item) > 5} {
                            set defer_p f

                                if {[string is true $debug]} {
                                    ns_log Notice " no defer because defer count exceeded"
                                }
                        } else {
                            lappend future_tasks $task_item

                            if {[string is true $debug]} {
                                ns_log Notice " defer"
                            }

                            set defer_p t
                        }
                        


                    } else {
                        
                        # the dependent item has a deadline
                        
                        if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                            set activity_time($task_item) 0
                            ns_log Notice "setting activity_time($task_item) 0 (location 3)"
                        }

                        set my_latest_start \
                            [latest_start \
                                 -end_date $latest_start($dependent_item) \
                                 -hours_to_complete $activity_time($task_item) \
                                 -hours_day $hours_day]
                        
                        if {[string is true $debug]} {
                            ns_log Notice " my_latest_start: $my_latest_start"
                        }

                        # we also only want to move forward the latest_start
                        # date if the dependent item is not already completed!

                        if {$task_percent_complete($dependent_item) < 100} {
                            if {[exists_and_not_null min_latest_start]} {
                                if {$my_latest_start < $min_latest_start} {
                                    set min_latest_start $my_latest_start
                                }
                            } else {
                                set min_latest_start $my_latest_start
                            }
                        }
                        
                        set defer_p f
                    }
                    
                }
                
                if {[string equal $defer_p f]} {
                    
                    # we check that latest_start doesn't already exist
                    # which it might for hard-deadlines

                    # we have to be fairly careful here. We want to
                    # set the latest_start date to the minimum
                    # latest_start, but only when min_latest_start
                    # actually has a value

                    if {[exists_and_not_null latest_start($task_item)]} {

                        if {[exists_and_not_null min_latest_start]} {
                        
                            if {$min_latest_start < $latest_start($task_item)} {
                                set latest_start($task_item) $min_latest_start
                            }
                            
                        } else {

                            if {[string is true $debug]} {
                                ns_log notice " setting latest start date (ignoring min_latest_start"
                            }

                            if {[string is false [exists_and_not_null activity_time($task_item)]]} {
                                set activity_time($task_item) 0
                                ns_log Notice "setting activity_time($task_item) 0 (location 4)"
                            }


                            set latest_start($task_item) \
                                [latest_start \
                                     -end_date $latest_finish($task_item) \
                                     -hours_to_complete $activity_time($task_item) \
                                     -hours_day $hours_day]

                        }
                    } else {

                        # so this task has no hard deadline.
                        # We now set the value to the minimum of the
                        # dependent tasks. Note that if the dependent
                        # tasks all have no hard deadlines, and the
                        # project is ongoing, then the value will be
                        # set to ""

                        set latest_start($task_item) $min_latest_start
                    }

                    if {[string is true $debug]} {
                        ns_log Notice " min_latest_start: $min_latest_start"
                    }

                    # we now set the latest finish. Ongoing tasks set
                    # the latest finish to empty (sometimes)
                    if {[empty_string_p $latest_start($task_item)]} {
                        set temp_lf ""
                    } else {
                        set temp_lf [my_latest_finish $min_latest_start $activity_time($task_item) $hours_day]
                    }

                    # if there is already a hard deadline for this
                    # task, then we check whether temp_lf is earlier,
                    # and set it to temp_lf if so
                    
                    if {[string is true $debug]} {
                        ns_log Notice " temp_lf: $temp_lf"
                    }

                    if {[empty_string_p $temp_lf]} {
                        
                        # if the task is ongoing, we clear the
                        # latest_finish. Otherwise, we leave the
                        # latest_finish as it is.
                        
                        if {[exists_and_not_null ongoing_task($task_item)] && [string is true $ongoing_task($task_item)]} {
                            set latest_finish($task_item) ""
                        }

                    } else {
                        if {[exists_and_not_null latest_finish($task_item)]} {
                            if {$temp_lf < $latest_finish($task_item)} {
                                set latest_finish($task_item) $temp_lf
                            }
                        } else {
                            set latest_finish($task_item) $temp_lf
                        }
                    }
                    
                    if {[string is true $debug]} {
                        if {[exists_and_not_null latest_start($task_item)]} {
                            ns_log Notice \
                                " latest_start ($task_item): $latest_start($task_item)"
                        }
                        if {[exists_and_not_null latest_finish($task_item)]} {
                            ns_log Notice \
                                " latest_finish($task_item): $latest_finish($task_item)"
                        }
                    }

                } else {
                    if {[string is true $debug]} {
                        ns_log Notice "Deferring $task_item"
                    }
                }
            }    

            # -------------------------------
            # add to list of tasks to process
            # -------------------------------

            if {[info exists depends($task_item)]} {
                set future_tasks [concat $future_tasks $depends($task_item)]
            }
        }

        if {[string is true $debug]} {
            ns_log Notice "future tasks: $future_tasks"
        }

        set present_tasks $future_tasks
    }

    # ----------------------------------------------
    # set up latest start date for project
    # ----------------------------------------------

    if {[empty_string_p $end_date]} {
        set min_latest_start ""
        set max_earliest_finish ""
    } else {
        set min_latest_start $end_date
        
        foreach task_item $task_list {

            if {[string is true $debug]} {
                ns_log Notice "* LS ($task_item): $latest_start($task_item)"
            }

            if {[exists_and_not_null earliest_finish($task_item)] && $min_latest_start > $latest_start($task_item)} {
                set max_earliest_finish $earliest_finish($task_item)
            }
        }

        set max_earliest_finish "[set max_earliest_finish]"
        set min_latest_start    "[set min_latest_start]"
    }

    
    # estimated_finish_date
    # latest_finish 

    db_dml update_project { }

    # now we go through and save all the values for the tasks!
    # this is very inefficient and stupid

    foreach task_item $task_list {

        if {[exists_and_not_null earliest_start($task_item)]} {
            set es "[set earliest_start($task_item)]"
        } else {
            set es ""
        }

        if {[exists_and_not_null earliest_finish($task_item)]} {
            set ef "[set earliest_finish($task_item)]"
        } else {
            set ef ""
        }

        if {[exists_and_not_null latest_start($task_item)]} {
            set ls "[set latest_start($task_item)]"
        } else {
            set ls ""
        }

        if {[exists_and_not_null latest_finish($task_item)]} {
            set lf "$latest_finish($task_item)"
        } else {
            set lf ""
        }

        # Only update the task if something has actually
        # changed. Hopefully this should help speed things up.
        
        if { \
                 [string equal $es $old_ES($task_item)] && \
                 [string equal $ef $old_EF($task_item)] && \
                 [string equal $ls $old_LS($task_item)] && \
                 [string equal $lf $old_LF($task_item)]} {
            # do nothing
        } else {
            db_dml update_task { }
        }
        

    }
    
    
    if {[string is true $debug]} {
        ns_log Notice "*******************"
    }
    
    return $task_list
    
}
