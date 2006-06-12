if [template::util::is_nil context] { set context {}}

set package_url [ad_conn package_url]

if { ![info exists header_stuff] } { set header_stuff {} }

if { ![info exists project_item_id] } { set project_item_id "" }

# Set up links in the navbar that the user has access to

set user_id [ad_conn user_id]
set package_id [ad_conn package_id]
set package_url [ad_conn package_url]
set page_url [ad_conn url]
set page_query [ad_conn query]

if {[string is false [empty_string_p $page_query]]} {
    set page_query "?$page_query"
}

set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# The links used in the navbar on format url1 label1 url2 label2 ...
set link_list {}


if { [ad_conn user_id] != 0} {
    if { [empty_string_p $project_item_id] } {
	lappend link_list [list "${package_url}tasks"]
    } else { 
	lappend link_list [list [export_vars -base "${package_url}tasks" {{pid_filter $project_item_id}}]]
    }
		       
    lappend link_list "[_ project-manager.Tasks]"

    lappend link_list [list "${package_url}task-calendar"]
    lappend link_list "[_ project-manager.Task_Calendar]"

    lappend link_list [list "${package_url}?assignee_id=${user_id}"]
    lappend link_list "[_ project-manager.Projects]"
}

if { $admin_p } {
    lappend link_list [list "${package_url}admin/"]
    lappend link_list "[_ project-manager.Admin]"
}

set navbar_list ""
foreach {navbar_url navbar_title} $link_list {
    lappend navbar_list [list "$navbar_url" "$navbar_title"]
}
