#

ad_page_contract {
    
    Adds assignees to a project
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    @arch-tag: f52518ee-57d2-474b-a627-9050654c2f3f
    @cvs-id $Id$
} {
    project_item_id:notnull
    user_id:notnull,multiple
    role_id:notnull,multiple
    return_url:notnull
} -properties {
} -validate {
} -errors {
}

# permissions
permission::require_permission -party_id $user_id -object_id $project_item_id -privilege write

set index 0

foreach user $user_id {

    set role [lindex $role_id $index]

    pm::project::assign \
        -project_item_id $project_item_id \
        -role_id $role_id \
        -party_id $user


    incr index
}

if {[llength $user_id] > 1} {
    set assign "[_ project-manager.Assignments]"
} else {
    set assign "[_ project-manager.Assignment]"
}

ad_returnredirect -message "[_ project-manager.assign_saved]" $return_url
