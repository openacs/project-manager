# 

ad_page_contract {
    
    Adds assignees to a task
    
    @author  (jader-ibr@bread.com)
    @creation-date 2004-11-18
    @arch-tag: b877079e-edc9-49ae-8e6b-4c8cfd6edbf0
    @cvs-id $Id$
} {
    task_item_id:notnull
    user_id:notnull,multiple
    role_id:notnull,multiple
    return_url:notnull
} -properties {
} -validate {
} -errors {
}

set present_user_id [ad_conn user_id]
set peeraddr        [ad_conn peeraddr]

set index 0

set comment "<ul>"

foreach user $user_id {

    set role [lindex $role_id $index]

    pm::task::assign \
        -task_item_id $task_item_id \
        -role_id $role_id \
        -party_id $user

    append comment "<li>Added: [person::name -person_id $user]</li>"

    incr index
}

append comment "</ul>"

pm::util::general_comment_add \
    -object_id $task_item_id \
    -title [pm::task::name -task_item_id $task_item_id] \
    -comment $comment \
    -mime_type "text/html" \
    -user_id $present_user_id \
    -peeraddr $peeraddr \
    -type "task" \
    -send_email_p f


if {[llength $user_id] > 1} {
    set assign "Assignments"
} else {
    set assign "Assignment"
}

ad_returnredirect -message "$assign saved" $return_url
