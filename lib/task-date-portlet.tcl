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

# format the hours remaining section

set task_info(hours_remaining) \
    [pm::task::hours_remaining \
         -estimated_hours_work $task_info(estimated_hours_work) \
         -estimated_hours_work_min $task_info(estimated_hours_work_min) \
         -estimated_hours_work_max $task_info(estimated_hours_work_max) \
         -percent_complete $task_info(percent_complete)]

set task_info(days_remaining) \
    [pm::task::days_remaining \
         -estimated_hours_work $task_info(estimated_hours_work) \
         -estimated_hours_work_min $task_info(estimated_hours_work_min) \
         -estimated_hours_work_max $task_info(estimated_hours_work_max) \
         -percent_complete $task_info(percent_complete)]

# format the dates according to the local settings
set task_info(earliest_start)  [lc_time_fmt $task_info(earliest_start) "%x"]
set task_info(earliest_finish) [lc_time_fmt $task_info(earliest_finish) "%x"]
set task_info(latest_start)    [lc_time_fmt $task_info(latest_start) "%x"]
set task_info(latest_finish)   [lc_time_fmt $task_info(latest_finish) "%x"]
set task_info(end_date)        [lc_time_fmt $task_info(end_date) "%x"]

