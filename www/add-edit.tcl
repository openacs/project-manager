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
set user_id    [auth::require_login]

# terminology
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower  [parameter::get -parameter "projectname" -default "project"]
set use_goal_p  [parameter::get -parameter "UseGoalP" -default "1"]
set use_project_code_p  [parameter::get -parameter "UseUserProjectCodesP" -default "1"]
if { [string length [parameter::get -parameter "PhotoAlbumURL" -default ""]] > 0} {
  set can_use_image_p 1
} else {
  set can_use_image_p 0
}

set use_project_customizations_p [parameter::get -parameter "UseProjectCustomizationsP" -default "0"]

set ongoing_by_default_p [parameter::get -parameter "OngoingByDefaultP" -default "f"]


if {[exists_and_not_null project_item_id] && ![exists_and_not_null project_id]} {
    set project_id [pm::project::get_project_id -project_item_id $project_item_id]
}


if {[exists_and_not_null project_id]} {
    set title "Edit a $project_term_lower"
    set context_bar [ad_context_bar "Edit $project_term"]

    # permissions
    permission::require_permission -party_id $user_id -object_id $package_id -privilege write

} else {
    set title "Add a $project_term_lower"
    set context_bar [ad_context_bar "New $project_term"]

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
            {label "[set project_term] name"}
            {value $project_name}
            {html {size 50}}
        }
        
        {description:text(textarea),optional
            {label "Description"}
            {value $description}
            {html { rows 5 cols 40 wrap soft}}}
        
        {customer_id:text(select),optional
            {label "Customer"}
            {options {{"--- TBD ---" ""} [db_list_of_lists get_customer {}]}}
        }

        {planned_start_date:text(text)
            {label "Starts"}
	    {html {id sel1}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel1', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
        }
        
        {planned_end_date:text(text) 
            {label "Deadline"}
	    {html {id sel2}}
	    {after_html {<input type='reset' value=' ... ' onclick=\"return showCalendar('sel2', 'y-m-d');\"> \[<b>y-m-d </b>\]
	    }}
        }

        
        {ongoing_p:text(select)
            {label "Project is ongoing?"}
            {options {{"No" f} {"Yes" t}}}
            {value $ongoing_p}
            {help_text "If yes, then this project has no deadline"}
        }
        
        {status_id:text(select)
            {label "Status"}
            {options {[db_list_of_lists get_status_codes { }]}}
        }

        {variables:text(multiselect),multiple
            {label "Logged variables"}
            {options {[logger::ui::variable_options_all]}}
            {values {$logger_values}}
            {html {size 6}}
        }

    } 

if {[exists_and_not_null project_id]} {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
        ad_form -extend -name add_edit -form {
            {category_ids:integer(category),multiple {label "Categories"}
                {html {size 7}} {value {$project_item_id $package_id}}
            }
        }
    }
} else {
    if {![empty_string_p [category_tree::get_mapped_trees $package_id]]} {
        ad_form -extend -name add_edit -form {
            {category_ids:integer(category),multiple,optional {label "Categories"}
                {html {size 7}} {value {}}
            }
        }
    }
}

if {$use_goal_p} {
    ad_form -extend -name add_edit \
        -form {
            {goal:text(textarea),optional
                {label "[set project_term] goal"}
                {value $goal}
                {html { rows 5 cols 40 wrap soft}}}
        } 
}


if {$use_project_code_p} {
    ad_form -extend -name add_edit \
        -form {
            {project_code:text,optional
                {label "[set project_term] code"}
                {value $project_code}
            }
        } 
}

if {$can_use_image_p} {
    ad_form -extend -name add_edit \
        -form {
            {use_image_p:text(checkbox),optional
                {label "Choose an Image?"}
                {options {{"" "t"}}}
            }
        } 
} else {
    ad_form -extend -name add_edit \
        -form {
            {use_image_p:text(hidden)
                {value "f"}
            }
        } 
}

ad_form -extend -name add_edit \
    -select_query_name project_query \
    -on_submit {
        set user_id [ad_conn user_id]
        set peeraddr [ad_conn peeraddr]
        # do this to avoid having to have both a yes and a no checkbox
        if { [string length $use_image_p] == 0 } {
          set use_image_p "n"
        }
    } \
    -new_request {
        
        if {[string equal $ongoing_by_default_p t]} {
            set ongoing_p t
        }

        set planned_end_date [util::date acquire clock [clock scan $planned_end_date]]
        set planned_end_date "[lindex $planned_end_date 0]-[lindex $planned_end_date 1]-[lindex $planned_end_date 2]"
        set planned_start_date [util::date acquire clock [clock scan $planned_start_date]]
       set planned_start_date "[lindex $planned_start_date 0]-[lindex $planned_start_date 1]-[lindex $planned_start_date 2]"
	
	
	 

    } \
    -new_data {

        set project_id [pm::project::new \
                            -project_name $project_name \
                            -project_code $project_code \
                            -parent_id $parent_id \
                            -goal $goal \
                            -description $description \
                            -planned_start_date $planned_start_date \
                            -planned_end_date $planned_end_date \
                            -actual_start_date "" \
                            -actual_end_date "" \
                            -ongoing_p $ongoing_p \
                            -status_id $status_id \
                            -organization_id $customer_id \
                            -creation_date "" \
                            -creation_user $user_id \
                            -creation_ip $peeraddr \
                            -package_id $package_id
                       ]

        set project_item_id [pm::project::get_project_item_id -project_id $project_id]
        set logger_project [pm::project::get_logger_project -project_item_id $project_item_id]

        if {[exists_and_not_null category_ids]} {
            category::map_object -remove_old -object_id $project_item_id $category_ids
        }

        if {[exists_and_not_null variables]} {
            foreach var $variables {
                logger::project::map_variable \
                    -project_id $logger_project \
                    -variable_id $var
            }
        } else {
            # add in the default variable
            logger::project::map_variable \
                -project_id $logger_project \
                -variable_id [logger::variable::get_default_variable_id]
        }

        # if we are choosing an image, go off and do that and then optionally
        # go to the custom code afterwards
        if {$use_image_p} {
            ad_returnredirect "add-edit-album?[export_url_vars project_item_id project_id use_project_customizations_p]"
            ad_script_abort
        }

        if {$use_project_customizations_p} {
            # warn of current bug so users can work around it
            ad_returnredirect -message "You must submit changes on this page or you will lose any data on this page" "add-edit-2?[export_url_vars project_item_id project_id]"
            ad_script_abort
        } else {
            ad_returnredirect -message "Project: '$project_name' added" "one?[export_url_vars project_item_id project_id]"
            ad_script_abort
        }

    } -edit_data {

        # we need to pass the old_project_id to add-edit-2.tcl because
        # the new revision will not have any of the custom values in
        # it until it is edited. So we need to pull in these values
        set old_project_id $project_id

        set project_id [pm::project::edit \
                            -project_item_id $project_item_id \
                            -project_name $project_name \
                            -project_code $project_code \
                            -parent_id $parent_id \
                            -goal $goal \
                            -description $description \
                            -planned_start_date $planned_start_date \
                            -planned_end_date $planned_end_date \
                            -actual_start_date "" \
                            -actual_end_date "" \
                            -logger_project $logger_project \
                            -ongoing_p $ongoing_p \
                            -status_id $status_id \
                            -organization_id $customer_id \
                            -creation_user $user_id \
                            -creation_ip $peeraddr \
                            -package_id $package_id]
        
        set project_item_id [pm::project::get_project_item_id \
                            -project_id $project_id]

        set logger_project [pm::project::get_logger_project -project_item_id $project_item_id]
 

        if {[exists_and_not_null variables]} {
            
            logger::project::remap_variables -project_id $logger_project -new_variable_list $variables
            
        } else {
            logger::project::remap_variables -project_id $logger_project -new_variable_list [logger::variable::get_default_variable_id]
        }

        if {[exists_and_not_null category_ids]} {
            category::map_object -remove_old -object_id $project_item_id $category_ids
        }

        # if we are choosing an image, go off and do that and then optionally
        # go to the custom code afterwards
        if {$use_image_p} {
            ad_returnredirect "add-edit-album?[export_url_vars project_item_id project_id use_project_customizations_p]"
            ad_script_abort
        }

    } -after_submit {

        if {$use_project_customizations_p} {
            # warn of current bug so users can work around it
            ad_returnredirect -message "You must submit changes on this page or you will lose any data on this page" "add-edit-2?[export_url_vars project_id old_project_id]"
            # to add back in subproject support, should use
            # compute_parent_status
            pm::project::compute_status $project_item_id
            ad_script_abort
        } else {
            ad_returnredirect -message "Changes to project saved" "one?[export_url_vars project_id]"
            # to add back in subproject support, should use
            # compute_parent_status
            pm::project::compute_status $project_item_id
            ad_script_abort
        }
}

