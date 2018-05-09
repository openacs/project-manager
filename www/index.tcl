# packages/project-manager/www/index.tcl

ad_page_contract {

  @author malte.sussdorff@cognovis.de

  @creation-date 2000-09-18
  @cvs-id $Id$
} {
    {view "month"}
    {date ""}
    {julian_date ""}
    {hide_closed_p "t"}
    {page 1}
    {tasks_orderby priority}
    {projects_orderby project_name}
    {elements "project_item_id task_item_id title priority end_date last_name"}
    {pm_elements "subsite planned_end_date"}
} -properties {
    context:onevalue
    subsite_name:onevalue
    subsite_url:onevalue
    nodes:multirow
    admin_p:onevalue
    user_id:onevalue
    show_members_page_link_p:onevalue
}

set main_site_p [string equal [ad_conn package_url] "/"]
set date [calendar::adjust_date -date $date -julian_date $julian_date]

# We may have to redirect to some application page
set redirect_url [parameter::get -parameter IndexRedirectUrl -default {}]
if { $redirect_url eq "" && $main_site_p } {
    set redirect_url [parameter::get_from_package_key -package_key acs-kernel -parameter IndexRedirectUrl]
}
if { $redirect_url ne "" } {
    ad_returnredirect $redirect_url
    ad_script_abort
}

# Handle IndexInternalRedirectUrl
set redirect_url [parameter::get -parameter IndexInternalRedirectUrl -default {}]
if { $redirect_url eq "" && $main_site_p } {
    set redirect_url [parameter::get_from_package_key -package_key acs-kernel -parameter IndexInternalRedirectUrl]
}
if { $redirect_url ne "" } {
    rp_internal_redirect $redirect_url
    ad_script_abort
}

set context [list]
set package_id [ad_conn package_id]
set admin_p [permission::permission_p -object_id $package_id -party_id [ad_conn untrusted_user_id] -privilege admin]

set user_id [ad_conn user_id]
set untrusted_user_id [ad_conn untrusted_user_id]

# Logger dates, limit to last 30 days
set today_ansi [clock format [clock scan today] -format "%Y-%m-%d"]
set then_ansi [clock format [clock scan "-30 days"] -format "%Y-%m-%d"]
set variable_id [logger::variable::get_default_variable_id]

# Get the list of logger projects
set logger_projects [list]
db_foreach pm_projects {select project_id as project_item_id from pm_project_assignment pa,acs_objects o where pa.project_id = o.object_id and o.package_id = :package_id and party_id = :user_id} {
    lappend logger_projects [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]
    
    # And get the subprojects as well.

    foreach subproject_id [pm::project::get_all_subprojects -project_item_id $project_item_id] {
	set logger_project_id [lindex [application_data_link::get_linked -from_object_id $subproject_id -to_object_type logger_project] 0]
	if {![string eq "" $logger_project_id]} {
	    lappend logger_projects $logger_project_id
	}
    }
}

if {$logger_projects eq ""} {
    if {[apm_package_ids_from_key -package_key "logger"] eq ""} {
	# No instance of logger installed, redirect to subsite admin
	ad_returnredirect -message "You need to install logger first" "../admin/applications"
	ad_script_abort
    }
    if {[application_link::get_linked -from_package_id $package_id -to_package_key "logger"] eq ""} {
	# There is no link between PM and logger, redirect to admin linking
	ad_returnredirect -message "<font color=red>Please setup the link between project manager and logger</font>" -html "admin/linking?return_url=[ad_return_url]" 
	ad_script_abort
    }
    
    # It seems we just did not setup a project yet, go directly to add project then
    ad_returnredirect -message "You can start by adding a new project" "add-edit"
} else {
    set project_ids $logger_projects
}