# Set up links in the navbar that the user has access to

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set page_url [ad_conn url]
set page_query [ad_conn query]

if {[string is false [empty_string_p $page_query]]} {
    set page_query "?$page_query"
}

set logger_url [pm::util::logger_url]


set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# The links used in the navbar on format url1 label1 url2 label2 ...
set link_list {}

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]


if { [ad_conn user_id] != 0} {
    if { [empty_string_p $project_item_id] } {
	lappend link_list [list "${package_url}tasks"]
    } else { 
	lappend link_list [list [export_vars -base "${package_url}tasks" {{pid_filter $project_item_id}}]]
    }
		       
    lappend link_list {}
    lappend link_list "[_ project-manager.Tasks]"
    
    if { $daily_p} {
	lappend link_list [list "${package_url}task-calendar"]
    } else {
	lappend link_list [list "${package_url}task-week-calendar"]
    }
    lappend link_list {}
    lappend link_list "[_ project-manager.Task_Calendar]"

    lappend link_list [list "${package_url}projects?assignee_id=${user_id}"]
    lappend link_list {}
    lappend link_list "[_ project-manager.Projects]"

    lappend link_list [list "${package_url}processes"]
    lappend link_list {}
    lappend link_list "[_ project-manager.Processes]"

    if [empty_string_p $project_item_id] {
	lappend link_list [list "[export_vars -base ${logger_url} {user_id {project_manager_url $package_url}}]"]
    } else {
	set logger_project_id [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]
	lappend link_list [list "[export_vars -base ${logger_url} {{project_manager_url $package_url} {project_id $logger_project_id}}]"]
    }
    lappend link_list {}
    lappend link_list "[_ project-manager.Logger]"

    lappend link_list [list "${package_url}task-select-project"]
    lappend link_list {}
    lappend link_list "[_ project-manager.Add_task]"
}

if { $admin_p } {
    lappend link_list [list "${package_url}admin/"]
    lappend link_list {}
    lappend link_list "[_ project-manager.Admin]"
}


# Convert the list to a multirow and add the selected_p attribute
multirow create links name url selected_p
foreach {url_list param_list label} $link_list {
    set selected_p 0

    foreach url $url_list {

        if {[string equal "$page_url$page_query" $url]} {
            set selected_p 1
        }
    }


    if { ![empty_string_p $param_list] } {
        append url "?[export_vars $param_list]"
    }

    multirow append links $label $url $selected_p
}

ad_return_template
