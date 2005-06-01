ad_page_contract {

    Simple add/edit form for projects

    @author jader@bread.com, ncarroll@ee.usyd.edu.au
    @creation-date 2003-05-15
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.

} {
    project_id:integer,optional
    {project_revision_id ""}
    {project_item_id ""}
    {project_name ""}
    {project_code ""}
    {parent_id ""}
    {goal ""}
    {description ""}
    {customer_id ""}
    {planned_start_date ""}
    {planned_end_date ""}
    {deadline_scheduling ""}
    {ongoing_p ""}
    {status_id ""}
    {logger_project ""}

} -properties {

    context_bar:onevalue
    title:onevalue

}

# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# permissions. Check that user has write permission on the package.
permission::require_permission -party_id $user_id -object_id $package_id -privilege write

# terminology
set project_term    [_ project-manager.Project]
set project_term_lower  [_ project-manager.project]
set use_goal_p  [parameter::get -parameter "UseGoalP" -default "1"]
set use_project_code_p  [parameter::get -parameter "UseUserProjectCodesP" -default "1"]
set ongoing_by_default_p [parameter::get -parameter "OngoingByDefaultP" -default "f"]


if {[exists_and_not_null project_item_id] && ![exists_and_not_null project_id]} {
    set project_id [pm::project::get_project_id -project_item_id $project_item_id]
}


if {[exists_and_not_null project_id]} {
    set title "[_ project-manager.lt_Edit_a_project_term_l]"
    set context_bar [ad_context_bar "[_ project-manager.Edit_project_term]"]

    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege write

} else {
    set title "[_ project-manager.lt_Add_a_project_term_lo]"
    set context_bar [ad_context_bar "[_ project-manager.New_project_term]"]

    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege create
}


if {[ad_form_new_p -key project_item_id]} {
    set logger_project ""
    set logger_values ""
} else {

    set logger_project [pm::project::get_logger_project -project_item_id $project_item_id]
    set logger_values [logger::project::get_variables -project_id $logger_project]

}

ad_form -name add_edit \
    -form {
        project_id:key
        
        {parent_id:text(hidden)
            {value $parent_id}
        }

        {project_item_id:text(hidden)
            {value $project_item_id}
        }

        {logger_project:text(hidden)
            {value $logger_project}
        }

        {project_name:text
            {label "[_ project-manager.lt_set_project_term_name]"}
            {value $project_name}
            {html {size 50}}
        }
        
        {description:text(textarea),optional
            {label "[_ project-manager.Description]"}
            {value $description}
            {html { rows 5 cols 40 wrap soft}}}
        
        {customer_id:text(select),optional
            {label "[_ project-manager.Customer]"}
            {options {{"[_ project-manager.---_TBD_---]" ""} [db_list_of_lists get_customer "select o.name, o.organization_id from organizations o order by o.name"]}}
        }

        {planned_start_date:text(text)
            {label "[_ project-manager.Starts]"}
	    {html {id sel1}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
        }
        
        {planned_end_date:text(text) 
            {label "[_ project-manager.Deadline_1]"}
	    {html {id sel2}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel2', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
        }

        
        {ongoing_p:text(select)
            {label "[_ project-manager.Project_is_ongoing]"}
            {options {{"[_ acs-kernel.common_no]" f} {"[_ acs-kernel.common_Yes]" t}}}
            {value $ongoing_p}
            {help_text "[_ project-manager.lt_If_yes_then_this_proj]"}
        }
        
        {status_id:text(select)
            {label "[_ project-manager.Status_1]"}
            {options {[db_list_of_lists get_status_codes { }]}}
        }

        {variables:text(multiselect),multiple
            {label "[_ project-manager.Logged_variables]"}
            {options {[logger::ui::variable_options_all]}}
            {values {$logger_values}}
            {html {size 6}}
        }

    } 

if {[exists_and_not_null project_id]} {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
        ad_form -extend -name add_edit -form {
            {category_ids:integer(category),multiple {label "[_ project-manager.Categories]"}
                {html {size 7}} {value {$project_item_id $package_id}}
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

if {$use_goal_p} {
    ad_form -extend -name add_edit \
        -form {
            {goal:text(textarea),optional
                {label "[_ project-manager.lt_set_project_term_goal]"}
                {value $goal}
                {html { rows 5 cols 40 wrap soft}}}
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

dtype::form::add_elements -prefix pm -object_type pm_project -object_id [value_if_exists project_id] -form add_edit -exclude_static -cr_widget none

ad_form -extend -name add_edit \
    -new_request {
        
        if {[string equal $ongoing_by_default_p t]} {
            set ongoing_p t
        }

        set planned_end_date [util::date acquire clock [clock scan $planned_end_date]]
        set planned_end_date "[lindex $planned_end_date 0]-[lindex $planned_end_date 1]-[lindex $planned_end_date 2]"
        set planned_start_date [util::date acquire clock [clock scan $planned_start_date]]
       set planned_start_date "[lindex $planned_start_date 0]-[lindex $planned_start_date 1]-[lindex $planned_start_date 2]"

    } -edit_request {
	db_1row project_query {}
    } -on_submit {
        
        set user_id [ad_conn user_id]
        set peeraddr [ad_conn peeraddr]
	set folder_id [pm::util::get_root_folder -package_id $package_id]
	set customer_name [organizations::name -organization_id $customer_id]
	if {![empty_string_p $customer_name]} {
	    append customer_name " - "
	}
	if {[empty_string_p $parent_id]} {
	    set parent_id $folder_id
	}
	set planned_start_date_sql "to_timestamp('$planned_start_date','YYYY MM DD HH24 MI SS')"
	set planned_end_date_sql "to_timestamp('$planned_end_date','YYYY MM DD HH24 MI SS')"

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

	    # create a logger project
	    set logger_project [logger::project::new \
				    -name "$customer_name$project_name" \
				    -description $description \
				    -project_lead $user_id \
				   ] 

	    # we want the logger project to show up in logger!
	    set logger_URLs [parameter::get -parameter "LoggerURLsToKeepUpToDate" -default ""]
	    foreach url $logger_URLs {
		# get the package_id
		set node_id [site_node::get_node_id -url $url]
		array set node [site_node::get -node_id $node_id]
		set this_package_id $node(package_id)

		logger::package::map_project \
		    -project_id $logger_project \
		    -package_id $this_package_id
	    }

	    # create a project manager project (associating the logger project
	    # with the logger project)

	    set project_id [dtype::form::process \
				-prefix pm \
				-object_type pm_project \
				-object_id $project_id \
				-form add_edit \
				-cr_widget none \
				-defaults [list title $project_name description $description mime_type "text/plain" context_id $parent_id parent_id $parent_id] \
				-default_fields {project_code goal {planned_start_date $planned_start_date_sql} {planned_end_date $planned_end_date_sql} actual_start_date actual_end_date ongoing_p status_id customer_id logger_project} \
				-exclude_static]

	    set project_item_id [pm::project::get_project_item_id -project_id $project_id]
	    # set logger_project [pm::project::get_logger_project -project_item_id $project_item_id]
	    set project_role [pm::role::default]

	    pm::project::assign \
		-project_item_id $project_item_id \
		-role_id $project_role \
		-party_id $user_id \
		-send_email_p "f"

	    if {[exists_and_not_null category_ids]} {
		category::map_object -remove_old -object_id $project_item_id $category_ids
	    }

	    if {[exists_and_not_null variables]} {
		foreach var $variables {
		    logger::project::map_variable -project_id $logger_project -variable_id $var
		}
	    } else {
		# add in the default variable
		logger::project::map_variable -project_id $logger_project -variable_id [logger::variable::get_default_variable_id]
	    }

	    callback pm::project_new -package_id $package_id -project_id $project_item_id
	}

    } -edit_data {

	db_transaction {
	    # we need to pass the old_project_id to add-edit-2.tcl because
	    # the new revision will not have any of the custom values in
	    # it until it is edited. So we need to pull in these values
	    set old_project_id $project_id

	    set logger_project [pm::project::get_logger_project \
				    -project_item_id $project_item_id]

	    set active_p [pm::status::open_p -task_status_id $status_id]

	    logger::project::edit \
		-project_id $logger_project \
		-name "$customer_name$project_name" \
		-description $description \
		-project_lead $user_id \
		-active_p $active_p

	    set project_id [dtype::form::process \
				-prefix pm \
				-object_type pm_project \
				-object_id $project_id \
				-form add_edit \
				-cr_widget none \
				-defaults [list title $project_name description $description mime_type "text/plain" context_id $parent_id parent_id $parent_id] \
				-default_fields {project_code goal {planned_start_date $planned_start_date_sql} {planned_end_date $planned_end_date_sql} actual_start_date actual_end_date ongoing_p status_id customer_id logger_project} \
				-exclude_static]

	    set project_item_id [pm::project::get_project_item_id \
				     -project_id $project_id]

	    # set logger_project [pm::project::get_logger_project -project_item_id $project_item_id]

	    if {[exists_and_not_null variables]} {
		logger::project::remap_variables -project_id $logger_project -new_variable_list $variables
	    } else {
		logger::project::remap_variables -project_id $logger_project -new_variable_list [logger::variable::get_default_variable_id]
	    }

	    if {[exists_and_not_null category_ids]} {
		category::map_object -remove_old -object_id $project_item_id $category_ids
	    }
	    callback pm::project_edit -package_id $package_id -project_id $project_item_id
	}

    } -after_submit {

	ad_returnredirect -message "[_ project-manager.lt_Changes_to_project_sa]" "one?[export_url_vars project_id]"
	# to add back in subproject support, should use
	# compute_parent_status
	pm::project::compute_status $project_item_id
	ad_script_abort
}
