# Author:         Miguel Marin (miguelmarin@viaro.net)
# Author:         Viaro Networs www.viaro.net
# creation_date:  2005-11-10
#
# Description:    Display all tasks across all projects in all project-manager instances
#                 where a party id is currently working on.
#
# Required Values:
# ---------------
# from_party_id      To get the tasks from.
#
#
# Pagination and orderby:
# ----------------------
# page        The page to show on the paginate.
# page_size   The number of rows to display in the list
# pt_orderby  To sort the list using this orderby value
# orderby_p   Boolean that indicates if you want to have the 
#             orderby functionality or not, default 't'
#
#
# Other Values:
# -------------
# elements      A list of the elements to show in the list.
# format        The format of the listtemplate layout. Default to "normal"



set required_param_list [list from_party_id]
set optional_param_list [list pt_orderby page page_size format orderby_p]
set optional_unset_list [list]

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

if { ![exists_and_not_null orderby_p] } {
    set orderby_p "t"
}

set default_orderby [pm::task::default_orderby]

if {[exists_and_not_null pt_orderby]} {
    pm::task::default_orderby -set $pt_orderby
}

if ![exists_and_not_null page_size] {
    set page_size 15
}

if ![exists_and_not_null page] {
    set page 1
}

if ![exists_and_not_null format] {
    set format normal
}

set user_id [ad_conn user_id]

# how to get back here
set return_url [ad_return_url -qualified]


if ![exists_and_not_null elements] {
    # Here are all elements available to show on the list
    set elements [list \
		      task_item_id \
		      title \
		      earliest_start \
		      earliest_finish \
		      latest_start \
		      latest_finish \
		      slack_time \
		      end_date \
		      status_type \
		      status_description \
		      days_remaining \
		      hours_remaining \
		      actual_days_worked \
		      actual_hours_worked \
		      project_item_id \
		      priority \
		      percent_complete \
		      edit_url]
}

set row_list [list]
foreach element $elements {
    lappend row_list $element
    lappend row_list [list]
}

# Orderby's to use in
if { $orderby_p } {
    set order_by_list [list \
			   default_value $default_orderby \
			   title {
			       label "[_ project-manager.Subject_1]"
			       orderby_desc "t.title desc, task_item_id"
			       orderby_asc "t.title asc, task_item_id"
			       default_direction asc
			   } \
			   description {
			       label "[_ project-manager.Description]"
			       orderby_desc "t.description desc, task_item_id"
			       orderby_asc "t.description, task_item_id"
			       default_direction asc
			   } \
			   slack_time {
			       label "[_ project-manager.Slack_1]"
			       orderby_desc "(latest_start - earliest_start) desc, task_item_id"
			       orderby_asc "(latest_start - earliest_start), task_item_id"
			       default_direction asc
			   } \
			   status {
			       label "[_ project-manager.Status_1]"
			       orderby_desc "status desc, t.latest_finish desc, task_item_id"
			       orderby_asc "status asc, t.latest_finish desc, task_item_id"
			       default_direction asc
			   } \
			   end_date {
			       orderby_asc "end_date, task_item_id asc"
			       orderby_desc "end_date desc, task_item_id desc"
			       default_direction asc
			   } \
			  ]
} else {
    set order_by_list [list]
}

template::list::create \
    -name tasks \
    -multirow tasks \
    -key task_item_id \
    -orderby_name "pt_orderby" \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name "tasks_pagination" \
    -selected_format $format \
    -elements {
	task_item_id {
	    label "[_ project-manager.number]"
	    link_url_col item_url
	    link_html {title "[_ project-manager.lt_View_this_project_ver]" }
	    display_template {<a href="@tasks.base_url@@tasks.item_url@">@tasks.task_item_id@</a>}
	}
	title {
	    label "[_ project-manager.Subject_1]"
	    display_template {
		<if @tasks.red_title_p@>
		   <font color="red">@tasks.title@</font>
		</if>
		<else>
		    <font color="green">@tasks.title@</font>
		</else>
	    }
	}
        earliest_start {
            label "[_ project-manager.Earliest_Start]"
            display_template {
		<if @tasks.days_to_earliest_start@ gt 1 or @tasks.status_type@ ne o>
		    @tasks.earliest_start_pretty@
		</if>
		<else>
		    <font color="\#00ff00">@tasks.earliest_start_pretty@</font>
		</else>
	    }
        }
        earliest_finish {
            label "[_ project-manager.Earliest_Finish]"
            display_template {
		<if @tasks.days_to_earliest_finish@ gt 1 or @tasks.status_type@ ne o>
		    @tasks.earliest_finish_pretty@
		</if>
		<else>
		    <font color="\#00ff00">@tasks.earliest_finish_pretty@</font>
		</else>
	    }
        }
        latest_start {
            label "[_ project-manager.Latest_Start]"
            display_template {
		<if @tasks.days_to_latest_start@ gt 1 or @tasks.status_type@ ne o>
		     @tasks.latest_start_pretty@
		</if>
		<else><font color="red">@tasks.latest_start_pretty@</font>
		</else>
	    }
        }
        latest_finish {
            label "[_ project-manager.Latest_Finish]"
            display_template {
		<if @tasks.days_to_latest_finish@ gt 1 or @tasks.status_type@ ne o>
		    @tasks.latest_finish_pretty@
		</if>
		<else>
		    <font color="red">@tasks.latest_finish_pretty@</font>
		</else>
	    }
        }
	end_date {
	    label "[_ project-manager.Deadline]"
            display_template {
		<if @tasks.days_to_end_date@ gt 1 or @tasks.status_type@ ne o>
		    @tasks.end_date_pretty@
		</if>
		<else>
		<font color="red">@tasks.end_date_pretty@</font>
		</else>
	    }
	}
	status_type {
            label "[_ project-manager.Done_1]"
            display_template {
		<a href="@tasks.task_close_url@"><if @tasks.status_type@ eq c><img border="0" src="/resources/checkboxchecked.gif" /></if><else><img border="0" src="/resources/checkbox.gif" /></else></a>
            }
        }
	status_description {
	    label "[_ project-manager.Status_1]"
	}
	slack_time {
	    label "[_ project-manager.Slack_1]"
	    display_template {
		<if @tasks.slack_time@ gt 1>
		    @tasks.slack_time@
		</if>
		<else>
		    <font color="red">@tasks.slack_time@</font>
		</else>
	    }
	}
        priority {
            label "[_ project-manager.Priority_1]"
            display_template {
		@tasks.priority@
            }
        }
	days_remaining {
	    label "[_ project-manager.Days_work]"
	    html {
		align right
	    }
	}
	hours_remaining {
	    label "[_ project-manager.Hours_remaining]"
	    html {
		align right
	    }
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
    } -orderby $order_by_list \
    -formats {
	normal {
	    label "[_ project-manager.Table]"
	    layout table
	    row $row_list
	}
    }

# Extend list of variables in the multirow
set extend_list [list \
		     item_url \
		     edit_url \
                     earliest_start_pretty \
                     earliest_finish_pretty \
                     end_date_pretty \
                     latest_start_pretty \
                     latest_finish_pretty \
                     slack_time \
                     hours_remaining \
                     days_remaining \
                     actual_days_worked \
                     base_url \
                     task_close_url \
                     project_url \
                     red_title_p]

db_multirow -extend $extend_list tasks tasks { } {

    set item_url [export_vars -base "task-one" {{task_id $task_item_id}}]
    set edit_url [export_vars -base "task-add-edit" {{task_id $task_item_id} project_item_id return_url}]

    if {[parameter::get -parameter "UseDayInsteadOfHour"] == "f"} {
	set fmt "%x %X"
    } else {
	set fmt "%x"
    }

    set earliest_start_pretty [lc_time_fmt $earliest_start $fmt]
    set earliest_finish_pretty [lc_time_fmt $earliest_finish $fmt]
    set latest_start_pretty [lc_time_fmt $latest_start $fmt]
    set latest_finish_pretty [lc_time_fmt $latest_finish $fmt]
    set end_date_pretty [lc_time_fmt $end_date $fmt]

    set red_title_p 0
    set sysdate [dt_sysdate -format "%Y-%m-%d %H:%M:%S"]
    if { [exists_and_not_null latest_start]} {
	if { $sysdate > $latest_start } {
	    set red_title_p 1
	}
    } else {
	if { $sysdate > $end_date } {
	    set red_title_p 1
	}
    }

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

    set hours_remaining \
	[pm::task::hours_remaining \
	     -estimated_hours_work $estimated_hours_work \
	     -estimated_hours_work_min $estimated_hours_work_min \
	     -estimated_hours_work_max $estimated_hours_work_max \
	     -percent_complete $percent_complete]

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
    acs_object::get -object_id $task_item_id -array task_array
    set base_url [lindex [site_node::get_url_from_object_id -object_id $task_array(package_id)] 0]
    set task_close_url [export_vars -base "${base_url}task-close" -url {task_item_id return_url}]
    set project_url [export_vars -base "${base_url}one" {project_item_id $tasks(project_item_id)}]
}
