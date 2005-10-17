# /packages/project-manager/lib/search-jobid.tcl
#
# Include that searchs for the jobid of a project (project name)
# and redirects to the found project
# 
# @author Miguel Marin (miguelmarin@viaro.net)
# @author Viaro Networks www.viaro.net
#
# Usage:
# ADP File:
# <include src="/packages/project-manager/lib/search-jobid">
#
# Expects:
# keyword

set output ""

ad_form -name search_jobid -form {
    {keyword:text(text)
	{label "[_ project-manager.Jobid]:"}
	{help_text "[_ project-manager.Jobid_help]"}
	{html {size 20}}
    }
} -on_submit {

    set project_item_id [db_string get_project { } -default 0]

    if { [string equal $project_item_id 0] } {
	set projects_list [db_list_of_lists get_projects { }]
	if { [string equal [llength $projects_list] 0] } {
	    append output "<b>Available Options:</b><br>&nbsp;&nbsp;&nbsp;&nbsp;<i>No Match</i>"
	} else {
	    append output "<b>Available Options:</b><br><ul>"
	    foreach project $projects_list {
		append output "<table><tr><td><li>[lindex $project 1]</td>"
		append output "<td><a href=\"one?project_item_id=[lindex $project 0]\">Go</a></td></tr></table>"
	    }
	    append output "</ul>"
	}
    } else {
	ad_returnredirect "one?project_item_id=$project_item_id"
    }
}