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
    ad_returnredirect [pm::project::search_url -keyword $keyword]
} -has_submit {1}