ad_page_contract {

    @author janine@furfly.net
    @cvs-id $Id$

    @return context_bar Context bar.
    @return title Page title.

} {
    project_id:integer
    {album_id:integer ""}
    {old_project_id:integer ""}

} -properties {

    context_bar:onevalue
    title:onevalue

}



# --------------------------------------------------------------- #
# the unique identifier for this package
set package_id [ad_conn package_id]
set user_id    [ad_maybe_redirect_for_registration]

# terminology
set project_term    [parameter::get -parameter "ProjectName" -default "Project"]
set project_term_lower  [parameter::get -parameter "projectname" -default "project"]
set photo_album_url [parameter::get -parameter "PhotoAlbumURL" -default ""]


set title "Edit a $project_term_lower"
set context_bar [ad_context_bar "Edit $project_term"]

permission::require_permission -party_id $user_id -object_id $package_id -privilege write

# get list of albums
# first get package_id of photo-album instance:
set pa_package_id [photo_album::get_package_id_from_url -url $photo_album_url]
# then get root folder id
set pa_root_folder_id [pa_get_root_folder $pa_package_id]
# now get album titles
set options [photo_album::list_albums_in_root_folder -root_folder_id $pa_root_folder_id]

ad_form -name add_edit \
    -form {
        {project_id:text(hidden)
            {value $project_id}}

        {old_project_id:text(hidden)
            {value $old_project_id}}

        {album:text(radio)
            {label "Album Name"}
            {options $options}
            {values $album_id}}
    } \
    -after_submit {
        # save changes
        db_dml update_album ""
        
        ad_returnredirect -message "Project changes saved" "add-edit-image?[export_url_vars project_id old_project_id pa_package_id]"
        ad_script_abort

    }

