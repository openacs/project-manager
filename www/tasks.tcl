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
    orderby:optional
    {party_id ""}
    {searchterm ""}
    {status_id ""}
    {page ""}
    {page_size 25}
    role_id:optional
    {project_item_id ""}
} -properties {
    task_term:onevalue
   context:onevalue
    tasks:multirow
    hidden_vars:onevalue
}


# --------------------------------------------------------------- #

if {[exists_and_not_null project_item_id]} {
    set passed_project_item_id $project_item_id
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


