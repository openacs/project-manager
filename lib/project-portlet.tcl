# packages/project-manager/lib/project-portlet.tcl
#
# Portlet for short project information
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c502a3ed-d1c0-4217-832a-6ccd86256024
# @cvs-id $Id$

set user_id [auth::require_login]
# Set the link to the permissions page
set permissions_url "[site_node::closest_ancestor_package -package_key subsite]/permissions/one?[export_vars {{object_id $project_item_id}}]"

# terminology and other parameters
set project_term       [_ project-manager.Project]
set use_goal_p         [parameter::get -parameter "UseGoalP" -default "1"]
set use_project_code_p [parameter::get -parameter "UseUserProjectCodesP" -default "1"]

db_1row project_query { } -column_array project

set richtext_list [list $project(description) $project(mime_type)]
set project(description) [template::util::richtext::get_property html_value $richtext_list]
set project_root [pm::util::get_root_folder]

set project(planned_start_date) [lc_time_fmt $project(planned_start_date) "%x"]
set project(planned_end_date)   [lc_time_fmt $project(planned_end_date) "%x"]
set project(estimated_finish_date) [lc_time_fmt $project(estimated_finish_date) "%x"]
set project(earliest_finish_date) [lc_time_fmt $project(earliest_finish_date) "%x"]
set project(latest_finish_date) [lc_time_fmt $project(latest_finish_date) "%x"]
set edit_url "[ad_conn package_url]add-edit?[export_url_vars project_item_id]"

# ------------------
# Dynamic Attributes
# ------------------

set form_attributes [list]
foreach element [dtype::form::metadata::widgets_list -object_type pm_project -exclude_static_p 1 -dform $project(dform)] {
    lappend form_attributes [lindex $element 3]
}

dtype::get_object -object_id $project_id -object_type pm_project -array dattr -exclude_static

multirow create dynamic_attributes name value
foreach attr [array names dattr] {
    if {[lsearch -exact $form_attributes $attr] > -1} {
	multirow append dynamic_attributes "[_ acs-translations.pm_project_$attr]" $dattr($attr)
    }
}
