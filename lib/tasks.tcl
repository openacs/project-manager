# Possible Filters:
# -----------------
# filter_party_id    Show tasks where this party_id participates
# filter_group_id    Show tasks where members of this group participate
# pid_filter         Show tasks only for this project_item_id
# is_observer_filter Show tasks where party_id is_observer_p "t" or "f"
# filter_package_id  Show tasks for this package_id
# instance_id        Show tasks for this instance_id
# status_id          Show tasks with this status_id.
# searchterm         Show tasks where the task title is like searchterm
# subproject_tasks   Show or hide subproject_tasks, this filter is dynamically added
#                    when pid_filter has a value.
# min_priority       Show tasks which have at least this priority
# max_priority       Show tasks which have maximum this priority
#
# Pagination and orderby:
# ---------------------- 
# page        The page to show on the paginate.
# page_size   The number of rows to display in the list
# orderby_p   Set it to 1 if you want to show the order by menu.
# tasks_orderby     To sort the list using this orderby value
#
# For Project Manager Task Portlet:
# ---------------------------------
# tasks_portlet_p   Value that indicates that this include is showing in the portlet of dotlrn
# page_num          The number of the page inside dotlrn
#
# Other Variables:
# ----------------
# actions_p      Boolean to specify if you like to show list actions or not
# bulk_actions_p Boolean to specify if you like to show bulk actions or not
# base_url       Url to use in links
# display_mode   Could be "list", then only the list of tasks will be shown or could be "filter", 
#                then filters would be added as well.

set required_param_list [list]
set optional_param_list [list tasks_orderby searchterm page actions_p base_url page_num page_size bulk_actions_p min_priority]
set optional_unset_list [list \
			     filter_party_id filter_group_id pid_filter \
			     is_observer_filter instance_id filter_package_id \
			     subproject_tasks status_id tasks_portlet_p]

foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
        if {[empty_string_p [set $optional_unset]] || [set $optional_unset] == 0} {
	    unset $optional_unset
	}
    }
}


# Deal with the include variable user_id and package_ids

if {[exists_and_not_null package_ids]} {
    set filter_package_id $package_ids
    set package_id [lindex $package_ids 0]
}

if {[exists_and_not_null user_id]} {
    set filter_party_id $user_id
}

if {![exists_and_not_null page_size]} {
    set page_size 10000
}

# Deal with the orderbys.
if {[exists_and_not_null tasks_orderby]} {
    set orderby_p 1
}

if {![info exists orderby_p]} {
    set orderby_p 0
}

# Make the end_date the default orderby
set default_orderby "end_date,asc"

if { ![exists_and_not_null tasks_portlet_p] } {
    set tasks_portlet_p f
} else {
    set show_rows $page_size

    # We are inside dotlrn so I will disable the 
    # pagination by setting the page_size value to null
    #
    # This sadly inteferes with certain other functionalities so it is taken out again
    # if you want a larger page_size, change it in project-manager-tasks-portlet.tcl in 
    # project-manager-portlet package.
#    set page_size ""
}

# The default display mode should be a list
if {![info exists display_mode]} {
    set display_mode "list"
}

if {![info exists format]} {
    set format "normal"
}

# the unique identifier for this package
if {![info exists package_id]} {
    set package_id [ad_conn package_id]
}

# Deal with the fact that we might work with days instead of hours

if {[parameter::get \
	 -parameter "UseDayInsteadOfHour" -default "t"] == "t"} {
    set days_string "days"
} else {
    set days_string "hours"
}

set exporting_vars {status_id party_id tasks_orderby page_num}
set hidden_vars [export_vars \
		     -no_empty -form $exporting_vars]

# how to get back here

set return_url [ad_return_url -qualified]

set contacts_url [util_memoize [list site_node::get_package_url \
				    -package_key contacts]]
# set up context bar
set context [list "[_ project-manager.Tasks]"]


set status_list [lang::util::localize_list_of_lists -list [db_list_of_lists get_status_values { }]]
set status_list [linsert $status_list 0 [list "#acs-kernel.common_All#" "-1"]]

set user_id [ad_maybe_redirect_for_registration]

# status defaults to open
if {![exists_and_not_null status_id] || $status_id == "-1"} {
    set status_where_clause ""
} else {
    set status_where_clause "ti.status = :status_id"
}

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

if {![empty_string_p $searchterm]} {

    # if we're searching, we disregard who we were searching for.

    if {[info exists party_id]} {
        unset party_id
    } 

    if {[regexp {([0-9]+)} $searchterm match query_digits]} {
        set search_where_clause "and (upper(cr.title) like upper('%$searchterm%')
 or t.item_id = :query_digits)  and cr.revision_id = t.latest_revision"
    } else {
        set search_where_clause "and upper(cr.title) like upper('%$searchterm%') and cr.revision_id = t.latest_revision"
    }
    set search_from_clause "cr_revisions cr,"
} else {
    set search_from_clause ""
    set search_where_clause ""
}

# Get the elements to display in the list
if {![exists_and_not_null elements]} {
    set elements [list \
		      project_item_id \
		      task_item_id \
		      title \
		      priority \
		      hours_remaining \
		      end_date \
		      last_name]
}

if { [exists_and_not_null subproject_tasks] && [exists_and_not_null pid_filter]} {
    set subprojects_list [db_list get_subprojects { } ]
    lappend subprojects_list $pid_filter
    set project_item_where_clause "t.parent_id in ([template::util::tcl_to_sql_list $subprojects_list])"
} else {
    set project_item_where_clause "t.parent_id = :pid_filter"
}

# Shall we display only items where we are an observer ?
set observer_from_clause ""

if {[exists_and_not_null is_observer_filter]} {
    set observer_from_clause " pm_task_assignment ta,  pm_roles r,"
    switch $is_observer_filter {
	f {
	    set observer_pagination_clause "and t.item_id = ta.task_id and ta.role_id = r.role_id and r.is_observer_p = 'f' and ta.party_id = :user_id"
	} 
	t {
	    set observer_pagination_clause "and t.item_id = ta.task_id and ta.role_id = r.role_id and r.is_observer_p = 't' and ta.party_id = :user_id"
	}
	default {
	    set observer_pagination_clause "and t.item_id = ta.task_id and ta.role_id = r.role_id and ta.party_id = :user_id"
	}
    }
} else {
    set observer_pagination_clause ""
}

# Clause for the minimum priority
if {[exists_and_not_null min_priority]} {
    set priority_clause "and priority >= :min_priority"
} else {
    set priority_clause ""
}

# Clause for the maximum priority
if {[exists_and_not_null max_priority]} {
    append priority_clause "and priority <= :max_priority"
}

# Filter by party_id. Only the tasks of this party will be shown
set party_id_clause ""
if {[exists_and_not_null filter_party_id]} {
    set observer_from_clause " pm_task_assignment ta,  pm_roles r,"
    set party_id_clause "and t.item_id = ta.task_id and ta.role_id = r.role_id and ta.party_id = :filter_party_id"
}

# Filter by group_id. As of now still untested
if {[exists_and_not_null filter_group_id]} {
    set observer_from_clause " pm_task_assignment ta,  pm_roles r,"
    set party_id_clause "and t.item_id = ta.task_id and ta.role_id = r.role_id and ta.party_id in (select member_id from group_member_map where group_id = :filter_group_id)"
}

# Filter by package_id
if {[exists_and_not_null filter_package_id]} {
    set filter_package_where_clause "op.package_id in ([template::util::tcl_to_sql_list $filter_package_id])"
} else {
    set filter_package_where_clause ""
}

set filters [list \
 		 searchterm [list \
				 label "[_ project-manager.Search_1]" \
			    ] \
		 status_id [list \
				label "[_ project-manager.Status_1]" \
				values { $status_list } \
				where_clause "$status_where_clause"
			   ] \
		 pid_filter [list \
				 label "[_ project-manager.Project_1]" \
				 where_clause "$project_item_where_clause"
			    ] \
		 page_size [list \
				label "[_ project-manager.Page_Size]" \
				values {10 20 30 50 100 500}
			    ] \
		 project_item_id [list \
				 label "[_ project-manager.Project_1]" \
				 where_clause "$project_item_where_clause"
			    ] \
		 instance_id [list \
				  where_clause "op.package_id = :instance_id"
			     ] \
		 is_observer_filter [list \
					 label "[_ project-manager.Observer]" \
					 values { {"[_ project-manager.Player]" f} { "[_ project-manager.Watcher]" t} } \
					] \
		 filter_package_id [list \
					where_clause "$filter_package_where_clause"
				   ] \
		]

if { [exists_and_not_null pid_filter] } {
    lappend filters subproject_tasks [list \
					  label "[_ project-manager.Subproject_tasks]" \
					  values {{ "[_ project-manager.Show]" 1}} \
					 ]
			
}

# Setup the actions, so we can append the rest later on
if {$actions_p == 1} {
    set actions [list \
		     "[_ project-manager.Add_task]" \
		     [export_vars -base "${base_url}task-select-project" {return_url}] "[_ project-manager.Add_a_task]"]
} else {
    set actions [list]
}

# Append each element to row_list that is used on 
# format section in template::list::create procedure
foreach element $elements {
    # Special treatement for days / hours

    if {$element == "remaining"} {
	set element "${days_string}_remaining"
    }
    if {$element == "worked"} {
	set element "actual_${days_string}_worked"
    }


    # If we display the items of a single user, show the role. Otherwise
    # show all players.

    if {$element == "role"} {
	set element "last_name"
    }
    append row_list "$element {}\n"
}

# Bulk actions to show in the list
set use_bulk_p  [parameter::get -parameter "UseBulkP" -default "0"]
if { $use_bulk_p == 1 || $bulk_actions_p == 1} {
    set row_list "multiselect {}\n $row_list"
    set bulk_actions [list \
			  "[_ project-manager.Close_tasks]" \
			  "${base_url}task-bulk-close" \
			  "[_ project-manager.Close_multiple_tasks]" \
			  "[_ project-manager.Assign_myself]" \
			  "${base_url}assign-myself" \
			  "[_ project-manager.Assign_myself_as_lead]"]

    set bulk_action_export_vars [list [list return_url] [list project_item_id]]
} else {
    set bulk_actions [list]
    set bulk_action_export_vars [list]
}

# Orderby's to use in
if { $orderby_p } {
    set order_by_list [list \
			   default_value $default_orderby \
			   slack_time {
			       label "[_ project-manager.Slack_1]"
			       orderby_desc "(latest_start - earliest_start) desc, task_item_id"
			       orderby_asc "(latest_start - earliest_start), task_item_id"
			       default_direction asc
			   } \
			   status {
			       label "[_ project-manager.Status_1]"
			       orderby_desc "status desc, t.end_date desc, task_item_id"
			       orderby_asc "status asc, t.end_date desc, task_item_id"
			       default_direction asc
			   } \
			   project_item_id {
			       orderby_asc "op.title asc, priority desc, end_date, task_item_id asc"
			       orderby_desc "op.title desc, priority desc, end_date desc, task_item_id desc"
			       default_direction asc
			   } \
			   priority {
			       orderby_asc "priority, end_date, task_item_id asc"
			       orderby_desc "priority desc, end_date desc,  earliest_start desc"
			       default_direction desc
			   } \
			   end_date {
			       orderby_asc "end_date, priority desc, task_item_id asc"
			       orderby_desc "end_date desc, priority desc, task_item_id desc"
			       default_direction asc
			   } \
			   estimated_hours_work_max {
			       orderby_asc "estimated_hours_work_max, task_item_id asc"
			       orderby_desc "estimated_hours_work_max desc, task_item_id desc"
			       default_direction desc
			   } \
			  ]
} else {
    set order_by_list [list \
			   default_value $default_orderby \
			   end_date {
			       orderby_asc "end_date, priority desc, task_item_id asc"
			       orderby_desc "end_date desc, priority desc, task_item_id desc"
			       default_direction asc
			   } 
		      ]
}


template::list::create \
    -name tasks \
    -multirow tasks \
    -key task_item_id \
    -selected_format $format \
    -elements {
	task_item_id {
	    label "[_ project-manager.number]"
	    link_url_col item_url
	    link_html {title "@tasks.title@" }
	    display_template {<a href="@tasks.base_url@@tasks.item_url@">@tasks.task_item_id@</a>}
	}
        status_type {
            label "[_ project-manager.Done_1]"
            display_template {<a href="@tasks.task_close_url@"><if @tasks.status_type@ eq c><img border="0" src="/resources/checkboxchecked.gif" /></if><else><img border="0" src="/resources/checkbox.gif" /></else></a>
            }
        }
	title {
	    label "[_ project-manager.Subject_1]"
	    display_template {
		<font color="@tasks.title_color@">@tasks.title@</font>
	    }
	}
        parent_task_id {
            label "[_ project-manager.Dep]"
            display_template {<a href="@tasks.base_url@task-one?task_id=@tasks.parent_task_id@">@tasks.parent_task_id@</a>
            }
        }
        priority {
            label "[_ project-manager.Priority_1]"
            display_template {
		@tasks.priority@
            }
        }
	slack_time {
	    label "[_ project-manager.Slack_1]"
	    display_template "<if @tasks.slack_time@ gt 1>@tasks.slack_time@</if><else><font color=\"red\">@tasks.slack_time@</font></else>"
	}
        party_id {
            label "[_ project-manager.Who]"
            display_template {@user_html;noquote@}
	}
	role {
	    label "[_ project-manager.Role]"
	}
        earliest_start {
            label "[_ project-manager.Earliest_Start]"
            display_template "<if @tasks.days_to_earliest_start@ gt 1 or @tasks.status_type@ ne o>@tasks.earliest_start_pretty@</if><else><font color=\"00ff00\">@tasks.earliest_start_pretty@</font></else>"
        }
        earliest_finish {
            label "[_ project-manager.Earliest_Finish]"
            display_template "<if @tasks.days_to_earliest_finish@ gt 1 or @tasks.status_type@ ne o>@tasks.earliest_finish_pretty@</if><else><font color=\"00ff00\">@tasks.earliest_finish_pretty@</font></else>"
        }
        latest_start {
            label "[_ project-manager.Latest_Start]"
            display_template "<if @tasks.days_to_latest_start@ gt 1 or @tasks.status_type@ ne o>@tasks.latest_start_pretty@</if><else><font color=\"red\">@tasks.latest_start_pretty@</font></else>"
        }
        latest_finish {
            label "[_ project-manager.Latest_Finish]"
            display_template "<if @tasks.days_to_latest_finish@ gt 1 or @tasks.status_type@ ne o>@tasks.latest_finish_pretty@</if><else><font color=\"red\">@tasks.latest_finish_pretty@</font></else>"
        }
	end_date {
	    label "[_ project-manager.Task_end_date]"
            display_template "<if @tasks.days_to_end_date@ gt 1 or @tasks.status_type@ ne o>@tasks.end_date_pretty@</if><else><font color=\"red\">@tasks.end_date_pretty@</font></else>"
	}
	status {
	    label "[_ project-manager.Status_1]"
	}
	project_status {
	    label "[_ project-manager.Status_1]"
	}
	days_remaining {
	    label "[_ project-manager.Days_work]"
	    html {
		align right
	    }
	}
	hours_remaining {
	    label "[_ project-manager.Hours_remaining]"
	    display_template "<div align=\"left\">@tasks.hours_remaining@</div><div align=\"right\"> (@tasks.estimated_hours_work_max@)</div>"
	}
	actual_days_worked {
	    label "[_ project-manager.Days_worked]"
	    html {
		align right
	    }
	}
	actual_hours_worked {
	    label "[_ project-manager.Hours_worked]"
	    html {
		align right
	    }
	}
	estimated_hours_work_max {
	    label "[_ project-manager.Estimated_Hours_Max]"
	    html {
		align left
	    }
	}
	project_item_id {
	    label "[_ project-manager.Project_1]"
	    display_template {<a href="@tasks.project_url@">@tasks.project_name@</a>}
	    hide_p {[ad_decode [exists_and_not_null project_item_id] 1 1 0]}
	}
	edit_url {
	    display_template {<a href="@tasks.base_url@@tasks.edit_url@">E</a>}
	}
	percent_complete {
	    label "[_ project-manager.Percent_complete]"
	}
        last_name {
            label "[_ project-manager.Who]"
            display_template { @tasks.user_html;noquote@
            }
	}
    } \
    -sub_class {
	narrow
    } \
    -filters $filters \
    -orderby $order_by_list \
    -actions $actions \
    -checkbox_name multiselect \
    -bulk_actions $bulk_actions \
    -bulk_action_export_vars $bulk_action_export_vars \
    -page_size_variable_p 1 \
    -page_size $page_size \
    -page_flush_p 1 \
    -page_query_name tasks_pagination \
    -orderby_name tasks_orderby \
    -html {
	width 100%
    } \
    -formats {
	normal {
	    label "[_ project-manager.Table]"
	    layout table
	    row $row_list
	}
	csv {
	    label "[_ project-manager.CSV]"
	    output csv
	    page_size 0
	    row $row_list
	}
    }

if { ![exists_and_not_null assign_group_p] } {
    set assign_group_p [parameter::get -parameter "AssignGroupP" -default 0]
}

set user_instead_full_p [parameter::get -parameter "UsernameInsteadofFullnameP" -default "f"]
if {[lsearch -exact $row_list project_status] == -1} {
    set project_status_p 0
} else {
    set project_status_p 1
}

set row_count 0
set more_p 0

# Extend list of variables in the multirow
set extend_list [list \
		     item_url \
		     earliest_start_pretty \
		     earliest_finish_pretty \
		     end_date_pretty \
		     latest_start_pretty \
		     latest_finish_pretty \
		     slack_time \
		     edit_url \
		     hours_remaining \
		     days_remaining \
		     actual_days_worked \
		     my_user_id \
		     user_url \
		     base_url \
		     task_close_url \
		     project_url \
		     project_status \
		     assignee_name \
		     red_title_p \
		     title_color \
		     user_html \
		    role_type]

set total_estimated_hours 0
set total_estimated_hours_max 0
db_multirow -extend $extend_list tasks tasks " " {

    if { $tasks_portlet_p && [string equal $row_count $show_rows] } {
	# When showing in dotlrn we don't want to have the complete
	# list of tasks in the portlet, so we count to the original
	# specified page_size and break the multirow when it reaches
	# that value and add a link to show all the tasks.
	set more_p 1
	break
    }

    set assignee_role_list [pm::task::assignee_role_list_ext -task_item_id $task_item_id]
    
    set user_html ""
    set user_is_lead_p 0
    foreach assignee $assignee_role_list {
	
	set assignee_id [lindex $assignee 0]
	set role_id [lindex $assignee 1]
	set is_lead_p [lindex $assignee 2]
	set is_observer_p [lindex $assignee 3]
	# Set the role_type, distinguishing leader,players and watchers
	if {$is_lead_p} {
	    set role_type "lead"
	} elseif {$is_observer_p} {
	    set role_type "observer"
	} else {
	    set role_type "player"
	}

	# if contacts is installed, link to it, otherwise link to pvt home
	if {[string eq "" $contacts_url]} {
	    set user_url [export_vars -base "/shared/community-member" {{user_id $assignee_id}}]
	} else {
	    set user_url [export_vars \
			      -base "${contacts_url}contact" {{party_id $assignee_id}}]
	}

	if { $assign_group_p } {
	    # We are going to show all asignees including groups
	    if { $user_instead_full_p } {
		if { [catch {set assignee_name [acs_user::get_element -user_id $assignee_id -element username]} err ] } {
		    set assignee_name [group::title -group_id $assignee_id]		
		}
	    } else {
		if { [catch {set assignee_name [person::name -person_id $assignee_id] } err] } {
		    # person::name give us an error so its probably a group so we get
		    # the title
		    set assignee_name [group::title -group_id $assignee_id]
		}
	    }
	} else {
	    if { $user_instead_full_p } {
		if { [catch {set assignee_name [acs_user::get_element -user_id $assignee_id -element username]} err ] } {
		# Apparently we did not get the assignee_name, probably because it is not a user.
		    set assignee_name "[person::name -person_id $assignee_id](no_user!!)"
		}
	    } else {
		if { [catch {set assignee_name [person::name -person_id $assignee_id] } err] } {
		    # person::name give us an error so its probably a group, here we don't want
		    # to show any group so we just continue the multirow
		    continue
		}
	    }
	}
        
	# Display the user differently if the user is the one using the system
	if {[string eq $assignee_id $user_id]} {
	    if {[string eq $role_type "lead"]} {
		set user_is_lead_p 1
	    }
	    append user_html "<span class=\"selected\">"
	} else {
	    append user_html ""
	}

	if {[string eq $role_type "lead"]} {
	    append user_html "<div class=\"pm_lead\">"
	} elseif {[string eq $role_type "player"]} {
	    append user_html "<div class=\"pm_player\">"
	} 	    

	# We dont want to show watchers
 	if {![string eq $role_type "observer"]} {
	    append user_html "$assignee_name"
	    append user_html "</div></br>"
	}
	if {[string eq $assignee_id $user_id]} {
	    append user_html "</span>"
	}
    }
    
    set item_url [export_vars \
		      -base "task-one" {{task_id $task_item_id}}]
    set edit_url [export_vars \
		      -base "task-add-edit" {{task_id $task_item_id} project_item_id return_url}]

    if {[parameter::get -parameter "UseDayInsteadOfHour"] == "t"} {
	set fmt "%x"
    } else {
	set fmt "%x %X"
    }

    set earliest_start_pretty [lc_time_fmt $earliest_start $fmt]
    set earliest_finish_pretty [lc_time_fmt $earliest_finish $fmt]
    set latest_start_pretty [lc_time_fmt $latest_start $fmt]
    set latest_finish_pretty [lc_time_fmt $latest_finish $fmt]
    set end_date_pretty [lc_time_fmt $end_date $fmt]
    set project_status [pm::project::get_status_description -project_item_id $project_item_id]

    if {!$project_status_p} {
	set project_name "[string index [lang::util::localize $project_status] 0]-$project_name"
    }

    # Default color is black
    set title_color "black"
    
    # If you are not an observer, make the color green
    if {$user_is_lead_p} {
	set title_color "green"
    }

    # Color the task red if the task is overdue
    #set sysdate [dt_sysdate -format "%Y-%m-%d %H:%M:%S"]
#    if { [exists_and_not_null latest_start]} {
#	if { $sysdate > $latest_start } {
#	    set title_color "red"
#	}
#    } elseif {[exists_and_not_null end_date]} {
#	if { $sysdate > $end_date } {
#	    set title_color "red"
#	}
#    }

    set red_title_p 0
    
    if {[exists_and_not_null earliest_start_j]} {
	set slack_time [pm::task::slack_time \
			    -earliest_start_j $earliest_start_j \
			    -today_j $today_j \
			    -latest_start_j $latest_start_j]
    } else {
	set slack_time "[_ project-manager.na]"
    }

    if {![exists_and_not_null percent_complete]} {
	set percent_complete 0
    }

    if {$hours_remaining eq ""} {
	set hours_remaining 0
    }

    set hours_remaining \
	[pm::task::hours_remaining \
	     -estimated_hours_work $estimated_hours_work \
	     -estimated_hours_work_min $estimated_hours_work_min \
	     -estimated_hours_work_max $estimated_hours_work_max \
	     -percent_complete $percent_complete]

    set total_estimated_hours [expr $total_estimated_hours + $estimated_hours_work]
    set total_estimated_hours_max [expr $total_estimated_hours_max + $estimated_hours_work_max]
    set days_remaining \
	[pm::task::days_remaining \
	     -estimated_hours_work $estimated_hours_work \
	     -estimated_hours_work_min $estimated_hours_work_min \
	     -estimated_hours_work_max $estimated_hours_work_max \
	     -percent_complete $percent_complete]

    if {[exists_and_not_null actual_hours_worked]} {
	set actual_days_worked [expr $actual_hours_worked / 24]
    } else {
	set actual_days_worked ""
    }
    set my_user_id $user_id
    

    acs_object::get -object_id $task_item_id -array task_array
    set base_url [lindex [site_node::get_url_from_object_id -object_id $task_array(package_id)] 0]
    set task_close_url [export_vars -base "${base_url}task-close" -url {task_item_id return_url}]
    set project_url [export_vars -base "${base_url}one" {project_item_id $tasks(project_item_id)}]
    incr row_count
}

# ------------------------- END OF FILE -------------------------
