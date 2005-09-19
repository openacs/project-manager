# 

ad_library {
    
    Procs to integrate calendar with project-manager
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-08-04
    @arch-tag: cb98fba5-fba0-449f-9c14-ad9a41bbbd61
    @cvs-id $Id$
}



namespace eval pm::calendar {
    
    ad_proc -public users_to_view {
    } {
        Returns a list of user_ids for users to view
        
        @author Jade Rubick (jader@bread.com)
        @creation-date 2004-09-13
        
        @return 
        
        @error 
    } {
        set user_id [ad_conn user_id]

        set user_list [db_list get_users {
            SELECT
            viewed_user
            FROM
            pm_users_viewed
            WHERE
            viewing_user = :user_id
        }]

        if {[empty_string_p $user_list]} {
            return $user_id
        } else {
            return $user_list
        }
    }


    ad_proc -public one_month_display {
        {-user_id:required}
        {-date ""}
        {-hide_closed_p "t"}
	{-display_p "l"}
	{-display_item "t"}
	{-package_id ""}
    } {
        Creates a month widget for tasks if display_item=t 
	Creates a month widget for projects if display_item=p
    } {
        set dotlrn_installed_p [apm_package_installed_p dotlrn]
        set day_template "<a href=?julian_date=\$julian_date>\$day_number</a>"
        set prev_nav_template "<a href=\"?view=month&date=\$ansi_date&user_id=$user_id\">&lt;</a>" 
        set next_nav_template "<a href=\"?view=month&date=\$ansi_date&user_id=$user_id\">&gt;</a>" 
	set instance_clause ""
	
        if {$dotlrn_installed_p} {
            if { [empty_string_p $package_id]} {
                set package_id [dotlrn_community::get_package_id_from_package_key -package_key project-manager -community_id [dotlrn_community::get_community_id]]
            } else {
                set package_id [ad_conn package_id]
            }
            if { ![string eq  [ad_conn package_id] [dotlrn::get_package_id]]} {
                set instance_clause "and o.package_id=:package_id"
            } 
        } else {
            set package_id [ad_conn package_id]
        }
	
        if {[empty_string_p $date]} {
            set date [dt_systime]
        }
	
        set date_list [dt_ansi_to_list $date]
        set month [lindex $date_list 1]
        set year [lindex $date_list 0]
	
        set first_of_month_date "$year-$month-01"
        set last_of_month_date  "$year-$month-[dt_num_days_in_month $year $month]"
	
        set items [ns_set create]
	
        # do not show closed items if the user requests not to
        if {[string is true $hide_closed_p]} {
            set hide_closed_clause " and s.status_type = 'o' "
        } else {
            set hide_closed_clause ""
        }
	
        set selected_users [pm::calendar::users_to_view]
        set selected_users_clause " and ts.task_id in (select task_id from pm_task_assignment where party_id in ([join $selected_users ", "]))"
	
        set last_task_id ""
        set last_latest_start_j ""
        set assignee_list [list]
	
	#display tasks by latest_finish as default
	
	set query_name "select_monthly_tasks"
	
	#display tasks by deadline
	
	if { [string eq $display_p d]} {
	    set query_name "select_monthly_tasks_by_deadline"
	}
	
	db_foreach  $query_name {} {
	    
	    set base_url [apm_package_url_from_id $instance_id]	    
	    
	    # highlight what you're assigned to.
	    if {[string equal $person_id $user_id]} {
		set font_begin "<span class=\"selected\">"
		set font_end "</span>"
	    } else {
		set font_begin ""
		set font_end ""
	    }
	    
	    if { \
		     ![empty_string_p $is_lead_p] && \
		     [string is true $is_lead_p]} {
		
		set font_begin "$font_begin<i>"
		set font_end "</i>$font_end"
	    }
	    
	    # if this is another row of the same item, just add the name.
	    if {[string equal $last_task_id $task_id]} {
		#append day_details "<li>, ${font_begin}${full_name}${font_end}</li>"
	    } else {
		
		# this is the beginning of an item.
		
		# save the last item for output
		    if {![empty_string_p $last_task_id]} {
			ns_set put $items $last_latest_start_j "${day_details}</ul></p></span>"
		    }
		    
		    # set up the next item for output
		    
		    if {[string equal $status "c"]} {
			set detail_begin "<strike>"
			set detail_end "</strike>"
		    } else {
			set detail_begin ""
			set detail_end ""
		    }
		    
		    # begin setting up this calendar item
                    set day_details "<span class=\"calendar-item\"><p>${detail_begin}<input type=\"checkbox\" name=\"task_item_id\" value=\"$task_id\" /><a href=\"task-one?task_id=$task_id\">$title${detail_end}</a> - <small><em>$project_name</em></small>"

		    # only add to the list if we want to see closed tasks
		    #append day_details "<ul><li>${font_begin}${full_name}${font_end}</li>"
		    
		}
	    
	    set last_task_id $task_id
	    set last_latest_start_j $latest_start_j
	}
	
	if {![empty_string_p $last_task_id ]} {
		
	    ns_set put $items $latest_start_j "$day_details</ul></p></span>"
	}
	
	
	# Display stuff
	set day_number_template "<font size=2>$day_template</font>"
	
	return [dt_widget_month -calendar_details $items -date $date \
		    -master_bgcolor black \
		    -header_bgcolor lavender \
		    -header_text_color black \
		    -header_text_size "+1" \
		    -day_header_bgcolor lavender \
		    -day_bgcolor white \
		    -today_bgcolor #FFF8DC \
		    -empty_bgcolor lightgrey \
		    -day_text_color black \
		    -prev_next_links_in_title 1 \
		    -prev_month_template $prev_nav_template \
		    -next_month_template $next_nav_template \
		    -day_number_template $day_number_template]
	
    }
    
    ad_proc -public one_month_project_display {
        {-user_id:required}
        {-date ""}
        {-hide_closed_p "t"}
    } {
        Creates a month widget for tasks if display_item=t 
	Creates a month widget for projects if display_item=p
    } {
	
        set day_template "<a href=?julian_date=\$julian_date>\$day_number</a>"
        set prev_nav_template "<a href=\"?view=month&date=\$ansi_date&user_id=$user_id\">&lt;</a>" 
        set next_nav_template "<a href=\"?view=month&date=\$ansi_date&user_id=$user_id\">&gt;</a>" 
	set instance_clause ""
	
	
	set package_id [dotlrn_community::get_package_id_from_package_key -package_key project-manager -community_id [dotlrn_community::get_community_id]]
	

	
	if { ![string eq  [ad_conn package_id] [dotlrn::get_package_id]]} {
	    set instance_clause "and f.package_id = :package_id"
	} 

        if {[empty_string_p $date]} {
            set date [dt_systime]
        }
	
        set date_list [dt_ansi_to_list $date]
        set month [lindex $date_list 1]
        set year [lindex $date_list 0]
	
        set first_of_month_date "$year-$month-01"
        set last_of_month_date  "$year-$month-[dt_num_days_in_month $year $month]"
	
        set items [ns_set create]
	
        # do not show closed items if the user requests not to
        if {[string is true $hide_closed_p]} {
            set hide_closed_clause " and s.status_type = 'o' "
        } else {
            set hide_closed_clause ""
        }
	
	set selected_users [pm::calendar::users_to_view]
	set selected_users_clause " and i.item_id in (select project_id from pm_project_assignment where party_id in ([join $selected_users ", "]))"
	
        set last_project_id ""
        set deadline ""
        set assignee_list [list]
	
	
	db_foreach select_monthly_projects_by_deadline {} {
	    set base_url [apm_package_url_from_id $instance_id]
	    
	    # highlight what you're assigned to.
	    #if {[string equal $person_id $user_id]} {
	    #	set font_begin "<span class=\"selected\">"
	    #set font_end "</span>"
	    #} #else {
	    set font_begin ""
	    set font_end ""
	    #}
	    
	    #if { \
		\#	     ![empty_string_p $is_lead_p] && \
	\#	     [string is true $is_lead_p]} {
	#	
	#	set font_begin "$font_begin<i>"
	#	set font_end "</i>$font_end"
	#    }
	    
	    #if this is another row of the same item, just add the name.
	    if {![string equal $last_project_id $project_id]} {
		# this is the beginning of an item.
		
		# save the last item for output
		    if {![empty_string_p $last_project_id]} {
			ns_set put $items $deadline "${day_details}</ul></p></span>"
		    }
		    
		    # set up the next item for output
		    
		    set detail_begin ""
			set detail_end ""

		    
		    # begin setting up this calendar item
		    set day_details "<span class=\"calendar-item\"><p>${detail_begin}<a href=\"${base_url}one?project_id=$project_id\">$project_id</a><br />$project_name${detail_end}"
		    
		    # only add to the list if we want to see closed projects
		    append day_details "<ul><li>${font_begin}${full_name}${font_end}</li>"
		    
		}
	    
	    set last_project_id $project_id
	    set deadline $deadline_j
	}
	
	if {![empty_string_p $last_project_id ]} {
		
	    ns_set put $items $deadline "$day_details</ul></p></span>"
	}
	
	
	# Display stuff
	set day_number_template "<font size=2>$day_template</font>"
	
	return [dt_widget_month -calendar_details $items -date $date \
		    -master_bgcolor black \
		    -header_bgcolor lavender \
		    -header_text_color black \
		    -header_text_size "+1" \
		    -day_header_bgcolor lavender \
		    -day_bgcolor white \
		    -today_bgcolor #FFF8DC \
		    -empty_bgcolor lightgrey \
		    -day_text_color black \
		    -prev_next_links_in_title 1 \
		    -prev_month_template $prev_nav_template \
		    -next_month_template $next_nav_template \
		    -day_number_template $day_number_template]
	
    }
    
    
}
