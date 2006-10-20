# /packages/project-manager/lib/search-jobid.tcl
#
# Include that searchs for the name or the project_code of a project (project name)
# and redirects to the found project if it's just one and to the
# first one if there are various.
# 
#
# This should probably rewritten to return a list of found projects. Maybe someone else cares to do it.
#
# Usage:
# ADP File:
# <include src="/packages/project-manager/lib/search-contact" keyword="@keyword@" return_url="@return_url@">
#
# Expects:
# keyword     The keyword to search projects
# return_url  The return_url to return if no project is found. It would be the same page if empty.

if { ![exists_and_not_null return_url] } {
    set return_url [ad_return_url]
}

set focus_message "if(this.value=='[_ project-manager.search_project]')this.value='';"
set blur_message "if(this.value=='')this.value='[_ project-manager.search_project]';"

ad_form -name search_project -form {
    {keyword:text(text)
	{html {size 20 onfocus "$focus_message" onblur "$blur_message" class search_project}}
	{value "[_ project-manager.search_project]"}
    }
    {return_url:text(hidden) {value $return_url}}
} -on_submit {
    set match_projects [db_list_of_lists get_projects { }]
    set match_length [llength $match_projects]
    if { [string equal $match_length 0] } {
	# No Match, run additional search
	set match_projects [db_list_of_lists get_projects_by_code { }]
	set match_length [llength $match_projects]
	if { [string equal $match_length 0] } {
	    # No Match just redirect
	    ad_returnredirect $return_url
	}
    }

    set project_item_id [lindex [lindex $match_projects 0] 0]
    set object_package_id [lindex [lindex $match_projects 0] 1]
    
    # We get the node_id from the package_id and use it 
    # to get the url of the project-manager
    set pm_node_id [site_node::get_node_id_from_object_id -object_id $object_package_id]
    set pm_url [site_node::get_url -node_id $pm_node_id]

    # Just redirect to the pm_url and project_item_id
    ad_returnredirect "${pm_url}one?project_item_id=$project_item_id"
} -has_submit {1}