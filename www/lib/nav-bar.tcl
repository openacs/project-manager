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


if { [ad_conn user_id] != 0} {
    if { [empty_string_p $project_item_id] } {
	lappend link_list [list "${package_url}tasks"]
    } else { 
	lappend link_list [list [export_vars -base "${package_url}tasks" {{project_item_id}}]]
    }
		       
    lappend link_list {}
    lappend link_list "Tasks"

    lappend link_list [list "${package_url}task-calendar"]
    lappend link_list {}
    lappend link_list "Task Calendar"

    lappend link_list [list "${package_url}?assignee_id=${user_id}"]
    lappend link_list {}
    lappend link_list "Projects"

    lappend link_list [list "${package_url}processes"]
    lappend link_list {}
    lappend link_list "Processes"

    if [empty_string_p $project_item_id] {
	lappend link_list [list "[export_vars -base ${logger_url} {user_id {project_manager_url $package_url}}]"]
    } else {
	set logger_project_id [pm::project::get_logger_project -project_item_id $project_item_id]
	lappend link_list [list "[export_vars -base ${logger_url} {{project_manager_url $package_url} {project_id $logger_project_id}}]"]
    }
    lappend link_list {}
    lappend link_list "Logger"

    lappend link_list [list "${package_url}task-select-project"]
    lappend link_list {}
    lappend link_list "Add task"
}

if { $admin_p } {
    lappend link_list [list "${package_url}admin/"]
    lappend link_list {}
    lappend link_list "Admin"
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
