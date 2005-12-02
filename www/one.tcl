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

            ad_complain "No project passed in"

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
set project_term       [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower [parameter::get -parameter "projectname" -default "project"]
set task_term          [parameter::get -parameter "TaskName" -default "Task"]
set use_goal_p         [parameter::get -parameter "UseGoalP" -default "1"]
set hide_done_tasks_p  [parameter::get -parameter "HideDoneTaskP" -default "1"]
set use_project_code_p [parameter::get -parameter "UseUserProjectCodesP" -default "1"]
set use_uncertain_completion_times_p [parameter::get -parameter "UseUncertainCompletionTimesP" -default "1"]
set use_project_customizations_p [parameter::get -parameter "UseProjectCustomizationsP" -default "0"]
set use_subprojects_p  [parameter::get -parameter "UseSubprojectsP" -default "0"]

# permissions
permission::require_permission -party_id $user_id -object_id $package_id -privilege read

set write_p  [permission::permission_p -object_id $package_id -privilege write] 
set create_p [permission::permission_p -object_id $package_id -privilege create]


set process_instance_options [pm::process::instance_options \
                                  -project_item_id $project_item_id \
                                  -process_instance_id $instance_id]


set process_reminder_url [export_vars -base process-reminder {instance_id project_item_id return_url}]

if {[empty_string_p $process_instance_options]} {
    set instance_html ""
} else {

    set instance_html "
<form action=\"one\" method=\"get\">
  [export_vars -form -entire_form -exclude {instance_id}]
  <select name=\"instance_id\">
    <option value=\"\">View all tasks</option>
    $process_instance_options
  </select>
  <input type=\"submit\" name=\"submit\" value=\"Go\" />
</form>"
}

# we do this so that the list builder templates don't add a where
# clause when instance_id is set.
if {[empty_string_p $instance_id]} {
    unset instance_id
}

# categories

set categories [list]
set cat_list [category::get_mapped_categories $project_item_id]
foreach cat $cat_list {
    lappend categories [category::get_name $cat]
}

db_1row project_query { } -column_array project

set richtext_list [list $project(description) $project(mime_type)]

set project(description) [template::util::richtext::get_property html_value $richtext_list]

set project_root [db_exec_plsql get_root_folder { }]

set project(planned_start_date) [lc_time_fmt $project(planned_start_date) "%x"]
set project(planned_end_date)   [lc_time_fmt $project(planned_end_date) "%x"]
set project(estimated_finish_date) [lc_time_fmt $project(estimated_finish_date) "%x"]
set project(earliest_finish_date) [lc_time_fmt $project(earliest_finish_date) "%x"]
set project(latest_finish_date) [lc_time_fmt $project(latest_finish_date) "%x"]

# ----------------
# general comments
# ----------------
set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 $project_item_id "[ad_conn url]?project_item_id=$project_item_id"]

set comments_link "<a href=\"[export_vars -base "comments/add" {{ object_id $project_item_id} {title "$project(project_name)"} {return_url [ad_return_url]} {type project} }]\">Add comment</a>"

if {$use_subprojects_p} {
  set add_subproject_link "<a href\=\"[export_vars -base "add-edit" {{ parent_id $project_item_id} }]\">Add subproject</a>"
}


# we can also get the link to the logger instance.
set logger_url [pm::util::logger_url]
set logger_project_url "$logger_url?project_id=$project(logger_project)"

if {![exists_and_not_null logger_variable_id]} {
    set logger_variable_id [logger::project::get_primary_variable \
                                -project_id $project(logger_project)]
}

set variable_widget [logger::ui::variable_select_widget \
                         -project_id $project(logger_project) \
                         -current_variable_id $logger_variable_id \
                         -select_name logger_variable_id]

set variable_exports [export_vars -form -entire_form -exclude {logger_variable_id logger_days }]

set log_url "${logger_url}log?project_id=$project(logger_project)&pm_project_id=$project_item_id&return_url=$return_url&variable_id=$logger_variable_id"

# There is no point showing an empty listbox, which happens if the user assigns all roles to himself. Doing it this way avoids another trip to the database.
set select_list_html [pm::role::project_select_list -select_name "role_id" -project_item_id $project_item_id -party_id $user_id]
if {[string compare $select_list_html "<select name=\"role_id\"></select>"]} {
    set assignee_add_self_widget "Add myself as <form method=\"post\" action=\"project-assign-add\">[export_vars -form {project_item_id user_id return_url}]$select_list_html<input type=\"Submit\" value=\"OK\" /></form>"
    set roles_listbox_p 1
} else {
    set roles_listbox_p 0
}

# Only need a 'remove myself' link if you are already assigned
set assigned_p [pm::project::assigned_p -project_item_id $project_item_id -party_id $user_id]
if {$assigned_p} {
    set assignee_remove_self_url [export_vars -base project-assign-remove {project_item_id user_id return_url}]
}

set assignee_edit_url [export_vars -base project-assign-edit {project_item_id return_url}]

set today_ansi [clock format [clock scan today] -format "%Y-%m-%d"]
set then_ansi [clock format [clock scan "-$logger_days days"] -format "%Y-%m-%d"]


set day_widget "Last <input type=\"text\" name=\"logger_days\" value=\"$logger_days\" size=\"5\" /> Days"


set my_title "$project(project_name)"


set edit_url "[ad_conn package_url]add-edit?[export_url_vars project_id project_item_id]"

# set up context bar, needs parent_id
if {[string equal $project(parent_id) $project_root]} {
    set context [list "$project(project_name)"]
} else {
    set context [list [list "one?project_item_id=$project(parent_id)" "Parent"] "$project(project_name)"]
}

set processes_html [pm::process::select_html]

# Tasks, using list-builder ---------------------------------

# Hide finished tasks. This should be added as a filter, but I did not have time to look it up in the howto. <openacs@sussdorff.de>

if {$hide_done_tasks_p} {
    set done_clause "and t.percent_complete < 100"
} else {
    set done_clause ""
}

set process_link "process-use?project_item_id=$project_item_id"

set default_orderby [pm::project::one_default_orderby]

if {[exists_and_not_null orderby_tasks]} {
    pm::project::one_default_orderby \
        -set $orderby_tasks
}


template::list::create \
    -name tasks \
    -multirow tasks \
    -key task_item_id \
    -html {width 100%} \
    -elements {
        task_item_id {
            label "ID"
        }
        status_type {
            label "Done"
            display_template {
                <a href="task-add-edit?task_item_id=@tasks.task_item_id@&project_item_id=@tasks.project_item_id@"><if @tasks.status_type@ eq c><img border="0" src="/resources/checkboxchecked.gif" /></if><else><img border="0" src="/resources/checkbox.gif" /></else></a>
            }
        }
        title {
            label "Subject"
            display_template "<if @tasks.status_type@ eq o><a href=\"@tasks.item_url@\">@tasks.title@</a></if><else><a href=\"@tasks.item_url@\">@tasks.title@</a></else>"
        } 
        parent_task_id {
            label "Dep"
            display_template {
                <a href="task-one?task_id=@tasks.parent_task_id@">@tasks.parent_task_id@</a>
            }
        }
        priority {
            label "Priority"
            display_template {
		@tasks.priority@
            }
        }
        slack_time {
            label "Slack"
            display_template "
            <if @tasks.status_type@ eq o and @tasks.slack_time@>
              <font size=\"-2\" color=\"777777\">
                @tasks.slack_time@
              </font>
            </if>"
        }
        earliest_start {
            label "Earliest Start"
            display_template "<if @tasks.days_to_earliest_start@ gt 1 or @tasks.status_type@ ne o>@tasks.earliest_start_pretty@</if><else><font color=\"00ff00\">@tasks.earliest_start_pretty@</font></else>"
        }
        earliest_finish {
            label "Earliest Finish"
            display_template "<if @tasks.days_to_earliest_finish@ gt 1 or @tasks.status_type@ ne o>@tasks.earliest_finish_pretty@</if><else><font color=\"00ff00\">@tasks.earliest_finish_pretty@</font></else>"
        }
        latest_start {
            label "Latest Start"
            display_template "<if @tasks.days_to_latest_start@ gt 1 or @tasks.status_type@ ne o>@tasks.latest_start_pretty@</if><else><font color=\"red\">@tasks.latest_start_pretty@</font></else>"
        }
        latest_finish {
            label "Latest Finish"
            display_template "<if @tasks.days_to_latest_finish@ gt 1 or @tasks.status_type@ ne o>@tasks.latest_finish_pretty@</if><else><font color=\"red\">@tasks.latest_finish_pretty@</font></else>"
        }
        last_name {
            label "Who"
            display_template {
                <group column="task_item_id">
                  <if @tasks.person_id@ eq @tasks.my_user_id@>
                    <span class="selected">
                  </if>
                  <if @tasks.is_lead_p@><i></if>
                  @tasks.first_names@&nbsp;@tasks.last_name@
                  <if @tasks.is_lead_p@></i></if>
                  <if @tasks.person_id@ eq @tasks.my_user_id@>
                    </span>
                  </if>
                  <br>
                </group>
            }

        }
    } \
    -bulk_actions {
        "Edit" "task-add-edit" "Edit tasks"
    } \
    -bulk_action_export_vars {
        project_item_id
        {return_url}
    } \
    -sub_class {
        narrow
    } \
    -filters {
        project_item_id {
            hide_p 1
        }
        instance_id {
            hide_p 1
            where_clause {ti.process_instance = :instance_id}
        }
        orderby_subproject {
            hide_p 1
        }
        orderby_people {
            hide_p 1
        }
    } \
    -orderby {
        default_value $default_orderby
        title {
            orderby_asc "title asc, task_item_id asc"
            orderby_desc "title desc, task_item_id desc"
            default_direction asc
        }
        priority {
            orderby_asc "priority, earliest_start, task_item_id asc, u.first_names, u.last_name"
            orderby_desc "priority desc, earliest_start desc, task_item_id desc, u.first_names, u.last_name"
            default_direction desc
        }
        earliest_start {
            orderby_asc "earliest_start, task_item_id asc, u.first_names, u.last_name"
            orderby_desc "earliest_start desc, task_item_id desc, u.first_names, u.last_name"
            default_direction asc
        }
        earliest_finish {
            orderby_asc "earliest_finish, task_item_id asc, u.first_names, u.last_name"
            orderby_desc "earliest_finish desc, task_item_id desc, u.first_names, u.last_name"
            default_direction asc
        }
        latest_start {
            orderby_asc "latest_start, task_item_id asc, u.first_names, u.last_name"
            orderby_desc "latest_start desc, task_item_id desc, u.first_names, u.last_name"
            default_direction asc
        }
        latest_finish {
            orderby_asc "latest_finish, task_item_id asc, u.first_names, u.last_name"
            orderby_desc "latest_finish desc, task_item_id desc, u.first_names, u.last_name"
            default_direction asc
        }
    } \
    -orderby_name orderby_tasks


db_multirow -extend { item_url earliest_start_pretty earliest_finish_pretty latest_start_pretty latest_finish_pretty slack_time my_user_id} tasks project_tasks_query {
} {
    set item_url [export_vars -base "task-one" { {task_id $task_item_id}}]

    set earliest_start_pretty [lc_time_fmt $earliest_start "%x"]
    set earliest_finish_pretty [lc_time_fmt $earliest_finish "%x"]
    set latest_start_pretty [lc_time_fmt $latest_start "%x"]
    set latest_finish_pretty [lc_time_fmt $latest_finish "%x"]

    set slack_time [pm::task::slack_time \
                        -earliest_start_j $earliest_start_j \
                        -today_j $today_j \
                        -latest_start_j $latest_start_j]

    set my_user_id $user_id
}


if {$use_subprojects_p} {

    # Subprojects, using list-builder ---------------------------------
    
    db_multirow subproject project_subproject_query { }
    
    template::list::create \
        -name subproject \
        -multirow subproject \
        -key item_id \
        -elements {
            project_name {
                label "Subject"
                display_template { <a href=\"@subproject.item_url@\">@subproject.project_name@</a> }
            }
            actual_hours_completed {
                label "Hours completed"
            }
        } \
        -sub_class {
            narrow
        } \
        -filters {
            project_item_id {}
            orderby_tasks {}
            orderby_people {}
        } \
        -html {
            width 100%
        }
    
    
    
    db_multirow -extend { item_url } subproject project_subproject_query {
    } {
        set item_url [export_vars -base "one" {project_item_id $item_id}]
    }
}

# People, using list-builder ---------------------------------

db_multirow people project_people_query { }

template::list::create \
    -name people \
    -multirow people \
    -key item_id \
    -elements {
        user_name {
            label "Who"
            display_template {
                <if @people.is_lead_p@><i></if>
                @people.user_name@
                <if @people.is_lead_p@></i></if>
            }
        }
        role_name {
            label "Role"
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        party_id {}
        orderby_subproject {}
        orderby_tasks {}
    } \
    -orderby {
        role_id {orderby role_id}
        default_value role_id,desc
    } \
    -orderby_name orderby_subproject \
    -html {
        width 100%
    }


db_multirow -extend { item_url } people project_people_query {
} {

}



# -------------------------CUSTOMIZATIONS--------------------------
# If there are customizations, put them in a multirow called custom
# -----------------------------------------------------------------

db_1row custom_query { } -column_array custom 

set customer_link "[site_node::get_package_url -package_key organizations]one?organization_id=$custom(customer_id)"

# end of customizations


ad_return_template
# ------------------------- END OF FILE ------------------------- #
