# packages/project-manager/lib/project-list.tcl
# List of all projects
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-23
# @arch-tag: 2f586eec-4768-42ef-a09a-4950ac00ddaf
# @cvs-id $Id$

# Pagination and orderby:
# ---------------------- 
# page        The page to show on the paginate.
# page_size   The number of rows to display in the list
# orderby_p   Set it to 1 if you want to show the order by menu.
# orderby     To sort the list using this orderby value
#
# package_id  The package_id which to limit the query to.
# subprojects_p Should subprojects be displayed as well?

set required_param_list "package_id"
set optional_param_list [list orderby pm_status_id searchterm bulk_p action_p page_num page_size\
			     filter_p base_url end_date_f user_space_p hidden_vars]
set optional_unset_list [list assignee_id  date_range is_observer_p previous_status_f current_package_f subprojects_p]
set dotlrn_installed_p [apm_package_installed_p dotlrn]
set invoice_installed_p [apm_package_installed_p dotlrn-invoices]
set contacts_installed_p [apm_package_installed_p contacts]

set user_id [ad_conn user_id]
foreach required_param $required_param_list {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}

if ![exists_and_not_null page_size] {
    set page_size 25
}

set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

set fmt "%x %X"
if { $daily_p } {
    set fmt "%x"
} 

set package_ids [join $package_id ","]

foreach optional_param $optional_param_list {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

foreach optional_unset $optional_unset_list {
    if {[info exists $optional_unset]} {
	if {[empty_string_p [set $optional_unset]]} {
	    unset $optional_unset
	}
    }
}

if {![info exists format]} {
    set format "normal"
}

# initialize the pa_from_clause. It should be empty unless needed
set pa_from_clause ""

if {[empty_string_p $user_space_p] && $dotlrn_installed_p} {
    set user_space_p 0
    set dotlrn_club_id [dotlrn_community::get_community_id]
    set pm_package_id [dotlrn_community::get_package_id_from_package_key \
			   -package_key "project-manager" \
			   -community_id $dotlrn_club_id]
} else {
    set pm_package_id [ad_conn package_id]
}
# This indicates that it came from the user space
# So we check that the user has lead or player role
# to show the projects.


set assignees_filter [pm::project::assignee_filter_select -status_id $pm_status_id]

# Set status
set status_where_clause "p.status_id = :pm_status_id"
if { ![exists_and_not_null pm_status_id]} {
    set pm_status_id [pm::project::default_status_open]
} elseif { [string equal $pm_status_id "-1"] } {
    set assignees_filter [pm::project::assignee_filter_select]
    set all_status [db_list_of_lists get_all_status { select status_id from pm_project_status }]
    set all_status [join $all_status ","]
    set status_where_clause "p.status_id in ($all_status)"
}

set assignees_filter [linsert $assignees_filter 0 [list "All" "-1"]]

# Set assignee
if { ![exists_and_not_null assignee_id]} {
    set pa_from_clause ",pm_project_assignment pa"
    set assignee_where_clause "pa.party_id = :user_id and p.item_id = pa.project_id"
} elseif { [string equal $assignee_id "-1"] } {
    # assignee_id of "-1" means all assignees
    set assignee_where_clause ""
} else {
    set pa_from_clause ",pm_project_assignment pa"
    set assignee_where_clause "pa.party_id = :assignee_id and p.item_id = pa.project_id"
}

# By default we show all subprojects as well
set subprojects_from_clause ""
set subprojects_where_clause ""

if {[exists_and_not_null subprojects_p]} {
    if {[string eq "f" $subprojects_p]} {
	set subprojects_from_clause ", acs_objects ao"
	set subprojects_where_clause "ao.object_type = 'content_folder' and ao.object_id = p.parent_id"
    } else {
	unset subprojects_p
    }
} else {
    unset subprojects_p
}
   
# We want to set up a filter for each category tree.

set export_vars [export_vars -form {pm_status_id orderby}]

if {[exists_and_not_null category_id]} {
    set temp_category_id $category_id
    set pass_cat $category_id
} else {
    set temp_category_id ""
    if {[info exists category_id]} {
	unset category_id
    }
}
    
if {![empty_string_p $searchterm]} {
    
    if {[regexp {([0-9]+)} $searchterm match query_digits]} {
	set search_term_where " (upper(p.title) like upper('%$searchterm%')
 or p.item_id = :query_digits) "
    } else {
	set search_term_where " upper(p.title) like upper('%$searchterm%')"
	}
} else {
    set search_term_where ""
    }

##############################################
# Filter for planned_end_date
    if {[exists_and_not_null date_range] } {
	set start_range_f [lindex [split $date_range "/"] 0]
	set end_range_f [lindex [split $date_range "/"] 1]
	if {![empty_string_p $start_range_f] && ![empty_string_p $end_range_f]} {
	    set p_range_where "p.planned_start_date > to_timestamp(:start_range_f, 'YYYY-MM-DD') and p.planned_start_date < to_timestamp(:end_range_f, 'YYYY-MM-DD') + interval '1 day'"
	} else {
	    if {![empty_string_p $start_range_f] } {
		set p_range_where "p.planned_start_date > to_timestamp(:start_range_f, 'YYYY-MM-DD')"
	    } elseif { ![empty_string_p $end_range_f] } {
		set p_range_where "p.planned_start_date < to_timestamp(:end_range_f, 'YYYY-MM-DD') + interval '1 day'"
	    } else {
		set p_range_where ""
	    }
	}
    } else {
	set p_range_where ""
    }

##############################################

set default_orderby [pm::project::index_default_orderby]
set default_orderby "project_name,desc"

if {[exists_and_not_null orderby]} {
    pm::project::index_default_orderby \
        -set $orderby
}

# Get url of the contacts package if it has been mounted for the links on the index page.
set contacts_url [util_memoize [list site_node::get_package_url -package_key contacts]]
if {[empty_string_p $contacts_url]} {
    set contact_column "@projects.customer_name@"
} else {
    set contact_column "<a href=\"${contacts_url}@projects.customer_id@\">@projects.customer_name@</a>"
}

# Store project names and all other project individuel data
set contact_coloum "fff" 



set row_list "checkbox {}\nproject_name {}\n" 
foreach element $elements {
        append row_list "$element {}\n"
}


if {$bulk_p == 1} {
    set bulk_actions [list "[_ project-manager.Close]" "@{base_url}/bulk-close" "[_ project-manager.Close_project]" ] 
} else {
    set bulk_actions [list]
}

if {$actions_p == 1} {
	
    set actions [list  "[_ project-manager.Add_project]" "[export_vars -base "${base_url}add-edit" -url {customer_id}]" "[_ project-manager.Add_project]"]

    if {$contacts_installed_p} {
        set customer_url [site_node::get_package_url -package_key contacts]
    } else {
        set customer_url [site_node::get_package_url -package_key organizations]
    }
    
    lappend actions "[_ project-manager.Customers]" $customer_url "[_ project-manager.View_customers]"
    
    if {$invoice_installed_p} {
        lappend actions "[_ project-manager.Projects_reports]" "reports" "[_ project-manager.Projects_reports]"
    }
	
} else {
    set actions [list "Project: $community_name" "$base_url"]
}

if {[exists_and_not_null is_observer_p]} {
    set pa_from_clause ",pm_project_assignment pa, pm_roles pr"
    if { $user_space_p } {
	set user_space_clause "pa.role_id = pr.role_id and pr.is_observer_p = :is_observer_p and p.item_id = pa.project_id"
    } else {
	set user_space_clause "pa.role_id = pr.role_id and pr.is_observer_p = :is_observer_p 
                           and p.object_package_id = :package_id and p.item_id = pa.project_id"
    }
} else {
    set user_space_clause ""
}

# If this filter is provided we can see all projects for a given contact
if {$dotlrn_installed_p} {
    set organization_id [lindex [application_data_link::get_linked -from_object_id [dotlrn_community::get_community_id] -to_object_type "organization"] 0]
} else {
    set organization_id ""
}

# If this filter is provided we can watch the projects in 
# all project manager instances
if { [exists_and_not_null current_package_f] } {
    if { [string equal $current_package_f 1] } {
	set current_package_where_clause ""
    } else {
	set current_package_where_clause "and p.object_package_id = :current_package_f"
    }
} else {
    set current_package_where_clause ""
}

# We are going to create the available options for the possible pairs
# of status_id's of the projects, to have options like "where status is open and closed"
set available_status [pm::status::project_status_select]
set control_list [list]
foreach option $available_status {
    set option_name [lindex $option 0]
    set option_id   [lindex $option 1]
    lappend previous_status_options [list $option_name $option_id]
    lappend control_list $option_id
    foreach option2 $available_status {
	set option_name2 [lindex $option2 0]
	set option_id2   [lindex $option2 1]
	if {![string equal $option_name $option_name2] && \
		[string equal [lsearch -exact $control_list "${option_id2},$option_id"] "-1"] } {
	    lappend previous_status_options [list "$option_name and $option_name2" "${option_id},$option_id2"]
	    lappend control_list "${option_id},$option_id2"
	}
    }
}

if { [exists_and_not_null previous_status_f] } {
    set status_values [split $previous_status_f ","]
    if { [string equal [llength $status_values] 1] } {
	# We are looking for one version of the project
	# that has status_id like the filter.
	set previous_status_where_clause "exists ( 
                                                 select distinct 1 from pm_projectsx pf 
                                                 where pf.status_id = $previous_status_f 
                                                 and pf.item_id = p.item_id )"
    } else {
	# We are looking of one project
	set previous_status_where_clause "exists ( 
                                                 select distinct 1 from pm_projectsx pmp, pm_projectsx pmp2 
                                                 where pmp.status_id = [lindex $status_values 0] 
                                                 and pmp2.status_id = [lindex $status_values 1] 
                                                 and pmp.item_id = pmp2.item_id 
                                                 and pmp.item_id = p.item_id) "
    }
} else {
    set previous_status_where_clause ""
}
set filters [list \
		 searchterm [list \
				 label "[_ project-manager.Search_1]" \
				 where_clause {$search_term_where}
			    ] \
		 date_range [list \
				 label "[_ project-manager.Planned_end_date]" \
				 where_clause {$p_range_where}
				] \
		 pm_status_id [list \
				label "[_ project-manager.Status_1]"  \
				default_value [pm::project::default_status_open] \
				values { {All "-1"} [pm::status::project_status_select]} \
				where_clause { $status_where_clause } \
			       ] \
		 assignee_id [list \
				  label "[_ project-manager.Assignee]" \
				  default_value $user_id \
				  values { $assignees_filter } \
				  where_clause {$assignee_where_clause} 
			     ] \
		 category_id [list \
				  label Categories \
				  where_clause {c.category_id = [join [value_if_exists category_id] ","]}
			     ] \
		 user_space_p [list] \
		 start_range_f [list] \
		 end_range_f [list] \
		 subprojects_p [list \
				    label "[_ project-manager.ShowSubprojects]" \
				    values { {"[_ project-manager.True]" t } { "[_ project-manager.False]" f} } \
				    where_clause { $subprojects_where_clause }
				] \
		 is_observer_p [list \
				    where_clause { $user_space_clause }
			       ] \
		 previous_status_f [list \
					label "[_ project-manager.Previous_Status]" \
					values { $previous_status_options } \
					where_clause { $previous_status_where_clause }
				   ] \
		 current_package_f [list \
				     label "[_ project-manager.Package_Instance]" \
				     values {{"[_ acs-kernel.common_All]" 1} {"[_ project-manager.Current]" $pm_package_id}} \
				 ] \
		]

template::list::create \
    -name projects \
    -multirow projects \
    -selected_format $format \
    -key project_item_id \
    -elements {
        project_name {
	    label "[_ project-manager.Project_name]"
	    link_url_col item_url
	    link_html { title "[_ project-manager.lt_View_this_project_ver]" }
	}
	project_code {
	    label "[_ project-manager.Project_code]"
	}
	customer_name {
	    label "[_ project-manager.Customer]"
	    display_template "
<if @projects.customer_id@ not nil>$contact_column</if><else>@projects.customer_name@</else>
"
	}
	creation_date {
	    label "[_ project-manager.Creation_date]"
            display_template "@projects.creation_date_lc@"
	}
	start_date {
	    label "[_ project-manager.Start_date]"
            display_template "@projects.start_date_lc@"
	}
	earliest_finish_date {
            label "[_ project-manager.Earliest_finish]"
            display_template "<if @projects.days_to_earliest_finish@ gt 1>@projects.earliest_finish_date@</if><else><font color=\"green\">@projects.earliest_finish_date@</font></else>"
        }
        latest_finish_date {
            label "[_ project-manager.Latest_Finish]"
            display_template "<if @projects.days_to_latest_finish@ gt 1>@projects.latest_finish_date@</if><else><font color=\"red\">@projects.latest_finish_date@</font></else>"
        }
	planned_end_date {
	    label "[_ project-manager.End_date]"
            display_template "@projects.planned_end_date_lc@"
	}
	actual_hours_completed {
            label "[_ project-manager.Hours_completed]"
	    display_template "@projects.actual_hours_completed@/@projects.estimated_hours_total@"
	}
	category_id {
	    display_template "<group column=\"project_item_id\"></group>"
	}
	status_id {
	    label "[_ project-manager.Status_1]"
	    display_template {@projects.pretty_status@}
	}
    } \
    -actions $actions \
    -bulk_actions $bulk_actions \
    -sub_class {
        narrow
    } \
    -filters $filters \
    -orderby {
	default_value $default_orderby
        project_name {
	    label "[_ project-manager.Project_name]"
	    orderby_desc "upper(p.title) desc"
	    orderby_asc "upper(p.title) asc"
	    default_direction asc
	}
	project_code {
	    label "[_ project-manager.Project_code]"
	    orderby_desc "lower(p.project_code) desc"
	    orderby_asc "lower(p.project_code) asc"
	    default_direction asc
	}
	customer_name {
	    label "[_ project-manager.Customer_Name]"
	    orderby_desc "upper(o.name) desc, earliest_finish_date desc"
	    orderby_asc "upper(o.name) asc, earliest_finish_date asc"
	    default_direction asc
	    }
	category_id {
	    label "[_ project-manager.Categories]"
	    orderby_desc "c.category_name desc"
	    orderby_asc "c.category_name asc"
	    default_direction asc
	}
	creation_date {
	    label "[_ project-manager.Creation_date]"
	    orderby_desc "p.creation_date desc"
	    orderby_asc "p.creation_date asc"
	    default_direction asc
	}
	start_date {
	    label "[_ project-manager.Start_date]"
	    orderby_desc "p.planned_start_date desc"
	    orderby_asc "p.planned_start_date asc"
	    default_direction asc
	}
	planned_end_date {
	    label "[_ project-manager.End_date]"
	    orderby_desc "p.planned_end_date desc"
	    orderby_asc "p.planned_end_date asc"
	    default_direction asc
	}
	latest_finish_date {
	    label "[_ project-manager.Latest_finish]"
	    orderby_desc "p.latest_finish_date desc"
	    orderby_asc "p.latest_finish_date asc"
	    default_direction asc
	}
	actual_hours_completed {
	    label "[_ project-manager.Hours_completed]"
	    orderby_desc "p.actual_hours_completed desc"
	    orderby_asc "p.actual_hours_completed asc"
	    default_direction asc
	}
    } \
    -page_size_variable_p 1 \
    -page_size $page_size \
    -page_flush_p 0 \
    -page_query_name projects_pagination \
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
    } \
    -orderby_name orderby \
    -html {
	width 100%
    }

db_multirow -extend { item_url customer_url category_select earliest_finish_date latest_finish_date start_date_lc earliest_start_date creation_date_lc planned_end_date_lc} projects project_folders " " {
    set earliest_finish_date [lc_time_fmt $earliest_finish_date $fmt]
    set latest_finish_date [lc_time_fmt $latest_finish_date $fmt]
    set creation_date_lc [lc_time_fmt $creation_date $fmt]
    set start_date_lc [lc_time_fmt $start_date "%x"]
    set planned_end_date_lc [lc_time_fmt $planned_end_date $fmt]
    set _base_url [site_node::get_url_from_object_id -object_id $package_id]
    if {![empty_string_p $_base_url]} {
	set base_url $_base_url
    }
    
    set item_url [export_vars -base "${base_url}one" {project_item_id}]
    
    # root CR folder
    set root_folder [pm::util::get_root_folder -package_id $package_id]
    
    # set category_select [pm::util::category_selects \
			     -export_vars $export_vars \
			     -category_id $temp_category_id \
			     -package_id $package_id \
			    ] 
}

ad_return_template
# ------------------------- END OF FILE ------------------------- #


