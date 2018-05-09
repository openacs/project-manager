set original_project_id $project_id

# for edits of tasks. We want to come back to here.
set return_url [ad_return_url -qualified]

# --------------------------------------------------------------- #

# the unique identifier for this package
set package_id  [ad_conn package_id]
set package_url [ad_conn package_url]
set user_id     [auth::require_login]


# terminology and other parameters
set project_term       [_ project-manager.Project]
set use_project_customizations_p [parameter::get -parameter "UseProjectCustomizationsP" -default "0"]
set use_subprojects_p  [parameter::get -parameter "UseSubprojectsP" -default "0"]
set use_fs_p [apm_package_installed_p file-storage]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

# Get Project Information
db_1row project_query { } -column_array project

set project(logger_project) [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

#------------------------
# Check if the project will be handled on daily basis or will show hours and minutes
#------------------------

set fmt "%x %r"
if { $daily_p } {
    set fmt "%x"
} 


# Context Bar and Title information
set portlet_master "/packages/project-manager/lib/portlet"
set project_root [pm::util::get_root_folder -package_id $package_id]
set my_title "$project_term \#$project_item_id: $project(project_name)"

set forum_id [application_data_link::get_linked -from_object_id $project(item_id) -to_object_type "forums_forum"]

set folder_id [lindex [application_data_link::get_linked -from_object_id $project(item_id) -to_object_type "content_folder"] 0]

set parent_project_id $project_item_id
set context [list]
while {$parent_project_id ne ""} {
    set project_name [pm::util::get_project_name -project_item_id $parent_project_id]
    lappend context [list "one?project_item_id=$parent_project_id" "$project_name"]
    set parent_project_id [pm::project::parent_project_id -project_id $parent_project_id]
}

# Reverse the list (as we go up the tree but need it down the tree)

set context [struct::list reverse $context]
lappend context "$project(project_name)"