ad_page_contract {

    @return context_bar Context bar.
    @return title Page title.

} {
    project_id:integer
    {old_project_id:integer ""}
    pa_package_id:integer

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


set title "Edit a $project_term_lower"
set context_bar [ad_context_bar "Edit $project_term"]

permission::require_permission -party_id $user_id -object_id $package_id -privilege write


# get list of photos in this album 
set options [list]
set photo_album_url [parameter::get -parameter "PhotoAlbumURL" -default ""]
set album_id [db_string get_album_id ""]
set photo_ids [pa_all_photos_in_album $album_id]
foreach photo_id $photo_ids {
  photo_album::photo::get -photo_id $photo_id -array photo_info
  lappend options [list "<img src=\"$photo_album_url/images/$photo_info(thumb_image_id)\" width=\"$photo_info(thumb_width)\" height=\"$photo_info(thumb_height)\" /><br />$photo_info(caption)" $photo_id]
}

ad_form -name add_edit \
    -form {
        {project_id:text(hidden)
            {value $project_id}}

        {old_project_id:text(hidden)
            {value $old_project_id}}

        {pa_package_id:text(hidden)
            {value $pa_package_id}}

        {image:text(radio)
            {label "Image"}
            {options $options}
            {value $photo_id}}
    } \
    -after_submit {
        # save changes
        db_dml do_update "update pm_projects set album_id = :album_id, image_id = :image where project_id = :project_id"

        ad_returnredirect -message "Project changes saved" "one?[export_url_vars project_id]"
        ad_script_abort

    }

