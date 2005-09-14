# packages/project-manager/lib/tasks.tcl
#
# Portlet with a list of tasks and the option to create new ones 
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: a5851ee1-763c-468f-85a5-2204b8f9e411
# @cvs-id $Id$

foreach required_param {project_id project_item_id instance_id} {
    if {![info exists $required_param]} {
	return -code error "$required_param is a required parameter."
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

# Set default format to table view
if {![info exists format]} {
    set format "normal"
}

set user_id     [auth::require_login]
set task_term          [_ project-manager.Task]
set hide_done_tasks_p  [parameter::get -parameter "HideDoneTaskP" -default "1"]
set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]

set process_instance_options [pm::process::instance_options \
                                  -project_item_id $project_item_id \
                                  -process_instance_id $instance_id]

if {[empty_string_p $process_instance_options]} {
    set instance_html ""
} else {

    set instance_html "
<form action=\"one\" method=\"get\">
  [export_vars -form -entire_form -exclude {instance_id}]
  <select name=\"instance_id\">
    <option value=\"\">[_ project-manager.View_all_tasks]</option>
    $process_instance_options
  </select>
  <input type=\"submit\" name=\"submit\" value=\"[_ project-manager.Go]\" />
</form>"
}

# Process Information
set process_reminder_url [export_vars -base process-reminder {instance_id project_item_id return_url}]


# we do this so that the list builder templates don't add a where
# claus when instance_id is set.
if {[empty_string_p $instance_id]} {
    unset instance_id
}

set processes_html [pm::process::select_html]

if {![info exists instance_id]} {
    set instance_id 0
}
