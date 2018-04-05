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
     @param pid_filter
} {
    
    project_item_id:integer,optional
    project_id:integer,optional
    pid_filter:integer,optional
    {page:integer ""}
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
                ![exists_and_not_null project_id] && ![exists_and_not_null pid_filter]} {

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
    pid_filter_exists {
	if {[exists_and_not_null pid_filter]} {
	    set project_item_id $pid_filter
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


# Retrieving the value of the parameter to know which include to call
set template_src [parameter::get -parameter "ProjectOne"]
# ------------------------- END OF FILE ------------------------- #
