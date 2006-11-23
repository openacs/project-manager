# packages/project-manager/tcl/project-manager-callback-procs.tcl

ad_library {
    
    Callback procs for Project manager
    
    @author Malte Sussdorff (sussdorff@sussdorff.de)
    @creation-date 2005-06-15
    @arch-tag: 200d82ba-f8e7-4f19-9740-39117474766f
    @cvs-id $Id$
}

ad_proc -public -callback pm::project_new {
    {-package_id:required}
    {-project_id:required}
    {-data:required}
    {-user_id ""}
    {-creation_ip ""}
} {
    Callback which is executed once the project has been created

    @param package_id PackageID of the project manager package
    @param project_id Item ID of the project
} -

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

ad_proc -public -callback pm::project_assign {
    {-project_id:required}
    {-role_id:required}
    {-party_id:required}
} {
}

ad_proc -public -callback pm::project_unassign {
    {-project_id:required}
    {-party_id:required}
} {
}

ad_proc -public -callback pm::project_links {
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

ad_proc -public -callback pm::install::after_instantiate {
    {-package_id:required}
} {
}


ad_proc -public -callback dotlrn_project_manager::new_community -impl project_manager {
    {-community_id:required}
    {-package_id:required}
} {
    instantiate and mount the logger package for a new project-manager instance
} {
    set logger_package_id [dotlrn::instantiate_and_mount \
                               -mount_point "logger" \
                               $community_id \
                               "logger" \
			       ]

    # (appl.)link the pm to the logger,
    application_link::new -this_package_id $package_id -target_package_id $logger_package_id
}

ad_proc -public -callback fs::file_revision_new -impl project_manager {
    {-package_id:required}
    {-file_id:required}
} {
    create a new task for each new file revision uploaded
} {
    db_1row file_info {
	select i.parent_id as folder_id, r.title, r.description, r.mime_type
	from cr_items i, cr_revisions r
	where i.item_id = :file_id
	and r.revision_id = i.latest_revision}

    # pm::link_new_tasks -object_id $file_id -linked_id $folder_id -role "Watcher" -title $title -description $description -mime_type $mime_type
}

ad_proc -public -callback contact::contact_form -impl project_manager {
    {-package_id:required}
    {-form:required}
    {-object_type:required}
    {-party_id}
} {
    If organisation, ask to create new project
} {
    if {0} {
	if {![exists_and_not_null party_id]} {
	    if {[llength [application_link::get_linked \
			      -from_package_id $package_id \
			      -to_package_key "project-manager"]] > 0} {
		if {$object_type != "person" } {
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
    }
}

ad_proc -public -callback contact::organization_new -impl project_manager {
    {-package_id:required}
    {-contact_id:required}
    {-name:required}
} {
    create a new project for new organization
} {
    upvar create_project_p create_project_p
    
    if {[exists_and_not_null create_project_p]
	&& $create_project_p == "t"} {

	set creation_user [ad_conn user_id]
	set creation_ip [ad_conn peeraddr]
	
	# Check if we have a .LRN Club linked in. If yes,only create
	# the project in the .LRN Club, otherwise in the default project
	# manager instances
	set dotlrn_club_id [application_data_link::get_linked -from_object_id $contact_id -to_object_type "dotlrn_club"]
	set pm_package_id [dotlrn_community::get_package_id_from_package_key -package_key "project-manager" -community_id $dotlrn_club_id]

	if {[empty_string_p $package_id]} {
	    set pm_package_id [lindex [application_link::get_linked \
					  -from_package_id $package_id \
					  -to_package_key "project-manager"] 0]
	}
	
	set project_id [pm::project::new \
			    -project_name $name \
			    -status_id 1 \
			    -organization_id $contact_id \
			    -creation_user $creation_user \
			    -creation_ip $creation_ip \
			    -package_id $pm_package_id]
	
	set project_item_id [pm::project::get_project_item_id \
				     -project_id $project_id]
	
	application_data_link::new -this_object_id $contact_id -target_object_id $project_item_id
	    
    }
}

ad_proc -public -callback subsite::url -impl pm_project {
    {-package_id:required}
    {-object_id:required}
    {-type ""}
} {
    return the page_url for an object of type pm_project
} {

    set base_url [apm_package_url_from_id $package_id]
    if {$type=="edit"} {
	return [export_vars -base "${base_url}add-edit" -url {{project_id $object_id}}]
    } else {
	return [export_vars -base "${base_url}one" -url {{project_id $object_id}}]
    }
}

ad_proc -public -callback subsite::url -impl pm_task {
    {-package_id:required}
    {-object_id:required}
    {-type ""}
} {
    return the page_url for an object of type pm_task
} {

    set base_url [apm_package_url_from_id $package_id]
    if {$type=="edit"} {
	return [export_vars -base "${base_url}task-add-edit-one" -url {{task_item_id $object_id}}]
    } else {
	return [export_vars -base "${base_url}task-one" -url {{task_id $object_id}}]
    }
}
