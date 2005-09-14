# packages/project-manager/lib/people.tcl
#
# List of assignees
#
# @author Malte Sussdorff (sussdorff@sussdorff.de)
# @creation-date 2005-05-01
# @arch-tag: c3229143-2307-482b-9f72-e12bd256ac08
# @cvs-id $Id$

foreach required_param {project_id project_item_id} {
    if {![info exists $required_param]} {
	return -code error "[_ project-manager.lt_required_param_is_a_r]"
    }
}
foreach optional_param {} {
    if {![info exists $optional_param]} {
	set $optional_param {}
    }
}

set user_id     [auth::require_login]
set default_layout_url [parameter::get -parameter DefaultPortletLayoutP]

# Get the URL for contacts
set contacts_url [site_node::get_package_url -package_key contacts]

# Check if contacts is installed
set contacts_installed_p [apm_package_installed_p contacts]

# Send Email URL
set send_email_url "send-mail?project_id=$project_id"

# There is no point showing an empty listbox, which happens if the user assigns all roles to himself. Doing it this way avoids another trip to the database.
set select_list_html [pm::role::project_select_list -select_name "role_id" -project_item_id $project_item_id -party_id $user_id]
if {[string compare $select_list_html "<select name=\"role_id\"></select>"]} {

    set assignee_add_self_widget "[_ project-manager.Add_myself_as] <form method=\"post\" action=\"project-assign-add\">[export_vars -form {project_item_id user_id return_url}]$select_list_html<input type=\"Submit\" value=\"[_ project-manager.OK]\" /></form>"
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

set assign_group_p [parameter::get -parameter "AssignGroupP" -default 0]
if { $assign_group_p } {
    set query_name "project_people_groups_query"
} else {
    set query_name "project_people_query"
}

db_multirow -extend {contact_url complaint_url name} people $query_name {} {
    set name [db_string get_user_name { } -default ""]
    if { $assign_group_p && [empty_string_p $name] } {
	set name [db_string get_group_name { } -default ""]
    }
    # If contacts is installed provide a link to the contacts party_id, otherwise don't
    if {![empty_string_p $contacts_url]} {
        set contact_url "${contacts_url}$party_id"
        set complaint_url [export_vars -base "${contacts_url}complaint-ae" {{project_id $project_id} {supplier_id $party_id}}]
    } else {
        set contact_url ""
    }
 }

set elements [list \
                  name [list \
			    label "[_ project-manager.Who]" \
			    display_template {<if @people.is_lead_p@><i></if>
				<a href="@people.contact_url@">@people.name@</a>
				<if @people.is_lead_p@></i></if>
			    } \
			   ] \
                  role_name [list \
                                 label "[_ project-manager.Role]" \
                             ]
             ]

if { $contacts_installed_p } {
    lappend elements complaint [list \
				    label "[_ contacts.Complaint]" \
				    display_template {<a href="@people.complaint_url@">[_ project-manager.Add_complaint]</a>
				    } \
				   ]
}

template::list::create \
    -name people \
    -multirow people \
    -key item_id \
    -elements $elements \
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

