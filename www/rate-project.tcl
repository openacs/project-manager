# packages/project-manager/www/rate-project

ad_page_contract {
    Creates the chunk to rate one project

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    project_id:integer,optional
    project_item_id:integer,notnull
}

set page_title [_ project-manager.rate_this_project]

if {![exists_and_not_null project_id]} {
    set project_id [pm::project::get_project_id -project_item_id $project_item_id]
}

set user_id [ad_conn user_id]
set context [list [list "one?project_id=$project_id" "One Project"] $page_title]
set context_object_id $project_id

# We create hidden items project_id and project_item_id
ad_form -name rate_project -form {
    {project_id:text(hidden)
	{value $project_id}
    }
    {project_item_id:text(hidden)
	{value $project_item_id}
    }
}

# Only rate Freelancers
set group_name "[parameter::get -parameter "RatedGroup"]"
set filter_group_id [group::get_id -group_name $group_name]

# We are going to create an element for each dimension-user pair to evaluate this project    
# First we get all users assigned to this project
#set users_list [pm::project::assignee_role_list -project_item_id $project_item_id]
set users_list [list]
db_multirow -extend { label } assignees get_assignees { } {
    set assignee_id $party_id
    set role [pm::role::name -role_id $role_id]    

    if {[apm_package_url_from_key "contacts"] == ""} {
	acs_user::get -user_id $assignee_id -array user_info
	set label "$user_info(first_names) $user_info(last_name) ($role):"
    } else {
	set label "[contact::name -party_id $assignee_id] ($role):"
    }

    lappend users_list [list $party_id $label]
}

# Now we get all the dimensions that for the rating
set dimensions_list [list]
db_multirow dimensions get_dimensions_list { } {
    lappend dimensions_list [list "$dimension_key" $title]
}

#set dimensions_list [ratings::get_available_dimensions]

# We keep a list of all created elements
set created_elements [list]

# We generate the form
if {[llength $users_list]>0} {
    foreach dimension $dimensions_list {
	foreach user $users_list {
	    set assignee_id [lindex $user 0]
	    set label [lindex $user 1]
	    ad_form -extend -name rate_project -form [ratings::dimension_ad_form_element -object_id $assignee_id \
							  -dimension_key [lindex $dimension 0] \
							  -section  "[lindex $dimension 1]:" \
							  -label "{$label}" \
							  -show_stars_p "f"]
	    lappend created_elements "${assignee_id}.[lindex $dimension 0]"
	}
    }
    
    ad_form -extend -name rate_project -on_submit {
	foreach element $created_elements {
	    set element_info [split $element "."]
	    set rating [template::element::get_value rate_project $element]
	    if {![empty_string_p $rating]} {
		set object_id [lindex $element_info 0]
		set dimension_key [lindex $element_info 1]
		set rating_id [ratings::rate -dimension_key $dimension_key \
				   -object_id $object_id \
				   -user_id $user_id \
				   -rating $rating \
				   -nomem_p "t"]
		db_dml update_context_id { }
	    }
	    
	}
    } -after_submit {
	ad_returnredirect "one?project_id=$project_id"
    }
} else {
    ad_returnredirect "one?project_id=$project_id"
}