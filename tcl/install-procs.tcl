ad_library {

    Project manager install library

    Procedures that deal with installing, instantiating, mounting.

    @creation-date 2003-01-31
    @author Jade Rubick <jader@bread.com>
    @copied-from Lars Pind <lars@collaboraid.biz>
    @cvs-id $Id$
}

namespace eval pm::install {}

ad_proc -private pm::install::package_install {
} {
    Package install callback proc.
} {

    # Create pm_project

    dtype::create -name {pm_project} -supertype {content_revision} -pretty_name {[_ project-manager.Project_1]} -pretty_plural {[_ project-manager.Projects]} -table_name {pm_projects} -id_column {project_id}
    content::type::attribute::new -content_type {pm_project} -attribute_name {project_code} -datatype {string} -pretty_name {[_ project-manager.Project_code]} -pretty_plural {[_ project-manager.Project_codes]} -column_spec {varchar(255)}
    content::type::attribute::new -content_type {pm_project} -attribute_name {goal} -datatype {string} -pretty_name {[_ project-manager.Project_goal]} -pretty_plural {[_ project-manager.Project_goals]} -column_spec {varchar(4000)}
    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_start_date} -datatype {date} -pretty_name {[_ project-manager.Planned_start_date]} -pretty_plural {[_ project-manager.Planned_start_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_end_date} -datatype {date} -pretty_name {[_ project-manager.Planned_end_date]} -pretty_plural {[_ project-manager.Planned_end_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_start_date} -datatype {date} -pretty_name {[_ project-manager.Actual_start_date]} -pretty_plural {[_ project-manager.Actual_start_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_end_date} -datatype {date} -pretty_name {[_ project-manager.Actual_end_date]} -pretty_plural {[_ project-manager.Actual_end_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {status_id} -datatype {integer} -pretty_name {[_ project-manager.Status_1]} -pretty_plural {[_ project-manager.Status_1]} -column_spec {integer}
    content::type::attribute::new -content_type {pm_project} -attribute_name {ongoing_p} -datatype {string} -pretty_name {[_ project-manager.Project_ongoing]} -pretty_plural {[_ project-manager.Projects_ongoing]} -column_spec {char(1)}
    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_finish_date} -datatype {date} -pretty_name {[_ project-manager.lt_Estimated_finish_date]} -pretty_plural {[_ project-manager.lt_Estimated_finish_date_1]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {earliest_finish_date} -datatype {date} -pretty_name {[_ project-manager.Earliest_finish_date]} -pretty_plural {[_ project-manager.lt_Earliest_finish_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {latest_finish_date} -datatype {date} -pretty_name {[_ project-manager.Latest_finish_date]} -pretty_plural {[_ project-manager.Latest_finish_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_hours_completed} -datatype {number} -pretty_name {[_ project-manager.lt_Actual_hours_complete]} -pretty_plural {[_ project-manager.lt_Actual_hours_complete]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_hours_total} -datatype {number} -pretty_name {[_ project-manager.lt_Estimated_hours_total]} -pretty_plural {[_ project-manager.lt_Estimated_hours_total]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_project} -attribute_name {customer_id} -datatype {integer} -pretty_name {[_ project-manager.Customer]} -pretty_plural {[_ project-manager.Customers]} -column_spec {integer}
    content::type::attribute::new -content_type {pm_project} -attribute_name {dform} -datatype {string} -pretty_name {[_ project-manager.Dynamic_Form]} -pretty_plural {[_ project-manager.Dynamic_Forms]} -column_spec {varchar(100)}

    # Create pm_task

    dtype::create -name {pm_task} -supertype {content_revision} -pretty_name {[_ project-manager.Task]} -pretty_plural {[_ project-manager.Tasks]} -table_name {pm_tasks_revisions} -id_column {task_revision_id}
    content::type::attribute::new -content_type {pm_task} -attribute_name {end_date} -datatype {date} -pretty_name {[_ project-manager.End_date]} -pretty_plural {[_ project-manager.End_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {percent_complete} -datatype {number} -pretty_name {[_ project-manager.Percent_complete]} -pretty_plural {[_ project-manager.Percents_complete]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {estimated_hours_work} -datatype {number} -pretty_name {[_ project-manager.Estimated_hours_work]} -pretty_plural {[_ project-manager.Estimated_hours_work]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {estimated_hours_work_min} -datatype {number} -pretty_name {[_ project-manager.lt_Estimated_minimum_hou]} -pretty_plural {[_ project-manager.lt_Estimated_minimum_hou]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {estimated_hours_work_max} -datatype {number} -pretty_name {[_ project-manager.lt_Estimated_maximum_hou]} -pretty_plural {[_ project-manager.lt_Estimated_maximum_hou]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {actual_hours_worked} -datatype {number} -pretty_name {[_ project-manager.Actual_hours_worked]} -pretty_plural {[_ project-manager.Actual_hours_worked]} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {earliest_start} -datatype {date} -pretty_name {[_ project-manager.Earliest_start_date]} -pretty_plural {[_ project-manager.Earliest_start_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {earliest_finish} -datatype {date} -pretty_name {[_ project-manager.Earliest_finish_date]} -pretty_plural {[_ project-manager.lt_Earliest_finish_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {latest_start} -datatype {date} -pretty_name {[_ project-manager.Latest_start_date]} -pretty_plural {[_ project-manager.Latest_start_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {latest_finish} -datatype {date} -pretty_name {[_ project-manager.Latest_finish_date]} -pretty_plural {[_ project-manager.Latest_finish_dates]} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {priority} -datatype {integer} -pretty_name {[_ project-manager.Priority_1]} -pretty_plural {[_ project-manager.Priorities]} -column_spec {integer}
    content::type::attribute::new -content_type {pm_task} -attribute_name {dform} -datatype {string} -pretty_name {[_ project-manager.Dynamic_Form]} -pretty_plural {[_ project-manager.Dynamic_Forms]} -column_spec {varchar(100)}

    # Create new relationship type for Application Links

    rel_types::new "application_link" "Application Link" "Application Links" apm_package 0 "" apm_package 0 ""
    rel_types::new "application_data_link" "Application Data Link" "Application Data Links" acs_object 0 "" acs_object 0 ""
}

ad_proc -private pm::install::package_instantiate {
    {-package_id:required}
} {
    Package instantiation callback proc.
} {
    # create a content folder

    set folder_id [content::folder::new \
		       -name "project_manager_$package_id" -package_id $package_id -context_id $package_id]

    # register the allowed content types for a folder

    content::folder::register_content_type -folder_id $folder_id -content_type {pm_project} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {pm_task} -include_subtypes t

    callback pm::install::after_instantiate -package_id $package_id
}

ad_proc -private pm::install::package_uninstantiate {
    {-package_id:required}
} {
    Package un-instantiation callback proc
} {

    # Delete the project repository

    # ns_log Debug "pm::install::package_uninstantiate getting folder_id
    # for package_id: $package_id" set folder_id [db_exec_plsql
    # get_folder_id {}] ns_log Debug "pm::install::package_uninstantiate
    # delete folder_id: $folder_id" db_exec_plsql delete_root_folder {}
}


ad_proc -private pm::link_new_tasks {
    -object_id:required
    -linked_id:required
    -role:required
    -title:required
    {-description ""}
    {-mime_type "text/plain"}
} {
    create new tasks in linked projects and link it to the object
} {
    set user_id [ad_conn user_id]
    set ip_addr [ad_conn peeraddr]

    db_1row get_watcher_role {
	select role_id
	from pm_roles
	where one_line = :role}

    # get linked projects to folder

    foreach project_item_id [application_data_link::get_linked \
				 -from_object_id $linked_id \
				 -to_object_type "pm_project"] {
	db_1row pm_package_id {
	    select package_id as pm_package_id
	    from acs_objects
	    where object_id = :project_item_id}

	set task_id [pm::task::new \
			 -project_id $project_item_id \
			 -title $title \
			 -description $description \
			 -mime_type $mime_type \
			 -creation_user $user_id \
			 -creation_ip $ip_addr \
			 -package_id $pm_package_id \
			 -no_callback]

	set task_item_id [pm::task::get_item_id \
			      -task_id $task_id]

	pm::task::assign \
	    -task_item_id $task_item_id \
	    -party_id     $user_id \
	    -role_id      $role_id

	application_data_link::new -this_object_id $object_id -target_object_id $task_item_id
    }
}

ad_proc -private pm::install::after_upgrade {
    {-from_version_name:required}
    {-to_version_name:required}
} {
    apm_upgrade_logic \
        -from_version_name $from_version_name \
        -to_version_name $to_version_name \
        -spec {
	    2.72a1 3.0d1 {
		db_transaction {
		    content::type::attribute::new -content_type {pm_project} -attribute_name {project_code} -datatype {string} -pretty_name {[_ project-manager.Project_code]} -pretty_plural {[_ project-manager.Project_codes]} -column_spec {varchar(255)}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {goal} -datatype {string} -pretty_name {[_ project-manager.Project_goal]} -pretty_plural {[_ project-manager.Project_goals]} -column_spec {varchar(4000)}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_start_date} -datatype {date} -pretty_name {[_ project-manager.Planned_start_date]} -pretty_plural {[_ project-manager.Planned_start_dates]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_end_date} -datatype {date} -pretty_name {[_ project-manager.Planned_end_date]} -pretty_plural {[_ project-manager.Planned_end_dates]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_start_date} -datatype {date} -pretty_name {[_ project-manager.Actual_start_date]} -pretty_plural {[_ project-manager.Actual_start_dates]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_end_date} -datatype {date} -pretty_name {[_ project-manager.Actual_end_date]} -pretty_plural {[_ project-manager.Actual_end_dates]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {status_id} -datatype {integer} -pretty_name {[_ project-manager.Status_1]} -pretty_plural {[_ project-manager.Status_1]} -column_spec {integer}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {ongoing_p} -datatype {string} -pretty_name {[_ project-manager.Project_ongoing]} -pretty_plural {[_ project-manager.Projects_ongoing]} -column_spec {char(1)}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_finished_date} -datatype {date} -pretty_name {[_ project-manager.lt_Estimated_finish_date]} -pretty_plural {[_ project-manager.lt_Estimated_finish_date_1]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {earliest_finish_date} -datatype {date} -pretty_name {[_ project-manager.Earliest_finish_date]} -pretty_plural {[_ project-manager.lt_Earliest_finish_dates]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {latest_finish_date} -datatype {date} -pretty_name {[_ project-manager.Latest_finish_date]} -pretty_plural {[_ project-manager.Latest_finish_dates]} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_hours_completed} -datatype {number} -pretty_name {[_ project-manager.lt_Actual_hours_complete]} -pretty_plural {[_ project-manager.lt_Actual_hours_complete]} -column_spec {numeric}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_hours_total} -datatype {number} -pretty_name {[_ project-manager.lt_Estimated_hours_total]} -pretty_plural {[_ project-manager.lt_Estimated_hours_total]} -column_spec {numeric}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {logger_project} -datatype {integer} -pretty_name {[_ project-manager.lt_Linked_logger_project]} -pretty_plural {[_ project-manager.lt_Linked_logger_project_1]} -column_spec {integer}

		    content::type::attribute::new -content_type {pm_task} -attribute_name {priority} -datatype {integer} -pretty_name {[_ project-manager.Priority_1]} -pretty_plural {[_ project-manager.Priorities]} -column_spec {integer}
		}
	    }

	    3.0d1 3.0d2 {
		rel_types::new "application_link" "Application Link" "Application Links" apm_package 0 "" apm_package 0 ""
	    }
	    3.0d2 3.0d3 {
		rel_types::new "application_data_link" "Application Data Link" "Application Data Links" acs_object 0 "" acs_object 0 ""
	    }
	    3.0d3 3.0d4 {
		content::type::attribute::delete -content_type {pm_project} -attribute_name {logger_project}
	    }
	    3.0d4 3.0d5 {
		content::type::attribute::new -content_type {pm_project} -attribute_name {dform} -datatype {string} -pretty_name {[_ project-manager.Dynamic_Form]} -pretty_plural {[_ project-manager.Dynamic_Forms]} -column_spec {varchar(100)}
		content::type::attribute::new -content_type {pm_task} -attribute_name {dform} -datatype {string} -pretty_name {[_ project-manager.Dynamic_Form]} -pretty_plural {[_ project-manager.Dynamic_Forms]} -column_spec {varchar(100)}
	    }
	}
}
