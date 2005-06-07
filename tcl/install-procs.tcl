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
    ## Create pm_project
    dtype::create -name {pm_project} -supertype {content_revision} -pretty_name {Project} -pretty_plural {Projects} -table_name {pm_projects} -id_column {project_id}
    content::type::attribute::new -content_type {pm_project} -attribute_name {project_code} -datatype {string} -pretty_name {Project code} -pretty_plural {Project codes} -column_spec {varchar(255)}
    content::type::attribute::new -content_type {pm_project} -attribute_name {goal} -datatype {string} -pretty_name {Project goal} -pretty_plural {Project goals} -column_spec {varchar(4000)}
    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_start_date} -datatype {date} -pretty_name {Planned start date} -pretty_plural {Planned start dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_end_date} -datatype {date} -pretty_name {Planned end date} -pretty_plural {Planned end dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_start_date} -datatype {date} -pretty_name {Actual start date} -pretty_plural {Actual start dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_end_date} -datatype {date} -pretty_name {Actual end date} -pretty_plural {Actual end dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {status_id} -datatype {integer} -pretty_name {Status} -pretty_plural {Status} -column_spec {integer}
    content::type::attribute::new -content_type {pm_project} -attribute_name {ongoing_p} -datatype {string} -pretty_name {Project ongoing} -pretty_plural {Projects ongoing} -column_spec {char(1)}
    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_finish_date} -datatype {date} -pretty_name {Estimated finish date} -pretty_plural {Estimated finish dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {earliest_finish_date} -datatype {date} -pretty_name {Earliest finish date} -pretty_plural {Earliest finish dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {latest_finish_date} -datatype {date} -pretty_name {Latest finish date} -pretty_plural {Latest finish dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_hours_completed} -datatype {number} -pretty_name {Actual hours completed} -pretty_plural {Actual hours completed} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_hours_total} -datatype {number} -pretty_name {Estimated hours total} -pretty_plural {Estimated hours total} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_project} -attribute_name {customer_id} -datatype {integer} -pretty_name {Customer} -pretty_plural {Customers} -column_spec {integer}
    content::type::attribute::new -content_type {pm_project} -attribute_name {dform} -datatype {string} -pretty_name {Dynamic Form} -pretty_plural {Dynamic Forms} -column_spec {varchar(100)}

    ## Create pm_task
    dtype::create -name {pm_task} -supertype {content_revision} -pretty_name {Task} -pretty_plural {Tasks} -table_name {pm_tasks_revisions} -id_column {task_revision_id}
    content::type::attribute::new -content_type {pm_task} -attribute_name {end_date} -datatype {date} -pretty_name {End date} -pretty_plural {End dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {percent_complete} -datatype {number} -pretty_name {Percent complete} -pretty_plural {Percents complete} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {estimated_hours_work} -datatype {number} -pretty_name {Estimated hours work} -pretty_plural {Estimated hours work} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {estimated_hours_work_min} -datatype {number} -pretty_name {Estimated minimum hours} -pretty_plural {Estimated minimum hours} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {estimated_hours_work_max} -datatype {number} -pretty_name {Estimated maximum hours} -pretty_plural {Estimated maximum hours} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {actual_hours_worked} -datatype {number} -pretty_name {Actual hours worked} -pretty_plural {Actual hours worked} -column_spec {numeric}
    content::type::attribute::new -content_type {pm_task} -attribute_name {earliest_start} -datatype {date} -pretty_name {Earliest start date} -pretty_plural {Earliest start dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {earliest_finish} -datatype {date} -pretty_name {Earliest finish date} -pretty_plural {Earliest finish dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {latest_start} -datatype {date} -pretty_name {Latest start date} -pretty_plural {Latest start dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {latest_finish} -datatype {date} -pretty_name {Latest finish date} -pretty_plural {Latest finish dates} -column_spec {timestamptz}
    content::type::attribute::new -content_type {pm_task} -attribute_name {priority} -datatype {integer} -pretty_name {Priority} -pretty_plural {Priorities} -column_spec {integer}
    content::type::attribute::new -content_type {pm_task} -attribute_name {dform} -datatype {string} -pretty_name {Dynamic Form} -pretty_plural {Dynamic Forms} -column_spec {varchar(100)}

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
    set folder_id [content::folder::new -name "project_manager_$package_id" -package_id $package_id ]
    # register the allowed content types for a folder
    content::folder::register_content_type -folder_id $folder_id -content_type {pm_project} -include_subtypes t
    content::folder::register_content_type -folder_id $folder_id -content_type {pm_task} -include_subtypes t
}

ad_proc -private pm::install::package_uninstantiate {
    {-package_id:required}
} {
    Package un-instantiation callback proc
} {
    # Delete the project repository

    # ns_log Debug "pm::install::package_uninstantiate getting folder_id for package_id: $package_id"
    # set folder_id [db_exec_plsql get_folder_id { }]
    # ns_log Debug "pm::install::package_uninstantiate delete folder_id: $folder_id"
    # db_exec_plsql delete_root_folder { }
}

ad_proc -public -callback pm::project_new {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
}

ad_proc -public -callback pm::project_edit {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
} {
}

ad_proc -public -callback pm::project_delete {
    {-package_id:required}
    {-project_id:required}
} {
}

ad_proc -public -callback pm::project_close {
    {-package_id:required}
    {-project_id:required}
} {
}

ad_proc -public -callback pm::task_new {
    {-package_id:required}
    {-task_id:required}
} {
}

ad_proc -public -callback pm::task_edit {
    {-package_id:required}
    {-task_id:required}
} {
}

ad_proc -public -callback pm::task_delete {
    {-package_id:required}
    {-task_id:required}
} {
}

ad_proc -public -callback pm::task_close {
    {-package_id:required}
    {-task_id:required}
} {
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
	where one_line = :role
    }

    # get linked projects to folder
    foreach project_item_id [application_data_link::get_linked -from_object_id $linked_id -to_object_type "pm_project"] {
	db_1row pm_package_id {
	    select package_id as pm_package_id
	    from acs_objects
	    where object_id = :project_item_id
	}
	
	set task_id [pm::task::new \
			 -project_id $project_item_id \
			 -title $title \
			 -description $description \
			 -mime_type $mime_type \
			 -creation_user $user_id \
			 -creation_ip $ip_addr \
			 -package_id $pm_package_id \
			 -no_callback]

	set task_item_id [pm::task::get_item_id -task_id $task_id]

	pm::task::assign \
	    -task_item_id $task_item_id \
	    -party_id     $user_id \
	    -role_id      $role_id

	application_data_link::new -this_object_id $object_id -target_object_id $task_item_id
    }
}

ad_proc -public -callback forum::message_new -impl project_manager {
    {-package_id:required}
    {-message_id:required}
} {
    create a new task for each new forum message
} {
    # make sure this is not a reply message
    forum::message::get -message_id $message_id -array message
    if {$message_id == $message(root_message_id)} {
	pm::link_new_tasks -object_id $message_id -linked_id $message(forum_id) -role "Watcher" -title $message(subject)
    }
}

ad_proc -public -callback fs::file_new -impl project_manager {
    {-package_id:required}
    {-file_id:required}
} {
    create a new task for each new file upload
} {
    db_1row file_info {
	select i.parent_id as folder_id, r.title, r.description, r.mime_type
	from cr_items i, cr_revisions r
	where i.item_id = :file_id
	and r.revision_id = i.latest_revision
    }

    pm::link_new_tasks -object_id $file_id -linked_id $folder_id -role "Watcher" -title $title -description $description -mime_type $mime_type
}

ad_proc -public -callback fs::file_edit -impl project_manager {
    {-package_id:required}
    {-file_id:required}
} {
    create a new task for each new file revision uploaded
} {
    db_1row file_info {
	select i.parent_id as folder_id, r.title, r.description, r.mime_type
	from cr_items i, cr_revisions r
	where i.item_id = :file_id
	and r.revision_id = i.latest_revision
    }

    pm::link_new_tasks -object_id $file_id -linked_id $folder_id -role "Watcher" -title $title -description $description -mime_type $mime_type
}

ad_proc -public -callback contact::contact_form -impl project_manager {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
} {
    If organisation, ask to create new project
} {
    if { [llength [application_link::get_linked -from_package_id $package_id -to_package_key "project-manager"]] > 0 } {
	if { $object_type != "person" } {
	    ad_form -extend -name $form -form {
		{create_project_p:text(radio) \
		     {label "[_ project-manager.create_project]"} \
		     {options {{[_ acs-kernel.common_Yes] "t"} {[_ acs-kernel.common_no] "f"}}} \
		     {values "f"}
		}
	    }
	}
    }
}

ad_proc -public -callback contact::contact_new_form -impl project_manager {
    {-package_id:required}
    {-contact_id:required}
    {-form:required}
    {-object_type:required}
} {
    create a new project for new organization
} {
    if { $object_type != "person" } {
	upvar create_project_p create_project_p

	if {[exists_and_not_null create_project_p] && $create_project_p == "t"} {
	    db_1row organisation_data {
		select o.name, ao.creation_user, ao.creation_ip
		from organizations o, acs_objects ao
		where o.organization_id = :contact_id
		and ao.object_id = o.organization_id
	    }

	    foreach pm_package_id [application_link::get_linked -from_package_id $package_id -to_package_key "project-manager"] {
		set project_id [pm::project::new \
				    -project_name $name \
				    -status_id 1 \
				    -organization_id $contact_id \
				    -creation_user $creation_user \
				    -creation_ip $creation_ip \
				    -package_id $pm_package_id]

		set project_item_id [pm::project::get_project_item_id -project_id $project_id]

		application_data_link::new -this_object_id $contact_id -target_object_id $project_item_id
	    }
	}
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
		    content::type::attribute::new -content_type {pm_project} -attribute_name {project_code} -datatype {string} -pretty_name {Project code} -pretty_plural {Project codes} -column_spec {varchar(255)}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {goal} -datatype {string} -pretty_name {Project goal} -pretty_plural {Project goals} -column_spec {varchar(4000)}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_start_date} -datatype {date} -pretty_name {Planned start date} -pretty_plural {Planned start dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {planned_end_date} -datatype {date} -pretty_name {Planned end date} -pretty_plural {Planned end dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_start_date} -datatype {date} -pretty_name {Actual start date} -pretty_plural {Actual start dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_end_date} -datatype {date} -pretty_name {Actual end date} -pretty_plural {Actual end dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {status_id} -datatype {integer} -pretty_name {Status} -pretty_plural {Status} -column_spec {integer}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {ongoing_p} -datatype {string} -pretty_name {Project ongoing} -pretty_plural {Projects ongoing} -column_spec {char(1)}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_finished_date} -datatype {date} -pretty_name {Estimated finish date} -pretty_plural {Estimated finish dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {earliest_finish_date} -datatype {date} -pretty_name {Earliest finish date} -pretty_plural {Earliest finish dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {latest_finish_date} -datatype {date} -pretty_name {Latest finish date} -pretty_plural {Latest finish dates} -column_spec {timestamptz}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {actual_hours_completed} -datatype {number} -pretty_name {Actual hours completed} -pretty_plural {Actual hours completed} -column_spec {numeric}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {estimated_hours_total} -datatype {number} -pretty_name {Estimated hours total} -pretty_plural {Estimated hours total} -column_spec {numeric}
		    content::type::attribute::new -content_type {pm_project} -attribute_name {logger_project} -datatype {integer} -pretty_name {Linked logger project} -pretty_plural {Linked logger projects} -column_spec {integer}

		    content::type::attribute::new -content_type {pm_task} -attribute_name {priority} -datatype {integer} -pretty_name {Priority} -pretty_plural {Priorities} -column_spec {integer}
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
		content::type::attribute::new -content_type {pm_project} -attribute_name {dform} -datatype {string} -pretty_name {Dynamic Form} -pretty_plural {Dynamic Forms} -column_spec {varchar(100)}
		content::type::attribute::new -content_type {pm_task} -attribute_name {dform} -datatype {string} -pretty_name {Dynamic Form} -pretty_plural {Dynamic Forms} -column_spec {varchar(100)}
	    }
	}
}
