# packages/project-manager/www/assign-myself
ad_page_contract { 
    Assign all the received tasks to the received role, default to lead.
    @author Miguel Marin (miguelmarin@viaro.net)
    @author Malte Sussdorff (malte.sussdorff@cognovis.de) (fixing the page)
} {
    task_item_id:multiple
    {role_id "1"}
    {return_url ""}
}

set user_id [ad_conn user_id]

set page_title "[_ project-manager.Assign_myself]"
set context [list $page_title]

if { ![exists_and_not_null $return_url] } {
    set return_url [get_referrer]
}

# To display the tasks in the ad_form
set show_tasks [list]
foreach task $task_item_id {
    lappend show_tasks "\#$task"
}

set roles_list [pm::role::select_list_filter]

set show_tasks [join $show_tasks ", "]

ad_form -name "reassign" -form {
    {task_item_id:text(hidden)
        {value $task_item_id}
    }
    {return_url:text(hidden)
        {value $return_url}
    }
    {show_tasks:text(text)
        {label "[_ project-manager.Tasks]:"}
        {value  $show_tasks}
        {mode display}
    }
    {role_id:text(select)
        {label "[_ project-manager.Role]:"}
	{options $roles_list}
    }
} -on_submit {

    # We are going to reassign all the checked tasks to the user_id
    foreach task $task_item_id {
	# We remove the current assignment
	pm::task::unassign -task_item_id $task -party_id $user_id

	# Assign the new role
	pm::task::assign -task_item_id $task -party_id $user_id -role_id $role_id
    }

} -after_submit {
    ad_returnredirect $return_url
}
