ad_page_contract {

    Page for customized columns on projects

    This is skipped if the UseProjectCustomizationsP is set to 0, used
    if it is set to 1.

    Use this page to create a second page for editing customized project
    information.

    @author jader@bread.com
    @creation-date 2003-12-05
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.

} {
    project_id:integer,optional
    {old_project_id ""}
    {project_item_id ""}
    {project_name ""}
    {description ""}

} -properties {

    context_bar:onevalue
    title:onevalue

}


# this is necessary for new projects
if {![exists_and_not_null old_project_id]} {
    set old_project_id $project_id
}

# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set subsite_id [ad_conn subsite_id]
set user_id    [auth::require_login]

set user_group_id [application_group::group_id_from_package_id \
                       -package_id $subsite_id]

# terminology
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower  [parameter::get -parameter "projectname" -default "project"]
set use_goal_p  [parameter::get -parameter "UseGoalP" -default "1"]
set use_project_code_p  [parameter::get -parameter "UseUserProjectCodesP" -default "1"]


set title "Edit a $project_term_lower"
set context_bar [ad_context_bar "Edit $project_term"]

permission::require_permission -party_id $user_id -object_id $package_id -privilege write

# set project_item_id [db_string get_item_id { }]
set keyval 1

ad_form -name add_edit \
    -form {
        keyval:key

        {project_id:text(hidden)
            {value $project_id}}       

        {project_item_id:text(hidden)
            {value $project_item_id}}

        {project_name:text(inform)
            {label "[set project_term] name"}
            {value $project_name}
        }

        {description:text(inform)
            {label "Old Description"}
            {value $description}
        }

    } \
    -validate {
    } \
    -select_query_name project_query \
    -on_submit {
        
        set user_id [ad_conn user_id]
        set peeraddr [ad_conn peeraddr]
        
    } \
    -new_data {

        ad_returnredirect -message "Project changes saved" "one?[export_url_vars project_item_id]"
        ad_script_abort
        
    } -edit_data {

        db_dml update_project { *SQL* }

    } -after_submit {
        
        ad_returnredirect -message "Project changes saved" "one?[export_url_vars project_item_id]"
        ad_script_abort

    }
