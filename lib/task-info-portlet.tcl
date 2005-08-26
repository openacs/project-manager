# packages/project-manager/lib/project-portlet.tcl
#
# Portlet for short project information
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c502a3ed-d1c0-4217-832a-6ccd86256024
# @cvs-id $Id$

set user_id [auth::require_login]
set urgency_threshold 8
set task_term       [_ project-manager.Task]
set task_term_lower [_ project-manager.task]

set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]

set task_id $task_info(item_id)
set print_link "task-print?&task_id=$task_info(item_id)&project_item_id=$task_info(project_item_id)"

# Set the link to the permissions page
set permissions_url "[site_node::closest_ancestor_package -package_key subsite]/permissions/one?[export_vars {{object_id $task_id}}]"

# set link to comments

set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 $task_id "[pm::task::get_url $task_id]"]

set comments_link "<a href=\"[export_vars -base "comments/add" {{ object_id $task_id} {title "$task_info(task_title)"} {return_url [ad_return_url]} {type task} }]\">[_ project-manager.Add_comment]</a>"

# ------------------
# Dynamic Attributes
# ------------------

set form_attributes [list]
foreach element [dtype::form::metadata::widgets_list -object_type pm_task -exclude_static_p 1 -dform $task_info(dform)] {
    lappend form_attributes [lindex $element 3]
}

dtype::get_object -object_id $task_revision_id -object_type pm_task -array dattr -exclude_static

multirow create dynamic_attributes name value
foreach attr [array names dattr] {
    if {[lsearch -exact $form_attributes $attr] > -1} {
	multirow append dynamic_attributes "[_ acs-translations.pm_task_$attr]" $dattr($attr)
    }
}


