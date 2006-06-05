# /packages/project-manager/www/comments/add.tcl

ad_page_contract {
    
    Adds a general comment to a project or task
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-09
    @arch-tag: 7448d185-3d5c-43f2-853e-de7c929c4526
    @cvs-id $Id$
} {
    object_id:integer,notnull
    title:notnull
    return_url:notnull
    {type "task"}
    {attach_p "f"}
    {description:html ""}
} -properties {
} -validate {
} -errors {
}

set title [lang::util::localize $title]
set display_title "[_ project-manager.lt_Add_a_comment_to_titl]"
set context [list "$display_title"]

# We get the parameter to see if we are going to send the email to all the 
# assignees (either a task or a project) or just the one that are not observers.
# So we get the defaultobserver_role_id to compare to the role of the assignees.

set exclude_observers_p [parameter::get -parameter "ExcludeObserversFromEMailP"]
set observer_role_id [db_list get_observer_role_id { }]
if { [string equal $type "project"] } {
    set assignees [pm::project::assignee_role_list -project_item_id $object_id]
} 

if { [string equal $type "task"] } {
    set assignees [pm::task::assignee_role_list -task_item_id $object_id]
}

set show_role_p 1

set assignee_list [list]

if { $exclude_observers_p } {
    foreach assignee $assignees {
	# Compare the role_id to the one get on observer_role_id
	# to see if it is an observer.
	if { [string equal [lsearch $observer_role_id [lindex $assignee 1]] "-1"]} {
	    # Not an observer. Added to the list
	    set party_id [lindex $assignee 0]
	    set name [person::name -person_id $party_id]
	    set email [party::email -party_id $party_id]

	    if {$show_role_p} {
		# display assigned role
		lappend assignee_list [list "$name ($email) ([pm::role::name -role_id [lindex $assignee 1]])" $party_id]
	    } else {
		lappend assignee_list [list "$name ($email)" $party_id]
	    }

	}
    }
} else {
    # We want every assignee so we just get the assignees name
    foreach assignee $assignees {
	set party_id [lindex $assignee 0]
	set name [person::name -person_id $party_id]
	set email [party::email -party_id $party_id]

	if {$show_role_p} {
	    # display assigned role
	    lappend assignee_list [list "$name ($email) ([pm::role::name -role_id [lindex $assignee 1]])" $party_id]
	} else {
	    lappend assignee_list [list "$name ($email)" $party_id]
	}
    }
}

set listed_party_ids {}
foreach assignee $assignee_list {
    lappend listed_party_ids [lindex $assignee 1]
}

    
# Include subprojects
foreach subproject_id [pm::project::get_all_subprojects -project_item_id $object_id] {
    set sub_assignees [pm::project::assignee_role_list -project_item_id $subproject_id]
    foreach assignee $sub_assignees {
	if { [string equal [lsearch $observer_role_id [lindex $assignee 1]] "-1"] || $exclude_observers_p != 1 } {
	    set party_id [lindex $assignee 0]
	    set name [person::name -person_id $party_id]
	    set email [party::email -party_id $party_id]
	    
	    if {[lsearch -exact $listed_party_ids $party_id] == -1} {
		lappend assignee_list [list "$name ($email)" $party_id]
		lappend listed_party_ids $party_id
	    }
	}
    }
}

ad_form -name comment \
    -form {
        acs_object_id_seq:key

        {object_id:text(hidden)
            {value $object_id}
        }

        {return_url:text(hidden)
            {value "$return_url"}
        }

        {type:text(hidden)
            {value "$type"}
        }

        {title:text
            {label "[_ project-manager.Title]"}
            {html {size 50}}
        }
        
        {description:richtext(richtext),optional
            {label "[_ project-manager.Comment_1]"}
            {html { rows 9 cols 40 wrap soft}}}
    }

ad_form -extend -name comment -form {
    {assignee:text(checkbox),multiple,optional
	{label "[_ project-manager.Send_email]"}
	{section "[_ project-manager.Assignees]" }
	{options $assignee_list}
    }
}
	

foreach group [split [parameter::get -parameter "CommentGroups"] ";"] {
    set group_id [group::get_id -group_name "$group"]
    set group_title [group::title -group_name $group]
    if {![string eq $group_id ""]} {
	
	set member_list [group::get_members -group_id $group_id]
	set assignee_list [list [list $group_title $group_id]]

	foreach member_id $member_list {
	    set name [contact::name -party_id $member_id]
	    set email [party::email -party_id $member_id]
	    
	    if {[lsearch -exact $listed_party_ids $member_id] == -1} {
		lappend assignee_list [list "$name ($email)" $member_id]
		lappend listed_party_ids $member_id
	    }
	}

	if {[llength $assignee_list] > 0} {
	    ad_form -extend -name comment -form {
		{${group_id}:text(checkbox),multiple,optional
		    {label "[_ project-manager.Send_email]"}
		    {section "$group_title" }
		    {options $assignee_list}
		}
	    }
	} 
    }
}

ad_form -extend -name comment -form {
    {attach_p:text(select),optional
	{label "[_ project-manager.Attach_a_file]"}
	{options {{"[_ acs-kernel.common_Yes]" "t"} {"[_ acs-kernel.common_no]" "f"}}}
	{value "f"}
    }
} -new_request {
    
    set description [template::util::richtext::create "" {}]
    
} -on_submit {

    # insert the comment into the database
    set description_body [template::util::richtext::get_property contents $description]
    set description_format [template::util::richtext::get_property format $description]

    set to_party_ids $assignee
    foreach group [split [parameter::get -parameter "CommentGroups"] ";"] {
	set group_id [group::get_id -group_name "$group"]
	foreach assignee_id [set $group_id] {
	    lappend to_party_ids "$assignee_id"
	}
    }
    
    set comment_id [pm::util::general_comment_add \
			-object_id $object_id \
			-title "$title" \
			-comment "$description_body" \
			-mime_type "$description_format" \
			-send_email_p "t" \
			-to_party_ids "$to_party_ids" \
			-type $type]
    
    # does not seem to be working for some reason
    util_user_message -message "[_ project-manager.lt_Comment_ad_quotehtml_]"
    
    if { [string equal $attach_p "f"] && ![empty_string_p $return_url] } {
	ad_returnredirect $return_url
    } else {
	ad_returnredirect "/comments/view-comment?[export_vars { comment_id return_url }]"
    }
}

