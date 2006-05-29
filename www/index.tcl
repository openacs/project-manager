ad_page_contract {

    Main view page for projects.
    
    @author jader@bread.com
    @author ncarroll@ee.usyd.edu.au (on first version that used CR)
    @creation-date 2003-05-15
    @cvs-id $Id$

    @return title Page title.
    @return context Context bar.
    @return projects Multirow data set of projects.
    @return task_term Terminology for tasks
    @return task_term_lower Terminology for tasks (lower case)
    @return project_term Terminology for projects
    @return project_term_lower Terminology for projects (lower case)

} {
    {orderby ""} 
    {pm_status_id:integer,optional}
    {searchterm ""}
    {end_range_f ""}
    {start_range_f ""}
    category_id:multiple,optional
    {format "normal"}
    {assignee_id ""}
    {pm_contact_id ""}
    {pm_etat_id ""}
    {user_space_p "0"}
    {subprojects_p "f"}
    {is_observer_p ""}
    {previous_status_f ""}
    {current_package_f ""}
    {page ""}
    {page_size 25}
    {page_num ""}
    
} -properties {

    context:onevalue
    projects:multirow
    write_p:onevalue
    create_p:onevalue
    admin_p:onevalue
    task_term:onevalue
    task_term_lower:onevalue
    project_term:onevalue
    project_term_lower:onevalue
    date_range:onevalue
}

# Sending only one value to the include
set date_range "${start_range_f}/$end_range_f"

set exporting_vars { status_id category_id assignee_id orderby format pm_status_id pm_contact_id pm_etat_id previous_status_f current_package_f subprojects_p }
set hidden_vars [export_vars -form $exporting_vars]

# set up context bar
set context [list]

# the unique identifier for this package
set user_id    [ad_maybe_redirect_for_registration]
set package_id [ad_conn package_id]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read
set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]
set admin_p [permission::permission_p -object_id $package_id -privilege admin]

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

#------------------------
# Check if the project will be handled on daily basis or will show hours and minutes
#------------------------

set fmt "%x %r"
if { $daily_p } {
    set fmt "%x"
} 

# root CR folder
set root_folder [pm::util::get_root_folder -package_id $package_id]

# Set status
if {![exists_and_not_null pm_status_id]} {
    set pm_status_id ""
}

# We want to set up a filter for each category tree.
set export_vars [export_vars -form {status_id orderby}]

if {[exists_and_not_null category_id]} {
    set pass_cat $category_id
} else {
    set pass_cat ""
}

set default_orderby [pm::project::index_default_orderby]

if {[exists_and_not_null orderby]} {
    pm::project::index_default_orderby \
        -set $orderby
}

# Only display the current package unless mentioned otherwise
if {$current_package_f ne 1} {
    set current_package_f $package_id
}

# Retrieving the name of the template to call
set template_src [parameter::get -parameter "ProjectList"]
