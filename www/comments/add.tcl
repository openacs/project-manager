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

set assignee_list [list]
if { $exclude_observers_p } {
    foreach assignee $assignees {
	# Compare the role_id to the one get on observer_role_id
	# to see if it is an observer.
	if { [string equal [lsearch $observer_role_id [lindex $assignee 1]] "-1"]} {
	    # Not an observer. Added to the list
	    set name [contact::name -party_id [lindex $assignee 0]]
	    set email [party::email -party_id [lindex $assignee 0]]
	    lappend assignee_list [list "$name ($email)" $email]
	}
    }
} else {
    # We want every assignee so we just get the assignees name
    foreach assignee $assignees {
	set name [contact::name -party_id [lindex $assignee 0]]
	set email [party::email -party_id [lindex $assignee 0]]
	lappend assignee_list [list "$name ($email)" $email]
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

# We will add a check/uncheck element to call the javascript function,
# this works only when the elements in the list is greather than one
if { [llength $assignee_list] > 1 } {
    ad_form -extend -name comment -form {
	{check_uncheck:text(checkbox),multiple,optional
	    {label "[_ project-manager.check_uncheck]"}
	    {options {{"" 1}}}
	    {value 1}
	    {section "[_ project-manager.Email]" }
	    {html {onclick check_uncheck_boxes(this.checked)}}
	}
        {to:text(checkbox)
            {label "[_ project-manager.Send_email]"}
	    {options $assignee_list}
	    {html {checked 1}}
	}
    } 
} else {
    ad_form -extend -name comment -form {
	{to:text(checkbox)
            {label "[_ project-manager.Send_email]"}
	    {section "[_ project-manager.Email]" }
	    {options $assignee_list}
	    {html {checked 1}}
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
    
    set comment_id [pm::util::general_comment_add \
			-object_id $object_id \
			-title "$title" \
			-comment "$description_body" \
			-mime_type "$description_format" \
			-send_email_p "t" \
			-to "$to" \
			-type $type]
    
    # does not seem to be working for some reason
    util_user_message -message "[_ project-manager.lt_Comment_ad_quotehtml_]"
    
    if { [string equal $attach_p "f"] && ![empty_string_p $return_url] } {
	ad_returnredirect $return_url
    } else {
	ad_returnredirect "/comments/view-comment?[export_vars { comment_id return_url }]"
    }
}

