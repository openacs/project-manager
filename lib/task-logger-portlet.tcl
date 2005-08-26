# packages/project-manager/lib/logger-portlet.tcl
#
# Portlet with logger information
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-02
# @arch-tag: 568fcb7a-e58c-4c1a-901d-a51c9d2ffe44
# @cvs-id $Id$

foreach required_param {logger_project logger_days project_item_id pm_url return_url} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {master} {
    if {![info exists $optional_param]} {
	set $optional_param [parameter::get -parameter DefaultPortletLayoutP]
    }
}

set package_url [ad_conn package_url]

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
set nextyear_ansi [clock format [clock scan "+ 365 day"] -format "%Y-%m-%d"]

#set task_info(priority) $task_info_priority
#set task_info(hours_remaining) $task_info_hours_remaining
#set task_info(hours_remaining) $task_info_percent
set day_widget "[_ project-manager.lt_Last_input_typetext_n]"