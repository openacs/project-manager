# 

ad_page_contract {
    
    Processes the form for assignments and removals
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-06-11
    @arch-tag: acef7904-fdc0-4fd7-9346-b6a1e011f604
    @cvs-id $Id$
} {
    project_item_id:integer,notnull
    return_url:notnull
    assignee:multiple
} -properties {
} -validate {
} -errors {
}

set user_id [ad_maybe_redirect_for_registration]

# remove assignments 
set current_assignees [pm::project::assign_remove_everyone \
                           -project_item_id $project_item_id]

foreach ass $assignee {

    regexp {(.*)-(.*)} $ass match party_id role_id

    if {[lsearch $current_assignees $party_id] > -1} {
        set send_email_p f
    } else {
        set send_email_p t
    }

    pm::project::assign \
        -project_item_id $project_item_id \
        -party_id $party_id \
        -role_id $role_id \
        -send_email_p $send_email_p

}

ad_returnredirect -message "Assignments saved" $return_url
