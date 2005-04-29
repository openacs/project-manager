# 

ad_page_contract {
    
    Removes assignment from a task
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-18
    @arch-tag: f70e02f1-2475-4ede-ad40-cda9567f99b1
    @cvs-id $Id$
} {
    task_item_id:integer,notnull
    user_id:notnull,multiple
    return_url:notnull
} -properties {
} -validate {
} -errors {
}

set present_user_id [ad_conn user_id]
set peeraddr        [ad_conn peeraddr]

set comment_pre "<ul>"
set comment_list [list]

foreach user $user_id {

    set assigned_p [pm::task::assigned_p \
                        -task_item_id $task_item_id \
                        -party_id $user]

    pm::task::unassign \
        -task_item_id $task_item_id \
        -party_id $user

    if {[string is true $assigned_p]} {
        lappend comment_list "<li>Removed: [person::name -person_id $user]</li>"
    }
}

append comment_post "</ul>"

if {[llength $comment_list] > 0} {

    set comment "$comment_pre [join $comment_list] $comment_post"

    pm::util::general_comment_add \
        -object_id $task_item_id \
        -title [pm::task::name -task_item_id $task_item_id] \
        -comment $comment \
        -mime_type "text/html" \
        -user_id $present_user_id \
        -peeraddr $peeraddr \
        -type "task" \
        -send_email_p f
}

if {[llength $user_id] > 1} {
    set assign "Assignments"
} else {
    set assign "Assignment"
}

ad_returnredirect -message "$assign removed" $return_url

