# packages/project-manager/lib/project-portlet.tcl
#
# Portlet for short project information
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c502a3ed-d1c0-4217-832a-6ccd86256024
# @cvs-id $Id$

set user_id [auth::require_login]

# terminology and other parameters
set project_term       [_ project-manager.Project]
set use_goal_p         [parameter::get -parameter "UseGoalP" -default "1"]
set use_project_code_p [parameter::get -parameter "UseUserProjectCodesP" -default "1"]
set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]
# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

#------------------------
# Check if the project will be handled on daily basis or will show hours and minutes
#------------------------

set fmt "%x %r"
if { $daily_p } {
    set fmt "%x"
} 

db_1row project_query { } -column_array project

set project(planned_start_date) [lc_time_fmt $project(planned_start_date) $fmt]
set project(planned_end_date)   [lc_time_fmt $project(planned_end_date) $fmt]
set project(estimated_finish_date) [lc_time_fmt $project(estimated_finish_date) $fmt]
set project(earliest_finish_date) [lc_time_fmt $project(earliest_finish_date) $fmt]
set project(latest_finish_date) [lc_time_fmt $project(latest_finish_date) $fmt]
