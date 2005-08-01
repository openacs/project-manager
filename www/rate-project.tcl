# packages/project-manager/www/rate-project

ad_page_contract {
    Creates the chunk to rate one project

    @author Miguel Marin (miguelmarin@viaro.net)
    @author Viaro Networks www.viaro.net
} {
    project_id:integer,notnull
    project_item_id:integer,notnull
}

set title [_ project-manager.rate_this_project]
set context [list [list "one?project_id=$project_id" "One Project"] $title]

set user_id [ad_conn user_id]
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

# We are going to create an element for each dimension-user pair to evaluate this project    
# First we get all users assigned to this project
set users_list [pm::project::assignee_role_list -project_item_id $project_item_id]

# Now we get all the dimensions that for the rating
set dimensions_list [ratings::get_available_dimensions]

# We keep a list of all created elements
set created_elements [list]

# We generate the form
foreach user $users_list {
    foreach dimension $dimensions_list {
	set assignee_id [lindex $user 0]
	acs_user::get -user_id $assignee_id -array user_info
	set role [pm::role::name -role_id [lindex $user 1]]
	ad_form -extend -name rate_project -form [ratings::dimension_ad_form_element -object_id $assignee_id \
						      -dimension_key [lindex $dimension 0] \
						      -section "{[_ project-manager.rate] $user_info(first_names) $user_info(last_name) ($role):}" \
						      -label "[lindex $dimension 1]:"]
	lappend created_elements "${assignee_id}.[lindex $dimension 0]"
    }
}

ad_form -extend -name rate_project -on_submit {
    foreach element $created_elements {
	set element_info [split $element "."]
	set rating [template::element::get_value rate_project $element]
	set object_id [lindex $element_info 0]
	set dimension_key [lindex $element_info 1]
	set rating_id [ratings::rate -dimension_key $dimension_key \
			   -object_id $object_id \
			   -user_id $user_id \
			   -rating $rating \
			   -nomem_p "t"]
	
	db_dml update_context_id { }
    }
} -after_submit {
    ad_returnredirect "one?project_id=$project_id"
}

