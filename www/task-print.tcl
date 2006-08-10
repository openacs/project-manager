ad_page_contract {
    Main view page for one task.

    @author jader@bread.com
    @creation-date 2003-07-28
    @cvs-id $Id$

    @return task_term Term to use for Task
    @return task_term_lower Term to use for task
    @return assignee_term Term to use for assignee
    @return watcher_term Term to use for watcher
    @return dependency multirow that stores dependency information
    @return dependency2 multirow that stores dependency information for tasks that have dependencies on this particular task

    @param task_id item_id for the task
    @param project_item_id the item_id for the project. Used for navigational links
    @param project_id the revision_id for the project. Used for navigational links
    @param context_bar value for context bar creation
    @param orderby_revisions specifies how the revisions table will be sorted
    @param orderby_dependency specifies how the dependencies will be sorted
    @param orderby_dependency2 specifies how the dependencies will be sorted (for tasks that have dependencies on this task)
} {
    task_id:integer,optional
    task_revision_id:integer,optional
    orderby_revisions:optional
    orderby_dependency:optional
    orderby_dependency2:optional
    {show_comment_p "f"}

} -properties {
    task_info:onerow
    project_item_id:onevalue
    project_id:onevalue
    context_bar:onevalue
    write_p:onevalue
    create_p:onevalue
    revisions:multirow
    dependency:multirow
    dependency2:multirow
    people:multirow
    task_term:onevalue
    task_term_lower:onevalue
    assignee_term:onevalue
    watcher_term:onevalue
    comments:onevalue
    comments_link:onevalue
} -validate {
    task_id_exists {
	set user_id    [ad_maybe_redirect_for_registration]
        if {![info exists task_id]} {
            set task_id [db_string get_task_id { }]
        }
    }
    revision_id_exists {
	set user_id    [ad_maybe_redirect_for_registration]
        if {![info exists task_revision_id]} {
            set task_revision_id [db_string get_revision_id { }]
        }
    }
}


# --------------------------------------------------------------- #

# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]


# terminology
set task_term       [_ project-manager.Task]
set task_term_lower [_ project-manager.task]
set assignee_term   [parameter::get -parameter "AssigneeName" -default "Assignee"]
set watcher_term    [parameter::get -parameter "WatcherName" -default "Watcher"]
set project_term    [_ project-manager.Project]

db_1row get_project_ids { }

set context_bar [ad_context_bar "one?project_item_id=$project_item_id $project_term" "[_ project-manager.View]"]

set project_title [pm::project::name -project_item_id $project_item_id]

set comments [general_comments_get_comments -print_content_p 1 -print_attachments_p 1 $task_id "[ad_conn url]?task_id=$task_id"]

set comments_link [general_comments_create_link -object_name pm_task -link_text "Add a comment" -context_id $package_id $task_id "[ad_conn url]?task_id=$task_id"]

set show_comment_link "<a href=\"[ad_conn url]?task_id=$task_id&show_comment_p=t\">show comments</a>"


# permissions
permission::require_permission -party_id $user_id -object_id $task_id -privilege read

set write_p  [permission::permission_p -object_id $task_id -privilege write]
set create_p [permission::permission_p -object_id $task_id -privilege create]

# Task info ----------------------------------------------------------

db_1row task_query { } -column_array task_info

set richtext_list [list $task_info(description) $task_info(mime_type)]

set task_info(description) [template::util::richtext::get_property html_value $richtext_list]

set task_info(slack_time) [pm::task::slack_time \
                               -earliest_start_j $task_info(earliest_start_j) \
                               -today_j $task_info(today_j) \
                               -latest_start_j $task_info(latest_start_j)]

# Dependency info ------------------------------------------------

template::list::create \
    -name dependency \
    -multirow dependency \
    -key task_id \
    -elements {
        dependency_type {
            label "[_ project-manager.Type]"
            display_template {
                <if @dependency.dependency_type@ eq start_before_start>
                <img border="0" src="resources/start_before_start.png">
                </if>
                <if @dependency.dependency_type@ eq start_before_finish>
                <img border="0" src="resources/start_before_finish.png">
                </if>
                <if @dependency.dependency_type@ eq finish_before_start>
                <img border="0" src="resources/finish_before_start.png">
                </if>
                <if @dependency.dependency_type@ eq finish_before_finish>
                <img border="0" src="resources/finish_before_finish.png">
                </if>
            }
        }
        task_id {
            label "[_ project-manager.Task]"
            display_col task_title
            link_url_col item_url
            link_html { title "[_ project-manager.View_this_task]" }
        }
        percent_complete {
            label "[_ project-manager.Status_1]"
            display_template "@dependency.percent_complete@\%"
        }
        end_date {
            label "[_ project-manager.Deadline_1]"
        }
    } \
    -orderby {
        percent_complete {orderby percent_complete}
        end_date {orderby end_date}
    } \
    -orderby_name orderby_dependency \
    -sub_class {
        narrow
    } \
    -filters {
        task_revision_id {}
        orderby_revisions {}
        orderby_dependency2 {}
    } \
    -html {
        width 100%
    }

db_multirow -extend { item_url } dependency dependency_query {
} {
    set item_url [export_vars -base "task-one" -override {{task_id $parent_task_id}} { task_id }]
}

# Dependency info (dependency other task have on this task) ------

template::list::create \
    -name dependency2 \
    -multirow dependency2 \
    -key task_id \
    -elements {
        dependency_type {
            label "[_ project-manager.Type]"
            display_template {
                <if @dependency2.dependency_type@ eq start_before_start>
                <img border="0" src="resources/start_before_start.png">
                </if>
                <if @dependency2.dependency_type@ eq start_before_finish>
                <img border="0" src="resources/start_before_finish.png">
                </if>
                <if @dependency2.dependency_type@ eq finish_before_start>
                <img border="0" src="resources/finish_before_start.png">
                </if>
                <if @dependency2.dependency_type@ eq finish_before_finish>
                <img border="0" src="resources/finish_before_finish.png">
                </if>
            }
        }
        task_id {
            label "[_ project-manager.Task]"
            display_col task_title
            link_url_eval {task-one?task_id=$task_id}
            link_html { title "[_ project-manager.View_this_task]" }
        }
        percent_complete {
            label "[_ project-manager.Status_1]"
            display_template "@dependency2.percent_complete@\%"
        }
        end_date {
            label "[_ project-manager.Deadline_1]"
        }
    } \
    -orderby {
        percent_complete {orderby percent_complete}
        end_date {orderby end_date}
    } \
    -orderby_name orderby_dependency2 \
    -sub_class {
        narrow
    } \
    -filters {
        task_revision_id {}
        orderby_revisions {}
        orderby_dependency {}
    } \
    -html {
        width 100%
    }


db_multirow -extend { item_url } dependency2 dependency2_query {
} {

}

# People, using list-builder ---------------------------------

db_multirow people task_people_query { }

template::list::create \
    -name people \
    -multirow people \
    -key last_name \
    -elements {
        first_names {
            label {Who}
            display_template {
                @people.user_info@ 
            }
        }
        role_id {
            label "[_ project-manager.Role]"
            display_template "@people.one_line@"
        }
    } \
    -sub_class {
        narrow
    } \
    -filters {
        party_id {}
        task_id {}
        orderby_subproject {}
        orderby_versions {}
        tasks_orderby {}
    } \
    -orderby {
        role_id {orderby role_id}
        default_value role_id,desc
    } \
    -orderby_name orderby_people \
    -html {
    }



db_multirow -extend { item_url } subproject task_people_query {
} {

}



ad_return_template

# ------------------------- END OF FILE ------------------------- #
