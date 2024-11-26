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
			     {options {{[_ acs-kernel.common_Yes] "t"} {[_ acs-kernel.common_No] "f"}}} \
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

ad_proc -public -callback acs_mail_lite::incoming_object_email -impl pm_task {
    -array:required
    -object_id:required
} {

    If the object_id is a task, store a comment with the task containing the contents of the e-mail.
    Append a list of files that were associated with the email to the task.
   
} {

    # Check if the object_id is a task
    if {[content::item::get_content_type -item_id $object_id] eq "pm_task"} {
	
	set task_item_id $object_id

	# As this is a connection less callback, set the IP Address to local
	set peeraddr "127.0.0.1"

	# Get the assignees
	foreach assignee [pm::task::assignee_role_list -task_item_id $task_item_id] {
	    # You could limit the assignees to only players and leads by filtering on the role
	    # We are not going to do that though, as a watcher does want to be informed about the task
	    lappend assignee_ids [lindex $assignee 0]
	}
	
	# get a reference to the email array
	upvar $array email
	
	# Get the sender from the e-mail
	set from_addr [lindex $email(from) 0]
	set sender_id [party::get_by_email -email $from_addr]

	# Deal with the files
	set files ""
	set file_ids ""
	
	# Get the folder_id in which to store the files. This is the associated folder for the project
	# If no folder_id is linked, just use the task_item_id as the context_id
	set project_item_id [pm::task::project_item_id -task_item_id $task_item_id]
	set folder_id [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type "content_folder"] 0]

	foreach file $email(files) {
	    set file_title [lindex $file 2]
	    set mime_type [lindex $file 0]
	    set file_path [ns_mktemp]
	    set f [open $file_path w+]
            fconfigure $f -translation binary
            puts -nonewline $f [lindex $file 3]
            close $f

	    # Create the content item
	    if {$folder_id ne ""} {
		set package_id [acs_object::package_id -object_id $folder_id]
		set existing_item_id [fs::get_item_id -name $file_title -folder_id $folder_id]
		if {$existing_item_id ne ""} {
		    set item_id $existing_item_id
		} else {
		    set item_id [db_nextval "acs_object_id_seq"]
		    content::item::new -name $file_title \
			-parent_id $folder_id \
			-item_id $item_id \
			-package_id $package_id \
			-creation_ip 127.0.0.1 \
			-creation_user $sender_id \
			-title $file_title
		}
	       ns_log Notice "$item_id :: $package_id"
	   	set revision_id [content::revision::new \
				     -item_id $item_id \
				     -tmp_filename $file_path\
				     -creation_user $sender_id \
				     -creation_ip 127.0.0.1 \
				     -package_id $package_id \
				     -title $file_title \
				     -description "File send by e-mail from $email(from) to $email(to) on subject $email(subject)" \
				     -mime_type $mime_type \
				     -is_live "t" 
				]
		
		file delete $file_path

	    } else {
		set package_id [acs_object::package_id -object_id $sender_id]	    
		set existing_item_id [content::item::get_id_by_name -name $file_title -parent_id $sender_id]
		if {$existing_item_id ne ""} {
		    set item_id $existing_item_id
		} else {
		    set item_id [db_nextval "acs_object_id_seq"]
		    content::item::new -name $file_title \
			-parent_id $sender_id \
			-item_id $item_id \
			-package_id $package_id \
			-creation_ip 127.0.0.1 \
			-creation_user $sender_id \
			-title $file_title
		}

	   	set revision_id [content::revision::new \
				     -item_id $item_id \
				     -tmp_filename $file_path\
				     -creation_user $sender_id \
				     -creation_ip 127.0.0.1 \
				     -package_id $package_id \
				     -title $file_title \
				     -description "File send by e-mail from $email(from) to $email(to) on subject $email(subject)" \
				     -mime_type $mime_type \
				     -is_live "t" 
				 ]
		
		file delete $file_path
	    }
		
	    # Create a list of file_id and file_title
	    lappend files  [list [content::revision::item_id -revision_id $revision_id] $file_title]
	}

	# Deal with the body
	template::util::list_of_lists_to_array $email(bodies) email_body
	if {[exists_and_not_null email_body(text/html)]} {
	    set comment $email_body(text/html)
	} else {
	    if {[exists_and_not_null email_body(text/plain)]} {
		set comment [ad_text_to_html $email_body(text/plain)]
	    } else {
		# No Body was given in the email
		set comment ""
	    }
	}

	set mime_type "text/html"
	append comment "<p><ul>"
	foreach file $files {
	    append comment "<li><a href=\"[ad_url]/file/[lindex $file 0]/[lindex $file 1]\">[lindex $file 1]</a>"
	}

	set subject [lindex $email(subject) 0]

	set comment_id [pm::util::general_comment_add \
			    -object_id $task_item_id \
			    -user_id $sender_id \
			    -peeraddr $peeraddr \
			    -title "$subject" \
			    -comment "$comment" \
			    -mime_type "$mime_type" \
			    -send_email_p "t" \
			    -to_party_ids "$assignee_ids" \
			    -type "task"]

    }
}

