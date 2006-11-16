# packages/project-manager/lib/logger-portlet.tcl
#
# Portlet with logger information
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-02
# @arch-tag: 568fcb7a-e58c-4c1a-901d-a51c9d2ffe44
# @cvs-id $Id$

foreach required_param {project_item_id pm_url return_url} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {master} {
    if {![info exists $optional_param]} {
	set $optional_param [parameter::get -parameter DefaultPortletLayoutP]
    }
}

set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]

# Get the current logger project
set logger_project [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]

# And get the subprojects as well.
set logger_projects [list $logger_project]
foreach subproject_id [pm::project::get_all_subprojects -project_item_id $project_item_id] {
    set logger_project_id [lindex [application_data_link::get_linked -from_object_id $subproject_id -to_object_type logger_project] 0]
    if {![string eq "" $logger_project_id]} {
	lappend logger_projects $logger_project_id
    }
}

# we can also get the link to the logger instance.
set logger_url [pm::util::logger_url]
set logger_project_url "$logger_url?project_id=$logger_project"

if {![exists_and_not_null logger_variable_id]} {
    set logger_variable_id [logger::project::get_primary_variable \
                                -project_id $logger_project]
}

set variable_widget [logger::ui::variable_select_widget \
                         -project_id $logger_project \
                         -current_variable_id $logger_variable_id \
                         -select_name logger_variable_id]

set variable_exports [export_vars -form -entire_form -exclude {logger_variable_id logger_days }]

set log_url "${logger_url}log?project_id=$logger_project&pm_project_id=$project_item_id&return_url=$return_url&variable_id=$logger_variable_id"


set today_ansi [clock format [clock scan today] -format "%Y-%m-%d"]
set then_ansi [clock format [clock scan "-$logger_days days"] -format "%Y-%m-%d"]


set day_widget "[_ project-manager.lt_Last_input_typetext_n]"
