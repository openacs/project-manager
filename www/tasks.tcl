ad_page_contract {

    Main view page for tasks.

    @author jader@bread.com
    @author openacs@sussdorff.de (MS)
    @creation-date 2003-12-03
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return tasks Multirow data set of tasks
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)

    @param mine_p is used to make the default be the user, but
    still allow people to view everyone.

} {
    {tasks_orderby ""}
    {filter_party_id ""}
    {searchterm ""}
    {status_id "1"}
    {page ""}
    {page_size 25}
    {page_num ""}
    role_id:optional
    {pid_filter ""}
    {instance_id ""}
    {is_observer_filter ""}
    {filter_package_id ""}
    {role_id ""}
    {base_url ""}
    {subproject_tasks ""}
} -properties {
    task_term:onevalue
   context:onevalue
    tasks:multirow
    hidden_vars:onevalue
}


# --------------------------------------------------------------- #

if {[exists_and_not_null pid_filter]} {
    set passed_project_item_id $pid_filter
} else {
    set passed_project_item_id 0
}

# how to get back here
set return_url [ad_return_url -qualified]

# set up context bar
set context [list "[_ project-manager.Tasks]"]

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# If we are in .LRN, then filter by package_id. This is actually a crude hack...
if {[expr [string match "/dotlrn/*" [ad_conn url]]]} {
    set com_id [dotlrn_community::get_community_id]
    if { [empty_string_p $com_id] } {
	# We are inside dotlrn but not in a community
	set filter_package_id ""
    } else {
	set filter_package_id $package_id
    }
}

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

#------------------------
# Check if the project will be handled on daily basis or will show hours and minutes
#------------------------

set fmt "%x %r"
if { $daily_p } {
    set fmt "%x"
} 


