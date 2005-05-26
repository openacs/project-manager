# 

ad_page_contract {
    
    Updates the users the user will see on the calendar
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-09-13
    @arch-tag: 43aadba9-fd89-414a-a6c7-3b25ac2a4779
    @cvs-id $Id$
} {
    {party_id:integer,multiple ""}
} -properties {
} -validate {
} -errors {
}

set user_id [ad_maybe_redirect_for_registration]

if {[empty_string_p party_id]} {
    set party_id [list $user_id]
}

db_transaction {
    db_dml delete_old_user_list {
        DELETE FROM
        pm_users_viewed
        WHERE
        viewing_user = :user_id
    }

    foreach party $party_id {
        db_dml add_user_to_view {
            INSERT INTO 
            pm_users_viewed
            (viewing_user, viewed_user) values
            (:user_id, :party)
        }
    }
}

ad_returnredirect -message "[_ project-manager.lt_Updated_who_you_will_]" task-calendar
