ad_page_contract {
    Main view page for one project. Also shows logged time, and allows a 
    user to log time

    @author jader@bread.com, ncarroll@ee.usyd.edu.au
    @creation-date 2003-05-15
    @cvs-id $Id$

    @return context Context bar.
    @return versions a multirow holding versions of the project
    @return live_revision the project_id of the live_revision

    @param project_name
    @param project_code
    @param project_folder_id
    @param goal
    @param description
    @param planned_start_date
    @param planned_end_date
    @param ongoing_p
    @param use_goal_p Specifies whether or not to include the goal field 1 = yes
    @param use_project_code_p Specifies whether or not to show the user-specified project code 1 = yes
    @param use_uncertain_completion_times_p Specifies whether or not to use PERT style uncertainty times 1 = yes
    @param logger_days The number of days back to view logged entries
    @param instance_id The process instance ID to show for tasks
} {

    project_item_id:integer,optional
    project_id:integer,optional
    {orderby_subproject ""}
    {orderby_tasks ""}
    {logger_variable_id:integer ""}
    {logger_days:integer "30"}
    {instance_id:integer ""}

} -properties {
    categories:onelist
    my_title:onevalue
    context:onevalue
    project:multirow
    people:multirow
    tasks:multirow
    people:multirow
    write_p:onevalue
    create_p:onevalue
    custom:multirow
    parent_task_id:onevalue
    task_type:onevalue
    project_id:onevalue
    use_goal_p:onevalue
    use_project_code_p:onevalue
    use_uncertain_completion_times_P:onevalue
    use_project_customizations_p:onevalue
    task_term:onevalue
    then_ansi:onevalue
    edit_url:onevalue
    comments:onevalue
    comments_link:onevalue
} -validate {
    project_exists {
        if {![exists_and_not_null project_item_id] && \
                ![exists_and_not_null project_id]} {

            ad_complain "[_ project-manager.No_project_passed_in]"

        }
    }
    project_item_id_exists {
        if {![exists_and_not_null project_item_id] && [exists_and_not_null project_id]} {
            set project_item_id [pm::project::get_project_item_id \
                                     -project_id $project_id]
        }
    }
    project_id_exists {
        if {![exists_and_not_null project_id] && [exists_and_not_null project_item_id]} {
            set project_id [pm::project::get_project_id \
                                -project_item_id $project_item_id]
        }
    }
    logger_days_positive {
        if {$logger_days < 1} {
            set logger_days 1
        }
    }
}

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

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

# Get Project Information
db_1row project_query { } -column_array project

# Context Bar and Title information
set portlet_master "/packages/project-manager/lib/portlet"
set project_root [pm::util::get_root_folder -package_id $package_id]
set my_title "$project_term \#$project_item_id: $project(project_name)"

set forum_id [application_data_link::get_linked -from_object_id $project(item_id) -to_object_type "forums_forum"]
set folder_id [application_data_link::get_linked -from_object_id $project(item_id) -to_object_type "content_folder"]


# set up context bar, needs project(parent_id)
if {[string equal $project(parent_id) $project_root]} {
    set context [list "$project(project_name)"]
} else {
    set parent_name [pm::util::get_project_name -project_item_id $project(parent_id)]
    set context [list [list "one?project_item_id=$project(parent_id)" "$parent_name"] "$project(project_name)"]
}


ad_return_template
# ------------------------- END OF FILE ------------------------- #
