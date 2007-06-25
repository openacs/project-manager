# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]
set include_url [parameter::get -parameter "ProjectAdd"]

# permissions. Check that user has write permission on the package.
permission::require_permission -party_id $user_id -object_id $package_id -privilege write

# terminology
set project_term    [_ project-manager.Project]
set project_term_lower  [_ project-manager.project]
set use_goal_p  [parameter::get -parameter "UseGoalP" -default "1"]
set use_project_code_p  [parameter::get -parameter "UseUserProjectCodesP" -default "1"]
set ongoing_by_default_p [parameter::get -parameter "OngoingByDefaultP" -default "f"]

# daily?
set daily_p [parameter::get -parameter "UseDayInsteadOfHour" -default "f"]

if {[exists_and_not_null project_item_id] && ![exists_and_not_null project_id]} {
    set project_id [pm::project::get_project_id -project_item_id $project_item_id]
}

# pm_project_title_seq does not exist in the database -alex
# We want to use project numbers if no project_name is given.
# If the user wants, he can still provide a project_name
#if {[empty_string_p $project_name]} {
#    set project_name [db_nextval pm_project_title_seq]
#}

if {[exists_and_not_null project_id]} {
    set title "[_ project-manager.lt_Edit_a_project_term_l]"
    set edit_p 1
    set context_bar [ad_context_bar "[_ project-manager.Edit_project_term]"]
    set project_options [pm::project::get_list_of_open -object_package_id $package_id]
    set project_options [concat [list [list "" ""]] $project_options]
    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege write

} else {
    set edit_p 0
    set title "[_ project-manager.lt_Add_a_project_term_lo]"
    set context_bar [ad_context_bar "[_ project-manager.New_project_term]"]

    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege create
}


if {[ad_form_new_p -key project_item_id]} {
    set logger_project ""
    set logger_values ""
} else {
    
    set logger_project [lindex [application_data_link::get_linked -from_object_id $project_item_id -to_object_type logger_project] 0]
    set logger_values [logger::project::get_variables -project_id $logger_project]

}

ad_form -name add_edit \
    -form {
        project_id:key
        
        {project_item_id:text(hidden)
            {value $project_item_id}
        }

        {dform:text(hidden)}
        {extra_data:text(hidden),optional}

        {project_name:text
            {label "[_ project-manager.lt_set_project_term_name]"}
            {value $project_name}
            {html {size 50}}
        }
        {ongoing_p:text(hidden)
            {value "f"}
        }
    }


if {$use_project_code_p} {
    ad_form -extend -name add_edit \
        -form {
            {project_code:text,optional
                {label "[_ project-manager.lt_set_project_term_code]"}
                {value $project_code}
            }
        } 
}

ad_form -extend -name add_edit \
    -form {
        {description:richtext(richtext),optional
            {label "[_ project-manager.Description]"}
            {value $description}
            {html {cols 80 wrap soft}}
	}
    }


if {[string is true $edit_p]} {
    ad_form -extend -name add_edit \
	-form {
	    {parent_id:text(select),optional
		{label "[_ project-manager.Parent_project]"}
		{value $parent_id}
		{options $project_options}
	    }
	}
} else {
    ad_form -extend -name add_edit \
	-form {
	    {parent_id:text(hidden)
		{value $parent_id}
	    }
	}
}
	


if {[exists_and_not_null customer_id]} {
    set customer_name [organizations::name -organization_id $customer_id]
    ad_form -extend -name add_edit \
	-form {
	    {customer_id:text(hidden)
		{value $customer_id}
	    } 
	    {customer_name:text(inform)
		{label "[_ project-manager.Customer]"}
		{values "$customer_name"}
	    }
	}
} else {
    ad_form -extend -name add_edit \
	-form {
	    {customer_id:text(select),optional
		{label "[_ project-manager.Customer]"}
		{options {{"[_ project-manager.---_TBD_---]" ""} [lang::util::localize_list_of_lists -list [db_list_of_lists get_customer "select o.name, o.organization_id from organizations o order by o.name"]]}}
	    }
	}
}

if {[exists_and_not_null customer_id]} {
    set dynamic_params(customer_id) $customer_id
} elseif {[exists_and_not_null project_item_id]} {
    set dynamic_params(customer_id) [db_string get_customer_id {}]
} else {
    set dynamic_params(customer_id) ""
}

dtype::form::add_elements -dform $dform -prefix pm -object_type pm_project -object_id [value_if_exists project_id] -form add_edit -exclude_static -cr_widget none -variables [array get dynamic_params]

set status_options [lang::util::localize [pm::status::project_status_select]]

ad_form -extend -name add_edit \
    -form {
        {status_id:text(select)
            {label "[_ project-manager.Status_1]"}
	    {options $status_options}
        }

	{planned_start_date:text(hidden)}

        {planned_end_date:text(text)
            {label "[_ project-manager.Deadline_1]"}
	    {html {id sel2}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel2', 'y-m-d');\"> \[<b>y-m-d</b>\]
	    }}
        }
    }

#------------------------
# Check if the project will be handled on daily basis or will request hours and minutes
#------------------------

if { $daily_p == "t"} {
    ad_form -extend -name add_edit -form {
	{planned_end_time:text(hidden)
	    {value ""}
        }
    }
} else {
    ad_form -extend -name add_edit -form {
	{planned_end_time:date
            {label "[_ project-manager.Deadline_Time]"}
	    {value {[template::util::date::now]}}
	    {format {[lc_get formbuilder_time_format]}} 
        }
    }
}


if {[exists_and_not_null project_id]} {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
        ad_form -extend -name add_edit -form {
            {category_ids:integer(category),multiple {label "[_ project-manager.Categories]"}
                {html {size 7}} {value {$project_id $package_id}}
            }
        }
    }
} else {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
        ad_form -extend -name add_edit -form {
            {category_ids:integer(category),multiple,optional {label "[_ project-manager.Categories]"}
                {html {size 7}} {value {}}
            }
        }
    }
}

ad_form -extend -name add_edit \
    -new_request {
        if {[string equal $ongoing_by_default_p t]} {
            set ongoing_p t
        }
	
	set planned_end_date [template::util::date::get_property linear_date_no_time [template::util::date::today]]
	set planned_end_date [join $planned_end_date "-"]
	set planned_start_date [template::util::date::now]
	set description [template::util::richtext::create "" {}]
    } -edit_request {

	db_1row project_query {}
	set description [template::util::richtext::create $description $mime_type]

	set planned_end_time [template::util::date::from_ansi $planned_end_date [lc_get frombuilder_time_format]]
	set planned_end_date [lindex $planned_end_date 0]

    } -on_submit {
        
        set user_id [ad_conn user_id]
        set peeraddr [ad_conn peeraddr]
	set folder_id [pm::util::get_root_folder -package_id $package_id]
	set callback_data(organization_id) $customer_id
	if {[exists_and_not_null variables]} {
	    set callback_data(variables) $variables
	}
	foreach {key value} $extra_data {
	    set callback_data($key) $value
	}

	set customer_name [organizations::name -organization_id $customer_id]
	if {![empty_string_p $customer_name]} {
	    append customer_name " - "
	}
	if {$parent_id eq ""} {
	    set parent_id $folder_id
	}

	if {$parent_id eq ""} {
	    set parent_id $package_id
	}

	set planned_end_date_list [split $planned_end_date "-"]
	append planned_end_date_list " [lrange $planned_end_time 3 5]"

	set planned_start_date_sql "to_timestamp('$planned_start_date','YYYY MM DD HH24 MI SS')"
	set planned_end_date_sql "to_timestamp('$planned_end_date_list','YYYY MM DD HH24 MI SS')"

        # insert the comment into the database
        set description_body [template::util::richtext::get_property contents $description]
        set description_format [template::util::richtext::get_property format $description]

    } -new_data {

	db_transaction {
	    # if the project is ongoing, there is no end date
	    # we set it to null to signify that. Technically, this
	    # is bad data model design -- we should just get rid of
	    # ongoing_p
	    if {[string equal $ongoing_p t]} {
		set actual_end_date ""
		set planned_end_date ""
	    }

	    # create a project manager project
	    set project_id [dtype::form::process \
				-dform $dform \
				-prefix pm \
				-object_type pm_project \
				-object_id $project_id \
				-form add_edit \
				-cr_widget none \
				-defaults [list title $project_name description $description_body mime_type $description_format context_id $parent_id parent_id $parent_id object_type pm_project] \
				-default_fields {project_code goal {planned_start_date $planned_start_date_sql} {planned_end_date $planned_end_date_sql} actual_start_date actual_end_date ongoing_p status_id customer_id dform} \
				-exclude_static]

	    set project_item_id [pm::project::get_project_item_id -project_id $project_id]
	    set project_role [pm::role::default]

	    pm::project::assign \
		-project_item_id $project_item_id \
		-role_id $project_role \
		-party_id $user_id \
		-send_email_p "t"

	    if {[exists_and_not_null category_ids]} {
		category::map_object -object_id $project_id $category_ids
	    }

	    # We need to check if the group exists before trying to
	    # give the group privileges
	    set employees_group_id [group::get_id -group_name "Employees"]
	    if { ![empty_string_p $employees_group_id] } {
		permission::grant -object_id $project_item_id -party_id $employees_group_id -privilege admin
	    }

	    callback pm::project_new -package_id $package_id -project_id $project_item_id -data [array get callback_data]
	}

    } -edit_data {

	db_transaction {
	    # we need to pass the old_project_id to add-edit-2.tcl because
	    # the new revision will not have any of the custom values in
	    # it until it is edited. So we need to pull in these values
	    set old_project_id $project_id

	    set project_id [dtype::form::process \
				-dform $dform \
				-prefix pm \
				-object_type pm_project \
				-object_id $project_id \
				-form add_edit \
				-cr_widget none \
				-defaults [list title $project_name description $description_body mime_type $description_format context_id $parent_id parent_id $parent_id object_type pm_project] \
				-default_fields {project_code goal {planned_start_date $planned_start_date_sql} {planned_end_date $planned_end_date_sql} actual_start_date actual_end_date ongoing_p status_id customer_id dform} \
				-exclude_static]

	    set project_item_id [pm::project::get_project_item_id -project_id $project_id]

	    db_dml update_parent_id {}
	    if {[exists_and_not_null category_ids]} {
		category::map_object -object_id $project_id $category_ids
	    }
	    callback pm::project_edit -package_id $package_id -project_id $project_item_id -data [array get callback_data]
	}

    } -after_submit {

	pm::project::flush -project_item_id $project_item_id

	ad_returnredirect -message "[_ project-manager.lt_Changes_to_project_sa]" "one?[export_url_vars project_id]"
	# to add back in subproject support, should use
	# compute_parent_status
	if { [parameter::get -parameter  UseDayInsteadOfHour -default f]} {
	    pm::project::compute_status $project_item_id
	} else {
	    pm::project::compute_status_mins $project_item_id
	}
	ad_script_abort
}

ad_return_template "../templates/project-ae"
