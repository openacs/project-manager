# 

ad_page_contract {
    
    Remove a project assignment for a list of assignees
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    @arch-tag: 479be68c-3849-4017-b950-ff6029839362
    @cvs-id $Id$
} {
    project_item_id:notnull
    user_id:notnull,multiple
    return_url:notnull
} -properties {
} -validate {
} -errors {
}


foreach user $user_id {

    pm::project::unassign \
        -project_item_id $project_item_id \
        -party_id $user
}

if {[llength $user_id] > 1} {
    set assign "Assignments"
} else {
    set assign "Assignment"
}

ad_returnredirect -message "$assign removed" $return_url
