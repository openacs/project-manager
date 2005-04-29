# 

ad_page_contract {
    
    Logs hours against multiple tasks at once.
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-04-13
    @arch-tag: 4d3fcd3a-71d0-4ca5-9213-51e4c4ec4620
    @cvs-id $Id$

    @param item_id A multiple containing the task item_ids
} {
    task_item_id:multiple
    {return_url ""}
} -properties {
} -validate {
} -errors {
}

set package_id [ad_conn package_id]
set user_id [auth::require_login]

set title "Log time for multiple tasks"

if {[exists_and_not_null return_url]} {
    set context [list [list $return_url Tasks] "Log time"]
} else {
    set context [list "Log time"]
}

