# 

ad_page_contract {
    
    Send email and update project status
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-14
    @arch-tag: f6cf8b76-a1e0-42a0-9489-000cad7ad7b5
    @cvs-id $Id$
} {
    number:multiple
    {return_url ""}
    {edit_p "f"}
    {using_process_p "f"}
    {process_instance_id:integer ""}
    {comments:html,array ""}
    {comments_mime_type:array ""}
    {send_email_p "t"}
} -properties {
} -validate {
} -errors {
}

# --------------------------------------------------------------------
# Internet Explorer sucks. It really really does. Due to length limits
# on URLs for IE, we have to pass these variables through
# ad_set_client_property.
# --------------------------------------------------------------------

foreach num $number {
    set project_item_id($num) [ad_get_client_property -- \
                                   project-manager \
                                   project_item_id($num)]

    set task_item_id($num) [ad_get_client_property -- \
                                project-manager \
                                task_item_id($num)]

}


# ---------------------------------------------
# set up the return_url if it's not already set
# ---------------------------------------------

if {[empty_string_p $return_url]} {
    set return_url [export_vars -base one \
                        {{project_item_id "$project_item_id([lindex $number 0])"}} ]
}


# --------------------------------------------------------------- 
# Set up
# --------------------------------------------------------------- 
set user_id       [auth::require_login]
set package_id    [ad_conn package_id]
set peeraddr      [ad_conn peeraddr]

if {[string is true $edit_p]} {
    permission::require_permission \
        -party_id $user_id \
        -object_id $package_id \
        -privilege write
} else {
    permission::require_permission \
        -party_id $user_id \
        -object_id $package_id \
        -privilege create
}

if {[string is true $using_process_p]} {

    set return_url "$return_url&[export_vars -url {{instance_id $process_instance_id}}]"
    
}

ad_progress_bar_begin -title "Updating status..." -message_1 "Please wait..." -message_2 "Will continue automatically"

# compute the status for all projects

# BUG: currently, if you have a task in a project, and you change the
# project to another project, it won't update the old project. It should

set computed_projects [list]

foreach num $number {

    if {[lsearch $computed_projects $project_item_id($num)] < 0} {

        pm::project::compute_status $project_item_id($num)
        lappend computed_projects $project_item_id($num)
    }
}

util_user_message -message "Saved tasks. You may need to refresh the screen to see the changes."

ad_progress_bar_end -url $return_url


# send out email alerts

if {[string is true $using_process_p]} {

    if {[string is true $send_email_p]} {
        pm::process::email_alert \
            -process_instance_id $process_instance_id \
            -project_item_id $project_item_id(1)
    }

} elseif {[string is true $edit_p]} {

    # append to comments what has changed in each task
    pm::task::what_changed \
        -task_item_id_array                 task_item_id \
        -number                             $number \
        -comments_array                     comments \
        -comments_mime_type_array           comments_mime_type

    foreach num $number {

        if {[exists_and_not_null comments($num)]} {
            # add comment to task
            pm::util::general_comment_add \
                -object_id $task_item_id($num) \
                -title [pm::task::name -task_item_id $task_item_id($num)] \
                -comment $comments($num) \
                -mime_type $comments_mime_type($num) \
                -user_id $user_id \
                -peeraddr $peeraddr \
                -type "task" \
                -send_email_p f
        
            if {[string is true $send_email_p]} {
                # send email notification
                pm::task::email_alert \
                    -task_item_id $task_item_id($num) \
                    -edit_p $edit_p \
                    -comment $comments($num) \
                    -comment_mime_type $comments_mime_type($num)
            }
        }
    }
} else {
    
    foreach num $number {

        if {[string is true $send_email_p]} {
            pm::task::email_alert \
                -task_item_id $task_item_id($num) \
                -edit_p $edit_p 
        }
    }

}
