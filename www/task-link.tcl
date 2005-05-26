#

ad_page_contract {
    
    Links two tasks together
    
    @author Jade Rubick (jader@bread.com)
    @creation-date 2004-10-14
    @arch-tag: 126cf2fd-ffcd-4396-961d-648dc8849fc4
    @cvs-id $Id$
} {
    to_task:integer,notnull
    from_task:integer,notnull
    {return_url "task-one?task_id=$from_task"}
} -properties {
} -validate {
} -errors {
}

set user_id     [ad_maybe_redirect_for_registration]
set package_id  [ad_conn package_id]

# permissions. This is a general 'does the user have permission to even ask for this page to be run?'
permission::require_permission -party_id $user_id -object_id $package_id -privilege write

# permissions. This is a general 'does the user have permission on the to_task?'
permission::require_permission -party_id $user_id -object_id $to_task -privilege write

# permissions. This is a general 'does the user have permission to even ask for this page to be run?'
permission::require_permission -party_id $user_id -object_id $from_task -privilege write

pm::task::link \
    -task_item_id_1 $from_task \
    -task_item_id_2 $to_task

ad_returnredirect -message "[_ project-manager.Tasks_linked]" $return_url
